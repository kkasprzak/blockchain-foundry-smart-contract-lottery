import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function truncateAddress(address: string): string {
  return `${address.slice(0, 6)}...${address.slice(-4)}`
}

export function formatRelativeTime(timestamp: bigint): string {
  const now = Math.floor(Date.now() / 1000)
  const diff = now - Number(timestamp)

  if (diff < 60) return "just now"
  if (diff < 3600) return `${Math.floor(diff / 60)} min ago`
  if (diff < 86400) return `${Math.floor(diff / 3600)} hours ago`
  if (diff < 604800) return `${Math.floor(diff / 86400)} days ago`
  return `${Math.floor(diff / 604800)} weeks ago`
}
