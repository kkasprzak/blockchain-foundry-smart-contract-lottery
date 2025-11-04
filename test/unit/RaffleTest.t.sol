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

    MyVRFCoordinatorV2_5Mock private s_vrfCoordinatorMock;
    uint256 private s_subscriptionId;

    event RaffleEntered(uint256 indexed roundNumber, address indexed player);
    event PrizeTransferFailed(uint256 indexed roundNumber, address indexed winnerAddress, uint256 prizeAmount);
    event DrawRequested(uint256 indexed roundNumber);
    event RoundCompleted(uint256 indexed roundNumber, address indexed winner, uint256 prize);

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

        vm.expectRevert(Raffle.Raffle__InvalidEntranceFee.selector);
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

        vm.expectRevert(Raffle.Raffle__InvalidInterval.selector);
        new Raffle(
            validEntranceFee,
            invalidInterval,
            address(s_vrfCoordinatorMock),
            KEY_HASH,
            s_subscriptionId,
            CALLBACK_GAS_LIMIT
        );
    }

    function test_RaffleRevertsWhenYouDontPayEnough() public {
        uint256 entranceFee = 0.01 ether;
        uint256 insufficientPayment = entranceFee / 10;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        _enterRaffleAsPlayer(raffle, player, insufficientPayment);
    }

    function test_RaffleRevertsWhenEnteringDuringDrawTime() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);

        _waitForDrawTime(interval + 1);

        raffle.pickWinner();

        vm.expectRevert(Raffle.Raffle__DrawingInProgress.selector);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);
    }

    function test_RaffleAllowsUserToEnterWithEnoughFee() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        _enterRaffleAsPlayer(raffle, player, entranceFee);
    }

    function test_RaffleAllowsUserToEnterWithMoreThanEnoughFee() public {
        uint256 entranceFee = 0.01 ether;
        uint256 overpayment = entranceFee * 2;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        _enterRaffleAsPlayer(raffle, player, overpayment);
    }

    function test_RaffleRevertsWhenPlayerIsAlreadyInRaffle() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        _enterRaffleAsPlayer(raffle, player, entranceFee);

        vm.expectRevert(Raffle.Raffle__PlayerIsAlreadyInRaffle.selector);
        _enterRaffleAsPlayer(raffle, player, entranceFee);
    }

    function test_RaffleRevertsWhenEntryWindowIsClosed() public {
        uint256 interval = 30;
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);
        _waitForDrawTime(interval + 1);

        vm.expectRevert(Raffle.Raffle__EntryWindowIsClosed.selector);
        _enterRaffleAsPlayer(raffle, player, entranceFee);
    }

    function test_RaffleRecordsPlayerWhenTheyEnter() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);
        _enterRaffleAsPlayer(raffle, player, entranceFee);

        assertTrue(raffle.isPlayerInRaffle(player));
    }

    function test_RaffleReturnsFalseForPlayerNotInRaffle() public {
        Raffle raffle = _createValidRaffle();

        assertFalse(raffle.isPlayerInRaffle(makeAddr("player")));
    }

    function test_RaffleEmitsEventOnEntrance() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        vm.expectEmit(true, true, false, false, address(raffle));
        emit RaffleEntered(1, player);

        _enterRaffleAsPlayer(raffle, player, entranceFee);
    }

    function test_PickWinnerEmitsDrawRequestedEvent() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);
        _enterRaffleAsPlayer(raffle, player, entranceFee);

        _waitForDrawTime(interval + 1);

        vm.expectEmit(true, false, false, false, address(raffle));
        emit DrawRequested(1);

        raffle.pickWinner();
    }

    function test_PickWinnerRevertsWhenNotEnoughTimeHasPassed() public {
        Raffle raffle = _createRaffleWithInterval(30);

        vm.expectRevert(Raffle.Raffle__NotEnoughTimeHasPassed.selector);
        raffle.pickWinner();
    }

    function test_PickWinnerRevertsWhenCalledByNonOperator() public {
        Raffle raffle = _createValidRaffle();
        address unauthorizedUser = makeAddr("unauthorizedUser");

        vm.prank(unauthorizedUser);
        vm.expectRevert(Raffle.Raffle__NotOperator.selector);
        raffle.pickWinner();
    }

    function test_PickWinnerSelectsWinnerFromParticipants() public {
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
        raffle.pickWinner();

        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(vm.getRecordedLogs().getVrfRequestId(), address(raffle), 1);

        assertEq(vm.getRecordedLogs().getWinner(), player2);
    }

    function test_PickWinnerTransfersPrizeToWinner() public {
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
        raffle.pickWinner();
        uint256 expectedWinnerBalance = 1 ether - entranceFee + totalPrizePool;

        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(vm.getRecordedLogs().getVrfRequestId(), address(raffle), 1);

        assertEq(player2.balance, expectedWinnerBalance);
    }

    function test_PickWinnerClearsParticipantsForNextRound() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);

        assertTrue(raffle.isPlayerInRaffle(player1));
        assertTrue(raffle.isPlayerInRaffle(player2));

        _waitForDrawTime(interval + 1);

        vm.recordLogs();
        raffle.pickWinner();
        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(vm.getRecordedLogs().getVrfRequestId(), address(raffle), 1);

        assertFalse(raffle.isPlayerInRaffle(player1));
        assertFalse(raffle.isPlayerInRaffle(player2));
    }

    function test_RafflePicksWinnerResetsEntryWindowForNextRound() public {
        uint256 interval = 30;
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);

        _waitForDrawTime(interval + 1);
        vm.recordLogs();
        raffle.pickWinner();
        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(vm.getRecordedLogs().getVrfRequestId(), address(raffle), 0);

        _enterRaffleAsPlayer(raffle, player2, entranceFee);

        assertFalse(raffle.isPlayerInRaffle(player1));
        assertTrue(raffle.isPlayerInRaffle(player2));
    }

    function test_PickWinnerResetsRoundWhenNoParticipants() public {
        uint256 interval = 30;
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        _waitForDrawTime(interval + 1);

        raffle.pickWinner();

        _enterRaffleAsPlayer(raffle, player, entranceFee);
        assertTrue(raffle.isPlayerInRaffle(player));
    }

    function test_PickWinnerContinuesWhenTransferFails() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);

        MaliciousWinnerRevertsOnReceive maliciousWinner = new MaliciousWinnerRevertsOnReceive();

        _fundPlayerForRaffle(address(maliciousWinner), 1 ether);

        _enterRaffleAsPlayer(raffle, address(maliciousWinner), entranceFee);

        _waitForDrawTime(interval + 1);

        vm.recordLogs();
        raffle.pickWinner();
        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(vm.getRecordedLogs().getVrfRequestId(), address(raffle), 0);

        assertFalse(raffle.isPlayerInRaffle(address(maliciousWinner)));
    }

    function test_PickWinnerEmitsPrizeTransferFailedWhenTransferReverts() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);

        MaliciousWinnerRevertsOnReceive maliciousWinner = new MaliciousWinnerRevertsOnReceive();

        _fundPlayerForRaffle(address(maliciousWinner), 1 ether);
        _enterRaffleAsPlayer(raffle, address(maliciousWinner), entranceFee);

        _waitForDrawTime(interval + 1);

        uint256 expectedPrizeAmount = entranceFee;

        vm.recordLogs();
        raffle.pickWinner();

        vm.expectEmit(true, true, false, true, address(raffle));
        emit PrizeTransferFailed(1, address(maliciousWinner), expectedPrizeAmount);

        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(vm.getRecordedLogs().getVrfRequestId(), address(raffle), 0);
    }

    function test_RoundCompletedEventEmittedAfterWinnerSelection() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);
        _enterRaffleAsPlayer(raffle, player, entranceFee);

        _waitForDrawTime(interval + 1);

        vm.recordLogs();
        raffle.pickWinner();

        uint256 expectedRoundNumber = 1;
        uint256 expectedPrize = entranceFee;

        vm.expectEmit(true, true, false, true, address(raffle));
        emit RoundCompleted(expectedRoundNumber, player, expectedPrize);

        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(vm.getRecordedLogs().getVrfRequestId(), address(raffle), 0);
    }

    function test_RoundCompletedEventEmittedWhenNoParticipants() public {
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithInterval(interval);

        _waitForDrawTime(interval + 1);

        uint256 expectedRoundNumber = 1;
        address expectedWinner = address(0);
        uint256 expectedPrize = 0;

        vm.expectEmit(true, true, false, true, address(raffle));
        emit RoundCompleted(expectedRoundNumber, expectedWinner, expectedPrize);

        raffle.pickWinner();
    }

    function test_RoundNumberIncrementsAcrossMultipleRounds() public {
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
        raffle.pickWinner();

        vm.expectEmit(true, true, false, true, address(raffle));
        emit RoundCompleted(1, player, entranceFee);
        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(vm.getRecordedLogs().getVrfRequestId(), address(raffle), 0);

        // Round 2
        _enterRaffleAsPlayer(raffle, player, entranceFee);
        _waitForDrawTime(interval + 1);
        vm.recordLogs();
        raffle.pickWinner();

        vm.expectEmit(true, true, false, true, address(raffle));
        emit RoundCompleted(2, player, entranceFee);
        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(vm.getRecordedLogs().getVrfRequestId(), address(raffle), 0);

        // Round 3
        _enterRaffleAsPlayer(raffle, player, entranceFee);
        _waitForDrawTime(interval + 1);
        vm.recordLogs();
        raffle.pickWinner();

        vm.expectEmit(true, true, false, true, address(raffle));
        emit RoundCompleted(3, player, entranceFee);
        s_vrfCoordinatorMock.simulateVRFCoordinatorCallback(vm.getRecordedLogs().getVrfRequestId(), address(raffle), 0);
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
}

contract MaliciousWinnerRevertsOnReceive {
    receive() external payable {
        revert("Malicious winner refuses payment");
    }
}
