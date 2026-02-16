# UX Spec: Separate Unclaimed Prize from Current Round Context

**Issue:** #78
**Decision:** Option A — move unclaimed prize to right sidebar

## Problem

Two ETH amounts displayed in close proximity cause user confusion:
- Full-width banner at top: "YOU WON! Unclaimed Prize: 0.05 ETH"
- Left sidebar card: "PRIZE POOL: 0.04 ETH"

Users think the amounts should match, suspect fees were deducted, or believe something is broken. The unclaimed prize is a sum from past rounds and has no relation to the current prize pool.

## Solution: Move to Right Sidebar

Remove the full-width `UnclaimedPrizeBanner` from above the grid. Replace it with a new card in the **right sidebar**, below `PlayerStatsCard`.

### Information Architecture

```
LEFT SIDEBAR (Game State)     CENTER        RIGHT SIDEBAR (Player Context)
├── Prize Pool  ← current     Wheel         ├── Current Round
├── Time Left                               ├── Your Stats
├── Entry Fee                               └── Your Winnings ← past (NEW)
```

Left = "what's happening in the game" (present tense).
Right = "about me as a player" (personal context).
Prize pool and winnings sit on **opposite sides of the screen**.

### Layout Change in RafflePage

**Before:**
```
[UnclaimedPrizeBanner — full width, above grid]
[grid: left sidebar | wheel | right sidebar]
```

**After:**
```
[grid: left sidebar | wheel | right sidebar]
                                └── CurrentRoundCard
                                └── PlayerStatsCard
                                └── YourWinningsCard (conditional)
```

No full-width banner. The card renders conditionally only when `hasUnclaimedPrize` is true.

## Card Design: "YOUR WINNINGS"

### Visual Spec

```
┌─────────────────────────────┐
│ 🏆 YOUR WINNINGS            │  title row
│                             │
│      0.05 ETH               │  amount (large)
│      from past rounds       │  subtitle
│                             │
│  ┌─────────────────────┐    │
│  │   CLAIM NOW          │    │  CTA button
│  └─────────────────────┘    │
│                             │
│  [error message area]       │  conditional, same as current
└─────────────────────────────┘
```

### Styling Rules

Follow existing card conventions from the codebase:

| Property | Value | Rationale |
|----------|-------|-----------|
| Border | `border-4 border-emerald-400` | Matches win/success color scheme |
| Background | `bg-gradient-to-br from-purple-900/70 to-violet-900/70 backdrop-blur-sm` | Same as all sidebar cards |
| Shadow/Glow | `shadow-[0_0_30px_rgba(52,211,153,0.4)]` | Emerald glow, same intensity as EntryFeeCard |
| Inner gradient | `bg-gradient-to-br from-emerald-400/5 via-transparent to-purple-600/10` | Consistent with other cards |

### Content Details

**Title row:**
- Icon: `Trophy` from lucide-react (same icon as current banner)
- Text: "YOUR WINNINGS" — matches naming convention of "YOUR STATS" card above
- Styling: `text-emerald-300 text-xl font-black` (consistent with other card titles)

**Amount:**
- Text: `{unclaimedPrize} ETH`
- Styling: `text-4xl font-black text-emerald-300 drop-shadow-[0_0_15px_rgba(52,211,153,0.8)]`
- Same size as Entry Fee amount display

**Subtitle:**
- Text: "from past rounds"
- Styling: `text-sm text-purple-300 font-bold`
- This line is the key UX differentiator — eliminates confusion with current prize pool

**CTA Button:**
- Text: "CLAIM NOW" (while idle) / "CLAIMING..." (while pending)
- Full width within the card
- Styling: emerald gradient, same as current claim button but sized to fit sidebar
- `bg-gradient-to-r from-emerald-400 via-green-300 to-emerald-400`
- `text-purple-950 font-black`
- `hover:scale-105 transition-all rounded-xl`
- Add subtle `animate-pulse` on the glow to draw attention

**Error message:**
- Same pattern as existing error messages in EntryFeeCard and current UnclaimedPrizeBanner
- Red background, dismiss button

### Animation

- Card glow: `animate-pulse` on the emerald shadow (subtle attention draw)
- Consistent with how other important cards use pulse (Prize Pool "JACKPOT!" text, countdown colons)
- No flash animation — reserve that for the Enter Raffle CTA only

## What to Remove

- Delete the `UnclaimedPrizeBanner` component (`frontend/src/components/raffle/UnclaimedPrizeBanner.tsx`)
- Remove its usage from `RafflePage.tsx` (lines 194-202)
- Remove its import

## What to Create

- New component: `frontend/src/components/raffle/YourWinningsCard.tsx`
- Same props interface as current `UnclaimedPrizeBanner` (unclaimedPrize, isClaimPending, claimErrorMessage, onClaim, onDismissError)

## What to Modify

- `RafflePage.tsx`: Add `YourWinningsCard` to the right sidebar section, after `PlayerStatsCard`, wrapped in the same `hasUnclaimedPrize` conditional

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| No unclaimed prize | Card not rendered, no empty space (same as any conditional card) |
| Claim in progress | Button shows "CLAIMING...", disabled state |
| Claim error | Error message appears below button with dismiss |
| Claim success | Card disappears after `refetchUnclaimedPrize` returns zero |

## Acceptance Criteria Mapping

- **AC1** (visual separation): Prize pool on left, winnings on right — maximum physical separation
- **AC2** (clear distinction): Different card titles ("PRIZE POOL" vs "YOUR WINNINGS"), different colors (amber vs emerald), subtitle "from past rounds", opposite sides of screen
- **No layout shift**: Conditional card in sidebar, no full-width element appearing/disappearing
