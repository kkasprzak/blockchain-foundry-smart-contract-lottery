// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract RafflePickWinner is Script {
    error RafflePickWinner__InvalidContractAddress();

    function pickWinner(address contractAddress) public returns (address) {
        if (contractAddress == address(0)) {
            revert RafflePickWinner__InvalidContractAddress();
        }

        console.log("Attempting to pick winner for raffle at:", contractAddress);

        vm.startBroadcast();
        address winner = Raffle(payable(contractAddress)).pickWinner();
        vm.stopBroadcast();

        console.log("Winner selection completed");
        console.log("Winner address:", winner);
        console.log("Winner balance:", winner.balance);

        return winner;
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);

        pickWinner(contractAddress);
    }
}
