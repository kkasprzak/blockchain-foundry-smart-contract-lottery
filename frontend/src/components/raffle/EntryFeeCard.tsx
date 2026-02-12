import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

interface EntryFeeCardProps {
  entranceFee: string | null
  isLoadingFee: boolean
  isConnected: boolean
  isEntryWindowClosed: boolean
  isPending: boolean
  showEntrySuccess: boolean
  errorMessage: string | null
  onEnter: () => void
  onDismissError: () => void
}

export function EntryFeeCard({
  entranceFee,
  isLoadingFee,
  isConnected,
  isEntryWindowClosed,
  isPending,
  showEntrySuccess,
  errorMessage,
  onEnter,
  onDismissError,
}: EntryFeeCardProps) {
  const [isButtonHovered, setIsButtonHovered] = useState(false)

  const buttonText = !isConnected
    ? "CONNECT FIRST"
    : isPending
      ? "PENDING..."
      : showEntrySuccess
        ? "ENTERED!"
        : isEntryWindowClosed
          ? "ENTRIES CLOSED"
          : "ENTER RAFFLE"

  const showFlash = isConnected && !isEntryWindowClosed && !isButtonHovered && !isPending

  return (
    <Card className="border-4 border-emerald-400 bg-gradient-to-br from-purple-900/70 to-violet-900/70 backdrop-blur-sm shadow-[0_0_30px_rgba(52,211,153,0.4)] relative overflow-hidden flex-1">
      <div className="absolute inset-0 bg-gradient-to-br from-emerald-400/5 via-transparent to-purple-600/10"></div>
      <CardHeader className="relative z-10">
        <CardTitle className="text-emerald-300 text-xl font-black">ENTRY FEE</CardTitle>
      </CardHeader>
      <CardContent className="relative z-10 flex flex-col gap-6">
        <div>
          <div className="text-4xl font-black text-emerald-300 drop-shadow-[0_0_15px_rgba(52,211,153,0.8)]">
            {isLoadingFee ? "Loading..." : entranceFee ? `${entranceFee} ETH` : "0.01 ETH"}
          </div>
          <p className="text-sm text-purple-300 font-bold">Per ticket</p>
        </div>
        <div className="space-y-3">
          <Button
            onClick={onEnter}
            disabled={!isConnected || isEntryWindowClosed || isPending}
            size="lg"
            onMouseEnter={() => setIsButtonHovered(true)}
            onMouseLeave={() => setIsButtonHovered(false)}
            className={`w-full text-xl font-black py-10 px-8 border-4 hover:scale-105 transition-all rounded-xl relative overflow-hidden disabled:opacity-70 disabled:cursor-not-allowed disabled:hover:scale-100 ${
              showEntrySuccess
                ? "bg-gradient-to-r from-emerald-400 via-green-300 to-emerald-400 text-purple-950 border-emerald-200 shadow-[0_0_80px_rgba(52,211,153,1)]"
                : `bg-gradient-to-r from-amber-400 via-yellow-300 to-amber-400 hover:from-amber-300 hover:via-yellow-200 hover:to-amber-300 text-purple-950 border-amber-200 shadow-[0_0_80px_rgba(251,191,36,1)] hover:shadow-[0_0_150px_rgba(251,191,36,1)] ${
                    showFlash ? "animate-flash" : ""
                  }`
            }`}
          >
            <div className="relative flex items-center justify-center gap-3">
              <span className="text-2xl">{buttonText}</span>
            </div>
          </Button>
          {errorMessage && (
            <div className="bg-red-900/80 border-2 border-red-500 rounded-lg p-3 backdrop-blur-sm">
              <div className="flex items-center justify-between gap-2">
                <p className="text-red-200 font-bold text-sm flex-1">{errorMessage}</p>
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
      </CardContent>
    </Card>
  )
}
