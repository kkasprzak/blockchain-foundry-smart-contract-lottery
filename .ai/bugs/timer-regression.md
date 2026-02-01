# Bug Report: Timer Does Not Auto-Refresh After Draw Completion

**Reporter:** QA Tester
**Date:** 2026-01-27
**Severity:** Low
**Type:** Regression

---

## Summary

Timer displays `0:0:0` after draw completion and does not automatically update to show the new round countdown. User must manually refresh the page (F5) to see the correct timer.

---

## Related User Stories

**Belongs to:** US-012: View Round Information (Issue #35) - CLOSED
**Discovered during:** US-017: Claim Prize (Issue #40) - Stage 1, AC-04 testing

---

## Description

After a draw completes (DrawCompleted event) and a new round begins:

**What works (auto-refreshes):**
- ✅ Prize Pool updates to 0 ETH
- ✅ Entries Count updates to 0
- ✅ Unclaimed Prize (green card) appears for winner

**What doesn't work:**
- ❌ Timer shows `0:0:0` and does not start counting down
- ❌ User must manually refresh page (F5) to see correct timer

---

## Steps to Reproduce

1. Enter raffle (local Anvil testnet)
2. **Do NOT refresh the browser**
3. Wait for entry window to close
4. Execute `make complete-draw`
5. Observe frontend without refreshing

**Expected:** Timer starts counting down new round (e.g., 4:59)
**Actual:** Timer displays `0:0:0` and does not update

---

## Impact

**Severity:** Low (cosmetic)
**User Impact:** User sees incorrect timer but can still use the application normally
**Workaround:** Refresh page (F5)

---

## Scope Analysis

- Timer is part of **US-012** which is marked as DONE
- This is a **regression** - functionality that should work, doesn't
- **NOT in scope** of US-017 (Claim Prize)
- Bug discovered "incidentally" during US-017 testing

---

## Decision Required

Product Owner should decide:

- **Option A:** Create new bug issue (linked to US-012)
- **Option B:** Include in current PR (Issue #40)
- **Option C:** Add to backlog
- **Option D:** Won't fix (low priority)

---

## Test Evidence

- Contract state: ✅ New round correctly started (verified via `getEntryDeadline()`)
- Frontend state: ❌ Timer hook not refreshing after DrawCompleted event
- Other data: ✅ All other fields refresh correctly (Prize Pool, Entries, Unclaimed Prize)

---

## Environment

- Local Anvil testnet
- Contract: 0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6
- Browser: [Not specified in testing]
- Date discovered: 2026-01-27
