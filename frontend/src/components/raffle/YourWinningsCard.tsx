import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Trophy } from "lucide-react"

interface YourWinningsCardProps {
  unclaimedPrize: string | null
  hasUnclaimedPrize: boolean
  isClaimPending?: boolean
  claimErrorMessage?: string | null
  onClaim?: () => void
  onDismissError?: () => void
}

export function YourWinningsCard({
  unclaimedPrize,
  hasUnclaimedPrize,
  isClaimPending,
  claimErrorMessage,
  onClaim,
  onDismissError,
}: YourWinningsCardProps) {
  const cardClassName = hasUnclaimedPrize
    ? "border-4 border-emerald-400 bg-gradient-to-br from-purple-900/70 to-violet-900/70 backdrop-blur-sm shadow-[0_0_30px_rgba(52,211,153,0.4)] relative overflow-hidden animate-pulse"
    : "border-4 border-purple-400 bg-gradient-to-br from-purple-900/70 to-violet-900/70 backdrop-blur-sm shadow-[0_0_30px_rgba(168,85,247,0.4)] relative overflow-hidden"

  return (
    <Card className={cardClassName}>
      <div className="absolute inset-0 bg-gradient-to-br from-emerald-400/5 via-transparent to-purple-600/10"></div>
      <CardHeader className="relative z-10">
        <CardTitle className="text-emerald-300 text-xl font-black flex items-center gap-2">
          <Trophy className="h-6 w-6" />
          YOUR WINNINGS
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4 relative z-10">
        {hasUnclaimedPrize ? (
          <>
            <div className="text-center space-y-2">
              <div className="text-4xl font-black text-emerald-300 drop-shadow-[0_0_15px_rgba(52,211,153,0.8)]">
                {unclaimedPrize} ETH
              </div>
              <div className="text-sm text-purple-300 font-bold">
                from past rounds
              </div>
            </div>

            <Button
              onClick={onClaim}
              disabled={isClaimPending}
              className="w-full bg-gradient-to-r from-emerald-400 via-green-300 to-emerald-400 hover:from-emerald-300 hover:via-green-200 hover:to-emerald-300 text-purple-950 font-black shadow-[0_0_20px_rgba(52,211,153,0.6)] hover:shadow-[0_0_30px_rgba(52,211,153,0.8)] border-2 border-emerald-200 hover:scale-105 transition-all rounded-xl disabled:opacity-70 disabled:cursor-not-allowed disabled:hover:scale-100"
            >
              {isClaimPending ? "CLAIMING..." : "CLAIM NOW"}
            </Button>

            {claimErrorMessage && (
              <div className="bg-red-900/80 border-2 border-red-500 rounded-lg p-3 backdrop-blur-sm">
                <div className="flex items-center justify-between gap-2">
                  <p className="text-red-200 font-bold text-sm flex-1">{claimErrorMessage}</p>
                  <button
                    onClick={onDismissError}
                    className="text-red-300 hover:text-red-100 font-black text-lg leading-none"
                    aria-label="Dismiss error"
                  >
                    ×
                  </button>
                </div>
              </div>
            )}
          </>
        ) : (
          <div className="text-center space-y-2">
            <div className="text-4xl font-black text-purple-400 drop-shadow-[0_0_15px_rgba(168,85,247,0.6)]">
              0 ETH
            </div>
            <div className="text-sm text-purple-300 font-bold">
              Win rounds to earn prizes
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  )
}
