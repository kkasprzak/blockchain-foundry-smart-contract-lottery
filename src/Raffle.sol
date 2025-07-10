// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Raffle {
    error Raffle__SendMoreToEnterRaffle();
    
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        s_players.push(payable(msg.sender));
    }

    function isPlayerInRaffle(address player) external view returns (bool) {
        for (uint256 i = 0; i < s_players.length; i++) {
            if (s_players[i] == player) {
                return true;
            }
        }
        return false;
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}