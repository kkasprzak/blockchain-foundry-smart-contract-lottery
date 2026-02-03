-include .env

.PHONY: help install build test clean deploy-sepolia deploy-local slither lint anvil-start anvil-stop
.PHONY: create-subscription fund-subscription add-consumer subscription-status
.PHONY: register-upkeep fund-upkeep upkeep-status
.PHONY: frontend-dev frontend-build indexer-dev indexer-codegen
.PHONY: enter-player-1 enter-player-2 enter-player-3 enter-player-4 enter-player-5 enter-5-players complete-draw

# Default target - show help when no target specified
help:
	@echo "Foundry Smart Contract Lottery - Available Commands"
	@echo "=================================================="
	@echo ""
	@echo "Development Commands:"
	@echo "  install          Install forge dependencies"
	@echo "  build            Compile all contracts"
	@echo "  clean            Clean build artifacts"
	@echo "  anvil-start      Start Anvil in background (logs to anvil.log)"
	@echo "  anvil-stop       Stop Anvil"
	@echo ""
	@echo "Testing Commands:"
	@echo "  test             Run all tests"
	@echo ""
	@echo "Security & Quality Commands:"
	@echo "  slither          Run Slither static analysis"
	@echo "  lint             Run Solhint linter"
	@echo ""
	@echo "Deployment Commands:"
	@echo "  deploy-local     Deploy to local network (anvil)"
	@echo "  deploy-sepolia   Deploy to Sepolia testnet"
	@echo ""
	@echo "Chainlink VRF Commands:"
	@echo "  create-subscription    Create new VRF subscription"
	@echo "  fund-subscription      Fund VRF subscription with LINK"
	@echo "  add-consumer           Register Raffle as VRF consumer"
	@echo "  subscription-status    Check VRF subscription details"
	@echo ""
	@echo "Chainlink Automation Commands:"
	@echo "  register-upkeep        Register new upkeep for Raffle contract"
	@echo "  fund-upkeep            Fund existing upkeep with LINK"
	@echo "  upkeep-status          Check upkeep balance and status"
	@echo ""
	@echo "Frontend Commands:"
	@echo "  frontend-dev           Start frontend development server"
	@echo "  frontend-build         Build frontend for production"
	@echo ""
	@echo "Indexer Commands:"
	@echo "  indexer-dev            Start indexer development server"
	@echo "  indexer-codegen        Generate Ponder types from config"
	@echo ""
	@echo "Local Contract Interaction:"
	@echo "  enter-player-1         Player 1 enters raffle (0.01 ETH)"
	@echo "  enter-player-2         Player 2 enters raffle (0.01 ETH)"
	@echo "  enter-player-3         Player 3 enters raffle (0.01 ETH)"
	@echo "  enter-player-4         Player 4 enters raffle (0.01 ETH)"
	@echo "  enter-player-5         Player 5 enters raffle (0.01 ETH)"
	@echo "  enter-5-players        All 5 players enter raffle"
	@echo "  complete-draw          Complete raffle draw (performUpkeep + VRF callback)"
	@echo ""
	@echo "Usage Examples:"
	@echo "  make test                         # Quick testing during development"
	@echo "  make slither                      # Run security analysis"
	@echo "  make deploy-local                 # Test deployment locally"
	@echo "  make create-subscription          # Create VRF subscription"
	@echo "  make register-upkeep              # Register Chainlink Automation upkeep"

# Install forge dependencies
install:
	forge install

# Build the project
build:
	forge build

# Run tests
test:
	forge test

# Clean build artifacts
clean:
	forge clean

# Start Anvil in background with logs (mines block every 5s)
anvil-start:
	@echo "Starting Anvil..."
	@anvil --block-time 5 > anvil.log 2>&1 &
	@sleep 1
	@echo "Anvil running (PID: $$(lsof -ti:8545)). Logs: anvil.log"

# Stop Anvil
anvil-stop:
	@echo "Stopping Anvil..."
	@-kill $$(lsof -ti:8545) 2>/dev/null && echo "Anvil stopped." || echo "Anvil not running."

# Deploy to Sepolia testnet
deploy-sepolia:
	@echo "Deploying Raffle to Sepolia testnet..."
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url sepolia --broadcast --account sepoliaKey --verify --etherscan-api-key sepolia -vvvv

