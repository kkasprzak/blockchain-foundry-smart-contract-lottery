// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {NetworkConfig} from "./NetworkConfig.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {MyVrfCoordinatorV25Mock} from "../../test/mocks/MyVrfCoordinatorV25Mock.sol";

contract AnvilNetworkConfig is NetworkConfig {
    uint96 private constant VRF_MOCK_BASE_FEE = 1 wei;
    uint96 private constant VRF_MOCK_GAS_PRICE = 1 gwei;
    int256 private constant VRF_MOCK_WEI_PER_UNIT_LINK = 0.004 ether;
    uint256 private constant VRF_SUBSCRIPTION_FUND_AMOUNT = 100_000 ether;
    bytes32 private constant VRF_KEY_HASH = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint32 private constant VRF_CALLBACK_GAS_LIMIT = 500000;

    function deployRaffle(uint256 entranceFee, uint256 interval) external override returns (Raffle) {
        vm.startBroadcast();

        MyVrfCoordinatorV25Mock vrfCoordinatorMock =
            new MyVrfCoordinatorV25Mock(VRF_MOCK_BASE_FEE, VRF_MOCK_GAS_PRICE, VRF_MOCK_WEI_PER_UNIT_LINK);

        uint256 subscriptionId = vrfCoordinatorMock.deterministicCreateSubscription();
        vrfCoordinatorMock.fundSubscription(subscriptionId, VRF_SUBSCRIPTION_FUND_AMOUNT);

        Raffle raffle = new Raffle(
            entranceFee, interval, address(vrfCoordinatorMock), VRF_KEY_HASH, subscriptionId, VRF_CALLBACK_GAS_LIMIT
        );

        vrfCoordinatorMock.addConsumer(subscriptionId, address(raffle));

        vm.stopBroadcast();

        return raffle;
    }
}
