import { useReadContract } from "wagmi";
import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";

export function useRoundNumber() {
  const { data, isLoading, error, refetch } = useReadContract({
    address: RAFFLE_ADDRESS,
    abi: RAFFLE_ABI,
    functionName: "getRoundNumber",
  });

  return {
    roundNumber: data as bigint | undefined,
    isLoading,
    error,
    refetch,
  };
}
