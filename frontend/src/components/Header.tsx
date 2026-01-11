import { ConnectButton } from '@rainbow-me/rainbowkit';

export function Header() {
  return (
    <header className="flex items-center justify-between p-4 border-b">
      <h1 className="text-2xl font-bold">Raffle DApp</h1>
      <ConnectButton showBalance={true} />
    </header>
  );
}
