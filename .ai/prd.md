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
- Automated lottery draws: The system conducts draws at predefined time intervals. A draw occurs only when the time interval has elapsed and at least one participant has entered. If no participants exist, the system waits for the next interval.
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

- US-001: Deploy basic lottery
  Description: As a lottery operator, I want to deploy a simple lottery contract on Sepolia, so that I can start offering a basic gambling service.
  Acceptance criteria:
    - Contract deploys successfully to Sepolia testnet.
    - Entry fee amount is configurable at deployment.
    - Basic contract configuration is verifiable on-chain.

- US-002: Enter lottery round
  Description: As a player, I want to pay an entry fee to join the current lottery round, so that I have a chance to win the prize pool.
  Acceptance criteria:
    - When I pay the exact entry fee, I am included in the current lottery round.
    - When I pay an incorrect amount, my transaction is rejected.
    - I receive confirmation that my entry was successful.
    - I can verify that I'm included in the current round.
    - Entries are only accepted until the draw interval has elapsed. After the interval has passed, new entries are rejected until the next round begins.
    - If I attempt to enter after the entry window has closed, my transaction is rejected with a clear error message.
    - The entry window and cutoff rules are clearly documented and verifiable on-chain.

- US-003: Manual draw process for end-to-end testing
  Description: As a lottery operator, I want to manually trigger a draw when ready, so that I can select a winner and complete the initial end-to-end flow for testing purposes.
  Acceptance criteria:
    - I can trigger a draw after the entry window has elapsed, regardless of participant count.
    - When I trigger a draw with no participants, the system resets the entry window for the next round without selecting a winner or transferring prizes.
    - Winner selection uses the simplest possible pseudo-random mechanism, sufficient for internal testing.
    - The draw process is logged via a basic event.
    - This functionality is for initial testing of the walking skeleton only and is not intended for real players.
    - Only the operator can trigger draws.

- US-004: Distribute winnings
  Description: As a winner, I want to automatically receive the entire prize pool when selected, so that I get my winnings immediately.
  Acceptance criteria:
    - Winner receives 100% of all collected entry fees.
    - Prize transfer happens automatically after winner selection.
    - Winner notification is logged through blockchain events.
    - New lottery round starts automatically after prize distribution.

- US-005: Integrate Verifiable Randomness
  Description: As a player, I want winner selection to use a provably fair and tamper-proof source of randomness, so that I can trust the outcome is not manipulated.
  Acceptance criteria:
    - The manual draw's pseudo-randomness is replaced with a call to a verifiable random function (VRF) oracle (e.g., Chainlink VRF).
    - The draw is still triggered manually by the operator.
    - The randomness request and fulfillment are logged via events.
    - The system handles potential delays or failures from the VRF oracle gracefully.

- US-006: Automate Draw Trigger
  Description: As a player, I want the lottery draw to be triggered automatically at scheduled intervals, so I can be sure it runs on time without operator dependency.
  Acceptance criteria:
    - The manual draw trigger is replaced by a decentralized automation service (e.g., Chainlink Automation).
    - Draws are automatically requested at the configured time interval.
    - The lottery contract must be funded with sufficient currency (e.g., LINK/ETH) to pay for automation service fees.
    - The system correctly handles cases where an upkeep check is skipped (e.g., no participants).

- US-007: Immutable lottery rules
  Description: As a player, I want the lottery rules to be permanently fixed after deployment, so that I can trust the game conditions won't change.
  Acceptance criteria:
    - Entry fee amount cannot be modified after deployment.
    - Draw interval cannot be changed after deployment.
    - Any rule changes require deploying a completely new lottery contract.
    - The immutable nature of rules is verifiable on the blockchain.

- US-008: Enhanced Security Protection
  Description: As a player, I want my entry fees and winnings to be protected against theft and technical vulnerabilities, so that I can participate with confidence.
  Acceptance criteria:
    - Reentrancy guards are implemented on all critical fund-handling functions (e.g., enter, payout).
    - The contract passes automated security analysis with a tool like Slither, with no medium or high-severity issues.
    - Follows the checks-effects-interactions pattern to prevent reentrancy.
    - Ownership of the contract is properly managed and restricted.

- US-009: Comprehensive Monitoring
  Description: As a lottery operator, I want to track all lottery activities and system health, so that I can ensure proper operation and maintain player trust.
  Acceptance criteria:
    - Player entry events log the `playerAddress` and `entryFee`.
    - Draw request events log the `requestId` for tracking.
    - Winner selection events log the `winnerAddress` and `prizeAmount`.
    - All event parameters crucial for filtering are indexed.

## 7. Success metrics

- Autonomous operation: The contract performs draws automatically on Sepolia at the configured interval without manual intervention.
- Pool disbursement accuracy: 100% of collected funds are transferred to the correct winner.
- Event observability: All key state changes are emitted as events and can be retrieved via node or Etherscan.
- Test coverage: Unit and integration tests cover all critical paths, edge cases, and failure modes.
- CI/CD reliability: GitHub Actions pipeline runs tests, style checks, and deploys successfully on each merge.