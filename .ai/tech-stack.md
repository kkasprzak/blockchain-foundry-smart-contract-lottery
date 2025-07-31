# Recommended Technical Stack

Based on a thorough review of the PRD, this document outlines the recommended technical stack for the project. The primary drivers for these choices are developer experience, alignment with Test-Driven Development (TDD), security, and the specific external service integrations required by the user stories.

### 1. Core Development Framework: Foundry

This is the central pillar of the stack and the most appropriate choice for this project.

*   **Components:** `Forge` (testing/deployment), `Cast` (on-chain interaction), and `Anvil` (local testnet).
*   **Why it's the right choice:**
    *   **High-Speed Testing:** Foundry's speed is critical for adhering to the TDD cycle. Fast feedback loops are essential for efficient development.
    *   **Solidity-Native Tests:** Writing tests directly in Solidity reduces context switching and allows for powerful, low-level testing that is perfect for smart contracts.
    *   **Integrated Tooling:** It provides a cohesive suite for the entire development lifecycle: compiling, testing, deploying, and on-chain interaction.
    *   **Alignment with PRD:** Directly supports all core development activities required, from deployment (US-001) to testing complex external interactions.

### 2. Smart Contract Language: Solidity

*   **Why it's the right choice:**
    *   It is the industry standard for the Ethereum Virtual Machine (EVM) and is explicitly part of the project's learning goals.
    *   The PRD's security story (**US-008**) references common patterns like reentrancy guards and the checks-effects-interactions pattern, which are well-understood concepts in the Solidity community.

### 3. External Services & Oracles: Chainlink

This is a non-negotiable requirement based directly on the PRD.

*   **Components:**
    *   **Chainlink VRF (Verifiable Random Function):** To fulfill **US-005 (Integrate Verifiable Randomness)**.
    *   **Chainlink Automation (formerly Keepers):** To fulfill **US-006 (Automate Draw Trigger)**.
*   **Why it's the right choice:**
    *   **Explicitly Required:** The PRD user stories name these services as the chosen solution for randomness and automation.
    *   **Industry Standard:** They are the most well-established and battle-tested services for these specific use cases on the blockchain.

### 4. Quality Assurance & Security Tooling

These tools are necessary to meet the specific acceptance criteria for security and to maintain high code quality.

*   **Static Analysis: Slither**
    *   **Why it's the right choice:** It directly fulfills the acceptance criterion in **US-008**: "The contract passes automated security analysis with a tool like Slither, with no medium or high-severity issues."
*   **Linter: Solhint**
    *   **Why it's the right choice:** Helps enforce style guides and security best practices automatically, contributing to the overall quality required by the project.
*   **Code Formatter: Prettier with a Solidity Plugin**
    *   **Why it's the right choice:** Ensures a consistent code style across the project, which is important for readability and maintainability. This directly supports the "style checks" mentioned in the CI/CD success metric.

### 5. Deployment & CI/CD

*   **Deployment Scripts: Forge Script (`forge script`)**
    *   **Why it's the right choice:** This is the idiomatic way to manage deployments within the Foundry ecosystem. It allows for repeatable, version-controlled deployment logic, which is perfect for **US-001 (Deploy basic lottery)**.
*   **CI/CD Platform: GitHub Actions**
    *   **Why it's the right choice:** This is explicitly named as a requirement in the PRD's "Success Metrics" section. The CI/CD pipeline should be configured to run the following on every push/PR:
        1.  `forge build` (Compilation check)
        2.  `forge test` (Unit & Integration tests)
        3.  `slither .` (Static security analysis)
        4.  `solhint` & `prettier --check` (Linting and formatting checks)