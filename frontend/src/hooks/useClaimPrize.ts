import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";
import { useContractWrite } from "./useContractWrite";

export function useClaimPrize() {
  const { write, isPending, isSuccess, isError, error, hash } =
    useContractWrite({
      address: RAFFLE_ADDRESS,
      abi: RAFFLE_ABI,
    });

  const claimPrize = async () => {
    await write({
      functionName: "claimPrize",
    });
  };

  return {
    claimPrize,
    isPending,
    isSuccess,
    isError,
    error,
    hash,
  };
}
