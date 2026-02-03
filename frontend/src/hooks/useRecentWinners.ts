import { useState, useEffect, useCallback } from "react"
import { formatEther } from "viem"
import { INDEXER_URL } from "@/config/indexer"
import { truncateAddress, formatRelativeTime } from "@/lib/utils"
import type { RecentWinner } from "@/types/raffle"

interface RoundData {
  roundNumber: string
  winner: string | null
  prizePool: string
  completedAt: string
}

interface GraphQLResponse {
  data?: {
    rounds?: {
      items: RoundData[]
    }
  }
  errors?: { message: string }[]
}

const RECENT_WINNERS_QUERY = `
  query RecentWinners($limit: Int!) {
    rounds(orderBy: "roundNumber", orderDirection: "desc", limit: $limit) {
      items {
        roundNumber
        winner
        prizePool
        completedAt
      }
    }
  }
`

export function useRecentWinners(limit: number = 12) {
  const [winners, setWinners] = useState<RecentWinner[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchWinners = useCallback(async () => {
    try {
      setIsLoading(true)
      setError(null)

      const response = await fetch(`${INDEXER_URL}/graphql`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          query: RECENT_WINNERS_QUERY,
          variables: { limit },
        }),
      })

      if (!response.ok) {
        throw new Error(`HTTP error: ${response.status}`)
      }

      const json: GraphQLResponse = await response.json()

      if (json.errors) {
        throw new Error(json.errors[0]?.message ?? "GraphQL error")
      }

      const rounds = json.data?.rounds?.items ?? []

      const transformedWinners: RecentWinner[] = rounds
        .filter((round) => round.winner !== null)
        .map((round) => ({
          roundNumber: BigInt(round.roundNumber),
          address: truncateAddress(round.winner!),
          prize: `${formatEther(BigInt(round.prizePool))} ETH`,
          time: formatRelativeTime(BigInt(round.completedAt)),
        }))

      setWinners(transformedWinners)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Unknown error"))
      setWinners([])
    } finally {
      setIsLoading(false)
    }
  }, [limit])

  useEffect(() => {
    fetchWinners()
  }, [fetchWinners])

  const refetchWithDelay = useCallback(
    (delayMs: number = 2000) => {
      setTimeout(() => {
        fetchWinners()
      }, delayMs)
    },
    [fetchWinners]
  )

  return {
    winners,
    isLoading,
    error,
    refetch: refetchWithDelay,
  }
}
