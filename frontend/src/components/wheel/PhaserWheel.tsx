import { useEffect, useRef, useMemo } from "react"
import Phaser from "phaser"
import { EventBus } from "./EventBus"
import { WheelScene, WHEEL_SIZE } from "./WheelScene"
import type { WheelSegment } from "./WheelScene"
import type { CurrentRoundPlayer } from "@/types/raffle"
import { truncateAddress } from "@/lib/utils"

interface PhaserWheelProps {
  players: CurrentRoundPlayer[]
  connectedAddress?: string
  spinTarget?: string | null
  frozen?: boolean
  onSpinComplete?: () => void
}

export function PhaserWheel({ players, connectedAddress, spinTarget, frozen, onSpinComplete }: PhaserWheelProps) {
  const containerRef = useRef<HTMLDivElement>(null)
  const gameRef = useRef<Phaser.Game | null>(null)
  const sceneReadyRef = useRef(false)
  const pendingDataRef = useRef<WheelSegment[] | null>(null)
  const lastSpinTargetRef = useRef<string | null>(null)

  const segments: WheelSegment[] = useMemo(() => {
    const truncated = connectedAddress
      ? truncateAddress(connectedAddress)
      : ""
    return players.map((p) => ({
      address: p.address,
      entries: p.entries,
      isConnected:
        truncated !== "" &&
        p.address.toLowerCase() === truncated.toLowerCase(),
    }))
  }, [players, connectedAddress])

  useEffect(() => {
    if (!containerRef.current || gameRef.current) return

    const game = new Phaser.Game({
      type: Phaser.AUTO,
      width: WHEEL_SIZE,
      height: WHEEL_SIZE,
      transparent: true,
      parent: containerRef.current,
      scene: WheelScene,
      banner: false,
      antialias: true,
    })
    gameRef.current = game

    const onReady = () => {
      sceneReadyRef.current = true
      if (pendingDataRef.current) {
        EventBus.emit("updatePlayers", pendingDataRef.current)
        pendingDataRef.current = null
      }
    }

    EventBus.on("sceneReady", onReady)

    return () => {
      EventBus.off("sceneReady", onReady)
      game.destroy(true)
      gameRef.current = null
      sceneReadyRef.current = false
      lastSpinTargetRef.current = null
    }
  }, [])

  useEffect(() => {
    if (sceneReadyRef.current) {
      EventBus.emit("updatePlayers", segments)
    } else {
      pendingDataRef.current = segments
    }
  }, [segments])

  useEffect(() => {
    if (!sceneReadyRef.current) return
    EventBus.emit(frozen ? "freeze" : "unfreeze")
  }, [frozen])

  useEffect(() => {
    if (!sceneReadyRef.current || !spinTarget) {
      lastSpinTargetRef.current = null
      return
    }

    if (spinTarget === lastSpinTargetRef.current) {
      return
    }

    lastSpinTargetRef.current = spinTarget
    EventBus.emit("startSpin", truncateAddress(spinTarget))
  }, [spinTarget, frozen])

  useEffect(() => {
    if (!onSpinComplete) return
    const handler = () => onSpinComplete()
    EventBus.on("spinComplete", handler)
    return () => { EventBus.off("spinComplete", handler) }
  }, [onSpinComplete])

  return (
    <div
      ref={containerRef}
      style={{ width: WHEEL_SIZE, height: WHEEL_SIZE }}
    />
  )
}
