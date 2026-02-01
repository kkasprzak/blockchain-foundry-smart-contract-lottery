import { useWatchContractEvent } from "wagmi";
import { formatEther } from "viem";
import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";
import type { DrawingResult } from "@/types/raffle";

interface UseWatchRaffleEventsProps {
  onRaffleEntered?: () => void;
  onDrawCompleted?: (result: DrawingResult) => void;
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
    onLogs(logs) {
      const log = logs[0];
      if (
        log?.args &&
        "winner" in log.args &&
        "prize" in log.args &&
        "roundNumber" in log.args &&
        log.args.winner !== undefined &&
        log.args.prize !== undefined &&
        log.args.roundNumber !== undefined
      ) {
        onDrawCompleted?.({
          roundNumber: log.args.roundNumber,
          winner: log.args.winner,
          prize: log.args.prize,
          prizeFormatted: formatEther(log.args.prize),
        });
      }
    },
  });
}
