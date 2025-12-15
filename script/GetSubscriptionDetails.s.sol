// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, ChainlinkConfig} from "./HelperConfig.s.sol";

contract GetSubscriptionDetails is Script {
    function run() external {
        uint256 subscriptionId = vm.envUint("VRF_SUBSCRIPTION_ID");
        getSubscriptionDetails(subscriptionId);
    }

    function getSubscriptionDetails(uint256 subscriptionId) public {
        HelperConfig helperConfig = new HelperConfig();
        ChainlinkConfig chainlinkConfig = helperConfig.chainlinkConfigForChain(block.chainid);

        (uint96 balance, uint96 nativeBalance, uint64 reqCount, address owner, address[] memory consumers) =
            chainlinkConfig.getSubscription(subscriptionId);

        console.log("=== Subscription Details ===");
        console.log("Subscription ID:", subscriptionId);
        console.log("Owner:", owner);
        console.log("LINK Balance (wei):", balance);
        console.log("Native Balance (wei):", nativeBalance);
        console.log("Request Count:", reqCount);
        console.log("Consumers count:", consumers.length);

        for (uint256 i = 0; i < consumers.length; i++) {
            console.log("  Consumer", i, ":", consumers[i]);
        }
    }
}
