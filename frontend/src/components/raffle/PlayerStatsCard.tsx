import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Separator } from "@/components/ui/separator"

interface PlayerStatsCardProps {
  playerEntryCount: number
  entriesCount: number
}

export function PlayerStatsCard({ playerEntryCount, entriesCount }: PlayerStatsCardProps) {
  const winChance = entriesCount > 0 ? Math.round((playerEntryCount / entriesCount) * 100) : 0

  return (
    <Card className="border-4 border-purple-400 bg-gradient-to-br from-purple-900/70 to-violet-900/70 backdrop-blur-sm shadow-[0_0_30px_rgba(168,85,247,0.4)] relative overflow-hidden flex-1">
      <div className="absolute inset-0 bg-gradient-to-br from-purple-400/5 via-transparent to-purple-600/10"></div>
      <CardHeader className="relative z-10">
        <CardTitle className="text-purple-300 text-xl font-black">YOUR STATS</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4 relative z-10">
        <div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-purple-300 font-bold">Your Entries</span>
            <span className="text-2xl font-black text-amber-300">{playerEntryCount}</span>
          </div>
        </div>
        <Separator className="bg-purple-600" />
        <div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-purple-300 font-bold">Win Chance</span>
            <span className="text-2xl font-black text-emerald-300">{winChance}%</span>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
