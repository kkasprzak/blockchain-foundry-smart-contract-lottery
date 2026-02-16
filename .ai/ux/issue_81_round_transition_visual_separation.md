# UX Spec: Visual Separation Between Raffle Rounds

**Issue:** #81

## Problem

When a round ends, data refreshes silently and instantly — round number changes, player list clears, timer restarts, stats reset. The user has no moment to absorb what happened. The page looks identical between round #5 and round #6.

## Core Principle: Frozen State + User-Controlled Transition

The entire UI stays **frozen on the old round's data** during the drawing and after the result is shown. The user explicitly closes the round result to transition to the new round. This creates a clear "curtain call" moment between rounds.

---

## State Timeline

```
 OPEN ROUND                  DRAWING                    RESULT SHOWN              NEW ROUND
─────────────────────┬──────────────────────┬──────────────────────────┬──────────────────────
 Timer counting      │ Timer: frozen        │ Timer: frozen            │ Timer: starts
 Players visible     │ Players: frozen      │ Players: frozen          │ Players: cleared
 Stats visible       │ Stats: frozen        │ Stats: frozen            │ Stats: reset
 Round #5            │ Round #5             │ Round #5                 │ Round #6
 Prize Pool: 0.5 ETH│ Prize Pool: 0.5 ETH  │ Prize Pool: 0 ETH       │ Prize Pool: 0 ETH
 Your Winnings: —    │ Your Winnings: —     │ Your Winnings: 0.5 ETH  │ Your Winnings: 0.5 ETH
 Entry: active       │ Entry: DISABLED      │ Entry: DISABLED          │ Entry: active
                     │                      │                          │
                     │ "DRAWING..."         │ Round Result Banner      │
                     │ Wheel spinning       │ (green, with close btn)  │
                     │                      │                          │
                     ↑                      ↑                          ↑
               timer hits 0          wheel animation ends       user clicks CLOSE
```

---

## What Updates When

### On Wheel Animation Complete

These two values update **the moment the wheel stops spinning**, before the banner appears:

| Component | Change | Why |
|-----------|--------|-----|
| **Prize Pool** | Resets to 0 | The pot was awarded — visually communicates "this prize is gone" |
| **Your Winnings** | Updates (shows new claimable prize if you won) | The user immediately sees if they gained something |

### On Banner Close (User Clicks CLOSE)

Everything else refreshes **only when the user dismisses the round result**:

