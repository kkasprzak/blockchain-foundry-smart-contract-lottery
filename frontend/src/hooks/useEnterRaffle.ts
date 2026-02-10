import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";
import { useContractWrite } from "./useContractWrite";

export function useEnterRaffle() {
  const { write, isPending, isSuccess, isError, error, hash } =
    useContractWrite({
      address: RAFFLE_ADDRESS,
      abi: RAFFLE_ABI,
    });

  const enterRaffle = async (entranceFeeWei: bigint) => {
    await write({
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