# Deploy to local network
deploy-local:
	@echo "Deploying Raffle to local network..."
	@cast rpc anvil_mine 20 --rpc-url local > /dev/null 2>&1 || true
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url local --broadcast --account localKey --password ""

# Run Slither static analysis
slither:
	@echo "Running Slither static analysis..."
	@slither . --foundry-compile-all --filter-paths "lib/,test/" --exclude-informational --exclude-optimization

# Run linters (Solhint + Forge lint)
lint:
	@echo "Running Solhint linter..."
	@solhint 'src/**/*.sol' 'test/**/*.sol' 'script/**/*.sol'
	@echo "Running Forge linter..."
	@forge lint

# Create new VRF subscription
create-subscription:
	@echo "Creating VRF subscription..."
	@forge script script/CreateSubscription.s.sol --rpc-url sepolia --broadcast --account sepoliaKey

# Fund VRF subscription with LINK
fund-subscription:
	@echo "Funding VRF subscription..."
	@echo "This will transfer 0.1 LINK (default) from your wallet to the subscription."
	@forge script script/FundSubscription.s.sol --rpc-url sepolia --broadcast --account sepoliaKey

# Register Raffle as VRF consumer
add-consumer:
	@echo "Adding Raffle contract as VRF consumer..."
	@forge script script/AddConsumer.s.sol --rpc-url sepolia --broadcast --account sepoliaKey

# Check VRF subscription status
subscription-status:
	@./script/get-subscription-details.sh

# Register new Chainlink Automation upkeep
register-upkeep:
	@echo "Registering Chainlink Automation upkeep..."
	@echo "This will transfer 2 LINK (default) from your wallet to fund the upkeep."
	@echo "Configure UPKEEP_FUND_AMOUNT in .env to change the amount."
	@forge script script/RegisterUpkeep.s.sol --rpc-url sepolia --broadcast --account sepoliaKey

# Fund existing upkeep with LINK
fund-upkeep:
	@echo "Funding Chainlink Automation upkeep..."
	@echo "This will transfer 2 LINK (default) from your wallet to the upkeep."
	@echo "Configure UPKEEP_FUND_AMOUNT in .env to change the amount."
	@forge script script/FundUpkeep.s.sol --rpc-url sepolia --broadcast --account sepoliaKey

# Local contract interaction

enter-player-1:
	@RAFFLE_ADDR=$$(jq -r '.transactions[] | select(.contractName == "Raffle") | .contractAddress' broadcast/DeployRaffle.s.sol/31337/run-latest.json); \
	echo "Player 1 entering raffle..."; \
	cast send $$RAFFLE_ADDR "enterRaffle()" --value 0.01ether --rpc-url local --private-key ${ANVIL_PLAYER_1_KEY}

enter-player-2:
	@RAFFLE_ADDR=$$(jq -r '.transactions[] | select(.contractName == "Raffle") | .contractAddress' broadcast/DeployRaffle.s.sol/31337/run-latest.json); \
	echo "Player 2 entering raffle..."; \
	cast send $$RAFFLE_ADDR "enterRaffle()" --value 0.01ether --rpc-url local --private-key ${ANVIL_PLAYER_2_KEY}

enter-player-3:
	@RAFFLE_ADDR=$$(jq -r '.transactions[] | select(.contractName == "Raffle") | .contractAddress' broadcast/DeployRaffle.s.sol/31337/run-latest.json); \
	echo "Player 3 entering raffle..."; \
	cast send $$RAFFLE_ADDR "enterRaffle()" --value 0.01ether --rpc-url local --private-key ${ANVIL_PLAYER_3_KEY}

enter-player-4:
	@RAFFLE_ADDR=$$(jq -r '.transactions[] | select(.contractName == "Raffle") | .contractAddress' broadcast/DeployRaffle.s.sol/31337/run-latest.json); \
	echo "Player 4 entering raffle..."; \
	cast send $$RAFFLE_ADDR "enterRaffle()" --value 0.01ether --rpc-url local --private-key ${ANVIL_PLAYER_4_KEY}

