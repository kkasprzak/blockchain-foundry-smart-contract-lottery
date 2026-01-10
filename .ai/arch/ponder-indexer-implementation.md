# Ponder Indexer Implementation Plan

## Context

**Goal:** Implement Ponder as an event indexer for the Raffle contract, enabling fast historical data queries for the frontend.

**Current state:**
- Raffle.sol contract deployed on Sepolia, working with Chainlink VRF and Automation
- Project is pure Foundry (no Node.js/package.json)
- Complete ABI available in `out/Raffle.sol/Raffle.json`
- Events to index: `RaffleEntered`, `DrawRequested`, `DrawCompleted`, `PrizeClaimed`, `PrizeClaimFailed`

**Architectural decisions:**
| Decision | Choice |
|----------|--------|
| **Structure** | Monorepo - Ponder as subfolder in current project |
| **Folder name** | `indexer/` |
| **Package manager** | pnpm |
| **Deployment** | Railway |

---

## Implementation Stages

### Stage 1: Project Initialization

**Goal:** Create Ponder project structure in `indexer/` folder

**Tasks:**
1. Create `indexer/` folder in project root
2. Initialize Node.js project (`package.json`)
3. Install Ponder dependencies
4. Configure TypeScript (`tsconfig.json`)
5. Add `.gitignore` for Node.js

**Structure after stage:**
```
blockchain-foundry-smart-contract-lottery/
├── src/                    # (existing) Solidity
├── indexer/                # (new) Ponder
│   ├── package.json
│   ├── tsconfig.json
│   ├── ponder.config.ts    # (placeholder)
│   ├── ponder.schema.ts    # (placeholder)
│   └── src/
│       └── index.ts        # (placeholder)
└── ...
```

**Completion criteria:** `cd indexer && pnpm install` runs without errors

---

### Stage 2: Local Anvil Configuration

**Goal:** Ponder works with local Anvil for fast development

**Tasks:**
1. Copy ABI from `out/Raffle.sol/Raffle.json` to `indexer/abis/`
2. Create `ponder.config.ts` with Anvil configuration:
   - Chain ID: 31337
   - RPC: http://127.0.0.1:8545
   - `disableCache: true` (critical for Anvil!)
3. Configure automatic address reading from Foundry broadcast
4. Add scripts to `package.json`: `dev`, `build`, `start`

**Key configuration:**
```typescript
// ponder.config.ts
chains: {
  anvil: {
    id: 31337,
    rpc: "http://127.0.0.1:8545",
    disableCache: true,  // CRITICAL!
  }
}
```

**Completion criteria:** `pnpm dev` starts without errors (even without handlers)

---

### Stage 3: Database Schema

**Goal:** Define data structure for indexed events

**Tasks:**
1. Create `ponder.schema.ts` with entities:
   - `Round` - lottery round information
   - `Entry` - player entries to rounds
   - `Player` - player statistics
   - `PrizeClaim` - prize payout history

**Schema:**
```typescript
// ponder.schema.ts
import { onchainTable } from "ponder";

export const round = onchainTable("round", (t) => ({
  id: t.text().primaryKey(),           // roundNumber as string
  roundNumber: t.bigint().notNull(),
  status: t.text().notNull(),          // "open" | "drawing" | "completed"
  prizePool: t.bigint(),
  winner: t.hex(),
  entriesCount: t.integer().notNull(),
  startedAt: t.bigint().notNull(),
  completedAt: t.bigint(),
}));

export const entry = onchainTable("entry", (t) => ({
  id: t.text().primaryKey(),
  roundId: t.text().notNull(),
  player: t.hex().notNull(),
  timestamp: t.bigint().notNull(),
  transactionHash: t.hex().notNull(),
}));

export const player = onchainTable("player", (t) => ({
  id: t.text().primaryKey(),           // address as string
  totalEntries: t.integer().notNull(),
  totalWins: t.integer().notNull(),
  totalPrizeWon: t.bigint().notNull(),
  lastEntryAt: t.bigint(),
}));

export const prizeClaim = onchainTable("prize_claim", (t) => ({
  id: t.text().primaryKey(),
  player: t.hex().notNull(),
  amount: t.bigint().notNull(),
  success: t.boolean().notNull(),
  timestamp: t.bigint().notNull(),
  transactionHash: t.hex().notNull(),
}));
```

