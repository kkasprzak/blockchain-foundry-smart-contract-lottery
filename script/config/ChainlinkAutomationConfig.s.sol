// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";

abstract contract ChainlinkAutomationConfig is Script {
    function registerUpkeep(string calldata name, address upkeepContract, uint32 gasLimit, uint96 amount)
        external
        virtual
        returns (uint256);

    function fundUpkeep(uint256 upkeepId, uint96 amount) external virtual;
}
