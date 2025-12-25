#!/bin/bash

# Get Chainlink Automation upkeep details
# Usage: ./script/get-upkeep-details.sh <upkeep_id>

set -e

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

# getUpkeep returns UpkeepInfo struct
RESULT=$(cast call $REGISTRY "getUpkeep(uint256)(address,uint32,bytes,uint96,address,uint64,uint32,uint96,bool,bytes)" $UPKEEP_ID --rpc-url $RPC_URL 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "Error: Could not fetch upkeep details. Is the upkeep ID correct?"
    exit 1
fi

# Parse the result (cast returns values on separate lines)
TARGET=$(echo "$RESULT" | sed -n '1p')
EXECUTE_GAS=$(echo "$RESULT" | sed -n '2p')
BALANCE=$(echo "$RESULT" | sed -n '4p')
ADMIN=$(echo "$RESULT" | sed -n '5p')
LAST_PERFORMED=$(echo "$RESULT" | sed -n '7p')
AMOUNT_SPENT=$(echo "$RESULT" | sed -n '8p')
PAUSED=$(echo "$RESULT" | sed -n '9p')

# Convert balance from wei to LINK (18 decimals)
BALANCE_LINK=$(echo "scale=4; $BALANCE / 1000000000000000000" | bc 2>/dev/null || echo "$BALANCE wei")
SPENT_LINK=$(echo "scale=4; $AMOUNT_SPENT / 1000000000000000000" | bc 2>/dev/null || echo "$AMOUNT_SPENT wei")

echo "Target Contract: $TARGET"
echo "Admin: $ADMIN"
echo "Gas Limit: $EXECUTE_GAS"
echo "LINK Balance: $BALANCE_LINK LINK"
echo "Amount Spent: $SPENT_LINK LINK"
echo "Last Performed Block: $LAST_PERFORMED"
echo "Paused: $PAUSED"
echo ""
echo "View on Chainlink Automation UI:"
echo "https://automation.chain.link/sepolia/$UPKEEP_ID"
