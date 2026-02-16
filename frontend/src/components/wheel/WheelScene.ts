import Phaser from "phaser"
import { EventBus } from "./EventBus"

export interface WheelSegment {
  address: string
  entries: number
  isConnected: boolean
}

const SEGMENT_COLORS = [
  0xe84393, 0x00cec9, 0xfdcb6e, 0x6c5ce7, 0x00b894,
  0xfd79a8, 0x0984e3, 0xe17055, 0x55efc4, 0xa29bfe,
]

export const WHEEL_SIZE = 450
const CENTER = WHEEL_SIZE / 2
const RADIUS = 195
const HUB_RADIUS = 30
const LABEL_MIN_DEGREES = 15
const ADDRESS_MIN_DEGREES = 25

export class WheelScene extends Phaser.Scene {
  private segments: WheelSegment[] = []
  private wheelContainer!: Phaser.GameObjects.Container
  private pointer!: Phaser.GameObjects.Graphics
  private isSpinning = false
  private isFrozen = false
  private pendingSegments: WheelSegment[] | null = null
  private winnerHighlight: Phaser.GameObjects.Graphics | null = null
  private winnerTween: Phaser.Tweens.Tween | null = null
  private spinTween: Phaser.Tweens.Tween | null = null

  constructor() {
    super("WheelScene")
  }

  create() {
    this.wheelContainer = this.add.container(CENTER, CENTER)
    this.pointer = this.createPointer()

    EventBus.on("updatePlayers", this.handleUpdate, this)
    EventBus.on("freeze", this.handleFreeze, this)
    EventBus.on("unfreeze", this.handleUnfreeze, this)
    EventBus.on("startSpin", this.spinToWinner, this)
    this.events.on("shutdown", this.cleanup, this)
    this.events.on("destroy", this.cleanup, this)

    EventBus.emit("sceneReady")
  }

  private handleUpdate = (segments: WheelSegment[]) => {
    if (this.isFrozen) {
      this.pendingSegments = segments
      return
    }
    this.segments = segments
    this.redraw()
  }

  private handleFreeze = () => {
    this.isFrozen = true
  }

  private handleUnfreeze = () => {
    this.isFrozen = false
    this.isSpinning = false
    this.cleanupWinnerHighlight()
    this.wheelContainer.setAngle(0)
    if (this.pendingSegments) {
      this.segments = this.pendingSegments
      this.pendingSegments = null
      this.redraw()
    }
  }

  private cleanup = () => {
    EventBus.off("updatePlayers", this.handleUpdate, this)
    EventBus.off("freeze", this.handleFreeze, this)
    EventBus.off("unfreeze", this.handleUnfreeze, this)
    EventBus.off("startSpin", this.spinToWinner, this)
    this.cleanupSpinTweens()
    this.cleanupWinnerHighlight()
    this.pointer.destroy()
  }

  private redraw() {
    this.wheelContainer.removeAll(true)

    if (this.segments.length === 0) {
      this.drawEmptyState()
      return
    }

    this.drawSegments()
    this.drawOuterRing()
    this.drawHub()
  }

  private drawEmptyState() {
    const gfx = this.add.graphics()
    gfx.lineStyle(4, 0xfbbf24, 0.5)
    gfx.strokeCircle(0, 0, RADIUS)
    gfx.lineStyle(2, 0xfbbf24, 0.3)
    gfx.strokeCircle(0, 0, RADIUS - 20)
    this.wheelContainer.add(gfx)

    const label = this.add
      .text(0, 0, "Waiting for\nplayers...", {
        fontSize: "24px",
        fontFamily: "system-ui, sans-serif",
        color: "#d8b4fe",
        align: "center",
        fontStyle: "bold",
      })
      .setOrigin(0.5)
    this.wheelContainer.add(label)
  }

  private drawSegments() {
    const totalEntries = this.segments.reduce((sum, s) => sum + s.entries, 0)
    let startDeg = -90
    const gfx = this.add.graphics()

    this.segments.forEach((segment, i) => {
      const sliceDeg = (segment.entries / totalEntries) * 360
      const color = SEGMENT_COLORS[i % SEGMENT_COLORS.length]
      const startRad = Phaser.Math.DegToRad(startDeg)
      const endRad = Phaser.Math.DegToRad(startDeg + sliceDeg)

      gfx.fillStyle(color, segment.isConnected ? 1 : 0.85)
      gfx.slice(0, 0, RADIUS, startRad, endRad, false)
      gfx.fillPath()

      gfx.lineStyle(2, 0x1a0a2e, 0.9)
      gfx.slice(0, 0, RADIUS, startRad, endRad, false)
      gfx.strokePath()

      startDeg += sliceDeg
    })

    this.wheelContainer.add(gfx)

    this.drawConnectedGlow(totalEntries)
    this.drawLabels(totalEntries)
  }

  private drawConnectedGlow(totalEntries: number) {
    let startDeg = -90
    const glow = this.add.graphics()
    let hasGlow = false

    this.segments.forEach((segment) => {
      const sliceDeg = (segment.entries / totalEntries) * 360

      if (segment.isConnected) {
        hasGlow = true
        glow.lineStyle(4, 0xffd700, 0.9)
        glow.slice(
          0,
          0,
          RADIUS + 4,
          Phaser.Math.DegToRad(startDeg + 0.5),
          Phaser.Math.DegToRad(startDeg + sliceDeg - 0.5),
          false,
        )
        glow.strokePath()
      }

      startDeg += sliceDeg
    })

    if (hasGlow) {
      this.wheelContainer.add(glow)
    } else {
      glow.destroy()
    }
  }

