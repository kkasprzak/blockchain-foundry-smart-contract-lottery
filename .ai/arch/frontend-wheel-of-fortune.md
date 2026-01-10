# Frontend Implementation Plan - Wheel of Fortune

## Context

**Goal:** Build a React-based frontend for the Raffle contract featuring an interactive Wheel of Fortune visualization for lottery draws.

**Current state:**
- Raffle.sol contract deployed on Sepolia with Chainlink VRF and Automation
- Ponder indexer planned (see `ponder-indexer-implementation.md`)
- No frontend exists yet

**Project structure decision:** Monorepo - frontend as `frontend/` subfolder alongside `indexer/` and smart contracts.

---

## Technology Stack

### Decisions Made

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **Build tool** | Vite | Fast HMR, native TS support, official Phaser template uses it |
| **Framework** | React 18+ | Industry standard, wagmi/RainbowKit require it |
| **Styling** | Tailwind CSS | Utility-first, works great with shadcn/ui |
| **UI Components** | shadcn/ui | Beautiful, accessible, customizable components |
| **Game Engine** | Phaser 3 | Wheel of Fortune animations, official React integration |
| **Wallet Connection** | RainbowKit | Most polished UI, actively maintained, built on wagmi |
| **Blockchain Hooks** | wagmi | De facto standard for React + Ethereum, 20+ hooks |
| **Low-level EVM** | viem | Modern, TypeScript-first, smallest bundle (35kB) |
| **Data Layer** | @ponder/react | Live queries via SSE from Ponder indexer |
| **State Management** | TanStack Query | Already included in wagmi and @ponder/react |

### Stack Rationale

#### Why viem over ethers.js or web3.js?

| Library | Weekly Downloads | Bundle Size | TypeScript | Status |
|---------|-----------------|-------------|------------|--------|
| ethers.js | ~2M | ~120kB | Good | Mature, stable |
| viem | ~1.9M | ~35kB | Native, best | Modern, growing |
| web3.js | ~566K | ~590kB | Added later | Legacy |

**Decision:** viem - newest, smallest bundle, best TypeScript support, foundation for wagmi/RainbowKit. Concepts transfer to ethers.js easily for job interviews.

#### Why wagmi?

- **No real alternatives** - wagmi is the de facto standard for React + Ethereum
- 20+ ready-to-use hooks (`useAccount`, `useBalance`, `useWriteContract`, etc.)
- Built-in caching, request deduplication (via TanStack Query)
- Auto-refresh on wallet/network/block changes
- TypeScript-first with full ABI type inference

Alternatives like web3-react (Uniswap) and useDApp exist but have less active development.

#### Why RainbowKit over ConnectKit or Web3Modal?

| Feature | RainbowKit | ConnectKit | Web3Modal (AppKit) |
|---------|------------|------------|-------------------|
| UI Quality | ★★★★★ | ★★★★☆ | ★★★☆☆ |
| Update Frequency | Frequent | Less frequent | Active |
| Customization | Excellent | Good | Basic |
| Built on | wagmi/viem | wagmi | wagmi |

**Decision:** RainbowKit - most polished, actively maintained, great theming. All three are built on wagmi, so skills transfer easily.

#### Why Phaser for Wheel of Fortune?

