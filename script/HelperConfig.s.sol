// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {MyVRFCoordinatorV2_5Mock} from "../test/mocks/MyVRFCoordinatorV2_5Mock.sol";

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

contract SepoliaNetworkConfig is NetworkConfig {
    address private constant VRF_COORDINATOR = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 private constant KEY_HASH = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint32 private constant CALLBACK_GAS_LIMIT = 500000;

    uint256 private immutable i_subscriptionId;

    error SepoliaNetworkConfig__SubscriptionIdRequired();

    constructor(uint256 subscriptionId) {
        if (subscriptionId == 0) {
            revert SepoliaNetworkConfig__SubscriptionIdRequired();
        }
        i_subscriptionId = subscriptionId;
    }

    function deployRaffle(uint256 entranceFee, uint256 interval) external override returns (Raffle) {
        vm.startBroadcast();

        Raffle raffle =
            new Raffle(entranceFee, interval, VRF_COORDINATOR, KEY_HASH, i_subscriptionId, CALLBACK_GAS_LIMIT);

        vm.stopBroadcast();

        return raffle;
    }
}

contract HelperConfig is Script {
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;

    function networkConfigForChain(uint256 chainId, uint256 subscriptionId) public returns (NetworkConfig) {
        if (chainId == SEPOLIA_CHAIN_ID) {
            return new SepoliaNetworkConfig(subscriptionId);
        }
        return new AnvilNetworkConfig();
    }
}
