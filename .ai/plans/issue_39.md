# Incremental Delivery Plan: US-016 - View Drawing Result

**GitHub Issue:** #39

**User Story:**
As a player,
I want to see who won when a drawing completes,
So that I know the round outcome.

---

## Acceptance Criteria Analysis

| AC | Description | Data Source | Complexity |
|----|-------------|-------------|------------|
| AC1 | Display winner address when DrawCompleted event is emitted | Real-time event (wagmi) | Low |
| AC2 | Show prize pool amount the winner won | Real-time event (wagmi) | Low |
| AC3 | Show "You won!" if connected user is the winner | Real-time event + connected address | Low |
| AC4 | Show "No winner - round reset" when no participants | Real-time event (winner = address(0)) | Low |
| AC5 | View round history with previous winners and prize amounts | Ponder indexer (historical data) | High |

**Sorting by complexity:**
- AC1-4 are tightly coupled (all use same real-time DrawCompleted event) - delivered together
- AC5 requires historical data storage infrastructure (Ponder indexer) - separate backend + frontend stages

---

## Stage 1: Real-time Winner Announcement (AC 1-4)

**Goal:** When a round completes, players immediately see who won and how much they won

**AC:**
- AC1: Given a drawing completes, when the DrawCompleted event is emitted, then the winner address is displayed
- AC2: Given the drawing has a winner, when I view the result, then I see the prize pool amount they won
- AC3: Given I am the winner, when viewing the result, then I see a clear visual indication ("You won!")
- AC4: Given no players entered the round, when the round completes, then I see "No winner - round reset"

**What we're building:**
- Capture winner and prize data from the DrawCompleted event (useWatchRaffleEvents already exists but does not capture the data)
- Display winner announcement in the center of screen when a round completes
- Show the winner's address (truncated) and the prize amount in ETH
- If the connected wallet is the winner, display "You won!" prominently
- If the winner address is 0x0 (no participants), display "No winner - round reset"

**Dependencies on previous stages:**
- None

**Definition of Done:**
- When a DrawCompleted event is emitted with a winner, the winner's address and prize amount are displayed
- When the connected user's address matches the winner, they see "You won!" prominently
- When DrawCompleted is emitted with winner = address(0), "No winner - round reset" is displayed
- The announcement is visible without page refresh (real-time)

**Acceptance Tests:**

### MUST TEST: AC Verification
| ID | AC | Test | Given → When → Then |
|----|-----|------|---------------------|
| AC-01 | AC1 | Winner address displayed | Round in drawing state → Drawing completes → Winner address visible on screen (shortened format like 0x742d...9f3a) |
| AC-02 | AC2 | Prize amount shown | Drawing completes → Check announcement → Prize amount displayed in ETH (e.g., "0.05 ETH", not wei) |
| AC-03 | AC3 | Current user sees "You won!" | Connected as wallet that won → Drawing completes → "You won!" message displayed prominently |
| AC-04 | AC4 | No winner message | Round with zero entries → Drawing completes → "No winner - round reset" message displayed |

### MUST TEST: Security
| ID | Risk | Test | Given → When → Then |
|----|------|------|---------------------|
| SEC-01 | Wrong prize displayed | Multiple entries with different fees → Drawing completes → Displayed prize matches actual total pool (verify via blockchain) |
| SEC-02 | Winner address mismatch | Winner announced → Cross-check with transaction logs → Displayed address matches actual winner from blockchain event |

### NICE TO HAVE
| ID | Type | Test | Given → When → Then |
|----|------|------|---------------------|
| OPT-01 | UX | Result dismissible | Drawing result shown → Click dismiss/close → Announcement disappears |
| OPT-02 | UX | Non-winner sees neutral result | Connected as non-winner wallet → Drawing completes → Winner shown without "You won!" message |
| OPT-03 | Edge | Multiple wallets connected | Two browser tabs, different wallets → Same round completes → Only winning wallet shows "You won!" |

### Quick Checklist (2 min)
- [ ] Announcement appears within 3 seconds of drawing completion (no page refresh)
- [ ] Winner address shortened to readable format (not full 42 chars)
- [ ] Prize amount readable (ETH with 2-4 decimals, not 18-digit wei)

---

## Stage 2: Ponder Indexer - Round History Backend (infrastructure for AC 5)

**Goal:** Historical round data is stored and accessible via API for the frontend

**AC:**
- AC5 (infrastructure): Given I want to see past rounds, when I view round history, then I see previous winners and prize amounts

**What we're building:**
- Ponder schema: `round` table storing roundNumber, winner, prizePool, completedAt
- Event handler for DrawCompleted that processes and stores round completion data
- API endpoint returning recent rounds (Ponder provides this via Hono)
- Local testing workflow with Anvil to verify indexing works

**Dependencies on previous stages:**
- None (can be developed in parallel with Stage 1)

**Definition of Done:**
- Ponder schema defines `round` table with required fields
- DrawCompleted event handler saves round data to the database
- API endpoint returns list of recent rounds with winner and prize data
- Indexer can be started locally with `pnpm dev` and syncs with Anvil

