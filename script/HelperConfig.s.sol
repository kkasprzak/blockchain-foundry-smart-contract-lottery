// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {NetworkConfig} from "./config/NetworkConfig.s.sol";
import {AnvilNetworkConfig} from "./config/AnvilNetworkConfig.s.sol";
import {SepoliaNetworkConfig} from "./config/SepoliaNetworkConfig.s.sol";
import {ChainlinkVRFConfig} from "./config/ChainlinkVRFConfig.s.sol";
import {AnvilChainlinkVRFConfig} from "./config/AnvilChainlinkVRFConfig.s.sol";
import {SepoliaChainlinkVRFConfig} from "./config/SepoliaChainlinkVRFConfig.s.sol";
import {ChainlinkAutomationConfig} from "./config/ChainlinkAutomationConfig.s.sol";
import {AnvilChainlinkAutomationConfig} from "./config/AnvilChainlinkAutomationConfig.s.sol";
import {SepoliaChainlinkAutomationConfig} from "./config/SepoliaChainlinkAutomationConfig.s.sol";

contract HelperConfig is Script {
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;

    function networkConfigForChain(uint256 chainId, uint256 subscriptionId) public returns (NetworkConfig) {
        if (chainId == SEPOLIA_CHAIN_ID) {
            return new SepoliaNetworkConfig(subscriptionId);
        }
        return new AnvilNetworkConfig();
    }

    function chainlinkVrfConfigForChain(uint256 chainId) public returns (ChainlinkVRFConfig) {
        if (chainId == SEPOLIA_CHAIN_ID) {
            return new SepoliaChainlinkVRFConfig();
        }
        return new AnvilChainlinkVRFConfig();
    }

    function chainlinkAutomationConfigForChain(uint256 chainId) public returns (ChainlinkAutomationConfig) {
        if (chainId == SEPOLIA_CHAIN_ID) {
            return new SepoliaChainlinkAutomationConfig();
        }
        return new AnvilChainlinkAutomationConfig();
    }
}
