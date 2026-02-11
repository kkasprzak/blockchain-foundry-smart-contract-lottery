import { useState, useMemo } from "react";

function parseErrorMessage(error: Error): string {
  const errorString = error.message.toLowerCase();

  if (
    errorString.includes("user rejected") ||
    errorString.includes("user denied")
  ) {
    return "Transaction rejected";
  }
  if (errorString.includes("insufficient funds")) {
    return "Insufficient funds";
  }
  if (
    errorString.includes("raffle__entrywindowisclosed") ||
    errorString.includes("entry window closed")
  ) {
    return "Entry window closed";
  }
  if (
    errorString.includes("raffle__invalidentrancefee") ||
    errorString.includes("entrance fee")
  ) {
    return "Invalid entrance fee";
  }
  if (errorString.includes("raffle__drawinginprogress")) {
    return "Drawing in progress";
  }
  if (errorString.includes("raffle__raffleisnotdrawing")) {
    return "Raffle not in drawing state";
  }

  return "Transaction failed. Please try again.";
}

export function useDismissableError(isError: boolean, error: Error | null) {
  const [isDismissed, setIsDismissed] = useState(false);

  const errorMessage = useMemo(() => {
    if (isError && error && !isDismissed) {
      return parseErrorMessage(error);
    }
    return null;
  }, [isError, error, isDismissed]);

  const handleDismiss = () => {
    setIsDismissed(true);
  };

  const resetDismissed = () => {
    setIsDismissed(false);
  };

  return {
    errorMessage,
    handleDismiss,
    resetDismissed,
    isDismissed,
  };
}
