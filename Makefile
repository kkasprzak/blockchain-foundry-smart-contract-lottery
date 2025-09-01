.PHONY: help install build test clean deploy-sepolia deploy-local

# Default target
help:
	@echo "Available commands:"
	@echo "  install       - Install dependencies"
	@echo "  build         - Compile contracts"
	@echo "  test          - Run tests"
	@echo "  clean         - Clean build artifacts"
	@echo "  deploy-sepolia - Deploy Raffle to Sepolia testnet"
	@echo "  deploy-local - Deploy Raffle to local network"

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
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url local --broadcast --account localKey