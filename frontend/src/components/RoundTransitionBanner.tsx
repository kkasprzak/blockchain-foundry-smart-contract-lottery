import { Card, CardContent } from "@/components/ui/card"
import { Zap, X, Crown } from "lucide-react"
import { truncateAddress } from "@/lib/utils"

const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"

interface RoundTransitionBannerProps {
  completedRoundNumber: bigint
  winner: `0x${string}`
  prizeFormatted: string
  isCurrentUserWinner: boolean
  onDismiss: () => void
}

interface ColorScheme {
  border: string
  shadow: string
  badgeBg: string
  badgeText: string
  progressBar: string
}

const AMBER_SCHEME: ColorScheme = {
  border: "border-amber-400",
  shadow: "shadow-[0_0_20px_rgba(251,191,36,0.5)]",
  badgeBg: "bg-amber-500",
  badgeText: "text-purple-950",
  progressBar: "bg-amber-400",
}

const EMERALD_SCHEME: ColorScheme = {
  border: "border-emerald-400",
  shadow: "shadow-[0_0_20px_rgba(52,211,153,0.5)]",
  badgeBg: "bg-emerald-500",
  badgeText: "text-purple-950",
  progressBar: "bg-emerald-400",
}

const PURPLE_SCHEME: ColorScheme = {
  border: "border-purple-400",
  shadow: "shadow-[0_0_20px_rgba(168,85,247,0.5)]",
  badgeBg: "bg-purple-500",
  badgeText: "text-white",
  progressBar: "bg-purple-400",
}

export function RoundTransitionBanner({
  completedRoundNumber,
  winner,
  prizeFormatted,
  isCurrentUserWinner,
  onDismiss,
}: RoundTransitionBannerProps) {
  const isNoWinner = winner === ZERO_ADDRESS

  // Select color scheme based on outcome
  const scheme = isNoWinner ? PURPLE_SCHEME : isCurrentUserWinner ? EMERALD_SCHEME : AMBER_SCHEME

  return (
    <Card
      className={`mb-6 border-2 ${scheme.border} bg-gradient-to-r from-purple-950/95 via-violet-950/95 to-purple-950/95 backdrop-blur-md ${scheme.shadow} relative overflow-hidden animate-slide-down`}
      role="status"
      aria-live="polite"
    >
      <CardContent className="px-5 py-3 relative z-10">
        <div className="flex items-center justify-between gap-4">
          {/* Round Badge (left) */}
          <div className={`flex items-center gap-2 px-3 py-1 rounded-full ${scheme.badgeBg}`}>
            <Zap className={`h-3 w-3 ${scheme.badgeText}`} />
            <span className={`font-black text-xs ${scheme.badgeText}`}>
              ROUND #{completedRoundNumber.toString()}
            </span>
          </div>

          {/* Outcome Info (center) */}
          <div className="flex-1 flex items-center justify-center gap-3 text-sm">
            {isNoWinner ? (
              <span className="font-bold text-purple-300">No participants</span>
            ) : isCurrentUserWinner ? (
              <>
                <Crown className="h-4 w-4 text-emerald-300" />
                <span className="font-black text-emerald-300">YOU WON!</span>
                <span className="font-mono font-bold text-emerald-200">{prizeFormatted} ETH</span>
              </>
            ) : (
              <>
                <span className="font-mono font-bold text-amber-200">
                  Winner: {truncateAddress(winner)}
                </span>
                <span className="text-amber-400/50">|</span>
                <span className="font-mono font-bold text-amber-200">{prizeFormatted} ETH</span>
              </>
            )}
          </div>

          {/* New Round Badge (right) */}
          <div className="flex items-center gap-2 px-3 py-1 rounded-full bg-cyan-500/20 border border-cyan-400/30 animate-pulse">
            <span className="h-2 w-2 rounded-full bg-cyan-400"></span>
            <span className="font-black text-xs text-cyan-300">NEW ROUND LIVE</span>
          </div>

          {/* Dismiss Button (far right) */}
          <button
            onClick={onDismiss}
            className="text-white/70 hover:text-white p-2 rounded-lg hover:bg-white/10 transition-colors"
            aria-label="Dismiss round transition banner"
          >
            <X className="h-5 w-5" />
          </button>
        </div>
      </CardContent>

      {/* Progress Bar (bottom edge) */}
      <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-purple-900/50">
        <div className={`h-full ${scheme.progressBar} opacity-60 animate-progress-shrink`}></div>
      </div>
    </Card>
  )
}
