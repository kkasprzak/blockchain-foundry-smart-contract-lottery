import { useState } from "react"
import { ConnectButton } from "@rainbow-me/rainbowkit"
import { useAccount } from "wagmi"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Separator } from "@/components/ui/separator"
import { Trophy, Users, Clock, Sparkles, Coins, Gift } from "lucide-react"
import { WheelPlaceholder } from "@/components/WheelPlaceholder"
import { useEntranceFee } from "@/hooks/useEntranceFee"
import { useRaffleTimeRemaining } from "@/hooks/useRaffleTimeRemaining"

export function RafflePage() {
  const { isConnected } = useAccount()
  const { entranceFee, isLoading: isLoadingFee } = useEntranceFee()
  const { timeLeft } = useRaffleTimeRemaining()
  const [lastRoundWinner] = useState<string | null>(null)
  const [isCurrentUserWinner, setIsCurrentUserWinner] = useState(false)
  const [isButtonHovered, setIsButtonHovered] = useState(false)

  const handleEnterRaffle = () => {
    console.log("Player added to raffle pool")
    // In production, this would call smart contract to enter raffle
  }

  const handleClaimPrize = () => {
    setIsCurrentUserWinner(false)
  }

  const recentWinners = [
    { address: "0x742d...9f3a", prize: "0.5 ETH", time: "2 hours ago" },
    { address: "0x8c3f...4e2b", prize: "0.5 ETH", time: "1 day ago" },
    { address: "0x1a5b...7c8d", prize: "0.5 ETH", time: "2 days ago" },
    { address: "0x9e2a...3b1f", prize: "0.5 ETH", time: "3 days ago" },
    { address: "0x4f8c...2d1e", prize: "0.5 ETH", time: "4 days ago" },
    { address: "0x7b3a...6c9f", prize: "0.5 ETH", time: "5 days ago" },
    { address: "0x2e5d...8a4b", prize: "0.5 ETH", time: "6 days ago" },
    { address: "0x9c1f...3e7a", prize: "0.5 ETH", time: "1 week ago" },
    { address: "0x6d4b...9f2c", prize: "0.5 ETH", time: "1 week ago" },
    { address: "0x3a7e...5d8b", prize: "0.5 ETH", time: "2 weeks ago" },
    { address: "0x8f2c...1a6d", prize: "0.5 ETH", time: "2 weeks ago" },
    { address: "0x5b9e...4c3f", prize: "0.5 ETH", time: "3 weeks ago" },
  ]

  const currentPlayers = [
    { address: "0x742d...9f3a", entries: 5 },
    { address: "0x8c3f...4e2b", entries: 3 },
    { address: "0x1a5b...7c8d", entries: 2 },
    { address: "0x9e2a...3b1f", entries: 1 },
    { address: "0x5d1c...8a4e", entries: 1 },
    { address: "0x4c8f...9e3a", entries: 4 },
    { address: "0x7a2b...5d1c", entries: 2 },
    { address: "0x3e9f...8c6b", entries: 3 },
    { address: "0x6b1d...4f7a", entries: 1 },
    { address: "0x9f4e...2c8d", entries: 2 },
    { address: "0x2d7a...6e9b", entries: 1 },
    { address: "0x8c3e...1f4d", entries: 3 },
    { address: "0x5f9b...7a2e", entries: 1 },
    { address: "0x1e6c...9d4f", entries: 2 },
    { address: "0x4a8d...3c7e", entries: 1 },
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-950 via-violet-950 to-purple-900 relative overflow-hidden">
      {/* Animated background effects */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_120%,rgba(120,0,255,0.3),transparent_50%)]"></div>
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_80%_20%,rgba(255,215,0,0.15),transparent_40%)]"></div>

      {[...Array(20)].map((_, i) => (
        <div
          key={i}
          className="absolute animate-fall"
          style={{
            left: `${5 + i * 4.5}%`,
            animationDelay: `${-10 + i * 0.4}s`,
            animationDuration: `${6 + (i % 4)}s`,
            opacity: 0.4 + (i % 3) * 0.15,
          }}
        >
          <div className="relative">
            <div className="absolute inset-0 blur-md bg-amber-400 rounded-full"></div>
            <Coins className="h-10 w-10 text-amber-400 relative animate-spin" style={{ animationDuration: "3s" }} />
          </div>
        </div>
      ))}

      {/* Header with LED border effect */}
      <header className="border-b-4 border-amber-400 bg-gradient-to-r from-purple-900/95 via-violet-900/95 to-purple-900/95 backdrop-blur-md shadow-[0_0_30px_rgba(251,191,36,0.5)] relative">
        <div className="absolute inset-0 bg-gradient-to-r from-transparent via-amber-400/10 to-transparent animate-pulse"></div>
        <div className="container mx-auto flex items-center justify-between px-4 py-5 relative z-10">
          <div className="flex items-center gap-4">
            <div className="relative">
              <div className="absolute inset-0 rounded-full bg-amber-400 blur-xl opacity-60 animate-pulse"></div>
              <div className="relative flex h-16 w-16 items-center justify-center rounded-full bg-gradient-to-br from-amber-300 via-yellow-400 to-amber-500 shadow-[0_0_40px_rgba(251,191,36,0.8)] border-4 border-amber-200">
                <Trophy className="h-9 w-9 text-purple-950 drop-shadow-lg" />
              </div>
            </div>
            <div>
              <h1 className="text-3xl font-black bg-gradient-to-r from-amber-200 via-yellow-300 to-amber-200 bg-clip-text text-transparent drop-shadow-[0_0_20px_rgba(251,191,36,0.8)] tracking-wider">
                MEGA RAFFLE
              </h1>
              <p className="text-xs text-amber-300 font-bold tracking-[0.3em] animate-pulse">JACKPOT TONIGHT</p>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <ConnectButton />
          </div>
        </div>
      </header>

      {/* Main Content */}
      <div className="container mx-auto px-4 py-8 relative z-10">
        {lastRoundWinner && (
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
                      {isCurrentUserWinner ? "🎉 YOU WON! 🎉" : "LAST ROUND WINNER"}
                    </h3>
                    <p className="text-amber-300 font-mono font-bold text-lg">{lastRoundWinner}</p>
                  </div>
                </div>
                {isCurrentUserWinner && (
                  <Button
                    onClick={handleClaimPrize}
                    size="lg"
                    className="bg-gradient-to-r from-emerald-400 via-green-300 to-emerald-400 hover:from-emerald-300 hover:via-green-200 hover:to-emerald-300 text-purple-950 text-xl font-black shadow-[0_0_30px_rgba(52,211,153,1)] hover:shadow-[0_0_50px_rgba(52,211,153,1)] border-3 border-emerald-200 px-8 py-6 hover:scale-105 transition-all rounded-2xl relative overflow-hidden"
                  >
                    <Gift className="mr-2 h-6 w-6" />
                    CLAIM PRIZE • 0.5 ETH
                  </Button>
                )}
              </div>
            </CardContent>
          </Card>
        )}

        <div className="grid gap-6 lg:grid-cols-12">
          {/* Left Sidebar */}
          <div className="flex flex-col space-y-6 lg:col-span-3">
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
                  0.5 ETH
                </div>
                <p className="text-base text-amber-400 font-black tracking-wider animate-pulse mt-2">JACKPOT!</p>
              </CardContent>
            </Card>

            <Card className="border-4 border-pink-400 bg-gradient-to-br from-purple-900/70 to-violet-900/70 backdrop-blur-sm shadow-[0_0_30px_rgba(236,72,153,0.4)] relative overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-br from-pink-400/5 via-transparent to-purple-600/10"></div>
              <CardHeader className="relative z-10">
                <CardTitle className="flex items-center gap-2 text-pink-300 text-xl font-black">
                  <Clock className="h-6 w-6 animate-pulse" />
                  TIME LEFT
                </CardTitle>
              </CardHeader>
              <CardContent className="relative z-10">
                <div className="flex items-center justify-center gap-2">
                  <div className="text-center bg-gradient-to-br from-pink-600 to-purple-700 rounded-xl p-3 border-3 border-pink-300 shadow-[0_0_15px_rgba(236,72,153,0.6)]">
                    <div className="text-4xl font-black text-amber-200 tabular-nums">{String(timeLeft.hours).padStart(2, "0")}</div>
                    <div className="text-xs text-pink-200 font-black">HRS</div>
                  </div>
                  <div className="text-3xl font-black text-amber-300 animate-pulse">:</div>
                  <div className="text-center bg-gradient-to-br from-pink-600 to-purple-700 rounded-xl p-3 border-3 border-pink-300 shadow-[0_0_15px_rgba(236,72,153,0.6)]">
                    <div className="text-4xl font-black text-amber-200 tabular-nums">
                      {String(timeLeft.minutes).padStart(2, "0")}
                    </div>
                    <div className="text-xs text-pink-200 font-black">MIN</div>
                  </div>
                  <div className="text-3xl font-black text-amber-300 animate-pulse">:</div>
                  <div className="text-center bg-gradient-to-br from-pink-600 to-purple-700 rounded-xl p-3 border-3 border-pink-300 shadow-[0_0_15px_rgba(236,72,153,0.6)]">
                    <div className="text-4xl font-black text-amber-200 tabular-nums">
                      {String(timeLeft.seconds).padStart(2, "0")}
                    </div>
                    <div className="text-xs text-pink-200 font-black">SEC</div>
                  </div>
                </div>
              </CardContent>
            </Card>

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
                <Button
                  onClick={handleEnterRaffle}
                  disabled={!isConnected}
                  size="lg"
                  onMouseEnter={() => setIsButtonHovered(true)}
                  onMouseLeave={() => setIsButtonHovered(false)}
                  className={`w-full bg-gradient-to-r from-amber-400 via-yellow-300 to-amber-400 hover:from-amber-300 hover:via-yellow-200 hover:to-amber-300 text-purple-950 text-xl font-black py-10 px-8 shadow-[0_0_80px_rgba(251,191,36,1)] hover:shadow-[0_0_150px_rgba(251,191,36,1)] border-4 border-amber-200 hover:scale-105 transition-all rounded-xl relative overflow-hidden ${
                    isConnected && !isButtonHovered ? "animate-flash" : ""
                  }`}
                >
                  <div className="relative flex items-center justify-center gap-3">
                    <span className="text-2xl">{isConnected ? "ENTER RAFFLE" : "CONNECT FIRST"}</span>
                  </div>
                </Button>
              </CardContent>
            </Card>
          </div>

          {/* Center Content - Wheel Placeholder */}
          <div className="space-y-6 lg:col-span-6 flex flex-col">
            <Card className="border-4 border-amber-400 bg-gradient-to-br from-purple-900/70 to-violet-900/70 backdrop-blur-sm shadow-[0_0_50px_rgba(251,191,36,0.6)] relative overflow-hidden flex-1">
              <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(251,191,36,0.1),transparent_70%)]"></div>
              <CardContent className="p-8 relative z-10 h-full flex flex-col justify-center">
                <div className="flex flex-col items-center justify-center">
                  <WheelPlaceholder />
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Right Sidebar */}
          <div className="flex flex-col space-y-6 lg:col-span-3">
            <Card className="border-4 border-cyan-400 bg-gradient-to-br from-purple-900/70 to-violet-900/70 backdrop-blur-sm shadow-[0_0_30px_rgba(34,211,238,0.4)] relative overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-br from-cyan-400/5 via-transparent to-purple-600/10"></div>
              <CardHeader className="relative z-10">
                <div className="flex items-center justify-between">
                  <CardTitle className="flex items-center gap-2 text-cyan-300 text-xl font-black">
                    <Users className="h-6 w-6" />
                    CURRENT ROUND
                  </CardTitle>
                  <Badge className="bg-cyan-400 text-purple-950 font-black px-3 py-1">{currentPlayers.length}</Badge>
                </div>
              </CardHeader>
              <CardContent className="relative z-10 max-h-96 overflow-y-auto">
                <div className="space-y-2">
                  {currentPlayers.map((player, i) => (
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

            <Card className="border-4 border-purple-400 bg-gradient-to-br from-purple-900/70 to-violet-900/70 backdrop-blur-sm shadow-[0_0_30px_rgba(168,85,247,0.4)] relative overflow-hidden flex-1">
              <div className="absolute inset-0 bg-gradient-to-br from-purple-400/5 via-transparent to-purple-600/10"></div>
              <CardHeader className="relative z-10">
                <CardTitle className="text-purple-300 text-xl font-black">YOUR STATS</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4 relative z-10">
                <div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-purple-300 font-bold">Your Entries</span>
                    <span className="text-2xl font-black text-amber-300">0</span>
                  </div>
                </div>
                <Separator className="bg-purple-600" />
                <div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-purple-300 font-bold">Win Chance</span>
                    <span className="text-2xl font-black text-emerald-300">0%</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>

        {/* Recent Winners */}
        <Card className="mt-6 border-4 border-amber-400 bg-gradient-to-br from-purple-900/70 to-violet-900/70 backdrop-blur-sm shadow-[0_0_30px_rgba(251,191,36,0.4)] relative overflow-hidden">
          <div className="absolute inset-0 bg-gradient-to-br from-amber-400/5 via-transparent to-purple-600/10"></div>
          <CardHeader className="relative z-10">
            <CardTitle className="flex items-center gap-2 text-amber-300 text-2xl font-black">
              <Trophy className="h-7 w-7" />
              RECENT WINNERS
            </CardTitle>
          </CardHeader>
          <CardContent className="relative z-10 max-h-[400px] overflow-y-auto">
            <div className="grid gap-3 md:grid-cols-2 lg:grid-cols-3">
              {recentWinners.map((winner, i) => (
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
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
