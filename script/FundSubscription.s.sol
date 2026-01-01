// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, ChainlinkConfig} from "./HelperConfig.s.sol";

contract FundSubscription is Script {
    uint256 public constant DEFAULT_FUND_AMOUNT = 1e17;

    function run() external {
        uint256 subscriptionId = vm.envUint("VRF_SUBSCRIPTION_ID");
        fundSubscription(subscriptionId, DEFAULT_FUND_AMOUNT);
    }

    function fundSubscription(uint256 subscriptionId, uint256 amount) public {
        HelperConfig helperConfig = new HelperConfig();
        ChainlinkConfig chainlinkConfig = helperConfig.chainlinkConfigForChain(block.chainid);

        console.log("Funding subscription:", subscriptionId);
        console.log("Amount (LINK wei):", amount);

        chainlinkConfig.fundSubscription(subscriptionId, amount);

        console.log("Subscription funded successfully!");
    }
}
