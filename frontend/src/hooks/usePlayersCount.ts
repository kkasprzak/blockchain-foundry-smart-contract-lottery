import { useReadContract } from "wagmi";
import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";

export function usePlayersCount() {
  const { data, isLoading, error } = useReadContract({
    address: RAFFLE_ADDRESS,
    abi: RAFFLE_ABI,
    functionName: "getPlayersCount",
  });

  return {
    playersCount: data ? Number(data) : 0,
    isLoading,
    error,
  };
}
