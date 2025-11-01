// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract Raffle is VRFConsumerBaseV2Plus {
    enum RaffleState {
        OPEN,
        DRAWING
    }

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

    uint256 private s_requestId;
    RaffleState private s_raffleState;

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
    error Raffle__DrawingInProgress();
    error Raffle__RaffleIsNotDrawing();
    error Raffle__InvalidRequestId();

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

        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }

        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__DrawingInProgress();
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

    function pickWinner() external {
        if (false == _isLotteryOperator(msg.sender)) {
            revert Raffle__NotOperator();
        }

        if (_isEntryWindowOpen()) {
            revert Raffle__NotEnoughTimeHasPassed();
        }

        if (s_players.length == 0) {
            _resetRaffleForNextRound();
            return;
        }

        s_raffleState = RaffleState.DRAWING;

        s_requestId = _requestRandomWords();
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function isPlayerInRaffle(address player) public view returns (bool) {
        return s_playersInRaffle[player];
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal virtual override {
        if (s_raffleState != RaffleState.DRAWING) {
            revert Raffle__RaffleIsNotDrawing();
        }

        if (s_requestId != requestId) {
            revert Raffle__InvalidRequestId();
        }

        address winner = s_players[randomWords[0] % s_players.length];
        uint256 prizeAmount = address(this).balance;

        _resetRaffleForNextRound();

        (bool success,) = payable(winner).call{value: prizeAmount}("");

        if (success) {
            emit WinnerSelected(winner, prizeAmount);
        } else {
            emit PrizeTransferFailed(winner, prizeAmount);
        }
    }

    function _resetRaffleForNextRound() private {
        for (uint256 i = 0; i < s_players.length; i++) {
            s_playersInRaffle[s_players[i]] = false;
        }
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    function _addPlayerToRaffle(address player) private {
        s_players.push(payable(player));
        s_playersInRaffle[player] = true;
    }

    function _requestRandomWords() private returns (uint256) {
        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
        });

        return s_vrfCoordinator.requestRandomWords(req);
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
