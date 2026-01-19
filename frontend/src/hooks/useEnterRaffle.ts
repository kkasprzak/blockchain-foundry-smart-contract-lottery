import { useWriteContract } from "wagmi";
import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";

export function useEnterRaffle() {
  const {
    writeContract,
    isPending,
    isSuccess,
    isError,
    error,
    data: hash,
  } = useWriteContract();

  const enterRaffle = (entranceFeeWei: bigint) => {
    writeContract({
      address: RAFFLE_ADDRESS,
      abi: RAFFLE_ABI,
      functionName: "enterRaffle",
      value: entranceFeeWei,
    });
  };

  return {
    enterRaffle,
    isPending,
    isSuccess,
    isError,
    error,
    hash,
  };
}
