# High-level Project Description

## Raffle (MVP)

### Main Problem
Traditional lottery solutions are centralized and lack transparency. Building a lottery on the Ethereum network removes centralization and provides full visibility into the drawing process.

### Minimum Set of Features
- **User Participation:** Ethereum users can enter the lottery by sending a configurable entry fee to the smart contract.
- **Automated Draws:** At fixed time intervals, the contract automatically selects a winner from the pool of participants.
- **Randomness:** Winner selection uses [Chainlink VRF (Verifiable Random Function)](https://docs.chain.link/vrf/v2/introduction) to ensure provable, tamper-proof randomness.
- **Automation:** The process of checking the interval and triggering the winner selection is handled by [Chainlink Automation (formerly Keepers)](https://docs.chain.link/chainlink-automation/introduction), ensuring decentralized and reliable execution.
- **Payout:** The winner receives the entire pool of collected funds. After each draw, the system resets for a new round.

### User Flow
1. A user sends the required entry fee to the contract to join the current round.
2. At the scheduled interval, Chainlink Automation triggers the contract to request a random number from Chainlink VRF.
3. Once the random number is received, the contract selects a winner and transfers the prize pool.
4. The contract resets, and a new round begins.

### Out of Scope for MVP
- No frontend will be developed; the focus is solely on the backend smart contract deployed on the Sepolia Ethereum testnet.

### Security and Edge Cases
- The contract will follow Solidity security best practices (e.g., reentrancy protection, safe fund transfers).
- If no participants have entered during an interval, no winner will be selected and the round will continue.
- If Chainlink VRF or Automation fails, the contract will wait for the next successful trigger.

### Economic Model
- There are no fees; the entire pool goes to the winner.
- The contract will be funded to cover Chainlink VRF and Automation costs, and these costs will be monitored during testing.

### Testing and Deployment
- The contract will be thoroughly tested with unit and integration tests, and deployed to the Sepolia testnet for live validation.

### Success Criteria
The project is successful when:
- The contract is deployed and operates autonomously on Sepolia.
- All core features work as intended, and the process follows the learning and development steps outlined in the [Cyfrin Updraft: Smart Contract Lottery](https://updraft.cyfrin.io/courses/foundry/smart-contract-lottery) and [10xDevs](https://www.10xdevs.pl/) courses.
- I gain practical experience in Solidity and using [Claude Code](https://www.anthropic.com/claude-code) as an AI coding assistant for project development.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
