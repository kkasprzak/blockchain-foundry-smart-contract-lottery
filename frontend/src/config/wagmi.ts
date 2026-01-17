import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { sepolia, anvil } from 'wagmi/chains';
import { http, webSocket, fallback } from 'viem';

const alchemyApiKey = import.meta.env.VITE_ALCHEMY_API_KEY;

export const config = getDefaultConfig({
  appName: 'Raffle Wheel of Fortune',
  projectId: import.meta.env.VITE_WALLETCONNECT_PROJECT_ID || 'development',
  chains: [sepolia, anvil],
  transports: {
    [sepolia.id]: fallback([
      webSocket(`wss://eth-sepolia.g.alchemy.com/v2/${alchemyApiKey}`),
      http(`https://eth-sepolia.g.alchemy.com/v2/${alchemyApiKey}`),
    ]),
    [anvil.id]: fallback([
      webSocket('ws://127.0.0.1:8545'),
      http('http://127.0.0.1:8545'),
    ]),
  },
});
