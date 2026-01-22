import { useWatchContractEvent } from "wagmi";
import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";

interface UseWatchRaffleEventsProps {
  onRaffleEntered?: () => void;
  onDrawCompleted?: () => void;
}

export function useWatchRaffleEvents({
  onRaffleEntered,
  onDrawCompleted,
}: UseWatchRaffleEventsProps) {
  useWatchContractEvent({
    address: RAFFLE_ADDRESS,
    abi: RAFFLE_ABI,
    eventName: "RaffleEntered",
    onLogs() {
      onRaffleEntered?.();
    },
  });

  useWatchContractEvent({
    address: RAFFLE_ADDRESS,
    abi: RAFFLE_ABI,
    eventName: "DrawCompleted",
    onLogs() {
      onDrawCompleted?.();
    },
  });
}
