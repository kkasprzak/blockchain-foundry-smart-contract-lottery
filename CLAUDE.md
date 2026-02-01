# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## User Story Status Tracking

All User Stories in `.ai/prd.md` are tagged with their current status using the following labels:

- **[BACKLOG]** - Not yet ready for development; may need refinement or dependencies
- **[READY]** - Fully defined and ready to start development; can be picked up immediately
- **[IN PROGRESS]** - Currently being worked on; tracked as an active GitHub issue
- **[DONE]** - Implementation completed, tested, and merged to main

## QA Testing Mode

When the user says **"continue testing as QA"**, **"test as QA"**, or **"act as QA tester"**:
- Read `.ai/qa-testing-protocol.md` for complete QA testing guidelines
- Follow the protocol strictly - you are a Manual QA Tester, NOT a developer
- Test behavior from user perspective, never analyze source code

## Lessons Learned

When the user says **"load lessons learned"** or **"lessons"**:
- Read `.ai/lessons-learned.md` for accumulated project knowledge and tips

## Browser Automation

Use `agent-browser` for web automation. Run `agent-browser --help` for all commands.

Core workflow:
1. `agent-browser open <url>` - Navigate to page
2. `agent-browser snapshot -i` - Get interactive elements with refs (@e1, @e2)
3. `agent-browser click @e1` / `fill @e2 "text"` - Interact using refs
4. Re-snapshot after page changes

## Project Architecture

This is a multi-component blockchain project with the following structure:

