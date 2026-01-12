import { useReadContract } from "wagmi";
import { formatEther } from "viem";
import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";

export function useEntranceFee() {
  const { data, isLoading, error } = useReadContract({
    address: RAFFLE_ADDRESS,
    abi: RAFFLE_ABI,
    functionName: "getEntranceFee",
  });

  return {
    entranceFee: data ? formatEther(data) : null,
    isLoading,
    error,
  };
}
