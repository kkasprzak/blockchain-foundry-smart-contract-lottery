// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ChainlinkVRFConfig} from "./ChainlinkVRFConfig.s.sol";

contract AnvilChainlinkVRFConfig is ChainlinkVRFConfig {
    function createSubscription() external pure override returns (uint256) {
        return 0;
    }

    function fundSubscription(uint256, uint256) external pure override {
        // No-op for Anvil: subscriptions are handled in AnvilNetworkConfig.deployRaffle()
        return;
    }

    function addConsumer(uint256, address) external pure override {
        // No-op for Anvil: consumers are added in AnvilNetworkConfig.deployRaffle()
        return;
    }
}
