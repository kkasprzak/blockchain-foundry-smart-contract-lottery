# Incremental Delivery Plan: US-014 - Enter Raffle

## User Story

**US-014: Enter Raffle** [READY]

As a player,
I want to pay the entrance fee to join the current round,
So that I have a chance to win the prize pool.

---

## Context

**Existing Infrastructure:**
- Wallet connection (RainbowKit) already exists (US-013 done)
- Contract ABI is available at `frontend/src/config/contracts.ts`
- Existing hooks: `useEntranceFee`, `usePrizePool`, `usePlayersCount`, `useRaffleTimeRemaining`, `useWatchRaffleEvents`
- RafflePage already has a placeholder "Enter Raffle" button with hover/connection state
- Entry window validation (`isEntryWindowClosed`) already exists via `useRaffleTimeRemaining` hook
- Real-time event watching already refreshes prize pool and player count on `RaffleEntered` event

**Missing:**
- `enterRaffle` function in contract ABI
- `useWriteContract` hook integration for transaction submission
- Transaction state handling (idle, pending, success, error)
- Visual feedback for transaction states

---

## Acceptance Criteria (sorted by complexity)

| AC# | Description | Complexity | Reason |
|-----|-------------|------------|--------|
| AC1 | Button visible when wallet connected | Simplest | Already exists, just needs refinement |
| AC2 | Button disabled when entry window closed | Simple | Uses existing `isEntryWindowClosed` |
| AC3 | Wallet prompts for entrance fee on click | Medium | Core transaction functionality |
| AC4 | Pending status indicator during transaction | Medium | Transaction state tracking |
| AC7 | Clear error message on failure | Medium | Error state handling |
| AC6 | Multiple entries allowed (additive) | Simple | Smart contract already supports, just verification |
| AC5 | See myself in players list after confirmation | Complex | Requires confirmation tracking + data refresh |

---

## Stage 1: Entry Button with Window Validation

**Goal:** User can see the Enter Raffle button with appropriate disabled state when entry window is closed.

**AC:**
- AC1: Given my wallet is connected, when I view the page, then I see an "Enter Raffle" button
- AC2: Given the entry window is closed, when I view the button, then it is disabled with explanatory text

**What we're building:**
- The existing "Enter Raffle" button becomes context-aware
- When wallet is connected AND entry window is open, button is enabled
- When wallet is connected BUT entry window is closed, button is disabled with explanatory text (e.g., "Entry Window Closed")
- When wallet is not connected, existing "Connect First" text remains

**Dependencies on previous stages:**
- None

**Definition of Done:**
- User with connected wallet sees enabled "Enter Raffle" button when entry window is open
- User with connected wallet sees disabled button with "Entry Window Closed" text when entry window is closed
- User without connected wallet sees "Connect First" text (existing behavior)

---

## Stage 2: Transaction Submission

**Goal:** User can click the button and their wallet prompts them to confirm the entrance fee transaction.

**AC:**
- AC3: Given I click "Enter Raffle", when the transaction is initiated, then my wallet prompts me to confirm the exact entrance fee amount

**What we're building:**
- Clicking the enabled "Enter Raffle" button triggers a smart contract transaction
- The wallet (MetaMask, etc.) opens with the exact entrance fee amount pre-filled
- User can approve or reject the transaction in their wallet

**Dependencies on previous stages:**
- Stage 1 (button must be enabled for user to click)

**Definition of Done:**
- User clicks "Enter Raffle" and wallet popup appears
- Wallet shows the correct entrance fee amount (from `useEntranceFee`)
- User can approve the transaction in wallet
- Transaction is submitted to the blockchain

---

## Stage 3: Transaction Feedback (Pending and Error States)

**Goal:** User sees clear feedback while transaction is pending and when errors occur.

**AC:**
- AC4: Given I confirm the transaction, when it is pending, then I see a "pending" status indicator
- AC7: Given the transaction fails, when the error occurs, then I see a clear error message

**What we're building:**
- After user confirms in wallet, button shows "Pending..." or similar indicator
- Button is disabled during pending state to prevent double-submission
- If transaction fails (rejected, insufficient funds, entry window closed, etc.), user sees a clear error message
- Error messages are human-readable, not raw blockchain errors

**Dependencies on previous stages:**
- Stage 2 (must be able to submit transactions)

**Definition of Done:**
- After confirming in wallet, user sees pending indicator on button
- Button is disabled while transaction is pending
- If transaction fails, user sees clear error message (e.g., "Transaction rejected", "Insufficient funds", "Entry window closed")
- User can try again after error is dismissed

---

## Stage 4: Confirmation and Data Refresh

**Goal:** User sees their entry reflected in the UI after transaction is confirmed.

**AC:**
- AC5: Given the transaction is confirmed, when the blockchain updates, then I see myself in the players list
- AC6: Given I already entered this round, when I click "Enter Raffle" again, then I am added as a separate entry (increasing my chances)

**What we're building:**
- After transaction is confirmed on blockchain, UI automatically updates
- Prize pool increases by entrance fee amount
- Player count increases
- User can enter multiple times, each entry is processed independently
- Success feedback (brief visual indication that entry was successful)

**Dependencies on previous stages:**
- Stage 3 (must have transaction submission and pending state)

**Definition of Done:**
- After transaction confirms, prize pool updates automatically (already working via events)
- After transaction confirms, player count updates automatically (already working via events)
- User can click "Enter Raffle" again for additional entries
- Each additional entry triggers new transaction and updates counts
- Brief success indication shown to user (optional: toast notification or button state change)

---

## Summary Table

| Stage | AC | Goal | Dependencies |
|-------|-----|------|--------------|
| 1 | AC1, AC2 | Button with entry window validation | - |
| 2 | AC3 | Transaction submission via wallet | Stage 1 |
| 3 | AC4, AC7 | Pending and error state feedback | Stage 2 |
| 4 | AC5, AC6 | Confirmation and multiple entries | Stage 3 |

**Implementation path:** Stage 1 -> Stage 2 -> Stage 3 -> Stage 4

---

## Technical Notes (for implementation reference)

These are high-level technical considerations, not implementation details:

1. **Contract ABI:** The `enterRaffle` function needs to be added to the ABI in `contracts.ts`
2. **Wagmi hooks:** `useWriteContract` from wagmi will be used for transaction submission
3. **Existing event watching:** `useWatchRaffleEvents` already handles data refresh on `RaffleEntered` event
4. **Entrance fee:** Already available via `useEntranceFee` hook
5. **Entry window state:** Already available via `useRaffleTimeRemaining` hook's `isEntryWindowClosed`

---

## Estimated Effort

- Stage 1: ~30 minutes (mostly UI state logic)
- Stage 2: ~1 hour (hook integration, ABI update)
- Stage 3: ~1 hour (state management, error handling)
- Stage 4: ~30 minutes (mostly verification, minor UI polish)

**Total estimated effort:** ~3 hours
