# Incremental Delivery Plan: US-016 - View Drawing Result

## User Story

**US-016: View Drawing Result**

As a player,
I want to see who won when a drawing completes,
So that I know the round outcome.

## Acceptance Criteria Analysis

| AC | Description | Complexity | Data Source | Dependencies |
|----|-------------|------------|-------------|--------------|
| AC1 | Winner address displayed when DrawCompleted event emitted | Low | Contract event (DrawCompleted) | useWatchRaffleEvents hook exists |
| AC2 | Prize pool amount shown with winner | Low | Contract event (DrawCompleted.prize) | AC1 |
| AC3 | "You won!" indication for current user | Low | Compare winner address with connected wallet | AC1 |
| AC4 | "No winner - round reset" for empty rounds | Low | Contract event (winner = address(0)) | AC1 |
| AC5 | Round history with previous winners and prizes | High | Requires indexer (Ponder) | AC1-4 complete |

## Sorting Rationale

1. **AC1 + AC2 + AC3 + AC4** are tightly coupled - they all depend on processing the DrawCompleted event and displaying results. The only difference is what text/styling is shown. These should be implemented together.

2. **AC5** (Round History) is significantly more complex because:
   - Requires setting up Ponder indexer schema for rounds
   - Requires creating indexing handlers for DrawCompleted events
   - Requires creating API endpoint to query historical data
   - Requires frontend to fetch from indexer API
   - This is a separate vertical slice that can be delivered after AC1-4

---

## Stage 1: Display Current Drawing Result

**Goal:** When a drawing completes, the user sees who won and how much they won, with special indication if they are the winner.

**AC:**
- AC1: Given a drawing completes, when the DrawCompleted event is emitted, then the winner address is displayed
- AC2: Given the drawing has a winner, when I view the result, then I see the prize pool amount they won
- AC3: Given I am the winner, when viewing the result, then I see a clear visual indication ("You won!")
- AC4: Given no players entered the round, when the round completes, then I see "No winner - round reset"

**What we're building:**
- A result notification that appears when the DrawCompleted event is received
- The notification shows the winner's address (truncated) and the prize amount in ETH
- If the connected wallet is the winner, display "You won!" with celebratory styling
- If the winner address is 0x0 (no participants), display "No winner - round reset"
- The notification should be prominent but dismissible

**Dependencies on previous stages:**
- None (useWatchRaffleEvents hook already exists and watches DrawCompleted)

**Definition of Done:**
- When a draw completes with a winner, users see the winner's address and prize amount
- When the connected user is the winner, they see "You won!" indication
- When a draw completes with no participants, users see "No winner - round reset"
- The result is visible without page refresh (real-time via events)

**Acceptance Tests:**

### MUST TEST: AC Verification
| ID | AC | Test | Given → When → Then |
|----|-----|------|---------------------|
| AC-01 | AC1 | Winner address displayed on draw completion | Round in DRAWING state → Draw completes with winner → Winner address displayed (truncated format like 0x1234...5678) |
| AC-02 | AC2 | Prize amount shown with winner | Draw completes → Check result display → Prize amount visible in ETH (e.g., "0.05 ETH") |
| AC-03 | AC3 | Current user sees "You won!" | Connected as wallet X → Draw completes, wallet X wins → "You won!" message displayed prominently |
| AC-04 | AC4 | No winner message for empty rounds | Round with zero entries → Draw completes → "No winner - round reset" message displayed |

### NICE TO HAVE
| ID | Type | Test | Given → When → Then |
|----|------|------|---------------------|
| OPT-01 | UX | Result dismissible | Drawing result shown → User clicks dismiss/close → Result notification disappears |
| OPT-02 | Edge | Multiple results | First draw completes → Second draw completes immediately → Second result replaces first (no stacking) |
| OPT-03 | UX | Non-winner sees neutral message | Connected as wallet X → Draw completes, wallet Y wins → Winner shown without "You won!" message (neutral display) |

### Quick Checklist (2 min)
- [ ] Winner address is truncated and readable (not full 42 characters)
- [ ] Prize amount displays with proper decimals (not wei)
- [ ] "You won!" styling is clearly celebratory (color/animation distinct)
- [ ] Notification appears without page refresh

---

## Stage 2: View Round History

**Goal:** Users can see a list of previous rounds with their winners and prize amounts.

**AC:**
- AC5: Given I want to see past rounds, when I view round history, then I see previous winners and prize amounts

**What we're building:**
- Ponder indexer schema for storing completed rounds (roundNumber, winner, prize, timestamp)
- Ponder indexing handler that processes DrawCompleted events and stores them
- API endpoint to query completed rounds with pagination
- Frontend component that fetches and displays historical rounds
- Replace the hardcoded "Recent Winners" section with real data from the indexer

**Dependencies on previous stages:**
- Stage 1 must be complete (so we have real-time display working; history is additive)

**Definition of Done:**
- The "Recent Winners" section shows actual historical data from past rounds
- Each entry shows: winner address (truncated), prize amount, and relative time
- Data is fetched from the Ponder indexer API
- New rounds appear in history after they complete (may require page refresh or polling)

**Acceptance Tests:**

### MUST TEST: AC Verification
| ID | AC | Test | Given → When → Then |
|----|-----|------|---------------------|
| AC-01 | AC5 | Historical rounds displayed | 3 rounds completed previously → View history section → See list of 3 past rounds with winners and prizes |

### NICE TO HAVE
| ID | Type | Test | Given → When → Then |
|----|------|------|---------------------|
| OPT-01 | UX | Most recent first | Multiple rounds in history → Check ordering → Newest rounds appear at top |
| OPT-02 | UX | Relative timestamps | Round completed 5 minutes ago → View history → Shows "5 minutes ago" (not absolute timestamp) |
| OPT-03 | Edge | Empty history | No rounds completed yet → View history → Shows appropriate empty state message |
| OPT-04 | UX | New round appears in history | View history with 2 rounds → Draw completes (round 3) → Refresh page and see 3 rounds |

### Quick Checklist (2 min)
- [ ] Historical winners display truncated addresses (consistent with current result)
- [ ] Prize amounts formatted consistently (ETH with decimals)
- [ ] History section replaces hardcoded "Recent Winners" data
- [ ] No console errors when fetching history data

---

## Summary Table

| Stage | AC | Goal | Dependencies |
|-------|-----|------|--------------|
| 1 | AC1, AC2, AC3, AC4 | Display real-time drawing result with winner/prize/"You won!" indication | - |
| 2 | AC5 | View round history with previous winners from indexer | Stage 1 |

**Implementation path:** AC1+AC2+AC3+AC4 (single stage) -> AC5

---

## Technical Context (for implementation reference)

### Current State
- `useWatchRaffleEvents` hook exists and watches `DrawCompleted` event but only triggers callback, does not extract event data
- `DrawCompleted` event contains: `roundNumber` (indexed), `winner` (indexed), `prize` (uint256)
- Ponder indexer has placeholder schema (not yet configured for raffle events)
- Frontend has hardcoded "Recent Winners" data

### Key Implementation Notes for Stage 1
- Need to modify `useWatchRaffleEvents` to extract and return event data (winner, prize) from `onLogs`
- Address `0x0000000000000000000000000000000000000000` indicates no winner (empty round)
- Winner address comparison with connected wallet should be case-insensitive

### Key Implementation Notes for Stage 2
- Ponder schema needs: `CompletedRound` table with (id, roundNumber, winner, prize, timestamp, blockNumber)
- Index the `DrawCompleted` event from the Raffle contract
- API endpoint: `GET /rounds` with optional pagination
- Consider using `@tanstack/react-query` for data fetching if not already used
