# Lessons Learned

Notes from working on the project - things worth remembering.

---

## 2025-02-01

### Deployment and configuration

- **Deploy to Anvil:** `make deploy-local` - deploys contract and saves address to `broadcast/DeployRaffle.s.sol/31337/run-latest.json`
- **Contract address for frontend:** set `VITE_RAFFLE_CONTRACT_ADDRESS` in `frontend/.env.local`
- **After changing .env:** must restart frontend (Vite doesn't hot-reload .env automatically)

### Completing lottery round (locally)

- **Command:** `make complete-draw`
- **What it does:**
  1. `performUpkeep()` - starts the draw
  2. `fulfillRandomWords()` - simulates VRF callback (only on Anvil with mock)
- **Players not required** - round will close even without players (emits `DrawCompleted` with `winner=address(0)`)

### Frontend logging

- **Logs saved to:** `frontend/dev.log` (via `tee` in Makefile)
- **Allows:** another Claude Code to read logs and help with debugging

### Makefile complete-draw and VRF

- **VRF Request ID changes with each round:** Don't use hardcoded `requestId=1` - each new round has different ID (2, 3, 4...)
- **Getting last request ID:** `cast logs --from-block 1 --address $VRF_ADDR --rpc-url http://localhost:8545 --json | jq -r '.[-1].data[0:66]'`
- **Don't hide errors:** `> /dev/null 2>&1` masks all errors - remove to see actual messages
- **Raffle stuck in DRAWING:** If `fulfillRandomWords()` fails, contract stays in DRAWING state and `checkUpkeep()` returns false. Must call `fulfillRandomWords()` with correct request ID to unstick.

### Anvil logs - what to ignore

- **MetaMask token detection:** When MetaMask interacts with contract, it tries to detect if it's a token via `symbol()`, `decimals()`, `balanceOf()`. These revert because Raffle is not a token - this is normal, not an error.
