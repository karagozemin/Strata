# =============================================================================
# YieldBrick - Makefile for Quick Commands
# Mantle Global Hackathon 2025
# =============================================================================

-include .env

# Default network
NETWORK ?= mantle_testnet

# Build
build:
	forge build

# Test
test:
	forge test -vvv

# Test with gas report
test-gas:
	forge test -vvv --gas-report

# Deploy to Mantle Testnet
deploy-testnet:
	forge script script/Deploy.s.sol:DeployYieldBrick \
		--rpc-url https://rpc.sepolia.mantle.xyz \
		--broadcast \
		--verify \
		-vvvv

# Deploy to local Anvil
deploy-local:
	forge script script/Deploy.s.sol:DeployYieldBrick \
		--rpc-url http://127.0.0.1:8545 \
		--broadcast \
		-vvvv

# Start local node
anvil:
	anvil --chain-id 31337

# Install dependencies
install:
	forge install OpenZeppelin/openzeppelin-contracts --no-commit
	forge install foundry-rs/forge-std --no-commit

# Clean
clean:
	forge clean

# Format
fmt:
	forge fmt

# Generate documentation
docs:
	forge doc

.PHONY: build test deploy-testnet deploy-local anvil install clean fmt docs
