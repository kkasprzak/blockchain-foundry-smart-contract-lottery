import { useState, useEffect, useRef, useCallback } from "react";
import { createClient } from "@ponder/client";
import { desc, eq } from "drizzle-orm";
import { MOCK_SSE, INDEXER_URL } from "@/config/indexer";
import { truncateAddress } from "@/lib/utils";
import { useCurrentRoundPlayers } from "@/hooks/useCurrentRoundPlayers";
import { schema } from "@/lib/ponderSchema";
import type { RoundPlayerFromPonder, CurrentRoundPlayer } from "@/types/raffle";

const RECONNECT_DELAY = 2000;
const MAX_RETRY_ATTEMPTS = 5;

export interface UseLiveCurrentRoundPlayersOptions {
  roundNumber: bigint | undefined;
}

export interface UseLiveCurrentRoundPlayersResult {
  players: CurrentRoundPlayer[];
  isLoading: boolean;
}

function isRoundPlayerFromPonder(obj: unknown): obj is RoundPlayerFromPonder {
  if (typeof obj !== "object" || obj === null) return false;
  const rec = obj as Record<string, unknown>;
  return (
    typeof rec.id === "string" &&
    typeof rec.roundNumber === "bigint" &&
    typeof rec.player === "string" &&
    typeof rec.entryCount === "number"
  );
}

function transformRoundPlayer(raw: RoundPlayerFromPonder): CurrentRoundPlayer {
  return {
    address: truncateAddress(raw.player),
    entries: raw.entryCount,
  };
}

export function useLiveCurrentRoundPlayers(
  options: UseLiveCurrentRoundPlayersOptions
): UseLiveCurrentRoundPlayersResult {
  const { roundNumber } = options;

  const graphqlResult = useCurrentRoundPlayers({
    roundNumber,
    enabled: !MOCK_SSE && roundNumber !== undefined,
  });

  const [players, setPlayers] = useState<CurrentRoundPlayer[]>([]);

  const reconnectTimeoutRef = useRef<NodeJS.Timeout | undefined>(undefined);
  const unsubscribeRef = useRef<(() => void) | null>(null);
  const isManualCloseRef = useRef(false);
  const reconnectAttemptRef = useRef(0);
  const startSSEConnectionRef = useRef<(() => Promise<void>) | null>(null);

  useEffect(() => {
    if (graphqlResult.players.length > 0 && players.length === 0) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setPlayers(graphqlResult.players);
    }
  }, [graphqlResult.players, players.length]);

  // Clear players when round changes
  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setPlayers([]);
  }, [roundNumber]);

  const startSSEConnection = useCallback(async () => {
    if (MOCK_SSE) return;
    if (isManualCloseRef.current) return;
    if (roundNumber === undefined) return;

    try {
      const client = createClient(`${INDEXER_URL}/sql`, { schema });

      const { unsubscribe } = await client.live(
        (db) =>
          db
            .select()
            .from(schema.roundPlayer)
            .where(eq(schema.roundPlayer.roundNumber, roundNumber))
            .orderBy(desc(schema.roundPlayer.entryCount)),

        (result) => {
          if (isManualCloseRef.current) return;

          reconnectAttemptRef.current = 0;

          const rows = Array.isArray(result) ? result : [];
          const transformed = rows
            .filter(isRoundPlayerFromPonder)
            .map(transformRoundPlayer);

          setPlayers(transformed);
        },

        (err) => {
          if (isManualCloseRef.current) return;

          const nextAttempt = reconnectAttemptRef.current + 1;
          reconnectAttemptRef.current = nextAttempt;

          console.error("SSE round players connection error:", err);

          if (unsubscribeRef.current) {
            try {
              unsubscribeRef.current();
              unsubscribeRef.current = null;
            } catch {
              // Ignore cleanup errors
            }
          }

          if (nextAttempt > MAX_RETRY_ATTEMPTS) return;

          if (reconnectTimeoutRef.current) {
            clearTimeout(reconnectTimeoutRef.current);
          }

          reconnectTimeoutRef.current = setTimeout(() => {
            startSSEConnectionRef.current?.();
          }, RECONNECT_DELAY);
        }
      );

      unsubscribeRef.current = unsubscribe;
    } catch (err) {
      if (isManualCloseRef.current) return;

      const nextAttempt = reconnectAttemptRef.current + 1;
      reconnectAttemptRef.current = nextAttempt;

      console.error("SSE round players connection failed:", err);

      if (nextAttempt > MAX_RETRY_ATTEMPTS) return;

      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
      }

      if (!isManualCloseRef.current) {
        reconnectTimeoutRef.current = setTimeout(() => {
          startSSEConnectionRef.current?.();
        }, RECONNECT_DELAY);
      }
    }
  }, [roundNumber]);

  useEffect(() => {
    startSSEConnectionRef.current = startSSEConnection;
  }, [startSSEConnection]);

  useEffect(() => {
    if (MOCK_SSE) return;
    if (roundNumber === undefined) return;
    if (graphqlResult.isLoading) return;

    isManualCloseRef.current = false;
    reconnectAttemptRef.current = 0;
    startSSEConnection();

    return () => {
      isManualCloseRef.current = true;
      if (unsubscribeRef.current) {
        try {
          unsubscribeRef.current();
          unsubscribeRef.current = null;
        } catch {
          // Ignore
        }
      }
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
      }
    };
  }, [startSSEConnection, graphqlResult.isLoading, roundNumber]);

  return {
    players,
    isLoading: graphqlResult.isLoading,
  };
}
