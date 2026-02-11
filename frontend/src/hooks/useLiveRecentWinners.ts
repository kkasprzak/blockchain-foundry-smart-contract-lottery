import { useState, useEffect, useRef, useCallback } from "react";
import { createClient } from "@ponder/client";
import { desc } from "drizzle-orm";
import { formatEther } from "viem";
import { MOCK_SSE, INDEXER_URL } from "@/config/indexer";
import { truncateAddress, formatRelativeTime } from "@/lib/utils";
import { useRecentWinners } from "@/hooks/useRecentWinners";
import { schema } from "@/lib/ponderSchema";
import type { RoundFromPonder, RecentWinner } from "@/types/raffle";

const RECONNECT_DELAY = 2000;
const MAX_RETRY_ATTEMPTS = 5;

const MOCK_WINNERS: RecentWinner[] = [
  {
    roundNumber: BigInt(5),
    address: truncateAddress("0x742d35Cc6634C0532925a3b844Bc9e7595f9f3a"),
    prize: "0.05 ETH",
    time: "5 min ago",
  },
  {
    roundNumber: BigInt(4),
    address: truncateAddress("0x1234567890abcdef1234567890abcdef12345678"),
    prize: "0.03 ETH",
    time: "1 hour ago",
  },
  {
    roundNumber: BigInt(3),
    address: "No winner",
    prize: "0 ETH",
    time: "2 hours ago",
  },
];

export interface UseLiveRecentWinnersOptions {
  limit?: number;
}

export interface UseLiveRecentWinnersResult {
  winners: RecentWinner[];
  isLoading: boolean;
  error: Error | null;
  isConnected: boolean;
  isReconnecting: boolean;
  isServiceUnavailable: boolean;
  isStale: boolean;
  reconnect: () => void;
}

function transformRound(raw: RoundFromPonder): RecentWinner {
  return {
    roundNumber: raw.roundNumber,
    address: raw.winner ? truncateAddress(raw.winner) : "No winner",
    prize: `${formatEther(raw.prizePool)} ETH`,
    time: formatRelativeTime(raw.completedAt),
  };
}

