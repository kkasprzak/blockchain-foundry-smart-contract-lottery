// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {
    AutomationCompatibleInterface
} from "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";

/// @title Raffle
/// @author Karol Kasprzak
/// @notice A decentralized lottery contract using Chainlink VRF for randomness and Automation for scheduling
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
    uint256 private constant VRF_TIMEOUT = 5 minutes;

    uint256 private immutable ENTRANCE_FEE;
    uint256 private immutable INTERVAL;
    uint256 private lastTimeStamp;
    bytes32 private immutable KEY_HASH;
    uint256 private immutable SUBSCRIPTION_ID;
    uint32 private immutable CALLBACK_GAS_LIMIT;

    address payable[] private players;
    uint256 private requestId;
    RaffleState private raffleState;
    uint256 private roundNumber;
    uint256 private prizePool;
    uint256 private vrfRequestTimestamp;

    mapping(address => uint256) private unclaimedPrizes;
    mapping(uint256 => mapping(address => uint256)) private playerEntryCount;

    /// @notice Emitted when a player enters the raffle
    /// @param roundNumber The current round number
    /// @param player The address of the player who entered
    event RaffleEntered(uint256 indexed roundNumber, address indexed player);

    /// @notice Emitted when a draw is requested from Chainlink VRF
    /// @param roundNumber The round number for which the draw was requested
    event DrawRequested(uint256 indexed roundNumber);

    /// @notice Emitted when a draw is completed and winner is selected
    /// @param roundNumber The round number that was drawn
    /// @param winner The address of the winner (address(0) if no players)
    /// @param prize The prize amount awarded to the winner
    event DrawCompleted(uint256 indexed roundNumber, address indexed winner, uint256 prize);

    /// @notice Emitted when a winner successfully claims their prize
    /// @param winner The address of the winner who claimed
    /// @param amount The amount claimed
    event PrizeClaimed(address indexed winner, uint256 amount);

    /// @notice Emitted when a prize claim fails (e.g., transfer rejected)
    /// @param winner The address of the winner whose claim failed
    /// @param amount The amount that failed to transfer
    event PrizeClaimFailed(address indexed winner, uint256 amount);

    error Raffle__InvalidEntranceFee();
    error Raffle__EntryWindowIsClosed();
    error Raffle__InvalidParameter(string message);
    error Raffle__DrawingInProgress();
    error Raffle__RaffleIsNotDrawing();
    error Raffle__InvalidRequestId();
    error Raffle__DrawingNotAllowed();
    error Raffle__NoUnclaimedPrize();

    /// @notice Creates a new Raffle contract
    /// @param entranceFee The fee required to enter the raffle (must be > 0)
    /// @param interval The time window in seconds during which players can enter
    /// @param vrfCoordinator The Chainlink VRF Coordinator address
    /// @param keyHash The Chainlink VRF key hash
    /// @param subscriptionId The Chainlink VRF subscription ID
    /// @param callbackGasLimit The gas limit for the VRF callback
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 keyHash,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        if (entranceFee == 0) {
            revert Raffle__InvalidParameter("Entrance fee cannot be zero");
        }

        if (interval == 0) {
            revert Raffle__InvalidParameter("Interval cannot be zero");
        }

        ENTRANCE_FEE = entranceFee;
        INTERVAL = interval;
        lastTimeStamp = block.timestamp;
        KEY_HASH = keyHash;
        SUBSCRIPTION_ID = subscriptionId;
        CALLBACK_GAS_LIMIT = callbackGasLimit;

        raffleState = RaffleState.OPEN;
        roundNumber = 1;
    }

    /// @notice Allows a player to enter the raffle by paying the entrance fee
    function enterRaffle() external payable {
        if (msg.value != ENTRANCE_FEE) {
            revert Raffle__InvalidEntranceFee();
        }

        if (_isRaffleInState(RaffleState.DRAWING)) {
            revert Raffle__DrawingInProgress();
        }

        if (_isEntryWindowClosed()) {
            revert Raffle__EntryWindowIsClosed();
        }

        _addPlayerToRaffle(msg.sender);
        prizePool += msg.value;
        ++playerEntryCount[roundNumber][msg.sender];

        emit RaffleEntered(roundNumber, msg.sender);
    }

    /// @notice Called by Chainlink Automation to execute the draw when conditions are met
    // slither-disable-next-line reentrancy-events,timestamp
    function performUpkeep(
        bytes calldata /* performData */
    )
        external
        override
    {
        if (_isVrfTimedOut()) {
            vrfRequestTimestamp = block.timestamp;
            requestId = _requestRandomWords();
            emit DrawRequested(roundNumber);
            return;
        }

        if (_isEntryWindowOpen() || _isRaffleInState(RaffleState.DRAWING)) {
            revert Raffle__DrawingNotAllowed();
        }

        if (players.length == 0) {
            uint256 currentRound = roundNumber;
            _resetRaffleForNextRound();
            emit DrawCompleted(currentRound, NO_WINNER, NO_PRIZE);
            return;
        }

        raffleState = RaffleState.DRAWING;
        vrfRequestTimestamp = block.timestamp;
        requestId = _requestRandomWords();
        emit DrawRequested(roundNumber);
    }

    /// @notice Allows winners to claim their unclaimed prizes
    // slither-disable-next-line reentrancy-eth
    function claimPrize() external nonReentrant {
        uint256 amount = unclaimedPrizes[msg.sender];
        if (amount == 0) {
            revert Raffle__NoUnclaimedPrize();
        }
        unclaimedPrizes[msg.sender] = 0;

        (bool success,) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            unclaimedPrizes[msg.sender] = amount;
            emit PrizeClaimFailed(msg.sender, amount);
            return;
        }

        emit PrizeClaimed(msg.sender, amount);
    }

    /// @notice Returns the entrance fee required to enter the raffle
    /// @return The entrance fee in wei
    function getEntranceFee() external view returns (uint256) {
        return ENTRANCE_FEE;
    }

    /// @notice Returns the timestamp when the current entry window closes
    /// @return The Unix timestamp (in seconds) when entries will no longer be accepted
    function getEntryDeadline() external view returns (uint256) {
        return lastTimeStamp + INTERVAL;
    }

    /// @notice Returns the current prize pool for this round
    /// @return The total accumulated entry fees in wei
    function getPrizePool() external view returns (uint256) {
        return prizePool;
    }

    /// @notice Returns the number of entries in current round
    /// @return The count of entries (same player can enter multiple times)
    function getEntriesCount() external view returns (uint256) {
        return players.length;
    }

    /// @notice Returns the unclaimed prize amount for a given address
    /// @param player The address to check
    /// @return The unclaimed prize amount in wei
    function getPlayerEntryCount(address player) external view returns (uint256) {
        return playerEntryCount[roundNumber][player];
    }

    function getUnclaimedPrize(address player) external view returns (uint256) {
        return unclaimedPrizes[player];
    }

    /// @notice Checks if the raffle is ready for a draw
    /// @return upkeepNeeded True if the entry window is closed and raffle is open
    /// @return performData Empty bytes (not used)
    // slither-disable-next-line timestamp
    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        bool normalCondition = _isEntryWindowClosed() && _isRaffleInState(RaffleState.OPEN);
        bool recoveryCondition = _isVrfTimedOut();
        return (normalCondition || recoveryCondition, EMPTY_PERFORM_DATA);
    }

    // slither-disable-next-line reentrancy-eth
    function fulfillRandomWords(uint256 incomingRequestId, uint256[] calldata randomWords)
        internal
        virtual
        override
        nonReentrant
    {
        if (!_isRaffleInState(RaffleState.DRAWING)) {
            revert Raffle__RaffleIsNotDrawing();
        }

        if (requestId != incomingRequestId) {
            revert Raffle__InvalidRequestId();
        }

        address winner = players[randomWords[0] % players.length];
        uint256 prizeAmount = prizePool;
        uint256 currentRound = roundNumber;

        unclaimedPrizes[winner] += prizeAmount;
        _resetRaffleForNextRound();

        emit DrawCompleted(currentRound, winner, prizeAmount);
    }

    function _resetRaffleForNextRound() private {
        players = new address payable[](0);
        lastTimeStamp = block.timestamp;
        raffleState = RaffleState.OPEN;
        ++roundNumber;
        prizePool = 0;
    }

    function _addPlayerToRaffle(address player) private {
        players.push(payable(player));
    }

    function _requestRandomWords() private returns (uint256) {
        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
            keyHash: KEY_HASH,
            subId: SUBSCRIPTION_ID,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: CALLBACK_GAS_LIMIT,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
        });

        return s_vrfCoordinator.requestRandomWords(req);
    }

    // slither-disable-next-line timestamp
    function _isEntryWindowOpen() private view returns (bool) {
        return block.timestamp - lastTimeStamp < INTERVAL + 1;
    }

    function _isEntryWindowClosed() private view returns (bool) {
        return !_isEntryWindowOpen();
    }

    function _isRaffleInState(RaffleState state) private view returns (bool) {
        return raffleState == state;
    }

    function _isVrfTimedOut() private view returns (bool) {
        return _isRaffleInState(RaffleState.DRAWING) && block.timestamp >= vrfRequestTimestamp + VRF_TIMEOUT;
    }
}
