# Product Requirement Document (PRD) - Raffle

## 1. Product overview

The Raffle smart contract provides a decentralized, transparent lottery on the Ethereum Sepolia testnet, allowing participants to enter by paying a configurable entry fee. Chainlink VRF ensures tamper-proof random winner selection, and Chainlink Automation triggers draws at fixed intervals. The contract resets after each draw and disburses the entire prize pool to the winner.

## 2. User problem

Traditional lottery systems are centralized and opaque. Users cannot verify the randomness and fairness of draws, and must trust administrators. This contract solves the problem by implementing a fully on-chain lottery with verifiable randomness and decentralized automation, restoring trust and transparency.

## 3. User personas

### Player

The Player represents anyone who participates in the lottery by paying entry fees for a chance to win the prize pool. This persona encompasses various gambling motivations and behaviors:

- **Casual Players**: Occasional participants who enter for entertainment or the excitement of potentially winning
- **Regular Players**: Consistent participants who may have preferred strategies or entry patterns
- **High-Stakes Players**: Participants willing to enter multiple times or with larger stakes for bigger potential rewards
- **Social Players**: Groups who may coordinate entries or share costs (though each entry is individual on-chain)

**Key motivations**: Winning prizes, entertainment, thrill of gambling, trust in fair play
**Key concerns**: Fairness of draws, security of funds, transparency of rules, ease of participation
**Technical comfort**: Varies from blockchain beginners to experienced DeFi users

### Lottery Operator

The Lottery Operator is the person or entity responsible for deploying, configuring, and maintaining the lottery smart contract. They act as the business owner of the lottery service.

**Primary responsibilities**: Deploying the contract with appropriate parameters, monitoring operations, ensuring the system runs smoothly
**Key motivations**: Providing a trustworthy gambling service, maintaining operational efficiency, building player confidence
**Key concerns**: System reliability, transparent operations, proper configuration, regulatory compliance (future consideration)
**Technical comfort**: High - must understand blockchain deployment and smart contract operations

## 4. Functional requirements

- Participant entry: Users must pay an exact entry fee amount to join the current lottery round. The system validates the payment amount and rejects entries with incorrect fees. Each valid entry is recorded and the participant becomes eligible to win.
- The system conducts draws at predefined time intervals. When the time interval elapses, the round completes. If participants exist, a winner is selected. If no participants exist, the round closes without a winner and a new round begins immediately.
- Random winner selection: When a draw is triggered, the system requests verifiable randomness from an external oracle service. Once randomness is received, a winner is selected from all participants in the current round.
- Prize distribution: The entire collected prize pool is transferred to the selected winner immediately after selection. No fees or commissions are deducted from the prize.
- Round reset: After prize distribution, the system automatically starts a new lottery round, clearing all previous participants and resetting the timer.
- Event logging: The system logs all significant actions including participant entries, draw requests, winner selections, and prize distributions for transparency and auditability.
- Configuration management: Entry fee amount and draw interval are fixed at deployment time and cannot be modified afterward. Parameter changes require deploying a new contract instance.
- Error handling: If external services fail or become unavailable, the system maintains its current state and retries operations when services recover. Invalid transactions are rejected with clear error messages.

## 5. Product borders

- In scope: Solidity smart contract on Sepolia Ethereum testnet; integration with Chainlink VRF v2 and Chainlink Automation; unit and integration tests; CI/CD pipeline in GitHub Actions.
- Out of scope: Frontend UI; mainnet deployment; token-based entry fee (only native ETH); fees or commissions taken by contract; user authentication outside of Ethereum address; manual draw processes.

## 6. User stories

- **US-001: Deploy Basic Lottery Contract**

  As a lottery operator,
  I want to deploy a simple lottery contract on Sepolia testnet,
  So that I can start offering a transparent gambling service with configurable parameters.

  **Acceptance Criteria:**

  - Given I provide an entry fee amount in the constructor, when I deploy the contract, then it deploys successfully to Sepolia testnet
  - Given the contract is deployed, when I check the entry fee, then it matches the amount I configured at deployment
  - Given the contract is deployed, when I verify on Etherscan, then the constructor parameters are visible and correct
  - Given the contract is deployed, when I check ownership, then I am set as the initial owner