enter-player-5:
	@RAFFLE_ADDR=$$(jq -r '.transactions[] | select(.contractName == "Raffle") | .contractAddress' broadcast/DeployRaffle.s.sol/31337/run-latest.json); \
	echo "Player 5 entering raffle..."; \
	cast send $$RAFFLE_ADDR "enterRaffle()" --value 0.01ether --rpc-url local --private-key ${ANVIL_PLAYER_5_KEY}

enter-5-players:
	@echo "Entering 5 players into raffle..."
	@$(MAKE) -s enter-player-1
	@$(MAKE) -s enter-player-2
	@$(MAKE) -s enter-player-3
	@$(MAKE) -s enter-player-4
	@$(MAKE) -s enter-player-5
	@echo "All 5 players entered!"

complete-draw:
	@echo "Completing full draw cycle (performUpkeep + VRF callback)..."
	@RAFFLE_ADDR=$$(jq -r '.transactions[] | select(.contractName == "Raffle") | .contractAddress' broadcast/DeployRaffle.s.sol/31337/run-latest.json); \
	VRF_ADDR=$$(jq -r '.transactions[] | select(.contractName == "MyVRFCoordinatorV2_5Mock" or .contractName == "MyVrfCoordinatorV25Mock") | .contractAddress' broadcast/DeployRaffle.s.sol/31337/run-latest.json | head -1); \
	echo "Step 0: Checking if raffle is ready for draw..."; \
	UPKEEP_NEEDED=$$(cast call $$RAFFLE_ADDR "checkUpkeep(bytes)(bool,bytes)" "0x" --rpc-url local | head -1); \
	if [ "$$UPKEEP_NEEDED" != "true" ]; then \
		echo "ERROR: Raffle not ready for draw (checkUpkeep=false)"; \
		echo "Possible reasons:"; \
		echo "  - Entry window still open (deadline not passed)"; \
		echo "  - Raffle already in DRAWING state"; \
		DEADLINE=$$(cast call $$RAFFLE_ADDR "getEntryDeadline()(uint256)" --rpc-url local); \
		CURRENT=$$(cast block latest --field timestamp --rpc-url local); \
		echo "  Entry deadline: $$DEADLINE, Current time: $$CURRENT"; \
		exit 1; \
	fi; \
	REQUESTS_BEFORE=$$(cast logs --from-block 1 --address $$VRF_ADDR --rpc-url http://localhost:8545 --json | jq 'length'); \
	echo "Step 1: Performing upkeep on Raffle at $$RAFFLE_ADDR"; \
	cast send $$RAFFLE_ADDR "performUpkeep(bytes)" "0x" --rpc-url local --account localKey --password "" || { echo "ERROR: performUpkeep failed"; exit 1; }; \
	echo "Step 2: Verifying VRF request was created..."; \
	REQUESTS_AFTER=$$(cast logs --from-block 1 --address $$VRF_ADDR --rpc-url http://localhost:8545 --json | jq 'length'); \
	if [ "$$REQUESTS_AFTER" -le "$$REQUESTS_BEFORE" ]; then \
		echo "No VRF request created - round completed without players (no VRF needed)"; \
		echo "Draw completed! New round started (no winner - 0 players)."; \
		exit 0; \
	fi; \
	REQUEST_ID=$$(cast logs --from-block 1 --address $$VRF_ADDR --rpc-url http://localhost:8545 --json | jq -r '.[-1].data[0:66]' | xargs printf "%d"); \
	echo "Step 3: Triggering VRF callback with request ID $$REQUEST_ID"; \
	cast send $$VRF_ADDR "fulfillRandomWords(uint256,address)" $$REQUEST_ID $$RAFFLE_ADDR --rpc-url local --account localKey --password "" || { echo "ERROR: fulfillRandomWords failed"; exit 1; }; \
	echo "Draw completed! Winner selected and new round started."

# Check upkeep status
upkeep-status:
	@./script/get-upkeep-details.sh

# Frontend commands
frontend-dev:
	cd frontend && pnpm dev 2>&1 | tee dev.log

frontend-build:
	cd frontend && pnpm build

# Indexer commands
indexer-dev:
	cd indexer && pnpm dev

indexer-codegen:
	cd indexer && pnpm codegen