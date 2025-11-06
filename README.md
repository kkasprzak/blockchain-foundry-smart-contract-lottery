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
- [Slither](https://github.com/crytic/slither) (optional, for security analysis)

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

3. Install Slither (optional, recommended for security):
```bash
brew install slither-analyzer
```

4. Build the project:
```bash
forge build
```

5. Run tests to verify setup:
```bash
forge test
```

## Deployment Environments

This project supports deployment to multiple environments, each optimized for different stages of development:

### Environment Overview

| Environment | Purpose | Network | Cost | Verification |
|------------|---------|---------|------|--------------|
| **Local** | Development & Testing | Anvil | Free | Not needed |
| **Testnet** | Integration Testing | Sepolia | Testnet ETH | Etherscan |
| **Mainnet** | Production | Ethereum | Real ETH | Etherscan |

---

## Local Environment (Anvil)

**Use Case**: Rapid development, testing, and debugging

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- No API keys required
- No external ETH needed

### Setup

1. **Start Anvil to see available accounts:**
   ```bash
   anvil
   # Displays 10 pre-funded accounts with their private keys
   ```

2. **Import one of Anvil's accounts into keystore:**
   ```bash
   cast wallet import localKey --interactive
   # When prompted, use any private key from the Anvil output above
   # Set a password for encryption
   ```

### Deployment

1. **Start Anvil:**
   ```bash
   anvil
   ```

2. **Deploy contract:**
   ```bash
   make deploy-local
   ```

### Features
- 10 pre-funded accounts (10,000 ETH each)
- Instant block mining and transaction processing
- No gas costs
- State resets when Anvil restarts
- Rich debugging information

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
Run Slither static security analysis:
```bash
make slither
```

Or run directly with Slither:
```bash
slither . --foundry-compile-all --filter-paths "lib/,test/" --exclude-informational --exclude-optimization
```

This analyzes the smart contracts for:
- Reentrancy vulnerabilities
- Access control issues
- Arithmetic problems
- Gas optimization opportunities
- Best practice violations

### Linting
Check code quality and style:
```bash
solhint 'src/**/*.sol'
```

---

## Testnet Environment (Sepolia)

**Use Case**: Integration testing with real network conditions

### Prerequisites

1. **API Keys:**
   - [Alchemy API Key](https://alchemy.com) for RPC endpoint
   - [Etherscan API Key](https://etherscan.io/apis) for verification

2. **Testnet ETH:**
   - Get from [Sepolia Faucet](https://sepoliafaucet.com)
   - Minimum ~0.01 ETH needed for deployment

### Setup

1. **Configure environment variables:**
   ```bash
   cp .env.example .env
   
   # Edit .env with your API keys:
   ALCHEMY_API_KEY=your_alchemy_api_key_here
   ETHERSCAN_API_KEY=your_etherscan_api_key_here
   ```

2. **Set up keystore account:**
   ```bash
   cast wallet import sepoliaKey --interactive
   # Enter your private key (without 0x prefix)
   # Set a password for encryption
   ```

### Deployment

```bash
make deploy-sepolia
```

This will:
- Deploy with default parameters (0.01 ETH entry, 30s interval)
- Automatically verify on Etherscan
- Provide contract address and verification URL

### Features
- Real network conditions and gas costs
- Etherscan verification and monitoring
- Persistent state (doesn't reset)
- Public testnet accessibility

---

## Mainnet Environment (Future)

**Use Case**: Production deployment with real funds

> ⚠️ **Not implemented yet** - Requires security audit and additional safety measures

### Prerequisites (Planned)
- Production RPC endpoint
- Security audit completion
- Multi-signature deployment setup

### Security Requirements
- Complete security audit
- Extensive testnet validation  
- Formal verification of critical functions
- Multi-signature deployment process

---

## Available Commands

```bash
make help           # Show all available commands
make build          # Compile contracts
make test           # Run tests
make slither        # Run Slither security analysis
make deploy-local   # Deploy to local Anvil
make deploy-sepolia # Deploy to Sepolia testnet
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