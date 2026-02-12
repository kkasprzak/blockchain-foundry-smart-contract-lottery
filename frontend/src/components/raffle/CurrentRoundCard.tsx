import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Ticket, Users } from "lucide-react"

interface CurrentRoundCardProps {
  entriesCount: number
  isLoadingEntries: boolean
  players: { address: string; entries: number }[]
  connectedAddress?: string
}

export function CurrentRoundCard({ entriesCount, isLoadingEntries, players, connectedAddress }: CurrentRoundCardProps) {
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
        {players.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-8 text-center">
            <Users className="h-10 w-10 text-cyan-600/50 mb-3" />
            <p className="text-cyan-400/60 font-bold text-sm">No players yet</p>
            <p className="text-cyan-600/40 text-xs mt-1">Be the first to enter!</p>
          </div>
        ) : (
          <div className="space-y-2">
            {players.map((player, i) => {
              const isConnectedUser = connectedAddress !== undefined && player.address === connectedAddress
              return (
                <div
                  key={player.address}
                  className={`flex items-center justify-between rounded-lg bg-purple-950/50 border-2 p-3 transition-colors ${
                    isConnectedUser
                      ? "border-amber-400/60 hover:border-amber-400/80"
                      : "border-cyan-600/30 hover:border-cyan-400/50"
                  }`}
                >
                  <div className="flex items-center gap-2">
                    <div className={`flex h-8 w-8 items-center justify-center rounded-full text-xs font-black text-purple-950 ${
                      isConnectedUser
                        ? "bg-gradient-to-br from-amber-300 to-yellow-500"
                        : "bg-gradient-to-br from-cyan-400 to-blue-500"
                    }`}>
                      #{i + 1}
                    </div>
                    <span className={`font-mono text-sm font-bold ${
                      isConnectedUser ? "text-amber-200" : "text-cyan-200"
                    }`}>
                      {player.address}
                      {isConnectedUser && <span className="text-amber-400 ml-1">(you)</span>}
                    </span>
                  </div>
                  <Badge className="bg-amber-400 text-purple-950 font-black">{player.entries}x</Badge>
                </div>
              )
            })}
          </div>
        )}
      </CardContent>
    </Card>
  )
}
