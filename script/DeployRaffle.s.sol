// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract DeployRaffle is Script {
    uint256 public constant DEFAULT_ENTRANCE_FEE = 0.01 ether;
    uint256 public constant DEFAULT_INTERVAL = 300; // 5 minutes for testing

    function setUp() public {}

    function run() public returns (Raffle) {
        return deployRaffle(DEFAULT_ENTRANCE_FEE, DEFAULT_INTERVAL);
    }

    function deployRaffle(uint256 entranceFee, uint256 interval) public returns (Raffle) {
        HelperConfig.NetworkConfig memory networkConfig = new HelperConfig().getActiveNetworkConfig();

        VRFCoordinatorV2_5Mock vrfCoordinatorMock =
            new VRFCoordinatorV2_5Mock(100000000000000000, 1000000000, 5300000000000000);
        uint256 subscriptionId = vrfCoordinatorMock.createSubscription();
        vrfCoordinatorMock.fundSubscription(subscriptionId, 100000000000000000000);

        vm.startBroadcast();

        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            address(vrfCoordinatorMock),
            networkConfig.keyHash,
            subscriptionId,
            networkConfig.callbackGasLimit
        );

        vm.stopBroadcast();

        vrfCoordinatorMock.addConsumer(subscriptionId, address(raffle));

        console.log("Raffle deployed to:", address(raffle));
        console.log("Entrance Fee:", entranceFee);
        console.log("Interval:", interval);

        return raffle;
    }
}
