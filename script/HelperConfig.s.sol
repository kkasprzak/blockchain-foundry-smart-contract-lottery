// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

abstract contract NetworkConfig is Script {
    function deployRaffle(uint256 entranceFee, uint256 interval) external virtual returns (Raffle);
}

contract AnvilNetworkConfig is NetworkConfig {
    function deployRaffle(uint256 entranceFee, uint256 interval) external override returns (Raffle) {
        vm.startBroadcast();

        // Create VRF Coordinator Mock
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(
            100000000000000000, // Base fee
            1000000000, // Gas price link
            5300000000000000 // Wei per unit link
        );

        // Create and fund subscription
        uint256 subscriptionId = vrfCoordinatorMock.createSubscription();
        vrfCoordinatorMock.fundSubscription(subscriptionId, 100000000000000000000);

        // Deploy Raffle contract
        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            address(vrfCoordinatorMock),
            0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae, // Key hash
            subscriptionId,
            500000 // Callback gas limit
        );

        // Add Raffle as consumer to VRF subscription
        vrfCoordinatorMock.addConsumer(subscriptionId, address(raffle));

        vm.stopBroadcast();

        return raffle;
    }
}

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    constructor() {
        // For now, always use Anvil config
        // We'll add Sepolia detection in the next step
        activeNetworkConfig = new AnvilNetworkConfig();
    }

    function networkConfig() public view returns (NetworkConfig) {
        return activeNetworkConfig;
    }
}
