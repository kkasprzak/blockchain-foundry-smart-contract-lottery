// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Raffle {
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private immutable i_operator;

    event RaffleEntered(address indexed player);
    event WinnerSelected(address indexed winnerAddress, uint256 prizeAmount);

    error Raffle__SendMoreToEnterRaffle();
    error Raffle__NotEnoughTimeHasPassed();
    error Raffle__NotOperator();
    error Raffle__EntryWindowIsClosed();

    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_operator = msg.sender;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }

        if (_isEntryWindowClosed()) {
            revert Raffle__EntryWindowIsClosed();
        }

        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() external returns (address) {
        if (false == _isLotteryOperator(msg.sender)) {
            revert Raffle__NotOperator();
        }

        if (_isEntryWindowOpen()) {
            revert Raffle__NotEnoughTimeHasPassed();
        }

        if (s_players.length == 0) {
            _resetRaffleForNextRound();
            return address(0);
        }

        address winner = s_players[_getRandomWinnerIndex()];
        uint256 prizeAmount = address(this).balance;

        _resetRaffleForNextRound();

        (bool success,) = payable(winner).call{value: prizeAmount}("");
        require(success, "Prize transfer failed");

        emit WinnerSelected(winner, prizeAmount);

        return winner;
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

    function _getRandomWinnerIndex() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % s_players.length;
    }

    function _resetRaffleForNextRound() private {
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
    }

    function _isEntryWindowOpen() private view returns (bool) {
        return block.timestamp - s_lastTimeStamp <= i_interval;
    }

    function _isEntryWindowClosed() private view returns (bool) {
        return !_isEntryWindowOpen();
    }

    function _isLotteryOperator(address user) private view returns (bool) {
        return user == i_operator;
    }
}
