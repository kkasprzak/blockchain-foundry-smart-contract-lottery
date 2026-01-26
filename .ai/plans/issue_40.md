# Incremental Delivery Plan: US-017 - Claim Prize

## User Story

**US-017: Claim Prize**

As a winner,
I want to claim my prize,
So that I receive my ETH winnings.

## Acceptance Criteria Analysis

| AC | Description | Data Source | Complexity |
|----|-------------|-------------|------------|
| AC1 | "Claim Prize" button visible when user has unclaimed winnings | Contract (`unclaimedPrizes` mapping - needs getter) | Simple |
| AC2 | Prize amount displayed when user has unclaimed winnings | Contract (`unclaimedPrizes` mapping - needs getter) | Simple |
| AC3 | Wallet prompts confirmation when clicking "Claim Prize" | Write transaction to `claimPrize()` | Medium |
| AC4 | Transaction status displayed while pending | Wagmi transaction state tracking | Medium |
| AC5 | Wallet balance updates after successful claim | Transaction confirmation + UI update | Medium |
| AC6 | "Claim Prize" button hidden when no unclaimed prizes | Conditional rendering based on balance | Simple |

## Sorting by Complexity (simplest to most complex)

1. **AC1 + AC2 + AC6** - These are tightly coupled: read unclaimed prize balance, show/hide button and amount
2. **AC3** - Initiate claim transaction (similar to existing enterRaffle flow)
3. **AC4** - Track and display transaction status (reuse patterns from Enter Raffle)
4. **AC5** - Success state and wallet balance update confirmation

## Smart Contract Dependency

The smart contract (US-010) already implements the pull payment pattern with:
- `claimPrize()` - function to withdraw prize
- `unclaimedPrizes` mapping - tracks pending withdrawals per address
- `PrizeClaimed` event - emitted on successful claim
- `PrizeClaimFailed` event - emitted if transfer fails
- `Raffle__NoUnclaimedPrize` error - reverted if no balance

**Missing:** A getter function `getUnclaimedPrize(address)` to read unclaimed balance from frontend.

---

## Stage 1: Display Unclaimed Prize Balance

**Goal:** User sees their unclaimed prize amount and a "Claim Prize" button when they have winnings.

**AC:**
- Given I have unclaimed winnings, when I view the page, then I see a "Claim Prize" button
- Given I have unclaimed winnings, when I view my balance, then I see the prize amount available to claim
- Given I have no unclaimed prizes, when I view the page, then the "Claim Prize" button is not visible

**What we are building:**
- Display user's unclaimed prize balance if greater than zero
- Show "Claim Prize" button only when user has unclaimed winnings
- Button and balance are hidden when there is nothing to claim

**Dependencies on previous stages:**
- None

**Definition of Done:**
- Connected user with unclaimed prize sees "Claim Prize" button with prize amount (e.g., "Claim Prize: 0.5 ETH")
- Connected user without unclaimed prize does not see the claim section
- Prize amount is read from the deployed contract
- Smart contract needs `getUnclaimedPrize(address)` getter function

**Acceptance Tests:**

### MUST TEST: AC Verification
| ID | AC | Test | Given → When → Then |
|----|-----|------|---------------------|
| AC-01 | AC1 | Button appears with unclaimed prize | Won raffle (0.5 ETH prize) → Connect wallet → "Claim Prize" button visible |
| AC-02 | AC2 | Prize amount displayed | Have 0.5 ETH unclaimed → View page → "Claim Prize: 0.5 ETH" shown |
| AC-03 | AC6 | Button hidden without prize | No unclaimed winnings → Connect wallet → No claim section visible |

### NICE TO HAVE
| ID | Type | Test | Given → When → Then |
|----|------|------|---------------------|
| OPT-01 | Edge | Multiple unclaimed prizes | Won rounds 1 and 2 (total 1.0 ETH) → View page → Shows combined total "1.0 ETH" |
| OPT-02 | UX | Balance updates automatically | Just won round → Wait 2-3 seconds → Claim button appears without page refresh |

### Quick Checklist (2 min)
- [ ] Prize amount matches what user won in previous round
- [ ] Button does not appear for users who never won
- [ ] ETH amount formatted clearly (not wei or scientific notation)

---

## Stage 2: Claim Transaction with Status Display

**Goal:** User can initiate and complete a prize claim transaction with clear status feedback.

