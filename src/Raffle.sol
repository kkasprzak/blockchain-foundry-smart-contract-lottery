// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Raffle {
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    event RaffleEntered(address indexed player);

    error Raffle__SendMoreToEnterRaffle();
    error Raffle__NotEnoughTimeHasPassed();

    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function isPlayerInRaffle(address player) external view returns (bool) {
        for (uint256 i = 0; i < s_players.length; i++) {
            if (s_players[i] == player) {
                return true;
            }
        }
        return false;
    }

    function pickWinner() external {
        if (block.timestamp - s_lastTimeStamp < i_interval) {
            revert Raffle__NotEnoughTimeHasPassed();
        }
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
