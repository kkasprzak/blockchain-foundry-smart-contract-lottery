// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {
    AutomationCompatibleInterface
} from "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";

contract Raffle is VRFConsumerBaseV2Plus, ReentrancyGuard, AutomationCompatibleInterface {
    enum RaffleState {
        OPEN,
        DRAWING
    }

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    address private constant NO_WINNER = address(0);
    uint256 private constant NO_PRIZE = 0;
    bytes private constant EMPTY_PERFORM_DATA = "";

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
    uint256 private s_roundNumber;

    event RaffleEntered(uint256 indexed roundNumber, address indexed player);
    event PrizeTransferFailed(uint256 indexed roundNumber, address indexed winnerAddress, uint256 prizeAmount);
    event DrawRequested(uint256 indexed roundNumber);
    event RoundCompleted(uint256 indexed roundNumber, address indexed winner, uint256 prize);

    error Raffle__SendMoreToEnterRaffle();
    error Raffle__NotEnoughTimeHasPassed();
    error Raffle__NotOperator();
    error Raffle__EntryWindowIsClosed();
    error Raffle__InvalidEntranceFee();
    error Raffle__InvalidInterval();
    error Raffle__PlayerIsAlreadyInRaffle(); // TODO: Refactor(Czy nadal uzywamy tego błędu?)
    error Raffle__DrawingInProgress();
    error Raffle__RaffleIsNotDrawing();
    error Raffle__InvalidRequestId();
    error Raffle__DrawingNotAllowed();

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
        s_roundNumber = 1;
    }

    function enterRaffle() external payable {
        if (msg.value != i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }

        if (_isRaffleInState(RaffleState.DRAWING)) {
            revert Raffle__DrawingInProgress();
        }

        if (_isEntryWindowClosed()) {
            revert Raffle__EntryWindowIsClosed();
        }

        if (isPlayerInRaffle(msg.sender)) {
            revert Raffle__PlayerIsAlreadyInRaffle();
        }

        _addPlayerToRaffle(msg.sender);

        emit RaffleEntered(s_roundNumber, msg.sender);
    }

    // slither-disable-next-line reentrancy-events
    function pickWinner() external {
        if (false == _isLotteryOperator(msg.sender)) {
            revert Raffle__NotOperator();
        }

        if (_isEntryWindowOpen()) {
            revert Raffle__NotEnoughTimeHasPassed();
        }

        if (s_players.length == 0) {
            uint256 roundNumber = s_roundNumber;

            _resetRaffleForNextRound();
            emit RoundCompleted(roundNumber, NO_WINNER, NO_PRIZE);
            return;
        }

        s_raffleState = RaffleState.DRAWING;
        s_requestId = _requestRandomWords();

        emit DrawRequested(s_roundNumber);
    }

    function performUpkeep(
        bytes calldata /* performData */
    )
        external
        override
    {
        if (_isEntryWindowOpen() || _isRaffleInState(RaffleState.DRAWING)) {
            revert Raffle__DrawingNotAllowed();
        }

        if (s_players.length == 0) {
            uint256 roundNumber = s_roundNumber;
            _resetRaffleForNextRound();
            emit RoundCompleted(roundNumber, NO_WINNER, NO_PRIZE);
            return;
        }

        s_raffleState = RaffleState.DRAWING;
        s_requestId = _requestRandomWords();
        emit DrawRequested(s_roundNumber);
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function isPlayerInRaffle(address player) public view returns (bool) {
        return s_playersInRaffle[player];
    }

    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        return (_isEntryWindowClosed() && _isRaffleInState(RaffleState.OPEN), EMPTY_PERFORM_DATA);
    }

    // slither-disable-next-line reentrancy-eth
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords)
        internal
        virtual
        override
        nonReentrant
    {
        if (_isRaffleInState(RaffleState.OPEN)) {
            revert Raffle__RaffleIsNotDrawing();
        }

        if (s_requestId != requestId) {
            revert Raffle__InvalidRequestId();
        }

        address winner = s_players[randomWords[0] % s_players.length];
        uint256 prizeAmount = address(this).balance;
        uint256 roundNumber = s_roundNumber;

        _resetRaffleForNextRound();

        emit RoundCompleted(roundNumber, winner, prizeAmount);

        (bool success,) = payable(winner).call{value: prizeAmount}("");

        if (!success) {
            emit PrizeTransferFailed(roundNumber, winner, prizeAmount);
        }
    }

    function _resetRaffleForNextRound() private {
        for (uint256 i = 0; i < s_players.length; i++) {
            s_playersInRaffle[s_players[i]] = false;
        }
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
        s_roundNumber++;
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

    // slither-disable-next-line timestamp
    function _isEntryWindowOpen() private view returns (bool) {
        return block.timestamp - s_lastTimeStamp <= i_interval;
    }

    function _isEntryWindowClosed() private view returns (bool) {
        return !_isEntryWindowOpen();
    }

    function _isLotteryOperator(address user) private view returns (bool) {
        return user == i_operator;
    }

    function _isRaffleInState(RaffleState state) private view returns (bool) {
        return s_raffleState == state;
    }
}
