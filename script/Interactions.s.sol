// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract RaffleEnterRaffle is Script {
    function enterRaffle(address contractAddress) public {
        vm.startBroadcast();
        Raffle(payable(contractAddress)).enterRaffle{value: 0.1 ether}();
        vm.stopBroadcast();

        console.log("Raffle entered successfully");
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);

        enterRaffle(contractAddress);
    }
}
