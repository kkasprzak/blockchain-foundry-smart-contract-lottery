// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {NetworkConfig} from "./NetworkConfig.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {MyVrfCoordinatorV25Mock} from "../../test/mocks/MyVrfCoordinatorV25Mock.sol";

contract AnvilNetworkConfig is NetworkConfig {
    function deployRaffle(uint256 entranceFee, uint256 interval) external override returns (Raffle) {
        vm.startBroadcast();

        // Create VRF Coordinator Mock
        MyVrfCoordinatorV25Mock vrfCoordinatorMock = new MyVrfCoordinatorV25Mock(
            0.002 ether,
            40 gwei,
            0.004 ether
        );

        uint256 subscriptionId = vrfCoordinatorMock.deterministicCreateSubscription();
        vrfCoordinatorMock.fundSubscription(subscriptionId, 100000000000000000000);

        // Deploy Raffle contract
        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            address(vrfCoordinatorMock),
            0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId,
            500000
        );

        vrfCoordinatorMock.addConsumer(subscriptionId, address(raffle));

        vm.stopBroadcast();

        return raffle;
    }
}