- [Official Phaser Wheel of Fortune tutorials](https://phaser.io/news/2018/08/wheel-of-fortune-tutorial) exist
- Dynamic segment generation (players join in real-time)
- Smooth spin animation with easing/inertia
- [Official Phaser + React + Vite template](https://github.com/phaserjs/template-react) (updated 2025)
- EventBus for React ↔ Phaser communication

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         FRONTEND                                │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐  │
│  │    shadcn/ui    │  │     Phaser 3    │  │   RainbowKit   │  │
│  │   (UI panels)   │  │ (Wheel of       │  │   (Connect     │  │
│  │                 │  │  Fortune)       │  │    Wallet)     │  │
│  └────────┬────────┘  └────────┬────────┘  └───────┬────────┘  │
│           │                    │                    │           │
│           └────────────────────┼────────────────────┘           │
│                                │                                │
│                    ┌───────────┴───────────┐                   │
│                    │    React + wagmi      │                   │
│                    │  (state, blockchain)  │                   │
│                    └───────────┬───────────┘                   │
│                                │                                │
│           ┌────────────────────┼────────────────────┐          │
│           │                    │                    │          │
│           ▼                    ▼                    ▼          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  @ponder/react  │  │      viem       │  │   TanStack      │ │
│  │  (live data)    │  │  (contract      │  │   Query         │ │
│  │                 │  │   calls)        │  │   (caching)     │ │
│  └────────┬────────┘  └────────┬────────┘  └─────────────────┘ │
└───────────┼─────────────────────┼───────────────────────────────┘
            │                     │
            ▼                     ▼
    ┌───────────────┐     ┌───────────────┐
    │    Ponder     │     │   Sepolia     │
    │   (indexer)   │     │  (contract)   │
    │   via SSE     │     │   via RPC     │
    └───────────────┘     └───────────────┘
```

---

## Data Flow

### Real-time Updates (Ponder Live Queries)

```typescript
// Frontend receives live updates via SSE (Server-Sent Events)
import { usePonderQuery } from "@ponder/react";

function WheelOfFortune({ roundId }) {
  // Auto-updates when new players join
  const { data: entries, isLive } = usePonderQuery({
    queryFn: (db) =>
      db.select().from(entry).where(eq(entry.roundId, roundId)),
  });

  // Aggregate entries to wheel segments
  const segments = aggregateToSegments(entries);

  return <PhaserWheel segments={segments} isLive={isLive} />;
}
```

### Blockchain Interactions (wagmi + viem)

```typescript
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseEther } from 'viem';

function EnterRaffleButton() {
  const { writeContract, data: hash, isPending } = useWriteContract();

  const { isLoading: isConfirming, isSuccess } =
    useWaitForTransactionReceipt({ hash });

  const handleEnter = () => {
    writeContract({
      address: RAFFLE_ADDRESS,
      abi: RaffleABI,
      functionName: 'enterRaffle',
      value: parseEther('0.01'),
    });
  };

  return (
    <Button onClick={handleEnter} disabled={isPending || isConfirming}>
      {isPending ? 'Confirm in wallet...' :
       isConfirming ? 'Confirming...' :
       'Enter Raffle'}
    </Button>
  );
}
```

---

## Implementation Stages

### Stage 1: Project Setup

**Goal:** Initialize Vite + React + TypeScript project

**Tasks:**
1. Create `frontend/` folder in monorepo root
2. Initialize Vite project with React + TypeScript template
3. Configure pnpm workspace (if using workspaces)
4. Set up Tailwind CSS
5. Install and configure shadcn/ui
6. Add base layout and routing (React Router)

**Structure after stage:**
```
frontend/
├── src/
│   ├── components/
│   ├── pages/
│   ├── App.tsx
│   └── main.tsx
├── index.html
├── package.json
├── tailwind.config.js
├── tsconfig.json
└── vite.config.ts
```

**Completion criteria:** `pnpm dev` shows basic React app with Tailwind styling

---

### Stage 2: Wallet Integration

**Goal:** Connect wallet using RainbowKit + wagmi

**Tasks:**
1. Install wagmi, viem, @tanstack/react-query, RainbowKit
2. Configure wagmi with Sepolia chain
3. Set up RainbowKit provider and theme
4. Create ConnectButton in header
5. Display connected account info
6. Handle network switching

**Key configuration:**
```typescript
// wagmi.config.ts
import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { sepolia } from 'wagmi/chains';

export const config = getDefaultConfig({
  appName: 'Raffle Wheel of Fortune',
  projectId: 'YOUR_WALLETCONNECT_PROJECT_ID',
  chains: [sepolia],
});
```

**Completion criteria:** User can connect MetaMask, see their address and balance

---

### Stage 3: Contract Integration

**Goal:** Read contract state and execute transactions

**Tasks:**
1. Copy ABI from `out/Raffle.sol/Raffle.json`
2. Create typed contract hooks using wagmi
3. Implement `useEntranceFee()` - read entrance fee
4. Implement `useEnterRaffle()` - enter lottery
5. Implement `useClaimPrize()` - claim winnings
6. Add transaction status feedback (pending, confirming, success, error)

**Completion criteria:** User can enter raffle and see transaction confirmations

---

### Stage 4: Ponder Integration

**Goal:** Display live data from Ponder indexer

**Tasks:**
1. Install @ponder/client and @ponder/react
2. Configure Ponder client with indexer URL
3. Create hooks for:
   - Current round entries
   - Player statistics
   - Round history
   - Recent winners
4. Implement live query subscriptions (SSE)

**Completion criteria:** UI updates in real-time when new players enter

---

### Stage 5: Phaser Wheel of Fortune

**Goal:** Implement interactive spinning wheel

**Tasks:**
1. Install Phaser 3
2. Create PhaserGame component with React bridge
3. Implement wheel rendering:
   - Dynamic segments based on players
   - Segment size proportional to entries
   - Player address labels (truncated)
   - Color coding per player
4. Implement spin animation:
   - Triggered when DrawCompleted event received
   - Easing/inertia effect
   - Lands on winner segment
5. Add sound effects (optional)

**Wheel logic:**
```typescript
// Segment calculation
const segments = players.map(player => ({
  address: player.address,
  entries: player.entryCount,
  percentage: player.entryCount / totalEntries * 100,
  color: generateColorFromAddress(player.address),
}));
```

**Completion criteria:** Wheel displays players, spins when draw completes, lands on winner

---

### Stage 6: UI Polish

**Goal:** Complete user interface with shadcn/ui

**Tasks:**
1. Main page layout:
   - Header with wallet connection
   - Wheel in center
   - Sidebar with round info
2. Round info panel:
   - Current prize pool
   - Number of entries
   - Time until draw
   - Entry fee
3. Player panel:
   - Your entries this round
   - Unclaimed prizes
   - Entry history
4. Winners panel:
   - Recent winners list
   - Prize amounts
5. Enter raffle modal/form
6. Responsive design (mobile)
7. Dark/light theme

**Completion criteria:** Polished, responsive UI matching modern dApp standards

---

### Stage 7: Testing

**Goal:** Ensure reliability with local testing

**Tasks:**
1. Set up local environment:
   - Anvil (local blockchain)
   - Ponder (local indexer)
   - Frontend (dev server)
2. Create test scenarios:
   - Connect wallet
   - Enter raffle (single, multiple entries)
   - Wait for draw
   - Verify wheel animation
   - Claim prize
3. Test edge cases:
   - No entries in round
   - User is winner
   - Transaction failures
   - Network switching

**Completion criteria:** Full user journey works on local Anvil

---

### Stage 8: Production Deployment

**Goal:** Deploy frontend to production

**Tasks:**
1. Configure environment variables:
   - Ponder API URL (Railway)
   - Contract address (Sepolia)
   - WalletConnect Project ID
   - Alchemy RPC URL
2. Build production bundle: `pnpm build`
3. Deploy to Vercel:
   - Connect GitHub repo
   - Configure build settings
   - Set environment variables
4. Test on Sepolia with production frontend
5. Configure custom domain (optional)

**Completion criteria:** Frontend accessible at public URL, works with Sepolia contract

---

### Stage 9: Makefile Integration

**Goal:** Add frontend commands to project workflow

**Tasks:**
1. Add to `Makefile`:
   ```makefile
   # Frontend commands
   frontend-dev:
       cd frontend && pnpm dev

   frontend-build:
       cd frontend && pnpm build

   frontend-preview:
       cd frontend && pnpm preview

   # Full stack local development
   dev-all:
       @echo "Starting Anvil, Ponder, and Frontend..."
       # Script to start all services
   ```

**Completion criteria:** `make frontend-dev` starts development server

---

## Summary

| Stage | Name | Effort | Dependencies |
|-------|------|--------|--------------|
| 1 | Project setup | ~1h | - |
| 2 | Wallet integration | ~2h | Stage 1 |
| 3 | Contract integration | ~2h | Stage 2 |
| 4 | Ponder integration | ~2h | Stage 3, Ponder deployed |
| 5 | Phaser Wheel | ~4-6h | Stage 4 |
| 6 | UI polish | ~4h | Stage 5 |
| 7 | Testing | ~2h | Stage 6 |
| 8 | Production deployment | ~1h | Stage 7 |
| 9 | Makefile integration | ~15min | Stage 1 |

**Total estimated time:** ~18-22h of work

---

## Files to Create

**New files:**
- `frontend/package.json`
- `frontend/vite.config.ts`
- `frontend/tsconfig.json`
- `frontend/tailwind.config.js`
- `frontend/postcss.config.js`
- `frontend/index.html`
- `frontend/src/main.tsx`
- `frontend/src/App.tsx`
- `frontend/src/wagmi.config.ts`
- `frontend/src/components/` (multiple)
- `frontend/src/hooks/` (contract hooks)
- `frontend/src/game/` (Phaser wheel)
- `frontend/.env.local`
- `frontend/.gitignore`

**Modifications:**
- `Makefile` - add frontend commands
- `.gitignore` (root) - exclude `frontend/node_modules`, `frontend/dist`

---

## External Dependencies

| Dependency | Purpose | Required Setup |
|------------|---------|----------------|
| WalletConnect | Wallet connections | Create project at cloud.walletconnect.com |
| Alchemy | RPC provider | Already configured for Sepolia |
| Vercel | Frontend hosting | Connect GitHub repo |
| Ponder (Railway) | Indexer API | From indexer plan |
