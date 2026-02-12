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

export interface RoundPlayerFromPonder {
  id: string
  roundNumber: bigint
  player: `0x${string}`
  entryCount: number
}

export interface CurrentRoundPlayer {
  address: string
  entries: number
}
