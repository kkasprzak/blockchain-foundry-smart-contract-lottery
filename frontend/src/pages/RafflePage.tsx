import { useState, useEffect, useRef, useCallback } from "react"
import { ConnectButton } from "@rainbow-me/rainbowkit"
import { useAccount } from "wagmi"
import { Card, CardContent } from "@/components/ui/card"
import { Trophy, Coins } from "lucide-react"
import { PhaserWheel } from "@/components/wheel/PhaserWheel"
import { RoundResultBanner } from "@/components/RoundResultBanner"
import { WrongNetworkBanner } from "@/components/WrongNetworkBanner"
import { PrizePoolCard } from "@/components/raffle/PrizePoolCard"
import { CountdownCard } from "@/components/raffle/CountdownCard"
import { EntryFeeCard } from "@/components/raffle/EntryFeeCard"
import { CurrentRoundCard } from "@/components/raffle/CurrentRoundCard"
import { PlayerStatsCard } from "@/components/raffle/PlayerStatsCard"
import { RecentWinnersCard } from "@/components/raffle/RecentWinnersCard"
import { YourWinningsCard } from "@/components/raffle/YourWinningsCard"
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
import { useRoundNumber } from "@/hooks/useRoundNumber"
import { useLiveCurrentRoundPlayers } from "@/hooks/useLiveCurrentRoundPlayers"
import { useDismissableError } from "@/hooks/useDismissableError"
import { truncateAddress } from "@/lib/utils"
import type { DrawingResult } from "@/types/raffle"
import { TARGET_CHAIN_ID } from "@/config/env"
import { sepolia, anvil } from "wagmi/chains"

const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"

