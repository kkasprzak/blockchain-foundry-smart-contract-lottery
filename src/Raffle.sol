// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract Raffle is VRFConsumerBaseV2Plus {
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    address payable[] private s_players;
    mapping(address => bool) private s_playersInRaffle;
    uint256 private s_lastTimeStamp;
    address private immutable i_operator;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    event RaffleEntered(address indexed player);
    event WinnerSelected(address indexed winnerAddress, uint256 prizeAmount);
    event PrizeTransferFailed(address indexed winnerAddress, uint256 prizeAmount);

    error Raffle__SendMoreToEnterRaffle();
    error Raffle__NotEnoughTimeHasPassed();
    error Raffle__NotOperator();
    error Raffle__EntryWindowIsClosed();
    error Raffle__InvalidEntranceFee();
    error Raffle__InvalidInterval();
    error Raffle__PlayerIsAlreadyInRaffle();

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 keyHash,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        if (entranceFee == 0) {
            revert Raffle__InvalidEntranceFee();
        }

        if (interval == 0) {
            revert Raffle__InvalidInterval();
        }

        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_operator = msg.sender;
        i_keyHash = keyHash;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }

        if (_isEntryWindowClosed()) {
            revert Raffle__EntryWindowIsClosed();
        }

        if (isPlayerInRaffle(msg.sender)) {
            revert Raffle__PlayerIsAlreadyInRaffle();
        }

        _addPlayerToRaffle(msg.sender);

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

        if (success) {
            emit WinnerSelected(winner, prizeAmount);
        } else {
            emit PrizeTransferFailed(winner, prizeAmount);
        }

        return winner;
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function isPlayerInRaffle(address player) public view returns (bool) {
        return s_playersInRaffle[player];
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal virtual override {}

    function _resetRaffleForNextRound() private {
        for (uint256 i = 0; i < s_players.length; i++) {
            s_playersInRaffle[s_players[i]] = false;
        }
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
    }

    function _addPlayerToRaffle(address player) private {
        s_players.push(payable(player));
        s_playersInRaffle[player] = true;
    }

    function _getRandomWinnerIndex() private returns (uint256) {
        uint256 requestId;
        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
        });

        requestId = s_vrfCoordinator.requestRandomWords(req);

        return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % s_players.length;
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
