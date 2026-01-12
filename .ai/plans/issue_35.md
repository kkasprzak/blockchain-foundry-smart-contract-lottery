# Incremental Delivery Plan: US-012 - View Round Information

## User Story

**US-012: View Round Information**

As a player,
I want to see current round information (entrance fee, prize pool, time until drawing),
So that I can decide whether to enter the raffle.

## Acceptance Criteria Analysis

| AC | Description | Data Source | Complexity |
|----|-------------|-------------|------------|
| AC1 | Entrance fee displayed in ETH | Contract (immutable - `getEntranceFee()`) | Simple |
| AC2 | Prize pool displayed (accumulated fees) | Contract (needs getter) or Indexer | Medium |
| AC3 | Number of players in current round | Contract (needs getter) or Indexer | Medium |
| AC4 | Time remaining until drawing | Contract (`lastTimeStamp`, `INTERVAL`) | Medium |
| AC5 | Data refreshes automatically on new entries | Wagmi polling or Indexer subscription | Medium |

## Sorting by Complexity (simplest to most complex)

1. **AC1** - Entrance fee is already available via `getEntranceFee()` - just needs frontend display
2. **AC4** - Time remaining requires reading two contract values and computing countdown
3. **AC2 + AC3** - Prize pool and player count require adding getter functions to contract OR using indexer
4. **AC5** - Auto-refresh builds on top of all previous ACs

## Implementation Path Decision

**Key Decision:** Data source for AC2, AC3, and AC5

**Option A: Direct Contract Reads (wagmi hooks)**
- Pros: Simpler, no indexer setup needed
- Cons: Requires adding getter functions to contract, less efficient for complex queries

**Option B: Indexer (Ponder)**
- Pros: More efficient for real-time updates, better for future features (history, analytics)
- Cons: More infrastructure to set up initially

**Recommended:** Option A (Direct Contract Reads) for simplicity, with auto-refresh via wagmi polling. The indexer can be enhanced later for US-016 (View Drawing Result) which needs historical data.

---

## Stage 1: Display Entrance Fee

**Goal:** User sees the entrance fee when visiting the raffle page.

**AC:** Given I visit the raffle website, when the page loads, then I see the entrance fee displayed in ETH

**What we are building:**
- A raffle information panel that displays the entrance fee
- The entrance fee is read directly from the deployed contract
- Value is formatted and displayed in ETH (not wei)

**Dependencies on previous stages:**
- None

**Definition of Done:**
- User visits the raffle page and sees "Entrance Fee: 0.01 ETH" (or configured amount)
- The value is read from the actual deployed contract
- Works on both Sepolia and local Anvil networks

---

## Stage 2: Display Time Remaining

**Goal:** User sees how much time is left before the drawing occurs.

**AC:** Given the entry window is active, when I view the page, then I see the time remaining until drawing

**What we are building:**
- A countdown timer showing time until the entry window closes
- Timer updates in real-time (every second)
- When time reaches zero, display changes to indicate drawing is imminent

**Dependencies on previous stages:**
- Stage 1 (raffle info panel exists)

**Definition of Done:**
- User sees countdown timer (e.g., "Time until drawing: 5:32")
- Timer counts down every second
- When entry window is closed, user sees "Drawing in progress..." or similar
- Smart contract needs getter functions for `lastTimeStamp` and `interval`

---

## Stage 3: Display Prize Pool and Player Count

**Goal:** User sees the current prize pool and number of participants.

**AC:**
- Given the current round has players, when I view the page, then I see the prize pool (accumulated entrance fees)
- Given the current round is open, when I view the page, then I see the number of players in the current round

**What we are building:**
- Display of current prize pool in ETH
- Display of player count in current round
- Both values read from the smart contract via new getter functions

**Dependencies on previous stages:**
- Stage 1 and Stage 2 (raffle info panel exists with entrance fee and timer)

**Definition of Done:**
- User sees "Prize Pool: 0.05 ETH" (sum of all entries)
- User sees "Players: 5" (number of entries in current round)
- Values reflect actual contract state
- Smart contract needs getter functions for `prizePool` and `players.length`

---

## Stage 4: Auto-Refresh on Blockchain Changes

**Goal:** Displayed data updates automatically when new players enter.

**AC:** Given the blockchain state changes, when a new player enters, then the displayed data refreshes automatically

**What we are building:**
- Automatic polling of contract data at regular intervals
- Optionally: event-based updates when RaffleEntered events are detected
- UI updates without manual page refresh

**Dependencies on previous stages:**
- Stage 3 (all data is already being displayed)

**Definition of Done:**
- When another user enters the raffle, the prize pool and player count update within a few seconds
- No manual page refresh required
- Countdown timer continues to work correctly during updates

---

## Summary Table

| Stage | AC | Goal | Dependencies |
|-------|-----|------|--------------|
| 1 | AC1 | Display entrance fee in ETH | - |
| 2 | AC4 | Display countdown timer to drawing | Stage 1 |
| 3 | AC2, AC3 | Display prize pool and player count | Stage 2 |
| 4 | AC5 | Auto-refresh data on blockchain changes | Stage 3 |

**Implementation path:** AC1 -> AC4 -> AC2 + AC3 -> AC5

---

## Smart Contract Changes Required

The current `Raffle.sol` only exposes `getEntranceFee()`. The following getter functions need to be added:

1. `getInterval()` - returns the draw interval (needed for Stage 2)
2. `getLastTimeStamp()` - returns the last timestamp (needed for Stage 2)
3. `getPrizePool()` - returns the current prize pool (needed for Stage 3)
4. `getPlayersCount()` - returns the number of players (needed for Stage 3)
5. `getRoundNumber()` - returns the current round number (useful context)
6. `getRaffleState()` - returns whether raffle is OPEN or DRAWING (needed for Stage 2)

These are simple view functions with no security implications.

---

## Notes

- This plan focuses on WHAT the user sees, not HOW it is implemented technically
- Technical decisions (specific hooks, component structure, styling) will be made during implementation
- The smart contract changes are minimal additions of view functions
- Future stories (US-015, US-016) will build on this foundation
