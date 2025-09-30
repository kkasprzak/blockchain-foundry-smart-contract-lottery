// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {MyVRFCoordinatorV2_5Mock} from "../test/mocks/MyVRFCoordinatorV2_5Mock.sol";
import {AddConsumer} from "./Interactions.s.sol";

abstract contract NetworkConfig is Script {
    function deployRaffle(uint256 entranceFee, uint256 interval) external virtual returns (Raffle);
}

contract AnvilNetworkConfig is NetworkConfig {
    function deployRaffle(uint256 entranceFee, uint256 interval) external override returns (Raffle) {
        vm.startBroadcast();

        // Create VRF Coordinator Mock
        MyVRFCoordinatorV2_5Mock vrfCoordinatorMock = new MyVRFCoordinatorV2_5Mock(
            0.002 ether, // Base fee: 0.1 LINK
            40 gwei, // Gas price link: 1 gwei
            0.004 ether // Wei per unit link: 4000000000000000000 (4e18)
        );

        uint256 subscriptionId = vrfCoordinatorMock.deterministicCreateSubscription();
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