export function RafflePage() {
  const { isConnected, address, chain } = useAccount()
  const { entranceFee, entranceFeeRaw, isLoading: isLoadingFee } = useEntranceFee()
  const {
    enterRaffle,
    isWaitingForSignature: isEnterWaitingForSignature,
    isWaitingForConfirmation: isEnterWaitingForConfirmation,
    isError,
    error,
    hash: enterTxHash,
  } = useEnterRaffle()
  const { timeLeft, isEntryWindowClosed, isLoading: isLoadingTime, refetch: refetchDeadline } = useRaffleTimeRemaining()
  const { prizePool, isLoading: isLoadingPrizePool, refetch: refetchPrizePool } = usePrizePool()
  const { entriesCount, isLoading: isLoadingEntries, refetch: refetchEntries } = useEntriesCount()
  const { unclaimedPrize, hasUnclaimedPrize, isLoading: isLoadingUnclaimedPrize, refetch: refetchUnclaimedPrize } = useUnclaimedPrize(address)
  const { playerEntryCount, refetch: refetchPlayerEntryCount } = usePlayerEntryCount(address)
  const {
    claimPrize,
    isWaitingForSignature: isClaimWaitingForSignature,
    isWaitingForConfirmation: isClaimWaitingForConfirmation,
    isSuccess: isClaimSuccess,
    isError: isClaimError,
    error: claimError,
    hash: claimTxHash,
  } = useClaimPrize()

  const { roundNumber, refetch: refetchRoundNumber } = useRoundNumber()
  const { players: currentPlayers } = useLiveCurrentRoundPlayers({ roundNumber })
  const { winners: recentWinners, isLoading: isLoadingWinners } = useLiveRecentWinners({ limit: 9 })
  const [drawingResult, setDrawingResult] = useState<DrawingResult | null>(null)
  const [pendingDrawResult, setPendingDrawResult] = useState<DrawingResult | null>(null)

  const spinTarget = pendingDrawResult?.winner ?? null
  const frozen = pendingDrawResult !== null || drawingResult !== null

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

  const [showClaimSuccess, setShowClaimSuccess] = useState(false)
  const claimSuccessTimeoutRef = useRef<NodeJS.Timeout | undefined>(undefined)
  const claimSuccessProcessedRef = useRef(false)

  useEffect(() => {
    return () => {
      if (entrySuccessTimeoutRef.current) clearTimeout(entrySuccessTimeoutRef.current)
      if (claimSuccessTimeoutRef.current) clearTimeout(claimSuccessTimeoutRef.current)
    }
  }, [])

  useWatchRaffleEvents({
    onRaffleEntered: (player) => {
      refetchPrizePool()
      refetchEntries()
      // Only flash success if the current user entered
      if (player.toLowerCase() === address?.toLowerCase()) {
        refetchPlayerEntryCount()
        flashEntrySuccess()
      }
    },
    onDrawCompleted: (result) => {
      if (result.winner === ZERO_ADDRESS) {
        setDrawingResult(result)
      } else {
        setPendingDrawResult(result)
      }
      // Only update Prize Pool and Your Winnings immediately
      // Everything else updates when user clicks "NEXT ROUND"
      refetchPrizePool()
      refetchUnclaimedPrize()
    },
  })

  const isCurrentUserWinner = drawingResult?.winner.toLowerCase() === address?.toLowerCase()

  useEffect(() => {
    if (isClaimSuccess && !claimSuccessProcessedRef.current) {
      claimSuccessProcessedRef.current = true
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setShowClaimSuccess(true)
      if (claimSuccessTimeoutRef.current) clearTimeout(claimSuccessTimeoutRef.current)
      claimSuccessTimeoutRef.current = setTimeout(() => setShowClaimSuccess(false), 3000)
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
    claimSuccessProcessedRef.current = false
    claimPrize()
  }

  const handleSpinComplete = useCallback(() => {
    if (pendingDrawResult) {
      setDrawingResult(pendingDrawResult)
      setPendingDrawResult(null)
    }
  }, [pendingDrawResult])

  const isWrongNetwork = isConnected && chain && chain.id !== TARGET_CHAIN_ID
  const targetChain = TARGET_CHAIN_ID === sepolia.id ? sepolia : anvil
  const targetChainName = targetChain.name
  const explorerBaseUrl = targetChain.blockExplorers?.default?.url

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
        {drawingResult && (
          <RoundResultBanner
            completedRoundNumber={drawingResult.roundNumber}
            winner={drawingResult.winner}
            prizeFormatted={drawingResult.prizeFormatted}
            isCurrentUserWinner={isCurrentUserWinner ?? false}
            onNextRound={() => {
              // Dismiss banner and refresh all data for new round
              setDrawingResult(null)
              refetchDeadline()
              refetchEntries()
              refetchPlayerEntryCount()
              refetchRoundNumber()
            }}
          />
        )}

        <div className="grid gap-6 lg:grid-cols-12">
          {/* Left Sidebar */}
          <div className="flex flex-col space-y-6 lg:col-span-3">
            <PrizePoolCard prizePool={prizePool} isLoading={isLoadingPrizePool} />
            <CountdownCard
              hours={timeLeft.hours}
              minutes={timeLeft.minutes}
              seconds={timeLeft.seconds}
              frozen={frozen}
            />
            <EntryFeeCard
              entranceFee={entranceFee}
              isLoadingFee={isLoadingFee}
              isConnected={isConnected}
              isEntryWindowClosed={isEntryWindowClosed}
              frozen={frozen}
              isWaitingForSignature={isEnterWaitingForSignature}
              isWaitingForConfirmation={isEnterWaitingForConfirmation}
              showEntrySuccess={showEntrySuccess}
              txHash={enterTxHash}
              explorerBaseUrl={explorerBaseUrl}
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
                <div className="flex flex-col items-center justify-center relative">
                  <PhaserWheel
                    players={currentPlayers}
                    connectedAddress={address}
                    spinTarget={spinTarget}
                    frozen={frozen}
                    onSpinComplete={handleSpinComplete}
                  />
                  {!isLoadingTime && isEntryWindowClosed && !spinTarget && !drawingResult && (
                    <div className="absolute inset-0 flex flex-col items-center justify-center bg-purple-950/80 backdrop-blur-sm rounded-lg">
                      <div className="text-5xl font-black bg-gradient-to-r from-amber-200 via-yellow-300 to-amber-200 bg-clip-text text-transparent drop-shadow-[0_0_20px_rgba(251,191,36,0.8)] animate-pulse">
                        DRAWING IN PROGRESS...
                      </div>
                      <p className="text-pink-300 font-bold mt-4 text-xl">Please wait for winner selection</p>
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Right Sidebar */}
          <div className="flex flex-col space-y-6 lg:col-span-3">
            <CurrentRoundCard
              roundNumber={roundNumber}
              entriesCount={entriesCount}
              isLoadingEntries={isLoadingEntries}
              players={currentPlayers}
              connectedAddress={address ? truncateAddress(address) : undefined}
            />
            <PlayerStatsCard
              playerEntryCount={playerEntryCount}
              entriesCount={entriesCount}
            />
            {!isLoadingUnclaimedPrize && (
              <YourWinningsCard
                unclaimedPrize={unclaimedPrize}
                hasUnclaimedPrize={hasUnclaimedPrize || showClaimSuccess}
                isWaitingForSignature={isClaimWaitingForSignature}
                isWaitingForConfirmation={isClaimWaitingForConfirmation}
                showClaimSuccess={showClaimSuccess}
                txHash={claimTxHash}
                explorerBaseUrl={explorerBaseUrl}
                claimErrorMessage={claimErrorMessage}
                onClaim={handleClaimPrize}
                onDismissError={handleDismissClaimError}
              />
            )}
          </div>
        </div>

        <RecentWinnersCard winners={recentWinners} isLoading={isLoadingWinners} />
      </div>
    </div>
  )
}
