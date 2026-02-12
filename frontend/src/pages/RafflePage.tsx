import { useState, useEffect, useRef } from "react"
import { ConnectButton } from "@rainbow-me/rainbowkit"
import { useAccount } from "wagmi"
import { Card, CardContent } from "@/components/ui/card"
import { Trophy, Coins } from "lucide-react"
import { WheelPlaceholder } from "@/components/WheelPlaceholder"
import { DrawCompletedAnnouncement } from "@/components/DrawCompletedAnnouncement"
import { WrongNetworkBanner } from "@/components/WrongNetworkBanner"
import { PrizePoolCard } from "@/components/raffle/PrizePoolCard"
import { CountdownCard } from "@/components/raffle/CountdownCard"
import { EntryFeeCard } from "@/components/raffle/EntryFeeCard"
import { CurrentRoundCard } from "@/components/raffle/CurrentRoundCard"
import { PlayerStatsCard } from "@/components/raffle/PlayerStatsCard"
import { RecentWinnersCard } from "@/components/raffle/RecentWinnersCard"
import { UnclaimedPrizeBanner } from "@/components/raffle/UnclaimedPrizeBanner"
import { useEntranceFee } from "@/hooks/useEntranceFee"
import { useEnterRaffle } from "@/hooks/useEnterRaffle"
import { useRaffleTimeRemaining } from "@/hooks/useRaffleTimeRemaining"
import { usePrizePool } from "@/hooks/usePrizePool"
import { useEntriesCount } from "@/hooks/useEntriesCount"
import { useWatchRaffleEvents } from "@/hooks/useWatchRaffleEvents"
import { useUnclaimedPrize } from "@/hooks/useUnclaimedPrize"
import { usePlayerEntryCount } from "@/hooks/usePlayerEntryCount"
import { useClaimPrize } from "@/hooks/useClaimPrize"
import { useLiveRecentWinners } from "@/hooks/useLiveRecentWinners"
import { useDismissableError } from "@/hooks/useDismissableError"
import type { DrawingResult } from "@/types/raffle"
import { TARGET_CHAIN_ID } from "@/config/env"
import { sepolia, anvil } from "wagmi/chains"

