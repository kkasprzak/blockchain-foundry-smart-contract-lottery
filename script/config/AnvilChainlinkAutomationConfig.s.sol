// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ChainlinkAutomationConfig} from "./ChainlinkAutomationConfig.s.sol";

contract AnvilChainlinkAutomationConfig is ChainlinkAutomationConfig {
    function registerUpkeep(string calldata, address, uint32, uint96) external pure override returns (uint256) {
        return 0;
    }

    function fundUpkeep(uint256, uint96) external pure override {
        // No-op for Anvil: automation is not supported locally
        return;
    }
}
