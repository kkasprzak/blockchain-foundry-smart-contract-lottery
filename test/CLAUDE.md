# Test Guidelines - xUnit Test Patterns

This file documents the test design principles from Gerard Meszaros's "xUnit Test Patterns" book that we apply in this test suite.

## Goals of Test Automation

*"Tests should help us improve quality. Tests should help us understand the SUT. Tests should reduce (and not introduce) risk. Tests should be easy to run. Tests should be easy to write and maintain. Tests should require minimal maintenance as the system evolves around them."*  
— Gerard Meszaros, xUnit Test Patterns (pp. 21-22)

### 1. **Tests Should Help Us Improve Quality**
- **Catch bugs early** - Tests run continuously during development
- **Prevent regressions** - Existing functionality stays working
- **Design feedback** - Hard-to-test code often indicates design problems
- **Documentation** - Tests serve as executable specifications

**Our Implementation:**
- TDD approach ensures quality from the start
- Comprehensive test coverage for all raffle functions
- Edge case testing (insufficient funds, unauthorized access, etc.)

### 2. **Tests Should Help Us Understand the SUT (System Under Test)**
- **Living documentation** - Tests show how the system should behave
- **Usage examples** - Tests demonstrate correct API usage
- **Business rules** - Test names and assertions express domain logic

**Our Implementation:**
- Clear test names: `test_RaffleRevertsWhenYouDontPayEnough`
- Business-focused scenarios: Multiple participants, realistic amounts
- Domain language: `_waitForDrawTime()` instead of technical `vm.warp()`

### 3. **Tests Should Reduce (and Not Introduce) Risk**
- **Reliable tests** - Tests themselves must be bug-free
- **Deterministic results** - Same input always produces same output
- **Isolated tests** - Tests don't depend on each other
- **Fast execution** - Quick feedback loop

**Our Implementation:**
- Independent test cases using fresh contract instances
- Deterministic test data (fixed addresses, amounts)
- No shared state between tests
- Fast Foundry test execution

### 4. **Tests Should Be Easy to Run**
- **Single command** - `forge test` runs all tests
- **No special setup** - Tests work in any environment
- **Clear output** - Pass/fail status immediately visible

**Our Implementation:**
- Standard Foundry test commands
- Self-contained tests with no external dependencies
- Clear test output with descriptive names

### 5. **Tests Should Be Easy to Write and Maintain**
- **Readable code** - Tests are code and need same quality standards
- **Helper methods** - Reduce duplication and complexity
- **Consistent patterns** - Familiar structure across all tests

**Our Implementation:**
- Creation Method pattern for consistent setup
- Test Utility Methods for common operations
- Consistent Four-Phase Test structure
- xUnit patterns for maintainability

### 6. **Tests Should Require Minimal Maintenance**
- **Stable interfaces** - Tests focus on behavior, not implementation
- **DRY principle** - Changes in one place, not scattered throughout
- **Abstraction** - Hide irrelevant details behind meaningful methods

**Our Implementation:**
- Creation Methods hide constructor complexity
- Business-focused assertions that survive refactoring
- Helper methods that encapsulate blockchain-specific operations

## Applied xUnit Test Patterns

### 1. **Creation Method Pattern**
**Principle:** Hide test object creation complexity behind factory methods.

**Implementation:**
```solidity
// Hides irrelevant constructor details for tests that don't care about specific values
function _createValidRaffle() private returns (Raffle) {
    return new Raffle(1 ether, 1);
}

// For tests that need specific entrance fees
function _createRaffleWithEntranceFee(uint256 entranceFee) private returns (Raffle) {
    return new Raffle(entranceFee, 1);
}

// For tests that need specific intervals
function _createRaffleWithInterval(uint256 interval) private returns (Raffle) {
    return new Raffle(1 ether, interval);
}
```

**Benefits:** 
- Tests focus on behavior, not setup details
- Easy maintenance when constructor changes
- Clear test intent

### 2. **"Tests as Specification" Pattern**
**Principle:** Tests should clearly communicate business requirements and expected behavior.

**Implementation:**
- Business-focused test names: `test_RaffleRevertsWhenYouDontPayEnough`
- Domain language in test helpers: `_waitForDrawTime()` instead of `vm.warp()`
- Clear assertion messages that express business rules

### 3. **"Introduce Explaining Variable" Pattern**
**Principle:** Replace magic numbers and unclear expressions with meaningful variable names.

**Before:**
```solidity
raffle.enterRaffle{value: entranceFee / 10}(); // What does /10 mean?
```

**After:**
```solidity
uint256 insufficientPayment = entranceFee / 10; // Clear business relationship
raffle.enterRaffle{value: insufficientPayment}();
```

### 4. **"Verify One Condition per Test" Pattern** 
**Principle:** Each test should verify exactly one condition or behavior.

**Applied to:**
- `test_PickWinnerSelectsWinnerFromParticipants` - Only verifies winner selection
- `test_PickWinnerTransfersPrizeToWinner` - Only verifies prize transfer amount
- `test_PickWinnerEmitsWinnerSelectedEvent` - Only verifies event emission

**Benefits:**
- Clear failure diagnosis
- Focused test purpose
- Easier maintenance

### 5. **Test Utility Method Pattern**
**Principle:** Extract reusable test logic into helper methods.

**Implementation:**
```solidity
function _waitForDrawTime(uint256 timeToWait) private {
    vm.warp(block.timestamp + timeToWait);
}
```

**Benefits:**
- Encapsulates blockchain-specific test operations
- Business-friendly method names
- Reusable across multiple tests

## Test Organization Principles

### Function Ordering
Following Solidity style guide within test contracts:
1. Public test functions (grouped by feature)
2. Private helper functions (`_createValidRaffle`, `_waitForDrawTime`, etc.)

### Test Naming Convention
- `test_[FeatureName][ExpectedBehavior]` 
- Examples:
  - `test_RaffleRevertsWhenYouDontPayEnough`
  - `test_PickWinnerSelectsWinnerFromParticipants`
  - `test_PickWinnerTransfersPrizeToWinner`

### Test Structure - Four Phase Test
1. **Setup/Arrange**: Create test objects and initial conditions
2. **Exercise/Act**: Execute the behavior being tested  
3. **Verify/Assert**: Check the expected outcome
4. **Teardown**: (Handled automatically by test framework)

## Business Domain Focus

### Domain Language in Tests
- Use business terminology in variable names
- Helper methods reflect business operations
- Test names express business rules, not technical implementation

### Realistic Test Scenarios
- Multiple participants in prize distribution tests
- Meaningful amounts and timeframes
- Edge cases that reflect real-world usage

## Guidelines for New Tests

1. **Start with Creation Methods** - Use existing factory methods when possible
2. **One Assertion Per Test** - Keep tests focused
3. **Business Language** - Use domain terminology
4. **Explaining Variables** - Replace magic numbers with meaningful names
5. **Realistic Scenarios** - Test with multiple participants when relevant
6. **Clear Intent** - Test name should explain expected behavior

## Pattern Evolution

As the test suite grows, watch for opportunities to apply additional xUnit patterns:
- **Object Mother**: For complex test data creation
- **Test Data Builder**: For fluent test setup APIs  
- **Custom Assertion**: For domain-specific verifications
- **Shared Fixture**: For common test setup scenarios

Remember: **Good test code is as important as good production code!**