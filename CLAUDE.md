# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Architecture

This is a Foundry-based Ethereum smart contract project with the following structure:

- **src/**: Smart contract source files (main contracts)
- **test/**: Test files using Foundry's testing framework with forge-std
- **script/**: Deployment and interaction scripts
- **lib/**: Dependencies (forge-std library for testing utilities)
- **foundry.toml**: Project configuration file

## Common Development Commands

### Build and Test
```bash
forge build                    # Compile all contracts
forge test                     # Run all tests
forge test --match-test <name> # Run specific test
forge test -vvv                # Run tests with verbose output
```

### Code Quality
```bash
forge fmt                      # Format Solidity code
forge snapshot                 # Generate gas usage snapshots
```

### Local Development
```bash
anvil                          # Start local Ethereum node
```

### Deployment
```bash
forge script script/<ScriptName>.s.sol:<ContractName> --rpc-url <rpc_url> --private-key <private_key>
```

### Blockchain Interaction
```bash
cast <subcommand>              # Swiss army knife for EVM interactions
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
- **Errors:** ContractName__ErrorName (`Raffle__SendMoreToEnterRaffle`, `Token__InsufficientBalance`)
- **Functions:** mixedCase (`getBalance`, `transfer`)
- **Variables:** mixedCase (`totalSupply`, `balancesOf`)
- **Constants:** ALL_UPPERCASE (`MAX_BLOCKS`, `TOKEN_NAME`)
- **Modifiers:** mixedCase (`onlyBy`, `onlyAfter`)
- **Enums:** CapWords (`TokenGroup`, `Frame`)

**Guidelines:**
- Avoid single letters like `l`, `O`, `I`
- Use `_leadingUnderscore` for internal/private functions
- Use `trailingUnderscore_` to avoid naming collisions
- Use `s_` for storage/state variables (can be modified after deployment)
- Use `i_` for immutable variables (set once in constructor, never changed)

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

## 🚨 CRITICAL: Test-Driven Development (TDD) is MANDATORY 🚨

**THIS PROJECT STRICTLY FOLLOWS TDD. NO EXCEPTIONS.**

### Why TDD is Non-Negotiable
- Tests define the contract's behavior and serve as living documentation
- Writing tests first prevents bugs and ensures correct implementation
- Tests act as safety nets during refactoring
- TDD leads to better contract design and modularity

### TDD Implementation Process - MUST FOLLOW THESE STEPS

**IMPORTANT: You MUST follow this exact process for EVERY feature, function, or bug fix:**

#### Step 1: Write a Failing Test FIRST
```solidity
// ALWAYS start by writing a test that fails
function test_TransferTokens() public {
    // Arrange
    uint256 amount = 100;
    address recipient = address(0x1);

    // Act & Assert
    vm.expectRevert(Token__InsufficientBalance.selector);
    token.transfer(recipient, amount);
}
```

#### Step 2: Run Test to Confirm Failure
```bash
forge test --match-test test_TransferTokens -vvv
# MUST see the test fail before proceeding
```

#### Step 3: Write MINIMAL Implementation
```solidity
// Only write enough code to make the test pass
function transfer(address to, uint256 amount) external {
    if (balances[msg.sender] < amount) {
        revert Token__InsufficientBalance();
    }
    // Implementation continues...
}
```

#### Step 4: Run Test to Confirm Success
```bash
forge test --match-test test_TransferTokens
# Test MUST pass before continuing
```

#### Step 5: Refactor (If Needed)
- Improve code quality while keeping tests green
- Run tests after each refactoring change
- Never skip this step - clean code is crucial

#### Step 6: Repeat for Next Feature
- Each new requirement starts with a new failing test
- Never write production code without a failing test first

### TDD Checklist - Use This Every Time

Before writing ANY production code, ask yourself:
- [ ] Have I written a failing test for this feature?
- [ ] Did I run the test and confirm it fails?
- [ ] Am I writing the minimum code needed to pass?
- [ ] Did I run the test again to confirm it passes?
- [ ] Have I refactored while keeping tests green?

### Common TDD Patterns in Solidity

#### Testing State Changes
```solidity
function test_StateChange() public {
    // Write this test BEFORE implementing the function
    uint256 initialValue = contract.getValue();
    contract.updateValue(42);
    assertEq(contract.getValue(), 42);
}
```

#### Testing Events
```solidity
function test_EventEmission() public {
    // Write this test BEFORE implementing the event
    vm.expectEmit(true, true, false, true);
    emit ValueUpdated(42);
    contract.updateValue(42);
}
```

#### Testing Reverts
```solidity
function test_RevertCondition() public {
    // Write this test BEFORE implementing the revert
    vm.expectRevert(Contract__InvalidInput.selector);
    contract.doSomething(0);
}
```

### Red-Green-Refactor Mantra

**Remember: RED → GREEN → REFACTOR**
1. **RED**: Write a test that fails
2. **GREEN**: Make it pass with minimal code
3. **REFACTOR**: Improve the code while tests stay green

### TDD Violations - What NOT to Do

❌ **NEVER**:
- Write implementation code before tests
- Create all the classes before writing the first failing test.
- Write multiple features without tests
- Skip the refactoring step
- Write tests after implementation
- Ignore failing tests
- Add unused parameters "just in case"

✅ **ALWAYS**:
- Write ONE simple failing test that naturally fails because the classes don't exist.
- Write ONE test at a time
- Let future tests drive additional requirements
- Keep tests simple and focused
- Run tests frequently
- Refactor with confidence

### Example TDD Workflow

```bash
# 1. Create test file first
touch test/MyContract.t.sol

# 2. Write failing test
# (edit test file with failing test)

# 3. Run test to see it fail
forge test --match-test test_MyFeature -vvv

# 4. Create implementation file
touch src/MyContract.sol

# 5. Write minimal code to pass

# 6. Run test to see it pass
forge test --match-test test_MyFeature

# 7. Refactor if needed

# 8. Run all tests to ensure nothing broke
forge test

# 9. Use Triangulation - Add more test cases to drive implementation forward
# Write additional failing tests that force you to generalize the implementation
# This prevents hardcoded solutions and ensures robust, complete functionality
```

### Final TDD Reminder

**If you find yourself writing production code without a failing test, STOP immediately and write the test first. This is not a suggestion—it's a requirement for this project.**

## 🤝 AI-Human Pair Programming Model

This project uses an AI-Human pair programming approach where:

**AI Assistant (Driver)**: Writes the actual code based on navigator guidance
**Human Developer (Navigator)**: Provides strategic direction, reviews code, guides decisions

### Role Definitions

#### Navigator (Human) Responsibilities:
- Define requirements and acceptance criteria
- Guide architectural decisions and design patterns
- Review code quality and suggest improvements
- Direct the TDD process and test strategy
- Make high-level strategic decisions
- Catch edge cases and potential issues
- Ensure code follows project conventions

#### Driver (AI) Responsibilities:
- Write failing tests based on navigator guidance
- Implement minimal code to pass tests
- Run tests and report results
- Refactor code while keeping tests green
- Follow coding conventions and style guides
- Execute commands and report outcomes
- Suggest implementation alternatives when appropriate

### Communication Patterns

#### Effective Navigator Commands:
```
"Let's start with a failing test for raffle entry validation"
"Run the test to confirm it fails, then implement minimal solution"
"Now let's refactor that validation logic for better readability"
"Add a test case for the edge case where entry fee is zero"
"Check if there are any gas optimizations we can make"
```

#### Driver Responses:
- Acknowledge the direction
- Write the requested code
- Run tests and report results
- Ask clarifying questions when guidance is unclear
- Suggest alternatives when encountering issues

### Integration with TDD Workflow

The pair programming model enhances our TDD process:

1. **Navigator**: "We need to test raffle entry with insufficient funds"
2. **Driver**: *Writes failing test and runs it*
3. **Navigator**: "Good, now implement just enough to make it pass"
4. **Driver**: *Implements minimal solution and confirms test passes*
5. **Navigator**: "Let's refactor for better error handling"
6. **Driver**: *Refactors while keeping tests green*

### Best Practices for Effective Collaboration

#### For the Navigator (Human):
- Be specific about requirements and expectations
- Provide context for architectural decisions
- Review code output and provide feedback
- Guide the pace - don't rush through important decisions
- Ask for alternatives when unsure about implementation
- Focus on the "why" behind requirements

#### For the Driver (AI):
- Always confirm understanding of requirements
- Write clean, well-structured code following conventions
- Run tests frequently and report all results
- Ask questions when requirements are ambiguous
- Suggest improvements when patterns emerge
- Maintain focus on minimal implementations

### Session Flow Example

```
Navigator: "Let's implement a new feature for automatic raffle winner selection"

Driver: "I'll create a todo list for this feature and start with a failing test.
        What should be the trigger condition for winner selection?"

Navigator: "When the raffle duration expires and we have at least one participant"

Driver: *Creates failing test for time-based winner selection*
        "Test created and failing. Should I implement the time check first?"

Navigator: "Yes, but keep it simple. Just check if current time > end time"

Driver: *Implements minimal time validation*
        "Implementation complete, test now passes. Ready for the next requirement?"
```

### Communication Guidelines

- **Be Clear**: Use specific, actionable language
- **Stay Focused**: Address one requirement at a time
- **Confirm Understanding**: AI should repeat back requirements
- **Report Progress**: AI should always report test results
- **Ask Questions**: Both parties should clarify when unsure
- **Celebrate Success**: Acknowledge when tests pass and features work

This collaborative approach leverages the speed and consistency of AI implementation with the strategic thinking and oversight of human expertise, ensuring high-quality, well-tested smart contract code.