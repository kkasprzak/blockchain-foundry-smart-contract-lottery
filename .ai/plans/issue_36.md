# Implementation Plan: US-013 Connect Wallet

## Context

**User Story:** US-013 - Connect Wallet
**Branch:** `feature/us-013-connect-wallet` (create from `main`)

**As a** player,
**I want to** connect my Ethereum wallet,
**So that I** can enter the raffle.

## Acceptance Criteria Analysis

| AC | Description | Complexity | Data Source | Dependencies |
|----|-------------|------------|-------------|--------------|
| AC1 | "Connect Wallet" button visible when not connected | Simple | Local state (wagmi) | None |
| AC2 | Modal shows wallet options (MetaMask, WalletConnect) | Simple | RainbowKit UI | AC1 |
| AC3 | Connected address displayed (truncated) | Simple | wagmi hooks | AC2 |
| AC4 | ETH balance displayed in header | Medium | wagmi `useBalance` hook | AC3 |
| AC5 | Click address to disconnect | Simple | RainbowKit/wagmi | AC3 |

## Sorting by Complexity

1. **AC1 + AC2 + AC3 + AC5** - These are tightly coupled (all provided by RainbowKit ConnectButton)
2. **AC4** - Requires additional hook (useBalance) on top of basic connection

**Key insight:** RainbowKit's `ConnectButton` component handles AC1, AC2, AC3, and AC5 out of the box. AC4 (balance display) requires explicit configuration or custom rendering.

---

## Stage 1: Basic Wallet Connection (AC1 + AC2 + AC3 + AC5)

**AC:**
- **AC1:** Given I am not connected, when I visit the page, then I see a "Connect Wallet" button
- **AC2:** Given I click "Connect Wallet", when the modal opens, then I see available wallet options (MetaMask, WalletConnect, etc.)
- **AC3:** Given I select a wallet and approve the connection, when the connection succeeds, then my address is displayed (truncated)
- **AC5:** Given my wallet is connected, when I click my address, then I can disconnect my wallet

**Minimal tasks:**
1. Install required packages: `wagmi`, `viem`, `@tanstack/react-query`, `@rainbow-me/rainbowkit`
2. Create wagmi configuration file (`/frontend/src/config/wagmi.ts`)
3. Obtain WalletConnect Project ID from cloud.walletconnect.com (or use placeholder for local dev)
4. Wrap App with required providers (WagmiProvider, QueryClientProvider, RainbowKitProvider)
5. Create Header component with RainbowKit ConnectButton
6. Add Header to main App layout

**Files to create/modify:**
- `/Users/karol/Projects/Private/Blockchain/blockchain-foundry-smart-contract-lottery/frontend/src/config/wagmi.ts` (new)
- `/Users/karol/Projects/Private/Blockchain/blockchain-foundry-smart-contract-lottery/frontend/src/components/Header.tsx` (new)
- `/Users/karol/Projects/Private/Blockchain/blockchain-foundry-smart-contract-lottery/frontend/src/App.tsx` (modify - add providers and Header)
- `/Users/karol/Projects/Private/Blockchain/blockchain-foundry-smart-contract-lottery/frontend/package.json` (modify - add dependencies)
- `/Users/karol/Projects/Private/Blockchain/blockchain-foundry-smart-contract-lottery/frontend/.env.local` (new - WalletConnect Project ID)

**Dependencies on previous stages:**
- None (first stage)

**"Done" criteria:**
1. User visits page and sees "Connect Wallet" button in header
2. Clicking button opens modal with MetaMask and WalletConnect options
3. After connecting, truncated address appears (e.g., "0x1234...abcd")
4. Clicking connected address shows dropdown with "Disconnect" option
5. Disconnecting returns to "Connect Wallet" button state

**Estimated time:** 1.5h

---

## Stage 2: Display ETH Balance (AC4)

**AC:**
- **AC4:** Given my wallet is connected, when I view the header, then I see my ETH balance

**Minimal tasks:**
1. Configure RainbowKit ConnectButton to show balance (using `showBalance` prop)
2. OR create custom ConnectButton using `ConnectButton.Custom` if more control needed
3. Verify balance updates after transactions

**Files to create/modify:**
- `/Users/karol/Projects/Private/Blockchain/blockchain-foundry-smart-contract-lottery/frontend/src/components/Header.tsx` (modify - add balance display)

