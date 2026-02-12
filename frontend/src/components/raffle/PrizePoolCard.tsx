import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Sparkles } from "lucide-react"

interface PrizePoolCardProps {
  prizePool: string | null
  isLoading: boolean
}

export function PrizePoolCard({ prizePool, isLoading }: PrizePoolCardProps) {
  return (
    <Card className="border-4 border-amber-400 bg-gradient-to-br from-purple-900/70 to-violet-900/70 backdrop-blur-sm shadow-[0_0_30px_rgba(251,191,36,0.4)] relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-amber-400/5 via-transparent to-purple-600/10"></div>
      <CardHeader className="relative z-10">
        <CardTitle className="text-amber-300 flex items-center gap-2 text-xl font-black">
          <Sparkles className="h-6 w-6 animate-pulse" />
          PRIZE POOL
        </CardTitle>
      </CardHeader>
      <CardContent className="relative z-10">
        <div className="text-5xl font-black bg-gradient-to-r from-amber-200 via-yellow-300 to-amber-200 bg-clip-text text-transparent drop-shadow-[0_0_15px_rgba(251,191,36,0.8)]">
          {isLoading ? "..." : prizePool ? `${prizePool} ETH` : "0 ETH"}
        </div>
        <p className="text-base text-amber-400 font-black tracking-wider animate-pulse mt-2">JACKPOT!</p>
      </CardContent>
    </Card>
  )
}
