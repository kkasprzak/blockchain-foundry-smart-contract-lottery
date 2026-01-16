import { useState, useEffect, useMemo } from "react";
import { useReadContract } from "wagmi";
import { RAFFLE_ABI, RAFFLE_ADDRESS } from "@/config/contracts";

interface TimeRemaining {
  hours: number;
  minutes: number;
  seconds: number;
}

export function useRaffleTimeRemaining() {
  const { data: deadline, isLoading } = useReadContract({
    address: RAFFLE_ADDRESS,
    abi: RAFFLE_ABI,
    functionName: "getEntryDeadline",
  });

  const [hasCalculated, setHasCalculated] = useState(false);

  const [timeLeft, setTimeLeft] = useState<TimeRemaining>({
    hours: 0,
    minutes: 0,
    seconds: 0,
  });

  useEffect(() => {
    if (!deadline) return;

    const updateTime = () => {
      const nowInSeconds = Math.floor(Date.now() / 1000);
      const remainingSeconds = Number(deadline) - nowInSeconds;

      if (remainingSeconds <= 0) {
        setTimeLeft({ hours: 0, minutes: 0, seconds: 0 });
      } else {
        setTimeLeft({
          hours: Math.floor(remainingSeconds / 3600),
          minutes: Math.floor((remainingSeconds % 3600) / 60),
          seconds: remainingSeconds % 60,
        });
      }
      setHasCalculated(true);
    };

    // Calculate initial time immediately
    updateTime();

    const timer = setInterval(updateTime, 1000);

    return () => clearInterval(timer);
  }, [deadline]);

  const isEntryWindowClosed = useMemo(
    () =>
      !isLoading &&
      hasCalculated &&
      deadline !== undefined &&
      timeLeft.hours === 0 &&
      timeLeft.minutes === 0 &&
      timeLeft.seconds === 0,
    [isLoading, hasCalculated, deadline, timeLeft]
  );

  return {
    timeLeft,
    isEntryWindowClosed,
    isLoading,
  };
}