**Dependencies on previous stages:**
- Stage 1 (wallet connection infrastructure)

**"Done" criteria:**
1. When wallet is connected, ETH balance is visible next to the address
2. Balance shows in format like "0.5 ETH" or "0.5012 ETH"
3. Balance reflects actual wallet balance on the connected network (Sepolia or local Anvil)

**Estimated time:** 30min

---

## Summary Table

| Stage | AC | Time | Dependencies | New Infrastructure |
|-------|-----|------|--------------|-------------------|
| 1 | AC1, AC2, AC3, AC5 | 1.5h | - | wagmi, viem, RainbowKit, TanStack Query |
| 2 | AC4 | 30min | Stage 1 | - |

**Total estimated time:** 2h

**Implementation path:** Stage 1 (AC1+AC2+AC3+AC5) -> Stage 2 (AC4)

---

## Detailed Implementation Notes

### Stage 1: Key Configuration

**wagmi.ts structure:**
```typescript
// /frontend/src/config/wagmi.ts
import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { sepolia } from 'wagmi/chains';

// Define local Anvil chain for development
const anvil = {
  id: 31337,
  name: 'Anvil',
  nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
  rpcUrls: {
    default: { http: ['http://127.0.0.1:8545'] },
  },
} as const;

export const config = getDefaultConfig({
  appName: 'Raffle Wheel of Fortune',
  projectId: import.meta.env.VITE_WALLETCONNECT_PROJECT_ID || 'development',
  chains: [sepolia, anvil],
});
```

**Provider wrapping in App.tsx:**
```typescript
import { WagmiProvider } from 'wagmi';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { RainbowKitProvider } from '@rainbow-me/rainbowkit';
import '@rainbow-me/rainbowkit/styles.css';
import { config } from './config/wagmi';

const queryClient = new QueryClient();

function App() {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
          <Header />
          {/* ... rest of app */}
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
```

**Header component:**
```typescript
// /frontend/src/components/Header.tsx
import { ConnectButton } from '@rainbow-me/rainbowkit';

export function Header() {
  return (
    <header className="...">
      <h1>Raffle DApp</h1>
      <ConnectButton />
    </header>
  );
}
```

### Stage 2: Balance Display

RainbowKit ConnectButton shows balance by default. If customization is needed:

```typescript
<ConnectButton
  showBalance={true}  // Default is true
  accountStatus="full" // Shows avatar + address
  chainStatus="icon"   // Shows network icon
/>
```

For custom styling, use `ConnectButton.Custom`:
```typescript
<ConnectButton.Custom>
  {({ account, chain, openAccountModal, openConnectModal, mounted }) => {
    // Custom rendering with full control
  }}
</ConnectButton.Custom>
```

---

## Environment Variables

Create `/frontend/.env.local`:
```
VITE_WALLETCONNECT_PROJECT_ID=your_project_id_here
```

For local development without WalletConnect, MetaMask works without a project ID. The WalletConnect Project ID is only required for WalletConnect mobile connections.

---

## Testing Checklist

### Stage 1 Testing
| Test | Action | Expected Result |
|------|--------|-----------------|
| T1.1 | Load page without wallet | "Connect Wallet" button visible |
| T1.2 | Click "Connect Wallet" | Modal opens with wallet options |
| T1.3 | Select MetaMask | MetaMask popup appears |
| T1.4 | Approve connection | Modal closes, address shown truncated |
| T1.5 | Click connected address | Dropdown appears with disconnect option |
| T1.6 | Click "Disconnect" | Returns to "Connect Wallet" state |

### Stage 2 Testing
| Test | Action | Expected Result |
|------|--------|-----------------|
| T2.1 | Connect wallet with ETH | Balance displayed (e.g., "0.5 ETH") |
| T2.2 | Connect empty wallet | Balance shows "0 ETH" |
| T2.3 | Switch network | Balance updates for new network |

---

## Dependencies to Install

```bash
cd frontend
pnpm add wagmi viem @tanstack/react-query @rainbow-me/rainbowkit
```

**Package versions (latest as of knowledge cutoff):**
- wagmi: ^2.x
- viem: ^2.x
- @tanstack/react-query: ^5.x
- @rainbow-me/rainbowkit: ^2.x
