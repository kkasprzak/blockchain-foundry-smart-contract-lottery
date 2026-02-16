import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Trophy, Check, ExternalLink } from "lucide-react"

interface YourWinningsCardProps {
  unclaimedPrize: string | null
  hasUnclaimedPrize: boolean
  isWaitingForSignature?: boolean
  isWaitingForConfirmation?: boolean
  showClaimSuccess?: boolean
  txHash?: `0x${string}`
  explorerBaseUrl?: string
  claimErrorMessage?: string | null
  onClaim?: () => void
  onDismissError?: () => void
}

export function YourWinningsCard({
  unclaimedPrize,
  hasUnclaimedPrize,
  isWaitingForSignature,
  isWaitingForConfirmation,
  showClaimSuccess,
  txHash,
  explorerBaseUrl,
  claimErrorMessage,
  onClaim,
  onDismissError,
}: YourWinningsCardProps) {
  // Derive button text from current phase
  const getButtonText = () => {
    if (showClaimSuccess) return "CLAIMED!"
    if (isWaitingForSignature) return "CONFIRM WALLET..."
    if (isWaitingForConfirmation) return "CONFIRMING..."
    return "CLAIM NOW"
  }

  const buttonText = getButtonText()
  const isDisabled = isWaitingForSignature || isWaitingForConfirmation || showClaimSuccess
  const showEtherscanLink = isWaitingForConfirmation && txHash && explorerBaseUrl
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

            <div className="space-y-2">
              <Button
                onClick={onClaim}
                disabled={isDisabled}
                className={`w-full text-purple-950 font-black border-2 hover:scale-105 transition-all rounded-xl disabled:cursor-not-allowed disabled:hover:scale-100 ${
                  showClaimSuccess
                    ? "bg-gradient-to-r from-amber-400 via-yellow-300 to-amber-400 shadow-[0_0_30px_rgba(251,191,36,0.8)] border-amber-200 disabled:opacity-100"
                    : isWaitingForSignature
                    ? "bg-gradient-to-r from-emerald-400 via-green-300 to-emerald-400 border-emerald-200 disabled:opacity-85 animate-pulse"
                    : isWaitingForConfirmation
                    ? "bg-gradient-to-r from-emerald-400 via-green-300 to-emerald-400 border-emerald-200 disabled:opacity-85 animate-shimmer bg-[length:200%_100%]"
                    : "bg-gradient-to-r from-emerald-400 via-green-300 to-emerald-400 hover:from-emerald-300 hover:via-green-200 hover:to-emerald-300 shadow-[0_0_20px_rgba(52,211,153,0.6)] hover:shadow-[0_0_30px_rgba(52,211,153,0.8)] border-emerald-200"
                }`}
                aria-live="polite"
              >
                <span className="flex items-center justify-center gap-2">
                  {showClaimSuccess && <Check className="h-5 w-5" />}
                  {isWaitingForConfirmation && (
                    <div className="border-2 border-purple-950/30 border-t-purple-950 rounded-full w-4 h-4 animate-spin" />
                  )}
                  {buttonText}
                </span>
              </Button>

              {showEtherscanLink && (
                <a
                  href={`${explorerBaseUrl}/tx/${txHash}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center justify-center gap-1 text-sm font-bold text-emerald-300/80 hover:text-emerald-200 transition-colors animate-fade-in"
                >
                  View transaction
                  <ExternalLink className="h-3 w-3" />
                </a>
              )}
            </div>

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
