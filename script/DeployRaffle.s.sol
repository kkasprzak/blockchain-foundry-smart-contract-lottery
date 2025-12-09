// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig, NetworkConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract DeployRaffle is Script {
    uint256 public constant DEFAULT_ENTRANCE_FEE = 0.01 ether;
    uint256 public constant DEFAULT_INTERVAL = 300; // 5 minutes for testing

    function setUp() public {}

    function run() public returns (Raffle) {
        return deployRaffle(DEFAULT_ENTRANCE_FEE, DEFAULT_INTERVAL);
    }

    function deployRaffle(uint256 entranceFee, uint256 interval) public returns (Raffle) {
        uint256 subscriptionId = vm.envOr("VRF_SUBSCRIPTION_ID", uint256(0));

        HelperConfig helperConfig = new HelperConfig();
        NetworkConfig networkConfig = helperConfig.networkConfigForChain(block.chainid, subscriptionId);

        Raffle raffle = networkConfig.deployRaffle(entranceFee, interval);

        console.log("Raffle deployed to:", address(raffle));
        console.log("Entrance Fee:", entranceFee);
        console.log("Interval:", interval);

        return raffle;
    }
}