export function useLiveRecentWinners(options?: UseLiveRecentWinnersOptions): UseLiveRecentWinnersResult {
  const { limit = 12 } = options ?? {};

  // Use existing GraphQL hook for initial data
  const graphqlResult = useRecentWinners({ limit, enabled: !MOCK_SSE });

  const [winners, setWinners] = useState<RecentWinner[]>(MOCK_SSE ? MOCK_WINNERS : []);
  const [error, setError] = useState<Error | null>(null);
  const [isConnected, setIsConnected] = useState(MOCK_SSE);
  const [isReconnecting, setIsReconnecting] = useState(false);
  const [isServiceUnavailable, setIsServiceUnavailable] = useState(false);

  const reconnectTimeoutRef = useRef<NodeJS.Timeout | undefined>(undefined);
  const unsubscribeRef = useRef<(() => void) | null>(null);
  const isManualCloseRef = useRef(false);
  const isFirstMessageRef = useRef(true);
  const reconnectAttemptRef = useRef(0);
  const startSSEConnectionRef = useRef<(() => Promise<void>) | null>(null);

  // Sync GraphQL data to local state when it loads (one-time initialization)
  useEffect(() => {
    if (graphqlResult.winners.length > 0 && winners.length === 0) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setWinners(graphqlResult.winners);
    }
  }, [graphqlResult.winners, winners.length]);

  const startSSEConnection = useCallback(async () => {
    if (MOCK_SSE) return;
    if (isManualCloseRef.current) return;

    try {
      // Create fresh client for each connection
      const client = createClient(`${INDEXER_URL}/sql`, { schema });

      // Subscribe to live updates
      const { unsubscribe } = await client.live(
        // Query function
        (db) =>
          db
            .select()
            .from(schema.round)
            .orderBy(desc(schema.round.roundNumber))
            .limit(limit),

        // onData callback - called when data changes
        (result) => {
          if (isManualCloseRef.current) return;

          if (isFirstMessageRef.current) {
            isFirstMessageRef.current = false;
          }

          // Reset connection state on successful message
          setIsConnected(true);
          setIsReconnecting(false);
          setIsServiceUnavailable(false);
          reconnectAttemptRef.current = 0;
          setError(null);

          // Transform and UPDATE data (SSE sends updates)
          const roundsTyped = result as unknown as RoundFromPonder[];
          const transformed = roundsTyped
            .filter((r) => r.winner !== null)
            .map(transformRound);

          setWinners(transformed);
        },

        // onError callback
        (err) => {
          if (isManualCloseRef.current) return;

          const nextAttempt = reconnectAttemptRef.current + 1;
          reconnectAttemptRef.current = nextAttempt;

          console.error("SSE connection error:", err);
          setError(err instanceof Error ? err : new Error(String(err)));
          setIsConnected(false);

          // Clean up current subscription
          if (unsubscribeRef.current) {
            try {
              unsubscribeRef.current();
              unsubscribeRef.current = null;
            } catch {
              // Ignore cleanup errors
            }
          }

          // Check if we exceeded max retry attempts
          if (nextAttempt > MAX_RETRY_ATTEMPTS) {
            setIsServiceUnavailable(true);
            setIsReconnecting(false);
            return;
          }

          // Attempt reconnection
          setIsReconnecting(true);

          if (reconnectTimeoutRef.current) {
            clearTimeout(reconnectTimeoutRef.current);
          }

          reconnectTimeoutRef.current = setTimeout(() => {
            startSSEConnectionRef.current?.();
          }, RECONNECT_DELAY);
        }
      );

      unsubscribeRef.current = unsubscribe;
      setIsConnected(true);

    } catch (err) {
      if (isManualCloseRef.current) return;

      const nextAttempt = reconnectAttemptRef.current + 1;
      reconnectAttemptRef.current = nextAttempt;

      console.error("SSE connection failed:", err);

      // Only update state if still mounted
      if (!isManualCloseRef.current) {
        setError(err instanceof Error ? err : new Error(String(err)));
        setIsConnected(false);

        if (nextAttempt > MAX_RETRY_ATTEMPTS) {
          setIsServiceUnavailable(true);
          setIsReconnecting(false);
          return;
        }

        setIsReconnecting(true);
      }

      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
      }

      if (!isManualCloseRef.current) {
        reconnectTimeoutRef.current = setTimeout(() => {
          startSSEConnectionRef.current?.();
        }, RECONNECT_DELAY);
      }
    }
  }, [limit]);

  // Store the function in ref for recursive calls
  useEffect(() => {
    startSSEConnectionRef.current = startSSEConnection;
  }, [startSSEConnection]);

  // Manual reconnect function for user-triggered reconnection
  const reconnect = useCallback(() => {
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
    }
    if (unsubscribeRef.current) {
      try {
        unsubscribeRef.current();
        unsubscribeRef.current = null;
      } catch {
        // Ignore
      }
    }
    setIsReconnecting(true);
    setIsServiceUnavailable(false);
    reconnectAttemptRef.current = 0;
    isFirstMessageRef.current = true;
    startSSEConnection();
  }, [startSSEConnection]);

  // Start connection on mount (after GraphQL loads initial data)
  useEffect(() => {
    if (MOCK_SSE) return;
    if (graphqlResult.isLoading) return; // Wait for initial data

    isManualCloseRef.current = false;
    isFirstMessageRef.current = true;
    // eslint-disable-next-line react-hooks/set-state-in-effect
    startSSEConnection();

    return () => {
      isManualCloseRef.current = true;
      if (unsubscribeRef.current) {
        try {
          unsubscribeRef.current();
        } catch {
          // Ignore
        }
      }
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
      }
    };
  }, [startSSEConnection, graphqlResult.isLoading]);

  return {
    winners,
    isLoading: graphqlResult.isLoading,
    error: error || graphqlResult.error,
    isConnected,
    isReconnecting,
    isServiceUnavailable,
    isStale: false,
    reconnect,
  };
}
