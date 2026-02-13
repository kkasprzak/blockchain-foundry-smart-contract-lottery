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
}

export function PhaserWheel({ players, connectedAddress }: PhaserWheelProps) {
  const containerRef = useRef<HTMLDivElement>(null)
  const gameRef = useRef<Phaser.Game | null>(null)
  const sceneReadyRef = useRef(false)
  const pendingDataRef = useRef<WheelSegment[] | null>(null)

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
    }
  }, [])

  useEffect(() => {
    if (sceneReadyRef.current) {
      EventBus.emit("updatePlayers", segments)
    } else {
      pendingDataRef.current = segments
    }
  }, [segments])

  return (
    <div
      ref={containerRef}
      style={{ width: WHEEL_SIZE, height: WHEEL_SIZE }}
    />
  )
}
