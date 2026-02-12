import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Clock } from "lucide-react"

interface CountdownCardProps {
  hours: number
  minutes: number
  seconds: number
}

export function CountdownCard({ hours, minutes, seconds }: CountdownCardProps) {
  return (
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
          <TimeUnit value={hours} label="HRS" />
          <div className="text-3xl font-black text-amber-300 animate-pulse">:</div>
          <TimeUnit value={minutes} label="MIN" />
          <div className="text-3xl font-black text-amber-300 animate-pulse">:</div>
          <TimeUnit value={seconds} label="SEC" />
        </div>
      </CardContent>
    </Card>
  )
}

function TimeUnit({ value, label }: { value: number; label: string }) {
  return (
    <div className="text-center bg-gradient-to-br from-pink-600 to-purple-700 rounded-xl p-3 border-3 border-pink-300 shadow-[0_0_15px_rgba(236,72,153,0.6)]">
      <div className="text-4xl font-black text-amber-200 tabular-nums">
        {String(value).padStart(2, "0")}
      </div>
      <div className="text-xs text-pink-200 font-black">{label}</div>
    </div>
  )
}
