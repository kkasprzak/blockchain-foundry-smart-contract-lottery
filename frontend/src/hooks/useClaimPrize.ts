import { useState } from "react";
import { useWriteContract, useWaitForTransactionReceipt } from "wagmi";
import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";

export function useClaimPrize() {
  const {
    writeContractAsync,
    isPending: isWritePending,
    reset: resetWrite,
  } = useWriteContract();

  const [writeError, setWriteError] = useState<Error | null>(null);
  const [txHash, setTxHash] = useState<`0x${string}` | undefined>(undefined);

  const {
    isLoading: isConfirming,
    isSuccess: isConfirmed,
    isError: isReceiptError,
    error: receiptError,
  } = useWaitForTransactionReceipt({
    hash: txHash,
  });

  const claimPrize = async () => {
    setWriteError(null);
    setTxHash(undefined);
    resetWrite();

    try {
      const hash = await writeContractAsync({
        address: RAFFLE_ADDRESS,
        abi: RAFFLE_ABI,
        functionName: "claimPrize",
      });

      setTxHash(hash);
    } catch (err) {
      setWriteError(err instanceof Error ? err : new Error(String(err)));
    }
  };

  const isPending = isWritePending || isConfirming;
  const isError = !!writeError || isReceiptError;
  const error = writeError || receiptError || null;

  return {
    claimPrize,
    isPending,
    isSuccess: isConfirmed,
    isError,
    error,
    hash: txHash,
  };
}