| Component | Change | Why |
|-----------|--------|-----|
| **Round Number** | Increments (e.g. #5 → #6) | New round begins |
| **Player List** | Clears | New round has no players yet |
| **Player Stats** | Resets (entries: 0, win chance: 0%) | User's stats for the new round |
| **Timer** | Starts counting down | New round countdown begins |
| **Entry Fee / Enter Raffle** | Becomes active | User can now enter the new round |

### During Drawing (Wheel Spinning)

Everything is **frozen** on old round data. No component updates. The only visible change is the wheel spinning and the "DRAWING IN PROGRESS" overlay.

Additionally:
- **Entry Fee button**: DISABLED (cannot enter during drawing)
- **Timer**: Frozen at 00:00:00 or hidden (not counting for new round yet)

---

## Round Result Banner (NEW — replaces DrawCompletedAnnouncement)

Appears immediately after the wheel animation completes (or immediately for no-participant rounds). Stays until user explicitly closes it.

### Position

Above the grid, full width — same spot as the current `DrawCompletedAnnouncement`.

### Visual Spec

**Someone else won:**
```
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│  🏆  ROUND #5 COMPLETE                                                  │
│                                                                          │
│      Winner: 0x1234...abcd                                               │
│      Prize: 0.5 ETH                                                     │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐    │
│  │                        NEXT ROUND →                              │    │
│  └──────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

**You won:**
```
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│  🏆  ROUND #5 — YOU WON!                                                │
│                                                                          │
│      Prize: 0.5 ETH                                                     │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐    │
│  │                        NEXT ROUND →                              │    │
│  └──────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

**No participants:**
```
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│  🏆  ROUND #5 — No participants                                         │
│                                                                          │
│      Round reset                                                         │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐    │
│  │                        NEXT ROUND →                              │    │
│  └──────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

### Color Scheme: Green

The user specified a green banner. Use the emerald scheme consistently (same one used in "You won" and "Your Winnings" throughout the app):

| Property | Value |
|----------|-------|
| Border | `border-4 border-emerald-400` |
| Background | `bg-gradient-to-r from-emerald-900/95 via-green-900/95 to-emerald-900/95 backdrop-blur-md` |
| Shadow | `shadow-[0_0_50px_rgba(52,211,153,0.6)]` |
| Inner glow | `from-emerald-400/10 via-transparent to-emerald-400/10 animate-pulse` |
| Icon bg | emerald gradient, same as existing announcement trophy icon |

### Content Rules

| Outcome | Title (line 1) | Subtitle (line 2) |
|---------|----------------|-------------------|
| Someone won | `ROUND #X COMPLETE` | `Winner: {truncated address}` + new line + `Prize: {amount} ETH` |
| You won | `ROUND #X — YOU WON!` | `Prize: {amount} ETH` |
| No participants | `ROUND #X — No participants` | `Round reset` |

### Title Styling

- Title: `text-2xl font-black text-emerald-300 drop-shadow-[0_0_15px_rgba(52,211,153,0.8)]`
- Subtitle — winner address: `font-mono font-bold text-lg text-emerald-200`
- Subtitle — prize/reset: `font-mono font-bold text-lg text-amber-300`

### "NEXT ROUND" Button

This is the key interaction — clicking it transitions the user to the new round.

| Property | Value |
|----------|-------|
| Text | `NEXT ROUND →` |
| Width | Full width within the card content |
| Background | `bg-gradient-to-r from-emerald-400 via-green-300 to-emerald-400` |
| Text color | `text-purple-950 font-black text-lg` |
| Border radius | `rounded-xl` |
| Hover | `hover:scale-[1.02] transition-all` |
| Shadow | `shadow-[0_0_20px_rgba(52,211,153,0.5)]` |
| Glow animation | Subtle `animate-pulse` on box-shadow only |

The button label says "NEXT ROUND →" — not "Close" or "Dismiss". It communicates forward momentum: "you're moving to the next round."

### Entrance Animation

- Fade in + slight scale: `opacity 0 → 1, scale(0.98) → scale(1)`
- Duration: 400ms
- Easing: `ease-out`
- The banner should feel like it "settles in" rather than slides or bounces

### No Auto-Dismiss

The banner does **NOT** auto-dismiss. The user must explicitly click "NEXT ROUND →" to proceed. This ensures:
- The user always sees the round result
- The transition to the new round is always a conscious action
- No data changes happen while the user is reading

### No X/Close Button

There is no X button in the corner. The only way to proceed is the "NEXT ROUND →" button. This forces the user to acknowledge the round ended before moving on. It also simplifies the interface — one clear call to action.

---

## Changes to Existing Components

### CurrentRoundCard

Replace the generic "CURRENT ROUND" title with the actual round number:

```
Before:  🎫 CURRENT ROUND
After:   🎫 ROUND #6
```

- Title format: `ROUND #{roundNumber}`
- Styling: same as current (`text-cyan-300 text-xl font-black`)
- This ensures a user who returns mid-round always knows which round is active

### EntryFeeCard

Add a **disabled state** during drawings:

- When a drawing is in progress (from timer hitting 0 until the user closes the round result banner), the Enter Raffle button is disabled
- Currently the "ENTRIES CLOSED" state exists when `isEntryWindowClosed` is true — this is similar but covers the period after the drawing too
- The button should remain in its "ENTRIES CLOSED" state until the user clicks "NEXT ROUND →" on the result banner
- After the banner is closed, the button returns to its normal active state for the new round

### CountdownCard

During the drawing and result phase, the timer should be **frozen**:

- While the wheel is spinning: timer shows `00:00:00` (or the last value before drawing started)
- While the round result banner is showing: timer stays frozen
- After user clicks "NEXT ROUND →": timer begins counting down for the new round

### DrawCompletedAnnouncement

**Remove.** This component is fully replaced by the Round Result Banner. The Round Result Banner covers all three scenarios (someone won, you won, no participants) and adds the round number + "NEXT ROUND" button.

### "DRAWING IN PROGRESS" Overlay

No changes. Still appears when timer hits 0 and entries close. Disappears when the wheel starts spinning (existing behavior).

---

## Complete Flow

### Happy Path: Someone Wins

```
1. Timer hits 0
   → "DRAWING IN PROGRESS" overlay appears
   → Entry fee button: DISABLED

2. DrawCompleted event fires
   → Wheel starts spinning to winner
   → All data stays frozen (old round)

3. Wheel animation completes
   → Prize Pool updates to 0
   → Your Winnings updates (if current user won)
   → Round Result Banner appears:
     "ROUND #5 COMPLETE — Winner: 0x12...ab — Prize: 0.5 ETH"
     [NEXT ROUND →]

4. User clicks "NEXT ROUND →"
   → Banner dismissed
   → Round number: #5 → #6
   → Player list: cleared
   → Stats: reset
   → Timer: starts counting
   → Entry fee: becomes active
```

### No Participants

```
1. Timer hits 0
   → DrawCompleted event fires with winner = 0x0
   → No wheel spin needed

2. Round Result Banner appears immediately:
   "ROUND #5 — No participants — Round reset"
   [NEXT ROUND →]
   → Prize Pool stays at 0 (was already 0)

3. User clicks "NEXT ROUND →"
   → Same refresh as happy path
```

### You Won

```
Same as happy path, but:
- Step 3: Your Winnings card updates to show claimable prize
- Banner shows: "ROUND #5 — YOU WON! — Prize: 0.5 ETH"
- After clicking "NEXT ROUND →", Your Winnings remains visible with the claimable prize
```

---

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| User refreshes page during result banner | Banner is gone (not persisted). Page shows current round state from blockchain — new round is already active on-chain. CurrentRoundCard shows current round number so user has context |
| DrawCompleted fires while user is mid-enter-raffle transaction | Transaction will likely fail (round ended). Entry fee button becomes disabled. Standard error handling applies |
| Multiple DrawCompleted events in quick succession | Each one should be shown sequentially. If a new DrawCompleted fires while the banner is showing, queue it — don't skip rounds |
| User won but doesn't close banner | Your Winnings already shows the prize (updated at wheel complete). Banner stays indefinitely until user clicks "NEXT ROUND →". No time pressure |
| Very fast round (few seconds) | Same flow. The banner forces a pause regardless of round speed |

---

## Acceptance Criteria Mapping

| AC | How it's addressed |
|----|--------------------|
| **AC1**: Visible indication of round transition | Round Result Banner is an unmissable full-width emerald card that blocks the new round until acknowledged. CurrentRoundCard always shows round number |
| **AC2**: Previous round outcome shown before new round | Banner shows winner/prize/round number. All old round data stays visible behind the banner. New round data only appears after user clicks "NEXT ROUND →" |
| **OPT-01**: Non-blocking transition | The banner doesn't block page interaction — but the Entry Fee button is intentionally disabled until the user moves to the next round. The user can still claim prizes, view stats, etc. |
| **OPT-02**: No-winner round | Banner shows "No participants / Round reset" with same "NEXT ROUND →" button |
| **OPT-03**: Rapid consecutive rounds | Each round result is shown sequentially. The banner forces the user to acknowledge each round before the next one appears |
