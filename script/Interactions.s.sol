// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract PerformUpkeep is Script {
    error PerformUpkeep__InvalidContractAddress();

    function performUpkeep(address contractAddress) public {
        if (contractAddress == address(0)) {
            revert PerformUpkeep__InvalidContractAddress();
        }

        vm.startBroadcast();
        Raffle(payable(contractAddress)).performUpkeep("");
        vm.stopBroadcast();
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);

        performUpkeep(contractAddress);
    }
}
