.PHONY: help install build test clean deploy-sepolia deploy-local slither

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
	@echo "Security Commands:"
	@echo "  slither          Run Slither static analysis"
	@echo ""
	@echo "Deployment Commands:"
	@echo "  deploy-local     Deploy to local network (anvil)"
	@echo "  deploy-sepolia   Deploy to Sepolia testnet"
	@echo ""
	@echo "Usage Examples:"
	@echo "  make test                         # Quick testing during development"
	@echo "  make slither                      # Run security analysis"
	@echo "  make deploy-local                 # Test deployment locally"

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