  private drawLabels(totalEntries: number) {
    let startDeg = -90

    this.segments.forEach((segment) => {
      const sliceDeg = (segment.entries / totalEntries) * 360
      const midRad = Phaser.Math.DegToRad(startDeg + sliceDeg / 2)

      if (sliceDeg >= LABEL_MIN_DEGREES) {
        const labelRadius = RADIUS * 0.65
        const lx = labelRadius * Math.cos(midRad)
        const ly = labelRadius * Math.sin(midRad)

        if (segment.isConnected) {
          const label = this.add
            .text(lx, ly, "★ You", {
              fontSize: "18px",
              fontFamily: "system-ui, sans-serif",
              color: "#ffd700",
              fontStyle: "bold",
              stroke: "#1a0a2e",
              strokeThickness: 4,
            })
            .setOrigin(0.5)
          this.wheelContainer.add(label)
        } else if (sliceDeg >= ADDRESS_MIN_DEGREES) {
          const label = this.add
            .text(lx, ly, segment.address, {
              fontSize: "11px",
              fontFamily: "monospace",
              color: "#ffffff",
              stroke: "#1a0a2e",
              strokeThickness: 3,
            })
            .setOrigin(0.5)
          this.wheelContainer.add(label)
        }
      }

      startDeg += sliceDeg
    })
  }

  private drawOuterRing() {
    const ring = this.add.graphics()
    ring.lineStyle(4, 0xfbbf24, 0.9)
    ring.strokeCircle(0, 0, RADIUS + 6)
    ring.lineStyle(2, 0xfbbf24, 0.4)
    ring.strokeCircle(0, 0, RADIUS + 10)
    this.wheelContainer.add(ring)
  }

  private drawHub() {
    const hub = this.add.graphics()
    hub.fillStyle(0x1a0a2e, 1)
    hub.fillCircle(0, 0, HUB_RADIUS)
    hub.lineStyle(3, 0xfbbf24, 0.9)
    hub.strokeCircle(0, 0, HUB_RADIUS)
    hub.fillStyle(0xfbbf24, 0.3)
    hub.fillCircle(0, 0, HUB_RADIUS - 8)
    this.wheelContainer.add(hub)
  }

  private spinToWinner = (winnerAddress: string) => {
    if (this.isSpinning) return
    this.isSpinning = true
    this.cleanupSpinTweens()

    const winnerIndex = this.segments.findIndex(
      (s) => s.address.toLowerCase() === winnerAddress.toLowerCase(),
    )

    if (winnerIndex === -1 || this.segments.length === 0) {
      this.isSpinning = false
      EventBus.emit("spinComplete")
      return
    }

    const totalEntries = this.segments.reduce((sum, s) => sum + s.entries, 0)

    let offsetDeg = 0
    for (let i = 0; i < winnerIndex; i++) {
      offsetDeg += (this.segments[i].entries / totalEntries) * 360
    }
    const sliceDeg = (this.segments[winnerIndex].entries / totalEntries) * 360
    const targetOffset = offsetDeg + sliceDeg / 2

    const jitterRange = sliceDeg * 0.3
    const jitter = (Math.random() * 2 - 1) * jitterRange
    const numSpins = 4 + Math.floor(Math.random() * 4)
    const totalRotation = numSpins * 360 - targetOffset + jitter

    const mainDuration = 3500 + Math.random() * 1000

    this.spinTween = this.tweens.add({
      targets: this.wheelContainer,
      angle: totalRotation,
      duration: mainDuration,
      ease: "Cubic.easeOut",
      onComplete: () => {
        this.spinTween = null
        this.isSpinning = false
        this.highlightWinnerSegment(winnerIndex)
        EventBus.emit("spinComplete")
      },
    })
  }

  private cleanupSpinTweens() {
    if (this.spinTween) {
      this.spinTween.stop()
      this.spinTween = null
    }
  }

  private highlightWinnerSegment(winnerIndex: number) {
    this.cleanupWinnerHighlight()

    const totalEntries = this.segments.reduce((sum, s) => sum + s.entries, 0)
    let startDeg = -90

    for (let i = 0; i < winnerIndex; i++) {
      startDeg += (this.segments[i].entries / totalEntries) * 360
    }
    const sliceDeg = (this.segments[winnerIndex].entries / totalEntries) * 360

    const glow = this.add.graphics()
    glow.lineStyle(6, 0xffd700, 1)
    glow.slice(
      0,
      0,
      RADIUS + 2,
      Phaser.Math.DegToRad(startDeg + 0.5),
      Phaser.Math.DegToRad(startDeg + sliceDeg - 0.5),
      false,
    )
    glow.strokePath()
    this.wheelContainer.add(glow)
    this.winnerHighlight = glow

    this.winnerTween = this.tweens.add({
      targets: glow,
      alpha: { from: 1, to: 0.4 },
      duration: 600,
      yoyo: true,
      repeat: -1,
      ease: "Sine.easeInOut",
    })
  }

  private cleanupWinnerHighlight() {
    if (this.winnerTween) {
      this.winnerTween.stop()
      this.winnerTween = null
    }
    if (this.winnerHighlight) {
      this.winnerHighlight.destroy()
      this.winnerHighlight = null
    }
  }

  private createPointer(): Phaser.GameObjects.Graphics {
    const pointer = this.add.graphics()
    const px = CENTER
    const py = CENTER - RADIUS - 10

    pointer.fillStyle(0xffd700, 1)
    pointer.fillTriangle(px, py + 20, px - 12, py, px + 12, py)
    pointer.lineStyle(2, 0x1a0a2e, 0.8)
    pointer.strokeTriangle(px, py + 20, px - 12, py, px + 12, py)
    pointer.setDepth(10)
    return pointer
  }
}