- **US-002: Enter Lottery Round**

  As a player,
  I want to pay an entry fee to join the current lottery round,
  So that I have a chance to win the prize pool.

  **Acceptance Criteria:**

  - Given the lottery is open, when I send exactly the entry fee amount to enterRaffle(), then I am added to the current round's participants
  - Given I send more than the entry fee, when I call enterRaffle(), then my transaction reverts with "Raffle\_\_SendMoreToEnterRaffle"
  - Given I send less than the entry fee, when I call enterRaffle(), then my transaction reverts with "Raffle\_\_SendLessToEnterRaffle"
  - Given I successfully enter, when the transaction completes, then an EnteredRaffle event is emitted with my address and entry fee
  - Given the entry window has elapsed, when I attempt to enter, then my transaction reverts with "Raffle\_\_RaffleNotOpen"
  - Given I already entered the current round, when I call enterRaffle() again with the exact entry fee, then I am added again as a separate entry
  - Given I enter multiple times, when the winner is selected, then my probability of winning is proportional to my number of entries

- **US-003: Manual Draw Control**

  As a lottery operator,
  I want to manually trigger draws during the development phase,
  So that I can validate the complete lottery flow before implementing automation.

  **Acceptance Criteria:**

  - Given the entry window has elapsed, when I call performDraw(), then a winner is selected from current participants
  - Given there are no participants, when I trigger a draw, then the system resets for the next round without prize distribution
  - Given a draw is triggered, when it completes, then a DrawRequested event is emitted with indexed roundNumber
  - Given I am not the operator, when I attempt to trigger a draw, then the transaction reverts with "Raffle\_\_NotOwner"
  - Given the entry window is still active, when I attempt a draw, then the transaction reverts with "Raffle\_\_RaffleNotReady"
  - Given a winner is selected, when the draw completes, then winner selection uses block.timestamp % participants.length for pseudo-randomness

- **US-004: Automatic Prize Distribution**

  As a lottery winner,
  I want to automatically receive the entire prize pool when selected,
  So that I get my winnings immediately without additional steps.

  **Acceptance Criteria:**

  - Given I am selected as winner, when the draw completes, then I receive 100% of all collected entry fees
  - Given the prize transfer, when it executes, then it uses the call method for secure ETH transfer
  - Given I am the winner, when prize distribution occurs, then a WinnerPicked event is emitted with my address and prize amount
  - Given the prize is distributed, when the transaction completes, then a new lottery round starts automatically with reset participants
  - Given the prize transfer fails, when the payout is attempted, then the transaction reverts and the lottery state remains unchanged

- **US-005: Integrate Chainlink VRF**

  As a player,
  I want winner selection to use provably fair and tamper-proof randomness,
  So that I can trust the outcome is not manipulated by the operator.

  **Acceptance Criteria:**

  - Given a draw is triggered, when performDraw() is called, then it requests randomness from Chainlink VRF v2
  - Given the VRF request is made, when it's submitted, then a RandomnessRequested event is emitted with requestId
  - Given the VRF responds, when fulfillRandomWords() is called, then the winner is selected using the random number
  - Given the VRF subscription lacks funds, when a draw is attempted, then the transaction reverts with "Raffle\_\_InsufficientVRFFunds"
  - Given the VRF request times out, when checked, then the contract maintains its current state until retry
  - Given the random number is received, when winner selection occurs, then it uses randomResult % participants.length

- **US-006: Automated Draw Scheduling**

  As a player,
  I want lottery draws to be triggered automatically at scheduled intervals,
  So that I can be sure draws happen on time without operator dependency.

  **Acceptance Criteria:**

  - Given the contract is registered with Chainlink Automation, when the time interval elapses, then checkUpkeep() returns true
  - Given checkUpkeep() returns true, when Chainlink calls performUpkeep(), then a draw is automatically triggered
  - Given the automation subscription lacks funds, when upkeep is needed, then the system pauses until refunded
  - Given the upkeep is performed, when it completes, then the next interval timer resets automatically