**Completion criteria:** `pnpm dev` creates tables in PGlite

---

### Stage 4: Event Handlers

**Goal:** Implement event indexing logic

**Tasks:**
1. Create `src/index.ts` with handlers for:
   - `handleRaffleEntered` - new player entry
   - `handleDrawRequested` - change round status to "drawing"
   - `handleDrawCompleted` - complete round, update winner
   - `handlePrizeClaimed` - record payout
   - `handlePrizeClaimFailed` - record failed payout

**Key logic:**
- On `RaffleEntered`: create/update Round, create Entry, update Player stats
- On `DrawCompleted`: close Round, update winner stats
- On `PrizeClaimed/Failed`: save PrizeClaim record

**Completion criteria:** Local tests with Anvil - events are correctly indexed

---

### Stage 5: Local Testing (Anvil)

**Goal:** Test full development workflow

**Tasks:**
1. Start Anvil: `anvil`
2. Deploy contract: `forge script script/DeployRaffle.s.sol --broadcast --rpc-url http://localhost:8545`
3. Start Ponder: `cd indexer && pnpm dev`
4. Execute test transactions (enterRaffle, performUpkeep, etc.)
5. Verify data in GraphQL playground (http://localhost:42069)

**Test scenarios:**
- [ ] Player enters lottery → Entry + Player created
- [ ] Round completes → Round status = "completed", winner set
- [ ] Player claims prize → PrizeClaim saved

**Completion criteria:** All test scenarios pass

---

### Stage 6: Sepolia Configuration

**Goal:** Ponder works with Sepolia testnet

**Tasks:**
1. Extend `ponder.config.ts` with Sepolia configuration:
   - Chain ID: 11155111
   - RPC from Alchemy (environment variable)
2. Add Sepolia contract address (from `.env` or hardcoded)
3. Set `startBlock` to deployment block
4. Create `.env.local` with `PONDER_RPC_URL_11155111`

**Completion criteria:** `pnpm dev` syncs data from Sepolia

---

### Stage 7: Production Deployment

**Goal:** Ponder publicly accessible for frontend

**Platform:** Railway (recommended by Ponder docs)

**Tasks:**
1. Prepare production configuration:
   - PostgreSQL instead of PGlite
   - Production RPC URL
2. Create `Dockerfile` (optional)
3. Configure Railway:
   - Environment variables
   - Health check: `/ready`
   - Custom start command: `ponder start`
4. Generate public URL for GraphQL API

**Completion criteria:** GraphQL API accessible at public URL

---

### Stage 8: Makefile Integration

**Goal:** Add Ponder commands to project workflow

**Tasks:**
1. Add to `Makefile`:
   ```makefile
   # Ponder commands
   index-dev:
       cd indexer && pnpm dev

   index-build:
       cd indexer && pnpm build

   index-start:
       cd indexer && pnpm start
   ```
2. Optional: script combining Anvil + Deploy + Ponder in one command

**Completion criteria:** `make index-dev` starts Ponder

---

## Summary

| Stage | Name | Effort | Dependencies |
|-------|------|--------|--------------|
| 1 | Project initialization | ~30 min | - |
| 2 | Anvil configuration | ~1h | Stage 1 |
| 3 | Database schema | ~1h | Stage 2 |
| 4 | Event handlers | ~2h | Stage 3 |
| 5 | Local testing | ~1h | Stage 4 |
| 6 | Sepolia configuration | ~30 min | Stage 5 |
| 7 | Production deployment | ~1-2h | Stage 6 |
| 8 | Makefile integration | ~15 min | Stage 1 |

**Total estimated time:** ~8-10h of work

---

## Files to Create/Modify

**New files:**
- `indexer/package.json`
- `indexer/tsconfig.json`
- `indexer/ponder.config.ts`
- `indexer/ponder.schema.ts`
- `indexer/src/index.ts`
- `indexer/abis/RaffleAbi.ts`
- `indexer/.env.local`
- `indexer/.gitignore`

**Modifications:**
- `Makefile` - add Ponder commands
- `.gitignore` (root) - exclude `indexer/node_modules`, `indexer/.ponder`