**AC:**
- Given I click "Claim Prize", when the transaction is initiated, then my wallet prompts me to confirm
- Given the claim transaction is pending, when I view the page, then I see the transaction status
- Given the claim succeeds, when the transaction confirms, then my wallet balance updates

**What we are building:**
- Transaction initiation when user clicks "Claim Prize"
- Wallet popup for transaction confirmation
- Pending state indicator while transaction is being processed
- Success state with automatic UI refresh after confirmation
- Error handling for failed transactions

**Dependencies on previous stages:**
- Stage 1 (unclaimed balance display and button exist)

**Definition of Done:**
- Clicking "Claim Prize" opens wallet for transaction confirmation
- While transaction is pending, user sees "Claiming..." or similar status
- After successful transaction:
  - "Claim Prize" section disappears (balance is now zero)
  - User's wallet balance reflects the received ETH
- If transaction fails, user sees clear error message
- User can retry after a failed claim

**Acceptance Tests:**

### MUST TEST: AC Verification
| ID | AC | Test | Given → When → Then |
|----|-----|------|---------------------|
| AC-04 | AC3 | Wallet prompts for confirmation | 0.5 ETH unclaimed → Click "Claim Prize" → Wallet popup appears for approval |
| AC-05 | AC4 | Transaction status shown | Clicked Claim, confirmed in wallet → Transaction pending → "Claiming..." status visible |
| AC-06 | AC5 | Balance updates after claim | 0.5 ETH unclaimed, wallet has 1.0 ETH → Claim successfully → Wallet shows 1.5 ETH, claim button disappears |

### MUST TEST: Security
| ID | Risk | Test | Given → When → Then |
|----|------|------|---------------------|
| SEC-01 | Funds stuck in pending | Transaction hangs | Pending claim → Network slow → Eventually confirms OR clear error (no silent failure) |
| SEC-02 | Double claim attempt | Rapid clicks | Click "Claim Prize" twice fast → Only one transaction submitted (button disabled during pending) |
| SEC-03 | Claim without balance | Manipulated state | No unclaimed prize → Force click claim → Transaction reverts with clear error message |

### NICE TO HAVE
| ID | Type | Test | Given → When → Then |
|----|------|------|---------------------|
| OPT-03 | Negative | User rejects transaction | Click Claim → Reject in wallet → Button returns to normal, can retry |
| OPT-04 | Negative | Insufficient gas | Very low ETH in wallet → Try to claim → Clear "insufficient gas" error |
| OPT-05 | Edge | Claim during new round | Have unclaimed prize, new round active → Claim prize → Successfully receive funds, can still enter new round |

### Quick Checklist (2 min)
- [ ] Button disabled during transaction to prevent double-click
- [ ] Wallet balance updates within 2-3 seconds after confirmation
- [ ] Claim section disappears immediately after successful claim
- [ ] Error messages are user-friendly (not raw blockchain errors)

---

## Summary Table

| Stage | AC | Goal | Dependencies |
|-------|-----|------|--------------|
| 1 | AC1, AC2, AC6 | Display unclaimed prize balance and conditional "Claim Prize" button | - |
| 2 | AC3, AC4, AC5 | Claim transaction with status display and success confirmation | Stage 1 |

**Implementation path:** AC1 + AC2 + AC6 -> AC3 + AC4 + AC5

---

## Smart Contract Changes Required

The current `Raffle.sol` has the `claimPrize()` function and `unclaimedPrizes` mapping, but the mapping is private. A getter function needs to be added:

```solidity
/// @notice Returns the unclaimed prize amount for a given address
/// @param player The address to check
/// @return The unclaimed prize amount in wei
function getUnclaimedPrize(address player) external view returns (uint256) {
    return unclaimedPrizes[player];
}
```

This is a simple view function with no security implications.

---

## Frontend ABI Updates Required

The `contracts.ts` file needs to include:

1. `claimPrize` function definition
2. `getUnclaimedPrize` function definition
3. `PrizeClaimed` event definition
4. `PrizeClaimFailed` event definition

---

## Notes

- This plan focuses on WHAT the user sees, not HOW it is implemented technically
- Technical decisions (specific hooks, component structure, styling) will be made during implementation
- The claim flow follows the same pattern as the existing "Enter Raffle" functionality
- The smart contract already implements the secure pull payment pattern (US-010)
- Error handling should cover:
  - User rejection of transaction
  - Insufficient gas
  - Network errors
  - Contract revert (no unclaimed prize)
