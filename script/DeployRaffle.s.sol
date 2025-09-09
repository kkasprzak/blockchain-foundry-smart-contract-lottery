// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract DeployRaffle is Script {
    uint256 public constant DEFAULT_ENTRANCE_FEE = 0.01 ether;
    uint256 public constant DEFAULT_INTERVAL = 300; // 5 minutes for testing

    function setUp() public {}

    function run() public returns (Raffle) {
        return deployRaffle(DEFAULT_ENTRANCE_FEE, DEFAULT_INTERVAL);
    }

    function deployRaffle(uint256 entranceFee, uint256 interval) public returns (Raffle) {
        vm.startBroadcast();

        Raffle raffle = new Raffle(entranceFee, interval, address(0));

        vm.stopBroadcast();

        console.log("Raffle deployed to:", address(raffle));
        console.log("Entrance Fee:", entranceFee);
        console.log("Interval:", interval);

        return raffle;
    }
}