- **US-007: Immutable Lottery Configuration**

  As a player,
  I want the lottery rules to be permanently fixed after deployment,
  So that I can trust the game conditions won't change unexpectedly.

  **Acceptance Criteria:**

  - Given the contract is deployed, when I check the entry fee, then it is stored in an immutable variable that cannot be modified
  - Given the contract is deployed, when I check the draw interval, then it is stored in an immutable variable that cannot be modified
  - Given the contract exists, when I review the code, then there are no setter functions for entry fee or draw interval
  - Given I want different rules, when I need changes, then I must deploy a completely new contract instance
  - Given the contract is verified, when I check on Etherscan, then the immutable nature of parameters is visible in the code

- **US-008: Enhanced Security Protection**

  As a player,
  I want my entry fees and winnings protected against theft and vulnerabilities,
  So that I can participate with confidence in the lottery's security.

  **Acceptance Criteria:**

  - Given any payable function, when called, then it uses OpenZeppelin's ReentrancyGuard modifier
  - Given the winner payout function, when executed, then it follows checks-effects-interactions pattern
  - Given any state-changing function, when called recursively, then it reverts with "ReentrancyGuard: reentrant call"
  - Given the contract code, when analyzed with Slither, then it passes with zero medium or high-severity issues
  - Given ownership functions exist, when called, then only the designated owner can execute them
  - Given the contract handles ETH, when transferring funds, then it uses secure transfer methods with proper error handling

- **US-009: Comprehensive Event Logging**

  As a lottery operator,
  I want to track all lottery activities through detailed event logs,
  So that I can monitor system health and maintain transparent operations.

  **Acceptance Criteria:**

  - Given a player enters the lottery, when the transaction succeeds, then a RaffleEntered event is emitted with indexed roundNumber and indexed playerAddress
  - Given a draw is requested, when pickWinner() is called successfully, then a DrawRequested event is emitted with indexed roundNumber
  - Given a prize transfer fails, when the winner cannot receive funds, then a PrizeTransferFailed event is emitted with indexed roundNumber, indexed winnerAddress, and prizeAmount
  - Given any round completes (with or without winner), when it finishes, then a RoundCompleted event is emitted with indexed roundNumber, indexed winner address (or address(0) if no participants), and prize amount
  - Given I filter events, when I query by indexed parameters, then I can efficiently search by player address, winner, or round number
  - Given I check event history, when I query the blockchain, then all lottery activities are permanently logged and auditable

- **US-010: Secure Winner Withdrawal Pattern**

  As a lottery winner,
  I want to securely withdraw my prize using a pull payment pattern,
  So that my winnings are protected from reentrancy attacks and contract failures cannot lock funds permanently.

  **Acceptance Criteria:**

  - Given I am selected as winner, when the draw completes, then my withdrawal becomes available but funds remain in contract
  - Given I have a pending withdrawal, when I call withdrawPrize(), then I receive 100% of my prize amount
  - Given I withdraw my prize, when the transfer completes, then my pending withdrawal balance is set to zero
  - Given I have no pending withdrawal, when I call withdrawPrize(), then the transaction reverts with "Raffle\_\_NoPrizeToWithdraw"
  - Given I withdraw my prize, when the withdrawal succeeds, then a PrizeWithdrawn event is emitted with my address and amount
  - Given the transfer fails during withdrawal, when I retry, then I can attempt withdrawal again without losing my prize
  - Given multiple winners across rounds, when they withdraw, then each receives only their designated prize amount

## 7. Success metrics

- Autonomous operation: The contract performs draws automatically on Sepolia at the configured interval without manual intervention.
- Pool disbursement accuracy: 100% of collected funds are transferred to the correct winner.
- Event observability: All key state changes are emitted as events and can be retrieved via node or Etherscan.
- Test coverage: Unit and integration tests cover all critical paths, edge cases, and failure modes.
- CI/CD reliability: GitHub Actions pipeline runs tests, style checks, and deploys successfully on each merge.
