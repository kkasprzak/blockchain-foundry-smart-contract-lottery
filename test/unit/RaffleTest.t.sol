// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Raffle} from "../../src/Raffle.sol";
import {MyVRFCoordinatorV2_5Mock} from "../mocks/MyVRFCoordinatorV2_5Mock.sol";
import {LogHelpers} from "../helpers/LogHelpers.sol";

contract RaffleTest is Test {
    using LogHelpers for Vm.Log[];

    bytes32 private constant KEY_HASH = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint32 private constant CALLBACK_GAS_LIMIT = 500000;
    bytes private constant EMPTY_CHECK_DATA = "";
    address private constant NO_WINNER = address(0);
    uint256 private constant NO_PRIZE = 0;
    uint256 private constant FIRST_ROUND = 1;
    uint256 private constant FIRST_ENTRY_WINS = 0;
    uint256 private constant SECOND_ENTRY_WINS = 1;
    uint256 private constant THIRD_ENTRY_WINS = 2;
    uint256 private constant FOURTH_ENTRY_WINS = 3;

    MyVRFCoordinatorV2_5Mock private s_vrfCoordinatorMock;
    uint256 private s_subscriptionId;

    event RaffleEntered(uint256 indexed roundNumber, address indexed player);
    event PrizeTransferFailed(uint256 indexed roundNumber, address indexed winnerAddress, uint256 prizeAmount);
    event DrawRequested(uint256 indexed roundNumber);
    event DrawCompleted(uint256 indexed roundNumber, address indexed winner, uint256 prize);

    function setUp() public {
        s_vrfCoordinatorMock = new MyVRFCoordinatorV2_5Mock(100000000000000000, 1000000000, 5300000000000000);
        s_subscriptionId = s_vrfCoordinatorMock.deterministicCreateSubscription();
        s_vrfCoordinatorMock.fundSubscription(s_subscriptionId, 100000000000000000000);
    }

    function test_RaffleInitializes() public {
        Raffle raffle = _createValidRaffle();
        assertTrue(address(raffle) != address(0));
    }

    function test_RaffleInitializes_WithEntranceFee() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);

        assertEq(raffle.getEntranceFee(), entranceFee);
    }

    function test_RaffleRevertsWithInvalidEntranceFee() public {
        uint256 invalidEntranceFee = 0;
        uint256 validInterval = 1;

        vm.expectRevert(abi.encodeWithSelector(Raffle.Raffle__InvalidParameter.selector, "Entrance fee cannot be zero"));
        new Raffle(
            invalidEntranceFee,
            validInterval,
            address(s_vrfCoordinatorMock),
            KEY_HASH,
            s_subscriptionId,
            CALLBACK_GAS_LIMIT
        );
    }

    function test_RaffleRevertsWithInvalidInterval() public {
        uint256 validEntranceFee = 0.01 ether;
        uint256 invalidInterval = 0;

        vm.expectRevert(abi.encodeWithSelector(Raffle.Raffle__InvalidParameter.selector, "Interval cannot be zero"));
        new Raffle(
            validEntranceFee,
            invalidInterval,
            address(s_vrfCoordinatorMock),
            KEY_HASH,
            s_subscriptionId,
            CALLBACK_GAS_LIMIT
        );
    }

    function test_PlayerCanEnterRaffleRoundWithExactEntryFee() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        _enterRaffleAsPlayer(raffle, player, entranceFee);
    }

    function test_EventEmittedWhenPlayerEntersRaffleRound() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        vm.expectEmit(true, true, false, false, address(raffle));
        emit RaffleEntered(1, player);

        _enterRaffleAsPlayer(raffle, player, entranceFee);
    }

    function test_PlayerCannotEnterRaffleRoundWhenPayingLessThanRequired() public {
        uint256 entranceFee = 0.01 ether;
        uint256 insufficientPayment = entranceFee / 10;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        vm.expectRevert(Raffle.Raffle__InvalidEntranceFee.selector);
        _enterRaffleAsPlayer(raffle, player, insufficientPayment);
    }

    function test_PlayerCannotEnterRaffleRoundWhenPayingMoreThanRequired() public {
        uint256 entranceFee = 0.01 ether;
        uint256 overpayment = entranceFee * 2;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        vm.expectRevert(Raffle.Raffle__InvalidEntranceFee.selector);
        _enterRaffleAsPlayer(raffle, player, overpayment);
    }

    function test_PlayerCanEnterRaffleMultipleTimes() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        _enterRaffleAsPlayer(raffle, player, entranceFee);
        _enterRaffleAsPlayer(raffle, player, entranceFee);
        _enterRaffleAsPlayer(raffle, player, entranceFee);

        assertEq(address(raffle).balance, 3 * entranceFee);
    }

    function test_MultipleEntriesIncreasesPrizePool() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);

        _waitForDrawTime(interval + 1);

        uint256 expectedPrizePool = entranceFee * 4;
        uint256 expectedWinnerBalance = 1 ether - 3 * entranceFee + expectedPrizePool;

        vm.recordLogs();
        _startDraw(raffle);
        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), FIRST_ENTRY_WINS
        );

        address winner = vm.getRecordedLogs().getWinner();

        assertEq(address(winner).balance, expectedWinnerBalance);
    }

    function test_MultipleEntriesGiveProportionalChances() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 10 ether);
        _fundPlayerForRaffle(player2, 10 ether);

        _setupRaffleEntriesForProportionalTest(raffle, player1, player2, entranceFee);
        assertEq(_runRound(raffle, interval, FIRST_ENTRY_WINS), player1);

        _setupRaffleEntriesForProportionalTest(raffle, player1, player2, entranceFee);
        assertEq(_runRound(raffle, interval, SECOND_ENTRY_WINS), player1);

        _setupRaffleEntriesForProportionalTest(raffle, player1, player2, entranceFee);
        assertEq(_runRound(raffle, interval, THIRD_ENTRY_WINS), player1);

        _setupRaffleEntriesForProportionalTest(raffle, player1, player2, entranceFee);
        assertEq(_runRound(raffle, interval, FOURTH_ENTRY_WINS), player2);
    }

    function test_PlayerCannotEnterRaffleRoundAfterTimeIntervalElapses() public {
        uint256 interval = 30;
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);
        _waitForDrawTime(interval + 1);

        vm.expectRevert(Raffle.Raffle__EntryWindowIsClosed.selector);
        _enterRaffleAsPlayer(raffle, player, entranceFee);
    }

    function test_PlayerCannotEnterRaffleRoundWhileDrawingIsInProgress() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);

        _waitForDrawTime(interval + 1);

        _startDraw(raffle);

        vm.expectRevert(Raffle.Raffle__DrawingInProgress.selector);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);
    }

    function test_DrawCannotStartBeforeTimeIntervalElapses() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);

        vm.expectRevert(Raffle.Raffle__DrawingNotAllowed.selector);
        _startDraw(raffle);
    }

    function test_CannotStartAnotherDrawWhilePreviousDrawIsInProgress() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);
        _enterRaffleAsPlayer(raffle, player, entranceFee);
        _waitForDrawTime(interval + 1);

        _startDraw(raffle);

        vm.expectRevert(Raffle.Raffle__DrawingNotAllowed.selector);
        _startDraw(raffle);
    }

    function test_EventEmittedWhenDrawCompletesWithNoWinner() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);

        _waitForDrawTime(interval + 1);

        vm.expectEmit(true, true, true, false, address(raffle));
        emit DrawCompleted(FIRST_ROUND, NO_WINNER, NO_PRIZE);

        _startDraw(raffle);
    }

    function test_EventEmittedWhenDrawCompletesWithWinner() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);
        _enterRaffleAsPlayer(raffle, player, entranceFee);

        _waitForDrawTime(interval + 1);

        vm.recordLogs();
        _startDraw(raffle);

        uint256 expectedRoundNumber = 1;
        uint256 expectedPrize = entranceFee;

        vm.expectEmit(true, true, false, true, address(raffle));
        emit DrawCompleted(expectedRoundNumber, player, expectedPrize);

        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), FIRST_ENTRY_WINS
        );
    }

    function test_EventEmittedWhenDrawStarts() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);
        _enterRaffleAsPlayer(raffle, player, entranceFee);

        _waitForDrawTime(interval + 1);

        vm.expectEmit(true, false, false, false, address(raffle));
        emit DrawRequested(FIRST_ROUND);

        _startDraw(raffle);
    }

    function test_WinnerIsDrawnFromPlayersInCurrentRound() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);

        _waitForDrawTime(interval + 1);

        vm.recordLogs();
        _startDraw(raffle);

        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(vm.getRecordedLogs().getVrfRequestId(), address(raffle), 1);

        assertEq(vm.getRecordedLogs().getWinner(), player2);
    }

    function test_WinnerReceivesPrizeAfterDrawCompletes() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");
        address player3 = makeAddr("player3");

        _fundPlayerForRaffle(player1, 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);
        _fundPlayerForRaffle(player3, 1 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);
        _enterRaffleAsPlayer(raffle, player3, entranceFee);

        _waitForDrawTime(interval + 1);

        uint256 totalPrizePool = entranceFee * 3;

        vm.recordLogs();
        _startDraw(raffle);
        uint256 expectedWinnerBalance = 1 ether - entranceFee + totalPrizePool;

        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(vm.getRecordedLogs().getVrfRequestId(), address(raffle), 1);

        assertEq(player2.balance, expectedWinnerBalance);
    }

    function test_EventEmittedWhenPrizeDeliveryFailsDueToMaliciousWinner() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);

        MaliciousWinnerRevertsOnReceive maliciousWinner = new MaliciousWinnerRevertsOnReceive();

        _fundPlayerForRaffle(address(maliciousWinner), 1 ether);
        _enterRaffleAsPlayer(raffle, address(maliciousWinner), entranceFee);

        _waitForDrawTime(interval + 1);

        uint256 expectedPrizeAmount = entranceFee;

        vm.recordLogs();
        _startDraw(raffle);

        vm.expectEmit(true, true, false, true, address(raffle));
        emit PrizeTransferFailed(1, address(maliciousWinner), expectedPrizeAmount);

        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), FIRST_ENTRY_WINS
        );
    }

    function test_SystemPreventsReentrancyAttackDuringPrizeDelivery() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);

        MaliciousWinnerReentersOnPrizeTransfer maliciousWinner =
            new MaliciousWinnerReentersOnPrizeTransfer(raffle, s_vrfCoordinatorMock, vm);

        _fundPlayerForRaffle(address(maliciousWinner), 1 ether);
        _enterRaffleAsPlayer(raffle, address(maliciousWinner), entranceFee);

        _waitForDrawTime(interval + 1);

        uint256 expectedPrizeAmount = entranceFee;

        vm.recordLogs();
        _startDraw(raffle);

        vm.expectEmit(true, true, false, true, address(raffle));
        emit PrizeTransferFailed(1, address(maliciousWinner), expectedPrizeAmount);

        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), FIRST_ENTRY_WINS
        );
    }

    function test_NewRoundStartsEvenWhenPrizeDeliveryFails() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        MaliciousWinnerRevertsOnReceive maliciousWinner = new MaliciousWinnerRevertsOnReceive();
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(address(maliciousWinner), 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);

        _enterRaffleAsPlayer(raffle, address(maliciousWinner), entranceFee);
        _completeRoundWithFailedTransfer(raffle, interval);

        _enterRaffleAsPlayer(raffle, player2, entranceFee);
    }

    function test_NewRoundStartsWithoutPreviousPlayers() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 10 ether);
        _fundPlayerForRaffle(player2, 10 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        assertEq(_runRound(raffle, interval, FIRST_ENTRY_WINS), player1);

        _enterRaffleAsPlayer(raffle, player2, entranceFee);
        assertEq(_runRound(raffle, interval, FIRST_ENTRY_WINS), player2);
    }

    function test_NewRoundStartsWithEmptyPrizePool() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 10 ether);
        _fundPlayerForRaffle(player2, 10 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _runRound(raffle, interval, FIRST_ENTRY_WINS);

        assertEq(address(raffle).balance, 0);
    }

    function test_EachRaffleRoundHasUniqueSequentialNumber() public {
        // Setup
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player = makeAddr("player");
        _fundPlayerForRaffle(player, 10 ether);

        // Round 1
        _enterRaffleAsPlayer(raffle, player, entranceFee);
        _waitForDrawTime(interval + 1);
        vm.recordLogs();
        _startDraw(raffle);

        vm.expectEmit(true, true, false, true, address(raffle));
        emit DrawCompleted(1, player, entranceFee);
        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), FIRST_ENTRY_WINS
        );

        // Round 2
        _enterRaffleAsPlayer(raffle, player, entranceFee);
        _waitForDrawTime(interval + 1);
        vm.recordLogs();
        _startDraw(raffle);

        vm.expectEmit(true, true, false, true, address(raffle));
        emit DrawCompleted(2, player, entranceFee);
        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), FIRST_ENTRY_WINS
        );

        // Round 3
        _enterRaffleAsPlayer(raffle, player, entranceFee);
        _waitForDrawTime(interval + 1);
        vm.recordLogs();
        _startDraw(raffle);

        vm.expectEmit(true, true, false, true, address(raffle));
        emit DrawCompleted(3, player, entranceFee);
        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), FIRST_ENTRY_WINS
        );
    }

    function test_EntryWindowIsOpenWhenIntervalHasNotPassed() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);

        _assertEntryWindowIsOpen(raffle);
    }

    function test_EntryWindowIsClosedWhenIntervalHasPassed() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);

        _waitForDrawTime(interval + 1);

        _assertEntryWindowIsClosed(raffle);
    }

    function _createValidRaffle() private returns (Raffle) {
        return _createRaffleWithEntranceFeeAndInterval(1 ether, 1);
    }

    function _createRaffleWithInterval(uint256 interval) private returns (Raffle) {
        return _createRaffleWithEntranceFeeAndInterval(1 ether, interval);
    }

    function _createRaffleWithEntranceFee(uint256 entranceFee) private returns (Raffle) {
        return _createRaffleWithEntranceFeeAndInterval(entranceFee, 1);
    }

    function _createRaffleWithEntranceFeeAndInterval(uint256 entranceFee, uint256 interval) private returns (Raffle) {
        Raffle raffle = new Raffle(
            entranceFee, interval, address(s_vrfCoordinatorMock), KEY_HASH, s_subscriptionId, CALLBACK_GAS_LIMIT
        );

        s_vrfCoordinatorMock.addConsumer(s_subscriptionId, address(raffle));

        return raffle;
    }

    function _waitForDrawTime(uint256 timeToWait) private {
        vm.warp(block.timestamp + timeToWait);
    }

    function _enterRaffleAsPlayer(Raffle raffle, address player, uint256 entranceFee) private {
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();
    }

    function _fundPlayerForRaffle(address player, uint256 amount) private {
        vm.deal(player, amount);
    }

    function _setupRaffleEntriesForProportionalTest(
        Raffle raffle,
        address player1,
        address player2,
        uint256 entranceFee
    ) private {
        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);
    }

    function _runRound(Raffle raffle, uint256 interval, uint256 randomWord) private returns (address) {
        _waitForDrawTime(interval + 1);

        vm.recordLogs();
        _startDraw(raffle);
        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), randomWord
        );

        return vm.getRecordedLogs().getWinner();
    }

    function _completeRoundWithFailedTransfer(Raffle raffle, uint256 interval) private {
        _waitForDrawTime(interval + 1);

        vm.recordLogs();
        _startDraw(raffle);
        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), FIRST_ENTRY_WINS
        );
    }

    function _assertEntryWindowIsOpen(Raffle raffle) private view {
        (bool upkeepNeeded,) = raffle.checkUpkeep(EMPTY_CHECK_DATA);
        assertFalse(upkeepNeeded);
    }

    function _assertEntryWindowIsClosed(Raffle raffle) private view {
        (bool upkeepNeeded,) = raffle.checkUpkeep(EMPTY_CHECK_DATA);
        assertTrue(upkeepNeeded);
    }

    function _startDraw(Raffle raffle) private {
        raffle.performUpkeep(EMPTY_CHECK_DATA);
    }
}

contract MaliciousWinnerRevertsOnReceive {
    receive() external payable {
        revert("Malicious winner refuses payment");
    }
}

contract MaliciousWinnerReentersOnPrizeTransfer {
    using LogHelpers for Vm.Log[];

    Raffle private s_raffle;
    MyVRFCoordinatorV2_5Mock private s_vrfCoordinatorMock;
    Vm private s_vm;

    constructor(Raffle _raffle, MyVRFCoordinatorV2_5Mock _vrfCoordinatorMock, Vm _vm) {
        s_raffle = _raffle;
        s_vrfCoordinatorMock = _vrfCoordinatorMock;
        s_vm = _vm;
    }

    receive() external payable {
        // Try to re-enter by calling VRF callback again
        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(
            s_vm.getRecordedLogs().getVrfRequestId(), address(s_raffle), 0
        );
    }
}
