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
  private container!: Phaser.GameObjects.Container

  constructor() {
    super("WheelScene")
  }

  create() {
    this.container = this.add.container(0, 0)

    EventBus.on("updatePlayers", this.handleUpdate, this)
    this.events.on("shutdown", this.cleanup, this)
    this.events.on("destroy", this.cleanup, this)

    EventBus.emit("sceneReady")
  }

  private handleUpdate = (segments: WheelSegment[]) => {
    this.segments = segments
    this.redraw()
  }

  private cleanup = () => {
    EventBus.off("updatePlayers", this.handleUpdate, this)
  }

  private redraw() {
    this.container.removeAll(true)

    if (this.segments.length === 0) {
      this.drawEmptyState()
      return
    }

    this.drawSegments()
    this.drawOuterRing()
    this.drawHub()
    this.drawPointer()
  }

  private drawEmptyState() {
    const gfx = this.add.graphics()
    gfx.lineStyle(4, 0xfbbf24, 0.5)
    gfx.strokeCircle(CENTER, CENTER, RADIUS)
    gfx.lineStyle(2, 0xfbbf24, 0.3)
    gfx.strokeCircle(CENTER, CENTER, RADIUS - 20)
    this.container.add(gfx)

    const label = this.add
      .text(CENTER, CENTER, "Waiting for\nplayers...", {
        fontSize: "24px",
        fontFamily: "system-ui, sans-serif",
        color: "#d8b4fe",
        align: "center",
        fontStyle: "bold",
      })
      .setOrigin(0.5)
    this.container.add(label)
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
      gfx.slice(CENTER, CENTER, RADIUS, startRad, endRad, false)
      gfx.fillPath()

      gfx.lineStyle(2, 0x1a0a2e, 0.9)
      gfx.slice(CENTER, CENTER, RADIUS, startRad, endRad, false)
      gfx.strokePath()

      startDeg += sliceDeg
    })

    this.container.add(gfx)

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
          CENTER,
          CENTER,
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
      this.container.add(glow)
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
        const lx = CENTER + labelRadius * Math.cos(midRad)
        const ly = CENTER + labelRadius * Math.sin(midRad)

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
          this.container.add(label)
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
          this.container.add(label)
        }
      }

      startDeg += sliceDeg
    })
  }

  private drawOuterRing() {
    const ring = this.add.graphics()
    ring.lineStyle(4, 0xfbbf24, 0.9)
    ring.strokeCircle(CENTER, CENTER, RADIUS + 6)
    ring.lineStyle(2, 0xfbbf24, 0.4)
    ring.strokeCircle(CENTER, CENTER, RADIUS + 10)
    this.container.add(ring)
  }

  private drawHub() {
    const hub = this.add.graphics()
    hub.fillStyle(0x1a0a2e, 1)
    hub.fillCircle(CENTER, CENTER, HUB_RADIUS)
    hub.lineStyle(3, 0xfbbf24, 0.9)
    hub.strokeCircle(CENTER, CENTER, HUB_RADIUS)
    hub.fillStyle(0xfbbf24, 0.3)
    hub.fillCircle(CENTER, CENTER, HUB_RADIUS - 8)
    this.container.add(hub)
  }

  private drawPointer() {
    const pointer = this.add.graphics()
    const px = CENTER
    const py = CENTER - RADIUS - 10

    pointer.fillStyle(0xffd700, 1)
    pointer.fillTriangle(px, py + 20, px - 12, py, px + 12, py)
    pointer.lineStyle(2, 0x1a0a2e, 0.8)
    pointer.strokeTriangle(px, py + 20, px - 12, py, px + 12, py)
    this.container.add(pointer)
  }
}
