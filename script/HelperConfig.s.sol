// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address vrfCoordinator;
        bytes32 keyHash;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
    }

    function getActiveNetworkConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            vrfCoordinator: address(0),
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae, // Gas Lane
            subscriptionId: 0,
            callbackGasLimit: 500000
        });
    }
}
