import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";
import { useContractWrite } from "./useContractWrite";

export function useClaimPrize() {
  const {
    write,
    isPending,
    isWaitingForSignature,
    isWaitingForConfirmation,
    isSuccess,
    isError,
    error,
    hash,
  } = useContractWrite({
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
    isWaitingForSignature,
    isWaitingForConfirmation,
    isSuccess,
    isError,
    error,
    hash,
  };
}
