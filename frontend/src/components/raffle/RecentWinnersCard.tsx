import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Trophy } from "lucide-react"
import type { RecentWinner } from "@/types/raffle"

interface RecentWinnersCardProps {
  winners: RecentWinner[]
  isLoading: boolean
}

export function RecentWinnersCard({ winners, isLoading }: RecentWinnersCardProps) {
  return (
    <Card className="mt-6 border-4 border-amber-400 bg-gradient-to-br from-purple-900/70 to-violet-900/70 backdrop-blur-sm shadow-[0_0_30px_rgba(251,191,36,0.4)] relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-amber-400/5 via-transparent to-purple-600/10"></div>
      <CardHeader className="relative z-10">
        <CardTitle className="flex items-center gap-2 text-amber-300 text-2xl font-black">
          <Trophy className="h-7 w-7" />
          RECENT WINNERS
        </CardTitle>
      </CardHeader>
      <CardContent className="relative z-10 max-h-[400px] overflow-y-auto">
        {isLoading && winners.length === 0 ? (
          <div className="text-center text-amber-300 py-8 font-bold">Loading...</div>
        ) : winners.length === 0 ? (
          <div className="text-center text-purple-300 py-8 font-bold">No completed rounds yet</div>
        ) : (
          <div className="grid gap-3 md:grid-cols-2 lg:grid-cols-3">
            {winners.map((winner, i) => (
              <div
                key={i}
                className="flex items-center justify-between rounded-xl bg-gradient-to-r from-purple-950/80 to-violet-900/80 border-3 border-amber-600/30 p-4 hover:border-amber-400/50 transition-all hover:shadow-[0_0_20px_rgba(251,191,36,0.8)]"
              >
                <span className="font-mono text-sm font-bold text-amber-300">{winner.address}</span>
                <div className="flex items-center gap-2">
                  <span className="text-sm text-amber-300 font-bold">Prize:</span>
                  <span className="text-2xl font-black text-emerald-300">{winner.prize}</span>
                </div>
                <span className="text-sm text-amber-300 font-bold">{winner.time}</span>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  )
}
