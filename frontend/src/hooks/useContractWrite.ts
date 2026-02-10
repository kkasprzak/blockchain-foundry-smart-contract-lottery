import { useState } from "react";
import { useWriteContract, useWaitForTransactionReceipt } from "wagmi";
import type { Abi, Address } from "viem";

interface UseContractWriteParams {
  address: Address;
  abi: Abi;
}

interface WriteParams {
  functionName: string;
  value?: bigint;
  args?: unknown[];
}

export function useContractWrite({ address, abi }: UseContractWriteParams) {
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

  const write = async ({ functionName, value, args }: WriteParams) => {
    setWriteError(null);
    setTxHash(undefined);
    resetWrite();

    try {
      const hash = await writeContractAsync({
        address,
        abi,
        functionName,
        value,
        args,
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
    write,
    isPending,
    isSuccess: isConfirmed,
    isError,
    error,
    hash: txHash,
  };
}
