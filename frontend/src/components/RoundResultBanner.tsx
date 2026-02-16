import { Card, CardContent } from "@/components/ui/card"
import { Trophy } from "lucide-react"
import { truncateAddress } from "@/lib/utils"

const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"

interface RoundResultBannerProps {
  completedRoundNumber: bigint
  winner: `0x${string}`
  prizeFormatted: string
  isCurrentUserWinner: boolean
  onNextRound: () => void
}

export function RoundResultBanner({
  completedRoundNumber,
  winner,
  prizeFormatted,
  isCurrentUserWinner,
  onNextRound,
}: RoundResultBannerProps) {
  const isNoWinner = winner === ZERO_ADDRESS

  const getTitle = () => {
    if (isNoWinner) return `ROUND #${completedRoundNumber} — No participants`
    if (isCurrentUserWinner) return `ROUND #${completedRoundNumber} — YOU WON!`
    return `ROUND #${completedRoundNumber} COMPLETE`
  }

  const getSubtitle = () => {
    if (isNoWinner) return "Round reset"
    if (isCurrentUserWinner) return `Prize: ${prizeFormatted} ETH`
    return (
      <>
        <div className="font-mono font-bold text-lg text-emerald-200">
          Winner: {truncateAddress(winner)}
        </div>
        <div className="font-mono font-bold text-lg text-amber-300">
          Prize: {prizeFormatted} ETH
        </div>
      </>
    )
  }

  return (
    <Card
      className="mb-6 border-4 border-emerald-400 bg-gradient-to-r from-emerald-900/95 via-green-900/95 to-emerald-900/95 backdrop-blur-md shadow-[0_0_50px_rgba(52,211,153,0.6)] relative overflow-hidden animate-slide-down"
      role="status"
      aria-live="polite"
    >
      <div className="absolute inset-0 bg-gradient-to-r from-emerald-400/10 via-transparent to-emerald-400/10 animate-pulse"></div>
      <CardContent className="p-8 relative z-10">
        <div className="flex flex-col items-center gap-6">
          {/* Trophy Icon */}
          <div className="relative">
            <div className="absolute inset-0 rounded-full bg-emerald-400 blur-xl opacity-80 animate-pulse"></div>
            <div className="relative flex h-20 w-20 items-center justify-center rounded-full bg-gradient-to-br from-emerald-300 via-green-400 to-emerald-500 border-4 border-emerald-200 shadow-[0_0_30px_rgba(52,211,153,1)]">
              <Trophy className="h-11 w-11 text-purple-950" />
            </div>
          </div>

          {/* Title */}
          <h3 className="text-2xl font-black text-emerald-300 drop-shadow-[0_0_15px_rgba(52,211,153,0.8)] text-center">
            {getTitle()}
          </h3>

          {/* Subtitle */}
          <div className="flex flex-col items-center gap-1 text-center">
            {getSubtitle()}
          </div>

          {/* Next Round Button */}
          <button
            onClick={onNextRound}
            className="w-full max-w-md bg-gradient-to-r from-emerald-400 via-green-300 to-emerald-400 text-purple-950 font-black text-lg py-4 px-8 rounded-xl hover:scale-[1.02] transition-all shadow-[0_0_20px_rgba(52,211,153,0.5)] hover:shadow-[0_0_30px_rgba(52,211,153,0.7)]"
            aria-label="Continue to next round"
          >
            NEXT ROUND →
          </button>
        </div>
      </CardContent>
    </Card>
  )
}
