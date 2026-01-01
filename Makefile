.PHONY: help install build test clean deploy-sepolia deploy-local slither lint
.PHONY: create-subscription fund-subscription add-consumer subscription-status
.PHONY: register-upkeep fund-upkeep upkeep-status

# Default target - show help when no target specified
help:
	@echo "Foundry Smart Contract Lottery - Available Commands"
	@echo "=================================================="
	@echo ""
	@echo "Development Commands:"
	@echo "  install          Install forge dependencies"
	@echo "  build            Compile all contracts"
	@echo "  clean            Clean build artifacts"
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

# Deploy to Sepolia testnet
deploy-sepolia:
	@echo "Deploying Raffle to Sepolia testnet..."
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url sepolia --broadcast --account sepoliaKey --verify --etherscan-api-key sepolia -vvvv

# Deploy to local network
deploy-local:
	@echo "Deploying Raffle to local network..."
	@cast rpc anvil_mine 20 --rpc-url local > /dev/null 2>&1 || true
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url local --broadcast --account localKey -vvvv

# Run Slither static analysis
slither:
	@echo "Running Slither static analysis..."
	@slither . --foundry-compile-all --filter-paths "lib/,test/" --exclude-informational --exclude-optimization

# Run linters (Solhint + Forge lint)
lint:
	@echo "Running Solhint linter..."
	@solhint 'src/**/*.sol'
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

# Check upkeep status
upkeep-status:
	@./script/get-upkeep-details.sh