import { Card, CardContent } from "@/components/ui/card"
import { Trophy, X } from "lucide-react"
import { truncateAddress } from "@/lib/utils"

const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"

interface DrawCompletedAnnouncementProps {
  winner: `0x${string}`
  prizeFormatted: string
  isCurrentUserWinner: boolean
  onDismiss: () => void
}

interface AnnouncementColors {
  border: string
  background: string
  shadow: string
  glow: string
  iconBg: string
  iconBorder: string
  iconShadow: string
  title: string
  titleShadow: string
  subtitle: string
  button: string
  buttonHover: string
}

const AMBER_COLORS: AnnouncementColors = {
  border: "border-amber-400",
  background: "from-amber-900/95 via-yellow-900/95 to-amber-900/95",
  shadow: "shadow-[0_0_50px_rgba(251,191,36,0.6)]",
  glow: "from-amber-400/10 via-transparent to-amber-400/10",
  iconBg: "bg-amber-400",
  iconBorder: "from-amber-300 via-yellow-400 to-amber-500 border-4 border-amber-200",
  iconShadow: "shadow-[0_0_30px_rgba(251,191,36,1)]",
  title: "text-amber-300",
  titleShadow: "drop-shadow-[0_0_15px_rgba(251,191,36,0.8)]",
  subtitle: "text-amber-200",
  button: "text-amber-300 hover:text-amber-100",
  buttonHover: "hover:bg-amber-400/20",
}

const EMERALD_COLORS: AnnouncementColors = {
  border: "border-emerald-400",
  background: "from-emerald-900/95 via-green-900/95 to-emerald-900/95",
  shadow: "shadow-[0_0_50px_rgba(52,211,153,0.6)]",
  glow: "from-emerald-400/10 via-transparent to-emerald-400/10",
  iconBg: "bg-emerald-400",
  iconBorder: "from-emerald-300 via-green-400 to-emerald-500 border-4 border-emerald-200",
  iconShadow: "shadow-[0_0_30px_rgba(52,211,153,1)]",
  title: "text-emerald-300",
  titleShadow: "drop-shadow-[0_0_15px_rgba(52,211,153,0.8)]",
  subtitle: "text-amber-300",
  button: "text-emerald-300 hover:text-emerald-100",
  buttonHover: "hover:bg-emerald-400/20",
}

interface AnnouncementCardProps {
  colors: AnnouncementColors
  title: string
  subtitle: string
  onDismiss: () => void
}

function AnnouncementCard({ colors, title, subtitle, onDismiss }: AnnouncementCardProps) {
  return (
    <Card className={`mb-6 border-4 ${colors.border} bg-gradient-to-r ${colors.background} backdrop-blur-md ${colors.shadow} relative overflow-hidden`}>
      <div className={`absolute inset-0 bg-gradient-to-r ${colors.glow} animate-pulse`}></div>
      <CardContent className="p-6 relative z-10">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="relative">
              <div className={`absolute inset-0 rounded-full ${colors.iconBg} blur-xl opacity-80 animate-pulse`}></div>
              <div className={`relative flex h-16 w-16 items-center justify-center rounded-full bg-gradient-to-br ${colors.iconBorder} ${colors.iconShadow}`}>
                <Trophy className="h-9 w-9 text-purple-950" />
              </div>
            </div>
            <div>
              <h3 className={`text-2xl font-black ${colors.title} ${colors.titleShadow}`}>
                {title}
              </h3>
              <p className={`${colors.subtitle} font-mono font-bold text-lg`}>{subtitle}</p>
            </div>
          </div>
          <button
            onClick={onDismiss}
            className={`${colors.button} p-2 rounded-lg ${colors.buttonHover} transition-colors`}
            aria-label="Dismiss announcement"
          >
            <X className="h-6 w-6" />
          </button>
        </div>
      </CardContent>
    </Card>
  )
}

export function DrawCompletedAnnouncement({
  winner,
  prizeFormatted,
  isCurrentUserWinner,
  onDismiss,
}: DrawCompletedAnnouncementProps) {
  const isNoWinner = winner === ZERO_ADDRESS

  if (isNoWinner) {
    return (
      <AnnouncementCard
        colors={AMBER_COLORS}
        title="No winner - round reset"
        subtitle="No participants in this round"
        onDismiss={onDismiss}
      />
    )
  }

  if (isCurrentUserWinner) {
    return (
      <AnnouncementCard
        colors={EMERALD_COLORS}
        title="You won!"
        subtitle={`Prize: ${prizeFormatted} ETH`}
        onDismiss={onDismiss}
      />
    )
  }

  return (
    <AnnouncementCard
      colors={AMBER_COLORS}
      title={`Winner: ${truncateAddress(winner)}`}
      subtitle={`Prize: ${prizeFormatted} ETH`}
      onDismiss={onDismiss}
    />
  )
}
