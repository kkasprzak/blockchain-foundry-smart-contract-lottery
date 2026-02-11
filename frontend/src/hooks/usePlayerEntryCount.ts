import { useReadContract } from "wagmi";
import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";

export function usePlayerEntryCount(address: `0x${string}` | undefined) {
  const { data, isLoading, error, refetch } = useReadContract({
    address: RAFFLE_ADDRESS,
    abi: RAFFLE_ABI,
    functionName: "getPlayerEntryCount",
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });

  return {
    playerEntryCount: data ? Number(data) : 0,
    isLoading,
    error,
    refetch,
  };
}
