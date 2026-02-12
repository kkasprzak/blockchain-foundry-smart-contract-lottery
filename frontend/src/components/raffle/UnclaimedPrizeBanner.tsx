import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Trophy, Gift } from "lucide-react"

interface UnclaimedPrizeBannerProps {
  unclaimedPrize: string | null
  isClaimPending: boolean
  claimErrorMessage: string | null
  onClaim: () => void
  onDismissError: () => void
}

export function UnclaimedPrizeBanner({
  unclaimedPrize,
  isClaimPending,
  claimErrorMessage,
  onClaim,
  onDismissError,
}: UnclaimedPrizeBannerProps) {
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
                YOU WON!
              </h3>
              <p className="text-amber-300 font-mono font-bold text-lg">Unclaimed Prize: {unclaimedPrize} ETH</p>
            </div>
          </div>
          <div className="flex flex-col gap-2">
            <Button
              onClick={onClaim}
              disabled={isClaimPending}
              size="lg"
              className="bg-gradient-to-r from-emerald-400 via-green-300 to-emerald-400 hover:from-emerald-300 hover:via-green-200 hover:to-emerald-300 text-purple-950 text-xl font-black shadow-[0_0_30px_rgba(52,211,153,1)] hover:shadow-[0_0_50px_rgba(52,211,153,1)] border-3 border-emerald-200 px-8 py-6 hover:scale-105 transition-all rounded-2xl relative overflow-hidden disabled:opacity-70 disabled:cursor-not-allowed disabled:hover:scale-100"
            >
              <Gift className="mr-2 h-6 w-6" />
              {isClaimPending ? "CLAIMING..." : `CLAIM PRIZE \u2022 ${unclaimedPrize} ETH`}
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
                    x
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
