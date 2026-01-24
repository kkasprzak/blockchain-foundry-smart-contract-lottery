import { useReadContract } from "wagmi";
import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";

export function useEntriesCount() {
  const { data, isLoading, error, refetch } = useReadContract({
    address: RAFFLE_ADDRESS,
    abi: RAFFLE_ABI,
    functionName: "getEntriesCount",
  });

  return {
    entriesCount: data ? Number(data) : 0,
    isLoading,
    error,
    refetch,
  };
}
