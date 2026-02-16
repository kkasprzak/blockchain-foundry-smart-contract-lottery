# UX Spec: Multi-Phase Claim Prize Transaction Feedback

**Issue:** #77
**Component:** `YourWinningsCard` (right sidebar)

## Problem

After clicking "CLAIM NOW", the user sees only "CLAIMING..." for ~40 seconds. They don't know:
- Whether they need to act (open MetaMask)
- Whether the transaction is in progress on blockchain
- Whether it succeeded

## Solution: 3-Phase Button States

Replace the single "CLAIMING..." state with three distinct phases that map to the blockchain transaction lifecycle.

## State Machine

```
                    click
    [IDLE] ─────────────────→ [WALLET]
  "CLAIM NOW"               "CONFIRM IN WALLET..."
      ↑                          │
      │ error/reject             │ wallet signed
      ←──────────────────────────┤
      │                          ↓
      │                    [CONFIRMING]
      │                   "CONFIRMING..."
      │                   + Etherscan link
      │                          │
      │ tx reverted              │ tx confirmed
      ←──────────────────────────┤
                                 ↓
                            [CLAIMED]
                           "CLAIMED!"
                           gold flash
                                 │
                                 │ 3 seconds
                                 ↓
                            [IDLE / 0 ETH]
```

---

## Phase 1: Wallet Signing

**Trigger:** Immediately after clicking "CLAIM NOW"

```
╔═══════════════════════════╗
║  CONFIRM IN WALLET...     ║  ← disabled, pulsing glow
╚═══════════════════════════╝
```

- **Button text:** `CONFIRM IN WALLET...`
- **Button state:** disabled, `opacity: 0.85`
- **Gradient:** Same emerald as current (no color change)
- **Animation:** Soft `pulse` on box-shadow only (glow breathes in/out, 2s cycle). This signals "waiting for you" without being aggressive. Do NOT pulse the text itself.

**Why this text:** User immediately knows they need to open MetaMask and sign. "CONFIRM IN WALLET" is an instruction, not a status.

## Phase 2: Blockchain Confirmation

**Trigger:** User signed in MetaMask, transaction submitted to blockchain

```
╔═══════════════════════════╗
║  ◌ CONFIRMING...          ║  ← disabled, shimmer gradient
╚═══════════════════════════╝
  View transaction ↗             ← new: Etherscan link
```

**Button:**
- **Text:** `CONFIRMING...` with a small CSS spinner before it
- **Spinner:** `border-2 border-purple-950/30 border-t-purple-950 rounded-full w-4 h-4 animate-spin`
- **Animation:** Shimmer effect on button gradient — `background-size: 200%`, `background-position` animates `-200% → 200%` over 2s linear infinite. Gives "work in progress" feel.
- **Button state:** disabled, `opacity: 0.85`

**Etherscan link:**
- **Position:** Centered below button, `margin-top: 8px`
- **Text:** `View transaction ↗` (with `ExternalLink` icon from lucide, 12px)
- **Color:** `text-emerald-300/80` → `hover:text-emerald-200`
- **Typography:** `text-sm font-bold`
- **Behavior:** Opens `{explorerBaseUrl}/tx/{txHash}` in new tab
- **Entrance:** Fade in with `opacity 0→1` over 300ms ease-out
- **Security:** `target="_blank" rel="noopener noreferrer"`

**Why the link:** Blockchain transactions are opaque. The link gives the user independent verification and builds trust. It also reduces "is it stuck?" anxiety.

## Phase 3: Success

**Trigger:** Transaction confirmed on blockchain

```
╔═══════════════════════════╗
║  ✓ CLAIMED!               ║  ← GOLD gradient, celebration glow
╚═══════════════════════════╝
```

- **Text:** `CLAIMED!` with checkmark icon (`Check` from lucide) before it
- **Color shift:** Gradient changes from emerald to **amber/gold** — `from-amber-400 via-yellow-300 to-amber-400`. This matches the casino celebration theme (golden header border, falling coins).
- **Glow:** `shadow-[0_0_30px_rgba(251,191,36,0.8)]`
- **Border:** `border-amber-200`
- **Text color:** `text-purple-950` (dark on gold — same as current)
- **Button state:** disabled
- **Etherscan link:** Disappears (no longer needed)
- **Duration:** Visible for **3 seconds**, then card transitions to the refetched state (0 ETH)

**Why gold:** Emerald = in progress. Gold = celebration/win. This distinction is already established in the app (golden header, golden wheel border, golden "MEGA RAFFLE" text).

## Error State: Wallet Rejection

