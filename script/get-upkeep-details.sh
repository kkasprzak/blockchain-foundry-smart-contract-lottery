#!/bin/bash

# Get Chainlink Automation upkeep details
# Usage: ./script/get-upkeep-details.sh <upkeep_id>

set -e

# Load .env file if it exists
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

UPKEEP_ID=${1:-$AUTOMATION_UPKEEP_ID}

if [ -z "$UPKEEP_ID" ]; then
    echo "Error: Upkeep ID required"
    echo "Usage: ./script/get-upkeep-details.sh <upkeep_id>"
    echo "Or set AUTOMATION_UPKEEP_ID environment variable"
    exit 1
fi

# Sepolia Automation Registry address
REGISTRY="0x86EFBD0b6736Bed994962f9797049422A3A8E8Ad"
RPC_URL="${SEPOLIA_RPC_URL:-https://eth-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY}"

echo "=== Upkeep Details ==="
echo "Upkeep ID: $UPKEEP_ID"
echo ""

# Get balance using getBalance (simpler call, returns uint96)
BALANCE_RAW=$(cast call $REGISTRY "getBalance(uint256)(uint96)" $UPKEEP_ID --rpc-url "$RPC_URL" 2>/dev/null) || BALANCE_RAW=""

if [ -n "$BALANCE_RAW" ]; then
    # Extract just the numeric value (first word before space or bracket)
    BALANCE=$(echo "$BALANCE_RAW" | awk '{print $1}')
    # Convert balance from wei to LINK (18 decimals)
    BALANCE_LINK=$(echo "scale=4; $BALANCE / 1000000000000000000" | bc 2>/dev/null || echo "$BALANCE wei")
    echo "LINK Balance: $BALANCE_LINK LINK"
else
    echo "Could not fetch balance (check RPC connection)"
fi

# Get minimum balance required
MIN_BALANCE_RAW=$(cast call $REGISTRY "getMinBalance(uint256)(uint96)" $UPKEEP_ID --rpc-url "$RPC_URL" 2>/dev/null) || MIN_BALANCE_RAW=""

if [ -n "$MIN_BALANCE_RAW" ]; then
    MIN_BALANCE=$(echo "$MIN_BALANCE_RAW" | awk '{print $1}')
    MIN_BALANCE_LINK=$(echo "scale=4; $MIN_BALANCE / 1000000000000000000" | bc 2>/dev/null || echo "$MIN_BALANCE wei")
    echo "Min Balance Required: $MIN_BALANCE_LINK LINK"
fi

echo ""
echo "View full details on Chainlink Automation UI:"
echo "https://automation.chain.link/sepolia/$UPKEEP_ID"
