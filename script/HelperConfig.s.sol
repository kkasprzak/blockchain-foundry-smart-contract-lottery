// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {MyVRFCoordinatorV2_5Mock} from "../test/mocks/MyVRFCoordinatorV2_5Mock.sol";
import {IVRFSubscriptionV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFSubscriptionV2Plus.sol";
import {IERC677} from "@chainlink/contracts/src/v0.8/shared/token/ERC677/IERC677.sol";

abstract contract NetworkConfig is Script {
    function deployRaffle(uint256 entranceFee, uint256 interval) external virtual returns (Raffle);
}

abstract contract ChainlinkConfig is Script {
    function createSubscription() external virtual returns (uint256);
    function fundSubscription(uint256 subscriptionId, uint256 amount) external virtual;
    function addConsumer(uint256 subscriptionId, address consumer) external virtual;
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

contract AnvilChainlinkConfig is ChainlinkConfig {
    function createSubscription() external override returns (uint256) {
        return 0;
    }

    function fundSubscription(uint256, uint256) external override {}

    function addConsumer(uint256, address) external override {}
}

contract SepoliaNetworkConfig is NetworkConfig {
    address private constant VRF_COORDINATOR = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 private constant KEY_HASH = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint32 private constant CALLBACK_GAS_LIMIT = 200000;

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

contract SepoliaChainlinkConfig is ChainlinkConfig {
    address private constant VRF_COORDINATOR = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    address private constant LINK_TOKEN = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    function createSubscription() external override returns (uint256) {
        vm.startBroadcast();

        uint256 subscriptionId = IVRFSubscriptionV2Plus(VRF_COORDINATOR).createSubscription();

        vm.stopBroadcast();

        return subscriptionId;
    }

    function fundSubscription(uint256 subscriptionId, uint256 amount) external override {
        vm.startBroadcast();

        IERC677(LINK_TOKEN).transferAndCall(VRF_COORDINATOR, amount, abi.encode(subscriptionId));

        vm.stopBroadcast();
    }

    function addConsumer(uint256 subscriptionId, address consumer) external override {
        vm.startBroadcast();

        IVRFSubscriptionV2Plus(VRF_COORDINATOR).addConsumer(subscriptionId, consumer);

        vm.stopBroadcast();
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

    function chainlinkConfigForChain(uint256 chainId) public returns (ChainlinkConfig) {
        if (chainId == SEPOLIA_CHAIN_ID) {
            return new SepoliaChainlinkConfig();
        }
        return new AnvilChainlinkConfig();
    }
}