**Trigger:** User rejects transaction in MetaMask

```
╔═══════════════════════════╗
║     CLAIM NOW             ║  ← returns to active state
╚═══════════════════════════╝

┌───────────────────────┐ ×
│ User rejected the     │
│ request               │
└───────────────────────┘
```

**No changes needed.** Existing red error box with dismiss button works correctly. Button returns to "CLAIM NOW" and is re-enabled.

---

## Animation Inventory

| Phase | Element | Animation | Duration | Easing | New CSS? |
|-------|---------|-----------|----------|--------|----------|
| Wallet | Button glow | `pulse` on box-shadow | 2s | ease-in-out | No (Tailwind built-in) |
| Confirming | Spinner icon | `spin` | 1s | linear | No (Tailwind built-in) |
| Confirming | Button gradient | `shimmer` (bg-position) | 2s | linear | **Yes** |
| Confirming | Etherscan link | `fade-in` (opacity) | 300ms | ease-out | **Yes** (or inline style) |
| Claimed | Color transition | emerald → gold | 300ms | ease-out | No (CSS transition) |

**New `@keyframes shimmer`:**
```css
@keyframes shimmer {
  0% { background-position: -200% center; }
  100% { background-position: 200% center; }
}
```

---

## Accessibility

- Button `disabled` attribute active throughout all three phases (prevents double-click)
- Add `aria-live="polite"` on the button text container so screen readers announce phase changes
- Etherscan link: `rel="noopener noreferrer"` for security
- Color is never the sole state indicator — text always changes alongside color
- Contrast: dark purple text on gold/emerald backgrounds exceeds WCAG AA (4.5:1)

---

## Implementation Guidance

### Data already available

`useContractWrite` hook already tracks the granular states internally:

| Internal variable | Maps to | Currently exposed as |
|-------------------|---------|---------------------|
| `isWritePending` | Phase 1 (wallet signing) | Merged into `isPending` |
| `isConfirming` | Phase 2 (blockchain confirmation) | Merged into `isPending` |
| `isConfirmed` | Phase 3 trigger | `isSuccess` |
| `txHash` | Etherscan link URL | `hash` |

The core change is **exposing these granular states** instead of only the merged `isPending`.

### Files to modify

1. **`useContractWrite.ts`** — Expose `isWaitingForSignature` (`= isWritePending`) and `isWaitingForConfirmation` (`= isConfirming`) alongside existing `isPending`
2. **`useClaimPrize.ts`** — Forward the two new granular states + `hash`
3. **`YourWinningsCard.tsx`** — Multi-phase button text, shimmer animation, Etherscan link, gold success state
4. **`RafflePage.tsx`** — Wire up granular states, add `showClaimSuccess` flash logic (3s timeout, same pattern as existing `showEntrySuccess`), derive `explorerBaseUrl` from target chain config

### Explorer URL

Derive from wagmi chain config: `sepolia.blockExplorers.default.url` → `https://sepolia.etherscan.io`. For local Anvil chain (no explorer), conditionally hide the Etherscan link.

### Success flash timing

Follow same pattern as `showEntrySuccess` / `flashEntrySuccess` in RafflePage:
1. `isClaimSuccess` → set `showClaimSuccess = true`, start 3s timer
2. During flash, force card to render in "has prize" layout (override `hasUnclaimedPrize`)
3. After 3s → `showClaimSuccess = false`, refetched data naturally shows 0 ETH

Use a ref to prevent processing the same success event twice. Reset the ref in `handleClaimPrize`.

### Props change for YourWinningsCard

Remove: `isClaimPending`

Add: `isWaitingForSignature`, `isWaitingForConfirmation`, `showClaimSuccess`, `txHash`, `explorerBaseUrl`

Button text derivation:
```
showClaimSuccess        → "CLAIMED!"
isWaitingForSignature   → "CONFIRM IN WALLET..."
isWaitingForConfirmation → "CONFIRMING..."
default                 → "CLAIM NOW"
```

---

## Future: Consistency with Enter Raffle (OPT-02)

This design creates a reusable **multi-phase feedback pattern**. The same pattern can later be applied to `EntryFeeCard` to replace its simple "PENDING..." state:

| Phase | Claim Prize | Enter Raffle (future) |
|-------|------------|----------------------|
| Wallet | CONFIRM IN WALLET... | CONFIRM IN WALLET... |
| Confirming | CONFIRMING... + link | CONFIRMING... + link |
| Success | CLAIMED! (gold) | ENTERED! (emerald) |

No action needed now — this is a future enhancement.
