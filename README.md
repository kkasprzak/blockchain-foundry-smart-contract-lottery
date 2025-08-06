# Foundry Smart Contract Lottery

A decentralized, transparent lottery system built on Ethereum that eliminates centralized control and provides verifiable fairness through blockchain technology.

## Table of Contents

- [Project Description](#project-description)
- [Tech Stack](#tech-stack)
- [Getting Started Locally](#getting-started-locally)
- [Available Scripts](#available-scripts)
- [Project Scope](#project-scope)
- [Project Status](#project-status)
- [License](#license)

## Project Description

The Foundry Smart Contract Lottery solves the fundamental problem of trust in traditional lottery systems. Traditional lotteries are centralized and opaque - users cannot verify the randomness and fairness of draws, and must trust administrators.

This smart contract implements a fully on-chain lottery with:

- **Verifiable Randomness**: Uses Chainlink VRF to ensure tamper-proof random winner selection
- **Automated Operations**: Chainlink Automation triggers draws at fixed intervals without human intervention
- **Complete Transparency**: All operations are recorded on-chain and publicly verifiable
- **Fair Distribution**: 100% of the prize pool goes to the winner with no fees deducted
- **Immutable Rules**: Entry fees and draw intervals are fixed at deployment and cannot be changed

Players pay a configurable entry fee to join lottery rounds. When the predetermined time interval elapses and participants have entered, the system automatically requests verifiable randomness, selects a winner, distributes the entire prize pool, and resets for the next round.

## Tech Stack

### Core Development
- **Foundry**: Blazing fast Ethereum development toolkit
  - **Forge**: Testing framework and deployment tool
  - **Cast**: Command-line tool for interacting with Ethereum
  - **Anvil**: Local Ethereum node for development
- **Solidity**: Smart contract programming language

### External Services
- **Chainlink VRF v2**: Verifiable random function for fair winner selection
- **Chainlink Automation**: Decentralized automation for scheduled draws

### Quality Assurance & Security
- **Slither**: Static analysis tool for security vulnerability detection
- **Solhint**: Solidity linter for code quality and best practices
- **Prettier**: Code formatter with Solidity support

### Deployment & CI/CD
- **Forge Script**: Deployment automation and management
- **GitHub Actions**: Continuous integration and deployment pipeline

## Getting Started Locally

### Prerequisites

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/foundry-smart-contract-lottery-f23
cd foundry-smart-contract-lottery-f23
```

2. Install dependencies:
```bash
forge install
```

3. Build the project:
```bash
forge build
```

4. Run tests to verify setup:
```bash
forge test
```

### Local Development

Start a local Ethereum node:
```bash
anvil
```

Deploy to local network:
```bash
forge script script/Counter.s.sol:CounterScript --rpc-url http://localhost:8545 --private-key <your_private_key>
```

## Available Scripts

### Build
Compile the smart contracts:
```bash
forge build
```

### Test
Run the test suite:
```bash
forge test
```

Run tests with verbosity:
```bash
forge test -vvv
```

### Format
Format code according to style guidelines:
```bash
forge fmt
```

### Gas Analysis
Generate gas usage snapshots:
```bash
forge snapshot
```

### Security Analysis
Run static security analysis:
```bash
slither .
```

### Linting
Check code quality and style:
```bash
solhint 'src/**/*.sol'
```

### Deploy
Deploy to Sepolia testnet:
```bash
forge script script/Counter.s.sol:CounterScript --rpc-url <sepolia_rpc_url> --private-key <your_private_key> --verify
```

### Interact with Contract
Use Cast for on-chain interactions:
```bash
cast <subcommand>
```

## Project Scope

### In Scope ✅
- Solidity smart contract deployed on Sepolia Ethereum testnet
- Integration with Chainlink VRF v2 for verifiable randomness
- Integration with Chainlink Automation for scheduled draws
- Comprehensive unit and integration test suite
- CI/CD pipeline with GitHub Actions
- Automated security analysis and code quality checks
- Entry fee payment validation and participant tracking
- Automated prize distribution to winners
- Event logging for complete transparency and auditability

### Out of Scope ❌
- Frontend user interface (contract interaction via CLI/scripts only)
- Mainnet deployment (testnet only for this version)
- Token-based entry fees (ETH only)
- Operator fees or commissions
- User authentication beyond Ethereum addresses
- Manual draw processes (fully automated only)
- Regulatory compliance features

## Project Status

**Current Phase**: MVP Development

### Completed Features
- ✅ Basic lottery contract structure
- ✅ Entry fee validation and participant tracking
- ✅ Manual draw functionality for testing
- ✅ Prize distribution mechanism

### In Development
- 🔄 Chainlink VRF integration for verifiable randomness
- 🔄 Chainlink Automation integration for scheduled draws
- 🔄 Enhanced security measures and reentrancy protection
- 🔄 Comprehensive event logging and monitoring

### Planned Features
- 📋 Complete test coverage for all user stories
- 📋 CI/CD pipeline with automated security checks
- 📋 Gas optimization and final security audit
- 📋 Documentation and deployment guides

### Success Metrics
- **Autonomous Operation**: Contract performs draws automatically on Sepolia
- **Fund Security**: 100% of collected funds transferred to correct winners
- **Transparency**: All state changes emitted as events and publicly queryable
- **Quality**: Comprehensive test coverage and passing security analysis
- **Reliability**: CI/CD pipeline successfully validates all changes

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**⚠️ Disclaimer**: This project is for educational and testing purposes only. It is deployed on Sepolia testnet and should not be used with real funds on mainnet without proper security audits and regulatory compliance review.