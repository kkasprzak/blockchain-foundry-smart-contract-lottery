import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Ticket } from "lucide-react"

interface CurrentRoundCardProps {
  entriesCount: number
  isLoadingEntries: boolean
  players: { address: string; entries: number }[]
}

export function CurrentRoundCard({ entriesCount, isLoadingEntries, players }: CurrentRoundCardProps) {
  return (
    <Card className="border-4 border-cyan-400 bg-gradient-to-br from-purple-900/70 to-violet-900/70 backdrop-blur-sm shadow-[0_0_30px_rgba(34,211,238,0.4)] relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-cyan-400/5 via-transparent to-purple-600/10"></div>
      <CardHeader className="relative z-10">
        <div className="flex items-center justify-between">
          <CardTitle className="flex items-center gap-2 text-cyan-300 text-xl font-black">
            <Ticket className="h-6 w-6" />
            CURRENT ROUND
          </CardTitle>
          <Badge className="bg-cyan-400 text-purple-950 font-black px-3 py-1">
            {isLoadingEntries ? "..." : entriesCount}
          </Badge>
        </div>
      </CardHeader>
      <CardContent className="relative z-10 max-h-96 overflow-y-auto">
        <div className="space-y-2">
          {players.map((player, i) => (
            <div
              key={i}
              className="flex items-center justify-between rounded-lg bg-purple-950/50 border-2 border-cyan-600/30 p-3 hover:border-cyan-400/50 transition-colors"
            >
              <div className="flex items-center gap-2">
                <div className="flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br from-cyan-400 to-blue-500 text-xs font-black text-purple-950">
                  #{i + 1}
                </div>
                <span className="font-mono text-sm font-bold text-cyan-200">{player.address}</span>
              </div>
              <Badge className="bg-amber-400 text-purple-950 font-black">{player.entries}x</Badge>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}
