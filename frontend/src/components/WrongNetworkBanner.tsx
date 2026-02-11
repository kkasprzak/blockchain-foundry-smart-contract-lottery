import { AlertTriangle } from "lucide-react";
import { useSwitchChain } from "wagmi";
import { Button } from "./ui/button";
import { TARGET_CHAIN_ID } from "@/config/env";

interface WrongNetworkBannerProps {
  currentChainId: number;
  targetChainName: string;
}

export function WrongNetworkBanner({
  currentChainId,
  targetChainName,
}: WrongNetworkBannerProps) {
  const { switchChain, isPending } = useSwitchChain();

  const handleSwitchNetwork = () => {
    switchChain({ chainId: TARGET_CHAIN_ID });
  };

  return (
    <div className="fixed top-0 left-0 right-0 z-50 bg-yellow-500/90 backdrop-blur-sm border-b border-yellow-600">
      <div className="container mx-auto px-4 py-3">
        <div className="flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <AlertTriangle className="h-5 w-5 text-yellow-900" />
            <div>
              <p className="text-sm font-semibold text-yellow-900">
                Wrong Network
              </p>
              <p className="text-xs text-yellow-800">
                Please switch to {targetChainName} to use this app. You are
                currently on chain ID {currentChainId}.
              </p>
            </div>
          </div>
          <Button
            onClick={handleSwitchNetwork}
            disabled={isPending}
            size="sm"
            className="bg-yellow-900 hover:bg-yellow-800 text-yellow-50"
          >
            {isPending ? "Switching..." : `Switch to ${targetChainName}`}
          </Button>
        </div>
      </div>
    </div>
  );
}
