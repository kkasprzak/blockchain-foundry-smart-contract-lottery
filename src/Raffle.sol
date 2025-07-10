// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

error SendMoreToEnterRaffle();

contract Raffle {
    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert SendMoreToEnterRaffle();
        }
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}