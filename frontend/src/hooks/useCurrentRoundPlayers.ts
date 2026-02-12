import { useState, useEffect, useCallback } from "react"
import { INDEXER_URL } from "@/config/indexer"
import { truncateAddress } from "@/lib/utils"
import type { CurrentRoundPlayer } from "@/types/raffle"

interface RoundPlayerData {
  player: string
  entryCount: number
}

interface GraphQLResponse {
  data?: {
    roundPlayers?: {
      items: RoundPlayerData[]
    }
  }
  errors?: { message: string }[]
}

const ROUND_PLAYERS_QUERY = `
  query RoundPlayers($roundNumber: BigInt!) {
    roundPlayers(where: { roundNumber: $roundNumber }, orderBy: "entryCount", orderDirection: "desc") {
      items {
        player
        entryCount
      }
    }
  }
`

interface UseCurrentRoundPlayersOptions {
  roundNumber: bigint | undefined
  enabled?: boolean
}

export function useCurrentRoundPlayers(options: UseCurrentRoundPlayersOptions) {
  const { roundNumber, enabled = true } = options
  const [players, setPlayers] = useState<CurrentRoundPlayer[]>([])
  const [isLoading, setIsLoading] = useState(enabled && roundNumber !== undefined)
  const [error, setError] = useState<Error | null>(null)

  const fetchPlayers = useCallback(async () => {
    if (roundNumber === undefined) return

    try {
      setIsLoading(true)
      setError(null)

      const response = await fetch(`${INDEXER_URL}/graphql`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          query: ROUND_PLAYERS_QUERY,
          variables: { roundNumber: roundNumber.toString() },
        }),
      })

      if (!response.ok) {
        throw new Error(`HTTP error: ${response.status}`)
      }

      const json: GraphQLResponse = await response.json()

      if (json.errors) {
        throw new Error(json.errors[0]?.message ?? "GraphQL error")
      }

      const items = json.data?.roundPlayers?.items ?? []

      const transformed: CurrentRoundPlayer[] = items.map((item) => ({
        address: truncateAddress(item.player),
        entries: item.entryCount,
      }))

      setPlayers(transformed)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Unknown error"))
      setPlayers([])
    } finally {
      setIsLoading(false)
    }
  }, [roundNumber])

  useEffect(() => {
    if (enabled && roundNumber !== undefined) {
      fetchPlayers()
    }
  }, [fetchPlayers, enabled, roundNumber])

  return { players, isLoading, error }
}