### Smart Contracts (Foundry)
- **src/**: Smart contract source files (main contracts)
- **test/**: Test files using Foundry's testing framework with forge-std
- **script/**: Deployment and interaction scripts
- **lib/**: Dependencies (forge-std library for testing utilities)
- **foundry.toml**: Project configuration file

### Indexer (Ponder)
- **indexer/**: Ponder-based blockchain indexer
- **Package manager**: **pnpm** (NOT npm)
- **Purpose**: Index blockchain events and provide API via Hono

### Frontend (React)
- **frontend/**: React-based user interface
- **Package manager**: **pnpm** (NOT npm)
- **Purpose**: Web3 application for interacting with smart contracts

## Common Development Commands

### Smart Contracts (Foundry)

**Build and Test:**
```bash
forge build                    # Compile all contracts
forge test                     # Run all tests
forge test --match-test <name> # Run specific test
forge test -vvv                # Run tests with verbose output
```

**Code Quality:**
```bash
forge fmt                      # Format Solidity code
forge snapshot                 # Generate gas usage snapshots
```

**Local Development:**
```bash
anvil                          # Start local Ethereum node
```

**Deployment:**
```bash
forge script script/<ScriptName>.s.sol:<ContractName> --rpc-url <rpc_url> --private-key <private_key>
```

**Blockchain Interaction:**
```bash
cast <subcommand>              # Swiss army knife for EVM interactions
```

### Indexer (Ponder)

**CRITICAL: Always use pnpm, NOT npm**

```bash
cd indexer                     # Navigate to indexer directory
pnpm install                   # Install dependencies
pnpm dev                       # Start development server
pnpm start                     # Start production server
pnpm lint                      # Run ESLint
pnpm typecheck                 # Run TypeScript type checking
```

### Frontend (React)

**CRITICAL: Always use pnpm, NOT npm**

```bash
cd frontend                    # Navigate to frontend directory
pnpm install                   # Install dependencies
pnpm dev                       # Start development server
pnpm build                     # Build for production
pnpm lint                      # Run ESLint
pnpm typecheck                 # Run TypeScript type checking
```

## Testing Framework

Tests inherit from `forge-std/Test.sol` and use:

- `setUp()` function for test initialization
- `assertEq()`, `assertTrue()`, etc. for assertions
- `testFuzz_` prefix for fuzz testing
- `vm.` cheatcodes for blockchain state manipulation

## Script Architecture

Deployment scripts inherit from `forge-std/Script.sol` and use:

- `setUp()` for script initialization
- `run()` as the main execution function
- `vm.startBroadcast()` and `vm.stopBroadcast()` to wrap deployment transactions

## Coding Conventions

### Naming Conventions

Follow the official Solidity style guide naming conventions:

**Standard Naming Styles:**

- **Contracts/Libraries:** CapWords (`SimpleToken`, `SmartBank`)
- **Structs:** CapWords (`MyCoin`, `Position`)
- **Events:** CapWords (`Deposit`, `Transfer`)
- **Errors:** ContractName**ErrorName (`Raffle**SendMoreToEnterRaffle`, `Token\_\_InsufficientBalance`)
- **Functions:** mixedCase (`getBalance`, `transfer`)
- **Variables:** mixedCase (`totalSupply`, `balancesOf`)
- **Constants:** ALL_UPPERCASE (`MAX_BLOCKS`, `TOKEN_NAME`)
- **Immutables:** SCREAMING_SNAKE_CASE (`ENTRANCE_FEE`, `INTERVAL`) - set once in constructor
- **Modifiers:** mixedCase (`onlyBy`, `onlyAfter`)
- **Enums:** CapWords (`TokenGroup`, `Frame`)

**Guidelines:**

- Avoid single letters like `l`, `O`, `I`
- Use `_leadingUnderscore` for internal/private functions
- Use `trailingUnderscore_` to avoid naming collisions
- **State variables:** mixedCase (`players`, `raffleState`, `prizePool`)

### Order of Layout

Follow the official Solidity style guide for contract layout:

**File Level Order:**

1. Pragma statements
2. Import statements
3. Events
4. Errors
5. Interfaces
6. Libraries
7. Contracts

**Within Contracts:**

1. Type declarations
2. State variables
3. Events
4. Errors
5. Modifiers
6. Functions

**Function Order:**

- constructor
- receive function
- fallback function
- external functions
- public functions
- internal functions
- private functions

Within each visibility group, place `view` and `pure` functions last.

### Code Formatting

Follow these Solidity style guide formatting rules:

**Indentation & Line Length:**

- Use 4 spaces per indentation level (no tabs)
- Maximum 120 characters per line
- UTF-8 or ASCII encoding

**Blank Lines:**

- Two blank lines around top-level contract declarations
- Single blank line between function declarations
- Can omit blank lines between related one-liner functions

**Whitespace:**

- No extraneous whitespace inside parentheses, brackets, or braces
- Single space around operators
- No multiple spaces for alignment
- Single space before opening braces

**Imports:**

- Always place at top of file (after pragma statements)
- Use relative paths (`"./Owned.sol"`)
- Contract/library names should match filenames

**Function Declarations:**

- Opening brace on same line as declaration with single space before
- Closing brace at same indentation level as function declaration
- Long functions: each parameter on own line at function body indentation
- Modifier order: visibility → mutability → virtual → override → custom modifiers

**Control Structures:**

- Single space between control structure and conditional parentheses
- Single space between conditional parentheses and opening brace
- Braces open on same line, close on own line at same indentation
- `else`/`else if` on same line as previous closing brace

**Variable Declarations:**

- Arrays: no space between type and brackets (`uint[] x` not `uint [] x`)
- Mappings: no space between `mapping` and type (`mapping(uint => uint)` not `mapping (uint => uint)`)

**Special Functions:**

- No space before parentheses in `receive()` and `fallback()`

## Gas Optimization

- Use `immutable` keyword for variables that are set once in constructor
- Use `constant` keyword for compile-time constants
- Prefer `uint256` over smaller uints for gas efficiency (unless packing structs)

## Code Quality Anti-Patterns (CRITICAL - NEVER VIOLATE)

These are common mistakes that must be avoided. Violating these rules results in poor code quality and maintainability issues.

### 1. NO Unnecessary Comments

**Rule:** Code must be self-explaining through clear naming and structure.

**WHY:** Comments indicate the code is not self-documenting. If you need comments to explain what code does, the code is poorly written.

**WRONG:**
```solidity
// Round 1: randomWord 0 % 4 = 0 -> player1 (index 0)
assertEq(_runRound(raffle, interval, 0), player1);
```

**CORRECT:**
```solidity
assertEq(_runRound(raffle, interval, 0), player1);
```

The method names `_runRound()` and test structure make the intent clear without comments.

### 2. NO Methods With "AND" in Name

**Rule:** Method names containing "AND" indicate Single Responsibility Principle violation.

**WHY:** A method should do ONE thing. "AND" in the name means it's doing multiple things, violating SRP.

**WRONG:**
```solidity
function _runRoundAndVerifyWinner(Raffle raffle, uint256 interval, uint256 randomWord, address expectedWinner) private {
    // Runs round AND verifies winner - TWO responsibilities
}
```

**CORRECT:**
```solidity
function _runRound(Raffle raffle, uint256 interval, uint256 randomWord) private returns (address) {
    // Only runs round and returns winner - ONE responsibility
}

// In test:
assertEq(_runRound(raffle, interval, 0), player1);  // Verification separate
```

### 3. NO Unnecessary Temporary Variables

**Rule:** If a variable is used exactly once, inline it.

**WHY:** Temporary variables add noise without adding clarity. Direct usage is clearer.

**WRONG:**
```solidity
address winner1 = _runRound(raffle, interval, 0);
assertEq(winner1, player1);
```

**CORRECT:**
```solidity
assertEq(_runRound(raffle, interval, 0), player1);
```

### 4. Command-Query Separation (CQS)

**Rule:** Methods should either DO something (command) OR return data (query), never both.

**WHY:** Mixing commands and queries makes code harder to understand and test. Side effects should be explicit.

**WRONG:**
```solidity
function _runRoundAndVerifyWinner(...) private {
    // Executes round (command) AND asserts result (query) - violates CQS
    address winner = _executeRound();
    assertEq(winner, expectedWinner);  // Assertion inside helper
}
```

**CORRECT:**
```solidity
function _runRound(...) private returns (address) {
    // Command: executes round
    // Query: returns winner data
    return winner;
}

// In test (query/assertion separate):
assertEq(_runRound(raffle, interval, 0), player1);
```

### 5. NO Assertions in Helper Methods

**Rule:** Test helper methods return data, test methods perform assertions.

**WHY:** Helpers with assertions are not reusable. Separating data retrieval from verification makes helpers flexible for different test scenarios.

**WRONG:**
```solidity
function _verifyWinner(address actualWinner, address expectedWinner) private {
    assertEq(actualWinner, expectedWinner);  // Assertion in helper
}
```

**CORRECT:**
```solidity
function _runRound(...) private returns (address) {
    return winner;  // Returns data only
}

// In test:
assertEq(_runRound(...), expectedWinner);  // Assertion in test
```

## Task-Based Development Workflow

### Task Management

- All tasks are tracked as GitHub issues on the project board
- Each issue represents a specific feature, bug fix, or improvement
- Work on one task at a time

### Daily Session Startup Protocol

**When to execute this protocol:**

Execute this startup routine when:
- User asks "what are we working on?" or "what's next?"
- User asks "what should we do today?"
- Beginning of a new session or day
- User mentions starting work

**Protocol (execute these steps in order):**

1. **Check git status and current branch:**
   ```bash
   git status
   ```
   Identify: current branch, issue number from branch name, uncommitted changes

2. **Check active GitHub issues:**
   ```bash
   # Check issues in progress
   gh issue list --json number,title,state,projectItems --limit 20 | jq '.[] | select(.projectItems[]?.status.name == "In progress") | {number, title, status: .projectItems[0].status.name}'

   # If no issues in progress, check all open issues
   gh issue list --state open
   ```
   Look for: issues with "In progress" status first, then the issue matching current branch, or next issue to work on

3. **Run tests to find failing tests (Kent Beck warm start):**
   ```bash
   forge test
   ```
   Look for:
   - Tests marked with TODO
   - Failing tests that serve as entry point for the session
   - This is the "Kent Beck technique" - starting day with a failing test provides immediate direction

4. **Check for existing plan:**
   ```bash
   ls .ai/plans/
   ```
   Look for: plan file matching current issue number (e.g., `issue_9.md` for issue #9)
   - If plan exists: read it to understand the implementation approach and current progress
   - Plans provide continuity between sessions and remind you of design decisions
   - Plan naming convention: `issue_<number>.md`
   - Present plan summary if found

**Present context to user:**

After executing the protocol, present:
- Current branch and related issue number
- **Issue in progress** from GitHub project status
- Status of uncommitted changes
- **Failing test as starting point** (if exists) - emphasize this is a warm start
- **Existing plan** (if found) - summarize key implementation steps and current progress
- List of open issues if starting fresh

**Example output:**

```
Current status:
- Branch: feature/issue-20-remove-duplicate-entry-prevention
- Issue in progress: #20 - Remove duplicate entry prevention to enable multiple entries per player
- Uncommitted changes: test/unit/RaffleTest.t.sol

Tests status:
✓ 32 tests passing
✗ 1 test failing: test_EntryWindowResetsAfterRoundCompletion()
  [FAIL: TODO: Implement entry window reset verification]

Existing plan found: .ai/plans/issue_20.md
- Phase 1: Remove duplicate prevention logic ✓
- Phase 2: Update tests for multiple entries ✓
- Phase 3: Implement entry window reset (IN PROGRESS)
- Phase 4: Integration tests

Perfect! We have a failing test as our starting point (Kent Beck style).
This gives us immediate direction - let's implement the entry window reset verification.
```

**Why this protocol:**

- **Immediate context**: No time wasted figuring out what to do
- **Kent Beck's failing test technique**: Failing test = instant warm start
- **Continuity**: Pick up exactly where previous session left off
- **Persistent plans**: Design decisions and progress preserved across sessions
- **Focus**: Clear next step instead of decision paralysis

### Starting Work on a Task

**IMPORTANT: Never work directly on the `main` branch**

1. **Sync with remote main:**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Create feature branch from origin/main:**
   ```bash
   git checkout -b feature/<descriptive-name>
   ```

   Branch naming examples:
   - `feature/add-roundid-to-raffleentered` (for issue #14)
   - `feature/issue-4-add-round-reset-event`
   - `fix/prize-transfer-error`

3. **Verify branch is based on latest origin/main**

### Working on the Task

- Follow TDD and Pair Programming practices (see skill documentation)
- **Commit frequently** - better to commit often than rarely
  - Commit after completing each logical unit of work
  - Commit BEFORE attempting risky refactoring
  - Use WIP commits if needed - can be cleaned up later with `git rebase`
- Use conventional commit format:
  - `feat:` - new feature
  - `fix:` - bug fix
  - `refactor:` - code refactoring
  - `test:` - adding/updating tests
  - `docs:` - documentation

### Git Safety Protocol

**CRITICAL: Protect your work from accidental loss**

1. **NEVER use `git checkout <file>` without committed work**
   - This permanently deletes uncommitted changes
   - Always commit or stash first

2. **Before risky operations:**
   ```bash
   git add -A
   git commit -m "wip: before risky refactor"
   ```

3. **Safe alternatives to dangerous commands:**
   - Instead of `git checkout <file>` → use `git stash` first
   - Instead of `git reset --hard` → commit first, then reset if needed
   - Use `git stash` to temporarily save work

4. **Recovery options:**
   - If you committed: `git reset --hard <commit-hash>` to go back
   - If you stashed: `git stash pop` to recover
   - If you lost work: check conversation history to recreate

5. **Tool usage warnings:**
   - `replace_all=true` in Edit tool is DANGEROUS
   - Can cause infinite recursion or unexpected replacements
   - Use only for simple, mechanical replacements
   - Test immediately after using `replace_all`

### Creating Pull Request

1. **Pre-push verification (REQUIRED):**

   Run checks for all modified components to catch issues before CI:

   **Smart Contracts (always run if any Solidity files modified):**
   ```bash
   forge test      # All tests must pass
   forge fmt       # Fix any formatting issues
   ```

   **Frontend (run if any files in `frontend/` modified):**
   ```bash
   cd frontend
   pnpm lint       # ESLint must pass
   pnpm build      # TypeScript + build must succeed
   cd ..
   ```

   **Indexer (run if any files in `indexer/` modified):**
   ```bash
   cd indexer
   pnpm lint       # ESLint must pass
   pnpm typecheck  # TypeScript must pass
   cd ..
   ```

   **CRITICAL:** Never push without running these checks - CI will fail otherwise and waste time.

2. **Push feature branch:**
   ```bash
   git push -u origin feature/<branch-name>
   ```

3. **Create PR with GitHub CLI:**
   ```bash
   gh pr create --title "feat: Title description (#issue-number)" --body "..."
   ```

4. **Link to GitHub Issue:**
   - Include `Closes #<issue-number>` in PR description
   - This automatically closes the issue when PR is merged

### Merging Pull Request

**Wait for CI pipeline to pass**, then merge:

```bash
gh pr merge <pr-number> --squash --delete-branch
```

### After Merge

Update local main:

```bash
git checkout main
git pull origin main
```

### Complete Workflow Example

```bash
# Start fresh from main
git checkout main
git pull origin main

# Create feature branch for issue #14
git checkout -b feature/add-roundid-to-raffleentered

# Work on the task (TDD/PP)...
# Commit frequently...
git add -A
git commit -m "feat: add roundNumber to events"

# Push and create PR
git push -u origin feature/add-roundid-to-raffleentered
gh pr create --title "feat: Add roundNumber to events (#14)" \
  --body "Closes #14"

# Wait for pipeline, then merge
gh pr merge 16 --squash --delete-branch

# Return to main
git checkout main
git pull origin main
```

### Key Rules

- ✅ Always create feature branch from latest `origin/main`
- ✅ Link PRs to issues using `Closes #X`
- ✅ Wait for CI pipeline to pass before merging
- ✅ Use squash merge to keep history clean
- ❌ Never work directly on `main` branch
- ❌ Never create branch from local `main` without syncing first
