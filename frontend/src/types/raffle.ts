export interface DrawingResult {
  roundNumber: bigint
  winner: `0x${string}`
  prize: bigint
  prizeFormatted: string
}

export interface RoundFromPonder {
  id: string
  roundNumber: bigint
  winner: `0x${string}` | null
  prizePool: bigint
  completedAt: bigint
}

export interface RecentWinner {
  roundNumber: bigint
  address: string
  prize: string
  time: string
}
