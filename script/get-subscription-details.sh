#!/bin/bash
#
# Get VRF Subscription Details from Sepolia
# Usage: ./script/get-subscription-details.sh
#

set -e

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found"
    exit 1
fi

# Validate required env vars
if [ -z "$ALCHEMY_API_KEY" ]; then
    echo "Error: ALCHEMY_API_KEY not set in .env"
    exit 1
fi

if [ -z "$VRF_SUBSCRIPTION_ID" ]; then
    echo "Error: VRF_SUBSCRIPTION_ID not set in .env"
    exit 1
fi

RPC_URL="https://eth-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY"
VRF_COORDINATOR="0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B"

echo "=== Subscription Details ==="
echo "Subscription ID: $VRF_SUBSCRIPTION_ID"
echo ""

# Call getSubscription on VRF Coordinator
result=$(cast call $VRF_COORDINATOR \
    "getSubscription(uint256)(uint96,uint96,uint64,address,address[])" \
    $VRF_SUBSCRIPTION_ID \
    --rpc-url "$RPC_URL")

# Parse results (cast returns each value on a new line)
balance=$(echo "$result" | sed -n '1p' | awk '{print $1}')
native_balance=$(echo "$result" | sed -n '2p' | awk '{print $1}')
req_count=$(echo "$result" | sed -n '3p' | awk '{print $1}')
owner=$(echo "$result" | sed -n '4p')
consumers=$(echo "$result" | sed -n '5p')

# Convert wei to LINK (divide by 10^18)
balance_link=$(echo "scale=4; $balance / 1000000000000000000" | bc)
native_balance_eth=$(echo "scale=4; $native_balance / 1000000000000000000" | bc)

echo "Owner: $owner"
echo "LINK Balance: $balance_link LINK ($balance wei)"
echo "Native Balance: $native_balance_eth ETH ($native_balance wei)"
echo "Request Count: $req_count"
echo "Consumers: $consumers"
