export interface DrawingResult {
  roundNumber: bigint
  winner: `0x${string}`
  prize: bigint
  prizeFormatted: string
}

export interface RecentWinner {
  roundNumber: bigint
  address: string
  prize: string
  time: string
}
