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

## We practice TDD

- Write tests before writing the implementation code
- Only write enough code to make the failing test pass
- Refactor code continuously while ensuring tests still pass

### TDD Implementation Process

- Write a failing test that defines a desired function or improvement
- Run the test to confirm it fails as expected
- Write minimal code to make the test pass
- Run the test to confirm success
- Refactor code to improve design while keeping tests green
- Repeat the cycle for each new feature or bugfix