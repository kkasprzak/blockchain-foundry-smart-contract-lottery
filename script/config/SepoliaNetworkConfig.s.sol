// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {NetworkConfig} from "./NetworkConfig.s.sol";
import {Raffle} from "../../src/Raffle.sol";

contract SepoliaNetworkConfig is NetworkConfig {
    address private constant VRF_COORDINATOR = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 private constant KEY_HASH = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint32 private constant CALLBACK_GAS_LIMIT = 200000;

    uint256 private immutable SUBSCRIPTION_ID;

    error SepoliaNetworkConfig__SubscriptionIdRequired();

    constructor(uint256 subscriptionId) {
        if (subscriptionId == 0) {
            revert SepoliaNetworkConfig__SubscriptionIdRequired();
        }
        SUBSCRIPTION_ID = subscriptionId;
    }

    function deployRaffle(uint256 entranceFee, uint256 interval) external override returns (Raffle) {
        vm.startBroadcast();

        Raffle raffle =
            new Raffle(entranceFee, interval, VRF_COORDINATOR, KEY_HASH, SUBSCRIPTION_ID, CALLBACK_GAS_LIMIT);

        vm.stopBroadcast();

        return raffle;
    }
}
