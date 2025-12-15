// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, ChainlinkConfig} from "./HelperConfig.s.sol";

contract AddConsumer is Script {
    function run() external {
        uint256 subscriptionId = vm.envUint("VRF_SUBSCRIPTION_ID");
        address consumerAddress = vm.envAddress("RAFFLE_CONTRACT_ADDRESS");

        addConsumer(subscriptionId, consumerAddress);
    }

    function addConsumer(uint256 subscriptionId, address consumer) public {
        HelperConfig helperConfig = new HelperConfig();
        ChainlinkConfig chainlinkConfig = helperConfig.chainlinkConfigForChain(block.chainid);

        console.log("Adding consumer to subscription:", subscriptionId);
        console.log("Consumer address:", consumer);

        chainlinkConfig.addConsumer(subscriptionId, consumer);

        console.log("Consumer added successfully!");
    }
}
