.PHONY: help install build test clean deploy-sepolia verify-sepolia

# Default target
help:
	@echo "Available commands:"
	@echo "  install       - Install dependencies"
	@echo "  build         - Compile contracts"
	@echo "  test          - Run tests"
	@echo "  clean         - Clean build artifacts"
	@echo "  deploy-sepolia - Deploy Raffle to Sepolia testnet"
	@echo "  verify-sepolia - Verify deployed contract on Sepolia"

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

# Verify contract on Sepolia (if deployment was done without --verify)
verify-sepolia:
	@echo "Please provide the contract address:"
	@read -p "Contract Address: " CONTRACT_ADDRESS; \
	forge verify-contract $$CONTRACT_ADDRESS src/Raffle.sol:Raffle --chain sepolia --etherscan-api-key $(ETHERSCAN_API_KEY)