**Acceptance Tests:**

### MUST TEST: AC Verification
| ID | AC | Test | Given → When → Then |
|----|-----|------|---------------------|
| AC-01 | AC5 | Event indexed to database | Indexer running, round completes with winner 0x742d... and prize 0.05 ETH → Trigger drawing on blockchain → Database contains round record with matching winner and prize |
| AC-02 | AC5 | API returns round history | 5 completed rounds in database → Query API endpoint → Receive JSON response with 5 rounds showing winners and prizes |

### NICE TO HAVE
| ID | Type | Test | Given → When → Then |
|----|------|------|---------------------|
| OPT-01 | Edge | No-winner round stored | Round with zero entries completes → Query API → Round record shows zero/null winner correctly |
| OPT-02 | UX | Rounds sorted newest first | Rounds 1,2,3 indexed → Query API → Response lists round 3, then 2, then 1 |
| OPT-03 | Performance | Large dataset query | 100 rounds indexed → Query recent rounds → Response returns within 1 second |

### Quick Checklist (2 min)
- [ ] Indexer starts without errors
- [ ] GraphQL playground accessible (default port)
- [ ] Round data appears in database within 5 seconds of blockchain event

---

## Stage 3: Recent Winners Panel (AC 5)

**Goal:** Players can see the history of past round winners with real data from the indexer

**AC:**
- AC5: Given I want to see past rounds, when I view round history, then I see previous winners and prize amounts

**What we're building:**
- Hook `useRecentWinners` that fetches recent rounds from the Ponder API
- Replace the hardcoded "Recent Winners" panel data with real data from the hook
- Real-time update when a new round completes (either via polling or event trigger)

**Dependencies on previous stages:**
- Stage 2 (Ponder indexer must be running and serving data)

**Ponder API Configuration:**
- **Base URL:** `http://localhost:42069`
- **GraphQL endpoint:** `http://localhost:42069/graphql`
- **Example query:**
```graphql
query {
  rounds(orderBy: "roundNumber", orderDirection: "desc", limit: 10) {
    items {
      id
      roundNumber
      winner
      prizePool
      completedAt
    }
  }
}
```
- `prizePool` is in wei (bigint) - convert to ETH with `formatEther()`
- `winner` is `null` when no participants (address(0) case)
- `completedAt` is block timestamp (bigint)

**Definition of Done:**
- Recent Winners panel shows real historical data from the Ponder API
- Each winner entry shows: truncated address, prize amount
- Hardcoded `recentWinners` array is removed from RafflePage
- Loading state is shown while fetching data

**Acceptance Tests:**

### MUST TEST: AC Verification
| ID | AC | Test | Given → When → Then |
|----|-----|------|---------------------|
| AC-01 | AC5 | Historical rounds displayed | 5 completed rounds in indexer → Load raffle page → Recent Winners panel shows 5 entries with winner addresses and prize amounts |

### NICE TO HAVE
| ID | Type | Test | Given → When → Then |
|----|------|------|---------------------|
| OPT-01 | UX | Real-time update | Viewing page with 5 winners → New drawing completes → Recent Winners panel updates to show 6 entries within 5 seconds |
| OPT-02 | Edge | Empty history | Fresh deployment with no completed rounds → Load page → Recent Winners shows empty state or placeholder |
| OPT-03 | UX | Loading state | API responds slowly → Load page → Loading indicator displayed while fetching data |
| OPT-04 | Edge | API unavailable | Indexer offline → Load page → Graceful error message (not crash) |

### Quick Checklist (2 min)
- [ ] All winner addresses shown in shortened format
- [ ] Prize amounts displayed in ETH (not wei)
- [ ] Most recent winner appears at top of list

---

## Summary Table

| Stage | AC | Goal | Dependencies | Status |
|-------|-----|------|--------------|--------|
| 1 | AC1, AC2, AC3, AC4 | Real-time winner announcement when round completes | - | ✅ DONE |
| 2 | AC5 (infra) | Ponder indexer stores historical round data | - | ✅ DONE |
| 3 | AC5 | Recent Winners panel shows real historical data | Stage 2 | ✅ DONE |

**Implementation path:** Stage 1 -> Stage 2 (can be parallel) -> Stage 3

**US-016 COMPLETED**

---

## Technical Context (Reference Only)

This section provides technical context for implementers but is NOT part of the plan.

**Current state:**
- `useWatchRaffleEvents` hook exists but only triggers callbacks, does not capture event data
- `DrawCompleted` event includes: `roundNumber` (indexed), `winner` (indexed), `prize` (uint256)
- Ponder indexer has placeholder files (example schema, example config)
- Architecture plan exists at `.ai/arch/ponder-indexer-implementation.md`
- Frontend uses hardcoded `recentWinners` array (lines 109-122 in RafflePage.tsx)

**Key event structure:**
```solidity
event DrawCompleted(
  uint256 indexed roundNumber,
  address indexed winner,
  uint256 prize
);
```

**Note:** When `winner` is `address(0)`, it means no players entered that round.
