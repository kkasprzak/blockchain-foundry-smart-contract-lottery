import { useReadContract } from "wagmi";
import { formatEther } from "viem";
import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";

export function usePrizePool() {
  const { data, isLoading, error, refetch } = useReadContract({
    address: RAFFLE_ADDRESS,
    abi: RAFFLE_ABI,
    functionName: "getPrizePool",
  });

  return {
    prizePool: data ? formatEther(data) : null,
    isLoading,
    error,
    refetch,
  };
}
