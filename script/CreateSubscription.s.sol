// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, ChainlinkVRFConfig} from "./HelperConfig.s.sol";

contract CreateSubscription is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        ChainlinkVRFConfig chainlinkVrfConfig = helperConfig.chainlinkVrfConfigForChain(block.chainid);

        chainlinkVrfConfig.createSubscription();

        console.log("Subscription created successfully!");
        console.log("To get your subscription ID:");
        console.log("  1. Go to https://vrf.chain.link/sepolia");
        console.log("  2. Connect your wallet");
        console.log("  3. Copy the subscription ID");
        console.log("  4. Add to .env: VRF_SUBSCRIPTION_ID=<your_id>");
    }
}
