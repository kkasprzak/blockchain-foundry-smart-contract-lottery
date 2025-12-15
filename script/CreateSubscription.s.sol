// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, ChainlinkConfig} from "./HelperConfig.s.sol";

contract CreateSubscription is Script {
    function run() external returns (uint256 subscriptionId) {
        HelperConfig helperConfig = new HelperConfig();
        ChainlinkConfig chainlinkConfig = helperConfig.chainlinkConfigForChain(block.chainid);

        subscriptionId = chainlinkConfig.createSubscription();

        console.log("Created subscription with ID:", subscriptionId);
        console.log("Add this to your .env file:");
        console.log("VRF_SUBSCRIPTION_ID=%s", subscriptionId);

        return subscriptionId;
    }
}
