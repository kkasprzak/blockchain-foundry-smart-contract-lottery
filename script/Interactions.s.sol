// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract RafflePickWinner is Script {
    error RafflePickWinner__InvalidContractAddress();

    function pickWinner(address contractAddress) public returns (address) {
        if (contractAddress == address(0)) {
            revert RafflePickWinner__InvalidContractAddress();
        }

        vm.startBroadcast();
        address winner = Raffle(payable(contractAddress)).pickWinner();
        vm.stopBroadcast();

        return winner;
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);

        pickWinner(contractAddress);
    }
}

contract DeployVRFMock is Script {
    function deployVRFMock() public returns (VRFCoordinatorV2_5Mock, uint256) {
        vm.startBroadcast();

        // Deploy VRF Coordinator Mock
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(
            0.002 ether, // Base fee
            40 gwei, // Gas price link
            0.004 ether // Wei per unit link
        );

        // Create subscription
        uint256 subscriptionId = vrfCoordinatorMock.createSubscription();

        vm.stopBroadcast();

        console.log("VRF Coordinator deployed to:", address(vrfCoordinatorMock));
        console.log("Subscription ID created:", subscriptionId);

        return (vrfCoordinatorMock, subscriptionId);
    }

    function run() external {
        deployVRFMock();
    }
}

contract FundSubscription is Script {
    function fundSubscription(address vrfCoordinator, uint256 subscriptionId, uint256 amount) public {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId, amount);
        vm.stopBroadcast();

        console.log("Funded subscription", subscriptionId, "with amount:", amount);
    }

    function run() external {
        fundSubscription(
            address(0xa513E6E4b8f2a923D98304ec87F64353C4D5C853),
            49932079205428894356633442460995043722247664406178411110384916193100478739311,
            1 ether
        );
    }
}

contract AddConsumer is Script {
    function addConsumer(address vrfCoordinator, uint256 subscriptionId, address raffle) public {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subscriptionId, raffle);
        vm.stopBroadcast();

        console.log("Added consumer", raffle, "to subscription", subscriptionId);
    }

    function run() external {}
}
