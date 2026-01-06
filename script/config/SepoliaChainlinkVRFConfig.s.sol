// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ChainlinkVRFConfig} from "./ChainlinkVRFConfig.s.sol";
import {IVRFSubscriptionV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFSubscriptionV2Plus.sol";
import {IERC677} from "@chainlink/contracts/src/v0.8/shared/token/ERC677/IERC677.sol";

contract SepoliaChainlinkVRFConfig is ChainlinkVRFConfig {
    address private constant VRF_COORDINATOR = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    address private constant LINK_TOKEN = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    function createSubscription() external override returns (uint256) {
        vm.startBroadcast();

        uint256 subscriptionId = IVRFSubscriptionV2Plus(VRF_COORDINATOR).createSubscription();

        vm.stopBroadcast();

        return subscriptionId;
    }

    function fundSubscription(uint256 subscriptionId, uint256 amount) external override {
        require(subscriptionId > 0, "Invalid subscription ID");
        require(amount > 0, "Amount must be greater than 0");

        vm.startBroadcast();

        require(
            IERC677(LINK_TOKEN).transferAndCall(VRF_COORDINATOR, amount, abi.encode(subscriptionId)),
            "LINK transfer failed"
        );

        vm.stopBroadcast();
    }

    function addConsumer(uint256 subscriptionId, address consumer) external override {
        require(subscriptionId > 0, "Invalid subscription ID");
        require(consumer != address(0), "Invalid consumer address");

        vm.startBroadcast();

        IVRFSubscriptionV2Plus(VRF_COORDINATOR).addConsumer(subscriptionId, consumer);

        vm.stopBroadcast();
    }
}