const CURRENT_PLAYERS = [
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

export function RafflePage() {
  const { isConnected, address, chain } = useAccount()
  const { entranceFee, entranceFeeRaw, isLoading: isLoadingFee } = useEntranceFee()
  const { enterRaffle, isPending, isError, error } = useEnterRaffle()
  const { timeLeft, isEntryWindowClosed, isLoading: isLoadingTime, refetch: refetchDeadline } = useRaffleTimeRemaining()
  const { prizePool, isLoading: isLoadingPrizePool, refetch: refetchPrizePool } = usePrizePool()
  const { entriesCount, isLoading: isLoadingEntries, refetch: refetchEntries } = useEntriesCount()
  const { unclaimedPrize, hasUnclaimedPrize, isLoading: isLoadingUnclaimedPrize, refetch: refetchUnclaimedPrize } = useUnclaimedPrize(address)
  const { playerEntryCount, refetch: refetchPlayerEntryCount } = usePlayerEntryCount(address)
  const { claimPrize, isPending: isClaimPending, isSuccess: isClaimSuccess, isError: isClaimError, error: claimError } = useClaimPrize()

  const { winners: recentWinners, isLoading: isLoadingWinners } = useLiveRecentWinners({ limit: 12 })
  const [drawingResult, setDrawingResult] = useState<DrawingResult | null>(null)

  const {
    errorMessage,
    handleDismiss: handleDismissError,
    resetDismissed: resetEnterError,
  } = useDismissableError(isError, error)

  const {
    errorMessage: claimErrorMessage,
    handleDismiss: handleDismissClaimError,
    resetDismissed: resetClaimError,
  } = useDismissableError(isClaimError, claimError)

  const [showEntrySuccess, setShowEntrySuccess] = useState(false)
  const entrySuccessTimeoutRef = useRef<NodeJS.Timeout | undefined>(undefined)

  const flashEntrySuccess = () => {
    setShowEntrySuccess(true)
    if (entrySuccessTimeoutRef.current) clearTimeout(entrySuccessTimeoutRef.current)
    entrySuccessTimeoutRef.current = setTimeout(() => setShowEntrySuccess(false), 3000)
  }

  useEffect(() => {
    return () => {
      if (entrySuccessTimeoutRef.current) clearTimeout(entrySuccessTimeoutRef.current)
    }
  }, [])

  useWatchRaffleEvents({
    onRaffleEntered: () => {
      refetchPrizePool()
      refetchEntries()
      refetchPlayerEntryCount()
      flashEntrySuccess()
    },
    onDrawCompleted: (result) => {
      setDrawingResult(result)
      refetchPrizePool()
      refetchEntries()
      refetchUnclaimedPrize()
      refetchDeadline()
      refetchPlayerEntryCount()
    },
  })

  const isCurrentUserWinner = drawingResult?.winner.toLowerCase() === address?.toLowerCase()

  useEffect(() => {
    if (isClaimSuccess) {
      refetchUnclaimedPrize()
    }
  }, [isClaimSuccess, refetchUnclaimedPrize])

  const handleEnterRaffle = () => {
    resetEnterError()
    if (entranceFeeRaw) {
      enterRaffle(entranceFeeRaw)
    }
  }

  const handleClaimPrize = () => {
    resetClaimError()
    claimPrize()
  }

  const isWrongNetwork = isConnected && chain && chain.id !== TARGET_CHAIN_ID
  const targetChain = TARGET_CHAIN_ID === sepolia.id ? sepolia : anvil
  const targetChainName = targetChain.name

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-950 via-violet-950 to-purple-900 relative overflow-hidden">
      {isWrongNetwork && chain && (
        <WrongNetworkBanner
          currentChainId={chain.id}
          targetChainName={targetChainName}
        />
      )}

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

      {/* Header */}
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
        {hasUnclaimedPrize && !isLoadingUnclaimedPrize && (
          <UnclaimedPrizeBanner
            unclaimedPrize={unclaimedPrize}
            isClaimPending={isClaimPending}
            claimErrorMessage={claimErrorMessage}
            onClaim={handleClaimPrize}
            onDismissError={handleDismissClaimError}
          />
        )}

        {drawingResult && (
          <DrawCompletedAnnouncement
            winner={drawingResult.winner}
            prizeFormatted={drawingResult.prizeFormatted}
            isCurrentUserWinner={isCurrentUserWinner ?? false}
            onDismiss={() => setDrawingResult(null)}
          />
        )}

        <div className="grid gap-6 lg:grid-cols-12">
          {/* Left Sidebar */}
          <div className="flex flex-col space-y-6 lg:col-span-3">
            <PrizePoolCard prizePool={prizePool} isLoading={isLoadingPrizePool} />
            <CountdownCard hours={timeLeft.hours} minutes={timeLeft.minutes} seconds={timeLeft.seconds} />
            <EntryFeeCard
              entranceFee={entranceFee}
              isLoadingFee={isLoadingFee}
              isConnected={isConnected}
              isEntryWindowClosed={isEntryWindowClosed}
              isPending={isPending}
              showEntrySuccess={showEntrySuccess}
              errorMessage={errorMessage}
              onEnter={handleEnterRaffle}
              onDismissError={handleDismissError}
            />
          </div>

          {/* Center Content */}
          <div className="space-y-6 lg:col-span-6 flex flex-col">
            <Card className="border-4 border-amber-400 bg-gradient-to-br from-purple-900/70 to-violet-900/70 backdrop-blur-sm shadow-[0_0_50px_rgba(251,191,36,0.6)] relative overflow-hidden flex-1">
              <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(251,191,36,0.1),transparent_70%)]"></div>
              <CardContent className="p-8 relative z-10 h-full flex flex-col justify-center">
                <div className="flex flex-col items-center justify-center">
                  {!isLoadingTime && isEntryWindowClosed ? (
                    <div className="text-center">
                      <div className="text-5xl font-black bg-gradient-to-r from-amber-200 via-yellow-300 to-amber-200 bg-clip-text text-transparent drop-shadow-[0_0_20px_rgba(251,191,36,0.8)] animate-pulse">
                        DRAWING IN PROGRESS...
                      </div>
                      <p className="text-pink-300 font-bold mt-4 text-xl">Please wait for winner selection</p>
                    </div>
                  ) : (
                    <WheelPlaceholder />
                  )}
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Right Sidebar */}
          <div className="flex flex-col space-y-6 lg:col-span-3">
            <CurrentRoundCard
              entriesCount={entriesCount}
              isLoadingEntries={isLoadingEntries}
              players={CURRENT_PLAYERS}
            />
            <PlayerStatsCard
              playerEntryCount={playerEntryCount}
              entriesCount={entriesCount}
            />
          </div>
        </div>

        <RecentWinnersCard winners={recentWinners} isLoading={isLoadingWinners} />
      </div>
    </div>
  )
}
