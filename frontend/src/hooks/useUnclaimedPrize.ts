import { useReadContract } from "wagmi";
import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";
import { formatEther } from "viem";

export function useUnclaimedPrize(address: `0x${string}` | undefined) {
  const { data, isLoading, error, refetch } = useReadContract({
    address: RAFFLE_ADDRESS,
    abi: RAFFLE_ABI,
    functionName: "getUnclaimedPrize",
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });

  return {
    unclaimedPrize: data ? formatEther(data) : "0",
    unclaimedPrizeRaw: data,
    hasUnclaimedPrize: data ? data > 0n : false,
    isLoading,
    error,
    refetch,
  };
}
