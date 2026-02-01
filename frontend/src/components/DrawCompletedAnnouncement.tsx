import { Card, CardContent } from "@/components/ui/card"
import { Trophy, X } from "lucide-react"
import { truncateAddress } from "@/lib/utils"

const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"

interface DrawCompletedAnnouncementProps {
  winner: `0x${string}`
  prizeFormatted: string
  isCurrentUserWinner: boolean
  onDismiss: () => void
}

export function DrawCompletedAnnouncement({
  winner,
  prizeFormatted,
  isCurrentUserWinner,
  onDismiss,
}: DrawCompletedAnnouncementProps) {
  const isNoWinner = winner === ZERO_ADDRESS

  if (isNoWinner) {
    return (
      <Card className="mb-6 border-4 border-amber-400 bg-gradient-to-r from-amber-900/95 via-yellow-900/95 to-amber-900/95 backdrop-blur-md shadow-[0_0_50px_rgba(251,191,36,0.6)] relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-r from-amber-400/10 via-transparent to-amber-400/10 animate-pulse"></div>
        <CardContent className="p-6 relative z-10">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="relative">
                <div className="absolute inset-0 rounded-full bg-amber-400 blur-xl opacity-80 animate-pulse"></div>
                <div className="relative flex h-16 w-16 items-center justify-center rounded-full bg-gradient-to-br from-amber-300 via-yellow-400 to-amber-500 border-4 border-amber-200 shadow-[0_0_30px_rgba(251,191,36,1)]">
                  <Trophy className="h-9 w-9 text-purple-950" />
                </div>
              </div>
              <div>
                <h3 className="text-2xl font-black text-amber-300 drop-shadow-[0_0_15px_rgba(251,191,36,0.8)]">
                  No winner - round reset
                </h3>
                <p className="text-amber-200 font-bold text-lg">No participants in this round</p>
              </div>
            </div>
            <button
              onClick={onDismiss}
              className="text-amber-300 hover:text-amber-100 p-2 rounded-lg hover:bg-amber-400/20 transition-colors"
              aria-label="Dismiss announcement"
            >
              <X className="h-6 w-6" />
            </button>
          </div>
        </CardContent>
      </Card>
    )
  }

  if (isCurrentUserWinner) {
    return (
      <Card className="mb-6 border-4 border-emerald-400 bg-gradient-to-r from-emerald-900/95 via-green-900/95 to-emerald-900/95 backdrop-blur-md shadow-[0_0_50px_rgba(52,211,153,0.6)] relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-r from-emerald-400/10 via-transparent to-emerald-400/10 animate-pulse"></div>
        <CardContent className="p-6 relative z-10">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="relative">
                <div className="absolute inset-0 rounded-full bg-emerald-400 blur-xl opacity-80 animate-pulse"></div>
                <div className="relative flex h-16 w-16 items-center justify-center rounded-full bg-gradient-to-br from-emerald-300 via-green-400 to-emerald-500 border-4 border-emerald-200 shadow-[0_0_30px_rgba(52,211,153,1)]">
                  <Trophy className="h-9 w-9 text-purple-950" />
                </div>
              </div>
              <div>
                <h3 className="text-2xl font-black text-emerald-300 drop-shadow-[0_0_15px_rgba(52,211,153,0.8)]">
                  You won!
                </h3>
                <p className="text-amber-300 font-mono font-bold text-lg">Prize: {prizeFormatted} ETH</p>
              </div>
            </div>
            <button
              onClick={onDismiss}
              className="text-emerald-300 hover:text-emerald-100 p-2 rounded-lg hover:bg-emerald-400/20 transition-colors"
              aria-label="Dismiss announcement"
            >
              <X className="h-6 w-6" />
            </button>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="mb-6 border-4 border-amber-400 bg-gradient-to-r from-amber-900/95 via-yellow-900/95 to-amber-900/95 backdrop-blur-md shadow-[0_0_50px_rgba(251,191,36,0.6)] relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-r from-amber-400/10 via-transparent to-amber-400/10 animate-pulse"></div>
      <CardContent className="p-6 relative z-10">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="relative">
              <div className="absolute inset-0 rounded-full bg-amber-400 blur-xl opacity-80 animate-pulse"></div>
              <div className="relative flex h-16 w-16 items-center justify-center rounded-full bg-gradient-to-br from-amber-300 via-yellow-400 to-amber-500 border-4 border-amber-200 shadow-[0_0_30px_rgba(251,191,36,1)]">
                <Trophy className="h-9 w-9 text-purple-950" />
              </div>
            </div>
            <div>
              <h3 className="text-2xl font-black text-amber-300 drop-shadow-[0_0_15px_rgba(251,191,36,0.8)]">
                Winner: {truncateAddress(winner)}
              </h3>
              <p className="text-amber-200 font-mono font-bold text-lg">Prize: {prizeFormatted} ETH</p>
            </div>
          </div>
          <button
            onClick={onDismiss}
            className="text-amber-300 hover:text-amber-100 p-2 rounded-lg hover:bg-amber-400/20 transition-colors"
            aria-label="Dismiss announcement"
          >
            <X className="h-6 w-6" />
          </button>
        </div>
      </CardContent>
    </Card>
  )
}
