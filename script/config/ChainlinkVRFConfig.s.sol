// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";

abstract contract ChainlinkVRFConfig is Script {
    function createSubscription() external virtual returns (uint256);
    function fundSubscription(uint256 subscriptionId, uint256 amount) external virtual;
    function addConsumer(uint256 subscriptionId, address consumer) external virtual;
}
