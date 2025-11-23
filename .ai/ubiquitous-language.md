# Ubiquitous Language

Domain-Driven Design (DDD) glossary of business concepts used in the Raffle project.

## Core Concepts

### Raffle
The entire lottery system that manages the game. It coordinates player participation, time-based rules, prize distribution, and ensures fair winner selection across multiple game cycles.

### Drawing
The process of randomly selecting a winner from all participants. This is a specific moment within a round where the system determines who wins the prize pool.

**Drawing lifecycle:**
1. **Draw starts** - The random selection process begins
2. **Drawing is in progress** - The system is calculating the winner
3. **Draw completes** - Winner is determined and prize is transferred

**Note:** "Drawing" refers to the ongoing selection process, while "draw" is the action itself (e.g., "start a draw").

### Round
A complete cycle of the lottery game from beginning to end. One round encompasses:
1. Entry window opens - Players can join
2. Time interval passes
3. Entry window closes - No more entries allowed
4. Drawing occurs - Winner is selected
5. Prize is distributed
6. System resets for the next round

Each round is independent, with its own:
- Unique round number
- Prize pool (accumulated entry fees)
- List of participants

## Relationships

```
Raffle (the system)
├── Round 1
│   ├── Entry phase
│   ├── Drawing phase
│   └── Completion
├── Round 2
│   └── ...
└── Round N
    └── ...
```

## Key Distinctions

- **Raffle** = The entire system (exists permanently)
- **Round** = One complete game cycle (repeatable)
- **Drawing** = The winner selection moment (happens once per round)
