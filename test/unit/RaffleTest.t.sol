// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Raffle} from "../../src/Raffle.sol";
import {MyVrfCoordinatorV25Mock} from "../mocks/MyVrfCoordinatorV25Mock.sol";
import {MaliciousWinnerRevertsOnReceive} from "../mocks/MaliciousWinnerRevertsOnReceive.sol";
import {MaliciousWinnerRevertsOnClaim} from "../mocks/MaliciousWinnerRevertsOnClaim.sol";
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

    MyVrfCoordinatorV25Mock private vrfCoordinatorMock;
    uint256 private subscriptionId;

    event RaffleEntered(uint256 indexed roundNumber, address indexed player);
    event DrawRequested(uint256 indexed roundNumber);
    event DrawCompleted(uint256 indexed roundNumber, address indexed winner, uint256 prize);
    event PrizeClaimed(address indexed winner, uint256 amount);
    event PrizeClaimFailed(address indexed winner, uint256 amount);

    function setUp() public {
        vrfCoordinatorMock = new MyVrfCoordinatorV25Mock(100000000000000000, 1000000000, 5300000000000000);
        subscriptionId = vrfCoordinatorMock.deterministicCreateSubscription();
        vrfCoordinatorMock.fundSubscription(subscriptionId, 100000000000000000000);
    }

    function testRaffleInitializes() public {
        Raffle raffle = _createValidRaffle();
        assertTrue(address(raffle) != address(0));
    }

    function testRaffleInitializesWithEntranceFee() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);

        assertEq(raffle.getEntranceFee(), entranceFee);
    }

    function testRaffleRevertsWithInvalidEntranceFee() public {
        uint256 invalidEntranceFee = 0;
        uint256 validInterval = 1;

        vm.expectRevert(abi.encodeWithSelector(Raffle.Raffle__InvalidParameter.selector, "Entrance fee cannot be zero"));
        new Raffle(
            invalidEntranceFee, validInterval, address(vrfCoordinatorMock), KEY_HASH, subscriptionId, CALLBACK_GAS_LIMIT
        );
    }

    function testRaffleRevertsWithInvalidInterval() public {
        uint256 validEntranceFee = 0.01 ether;
        uint256 invalidInterval = 0;

        vm.expectRevert(abi.encodeWithSelector(Raffle.Raffle__InvalidParameter.selector, "Interval cannot be zero"));
        new Raffle(
            validEntranceFee, invalidInterval, address(vrfCoordinatorMock), KEY_HASH, subscriptionId, CALLBACK_GAS_LIMIT
        );
    }

    function testPlayerCanEnterRaffleRoundWithExactEntryFee() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        _enterRaffleAsPlayer(raffle, player, entranceFee);
    }

    function testEventEmittedWhenPlayerEntersRaffleRound() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        vm.expectEmit(true, true, false, false, address(raffle));
        emit RaffleEntered(1, player);

        _enterRaffleAsPlayer(raffle, player, entranceFee);
    }

    function testPlayerCannotEnterRaffleRoundWhenPayingLessThanRequired() public {
        uint256 entranceFee = 0.01 ether;
        uint256 insufficientPayment = entranceFee / 10;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        vm.expectRevert(Raffle.Raffle__InvalidEntranceFee.selector);
        _enterRaffleAsPlayer(raffle, player, insufficientPayment);
    }

    function testPlayerCannotEnterRaffleRoundWhenPayingMoreThanRequired() public {
        uint256 entranceFee = 0.01 ether;
        uint256 overpayment = entranceFee * 2;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        vm.expectRevert(Raffle.Raffle__InvalidEntranceFee.selector);
        _enterRaffleAsPlayer(raffle, player, overpayment);
    }

    function testPlayerCanEnterRaffleMultipleTimes() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);

        _enterRaffleAsPlayer(raffle, player, entranceFee);
        _enterRaffleAsPlayer(raffle, player, entranceFee);
        _enterRaffleAsPlayer(raffle, player, entranceFee);

        assertEq(address(raffle).balance, 3 * entranceFee);
    }

    function testMultipleEntriesIncreasesPrizePool() public {
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
        uint256 balanceBeforeClaim = player1.balance;

        vm.recordLogs();
        _startDraw(raffle);
        vrfCoordinatorMock.simulateVrfCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), FIRST_ENTRY_WINS
        );

        address winner = vm.getRecordedLogs().getWinner();

        vm.prank(winner);
        raffle.claimPrize();

        assertEq(address(winner).balance, balanceBeforeClaim + expectedPrizePool);
    }

    function testMultipleEntriesGiveProportionalChances() public {
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

    function testPlayerCannotEnterRaffleRoundAfterTimeIntervalElapses() public {
        uint256 interval = 30;
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);
        _waitForDrawTime(interval + 1);

        vm.expectRevert(Raffle.Raffle__EntryWindowIsClosed.selector);
        _enterRaffleAsPlayer(raffle, player, entranceFee);
    }

    function testPlayerCannotEnterRaffleRoundWhileDrawingIsInProgress() public {
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

    function testEventEmittedWhenDrawStarts() public {
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

    function testEventEmittedWhenDrawCompletesWithWinner() public {
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

        vrfCoordinatorMock.simulateVrfCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), FIRST_ENTRY_WINS
        );
    }

    function testWinnerIsDrawnFromPlayersInCurrentRound() public {
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

        vrfCoordinatorMock.simulateVrfCoordinatorCallback(vm.getRecordedLogs().getVrfRequestId(), address(raffle), 1);

        assertEq(vm.getRecordedLogs().getWinner(), player2);
    }

    function testEventEmittedWhenDrawCompletesWithNoWinner() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);

        _waitForDrawTime(interval + 1);

        vm.expectEmit(true, true, true, false, address(raffle));
        emit DrawCompleted(FIRST_ROUND, NO_WINNER, NO_PRIZE);

        _startDraw(raffle);
    }

    function testDrawCannotStartBeforeTimeIntervalElapses() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);

        vm.expectRevert(Raffle.Raffle__DrawingNotAllowed.selector);
        _startDraw(raffle);
    }

    function testCannotStartAnotherDrawWhilePreviousDrawIsInProgress() public {
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

    function testNewRoundStartsEvenWhenPrizeDeliveryFails() public {
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

    function testNewRoundStartsWithoutPreviousPlayers() public {
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

    function testNewRoundStartsWithEmptyPrizePool() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 10 ether);
        _fundPlayerForRaffle(player2, 10 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _runRound(raffle, interval, FIRST_ENTRY_WINS);

        _enterRaffleAsPlayer(raffle, player2, entranceFee);
        uint256 balanceAfterEntry = player2.balance;

        _runRound(raffle, interval, FIRST_ENTRY_WINS);

        vm.prank(player2);
        raffle.claimPrize();

        assertEq(player2.balance, balanceAfterEntry + entranceFee);
    }

    function testEachRaffleRoundHasUniqueSequentialNumber() public {
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
        vrfCoordinatorMock.simulateVrfCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), FIRST_ENTRY_WINS
        );

        // Round 2
        _enterRaffleAsPlayer(raffle, player, entranceFee);
        _waitForDrawTime(interval + 1);
        vm.recordLogs();
        _startDraw(raffle);

        vm.expectEmit(true, true, false, true, address(raffle));
        emit DrawCompleted(2, player, entranceFee);
        vrfCoordinatorMock.simulateVrfCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), FIRST_ENTRY_WINS
        );

        // Round 3
        _enterRaffleAsPlayer(raffle, player, entranceFee);
        _waitForDrawTime(interval + 1);
        vm.recordLogs();
        _startDraw(raffle);

        vm.expectEmit(true, true, false, true, address(raffle));
        emit DrawCompleted(3, player, entranceFee);
        vrfCoordinatorMock.simulateVrfCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), FIRST_ENTRY_WINS
        );
    }

    function testWinnerCanWithdrawPrize() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);

        uint256 balanceBeforeWithdrawal = player1.balance;
        uint256 expectedPrize = entranceFee * 2;

        _runRound(raffle, interval, FIRST_ENTRY_WINS);

        vm.prank(player1);
        raffle.claimPrize();

        assertEq(player1.balance, balanceBeforeWithdrawal + expectedPrize);
    }

    function testNonWinnerCannotClaimPrize() public {
        Raffle raffle = _createValidRaffle();
        address nonWinner = makeAddr("nonWinner");

        vm.prank(nonWinner);
        vm.expectRevert(Raffle.Raffle__NoUnclaimedPrize.selector);
        raffle.claimPrize();
    }

    function testEventEmittedWhenWinnerClaimsPrize() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);

        _runRound(raffle, interval, FIRST_ENTRY_WINS);

        uint256 expectedPrize = entranceFee * 2;

        vm.expectEmit(true, false, false, true, address(raffle));
        emit PrizeClaimed(player1, expectedPrize);

        vm.prank(player1);
        raffle.claimPrize();
    }

    function testClaimPrizeEmitsEventWhenTransferFails() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);

        MaliciousWinnerRevertsOnClaim maliciousWinner = new MaliciousWinnerRevertsOnClaim();
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(address(maliciousWinner), 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);

        _enterRaffleAsPlayer(raffle, address(maliciousWinner), entranceFee);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);

        _runRound(raffle, interval, FIRST_ENTRY_WINS);

        uint256 expectedPrize = entranceFee * 2;

        maliciousWinner.shouldRevert(true);

        vm.expectEmit(true, false, false, true, address(raffle));
        emit PrizeClaimFailed(address(maliciousWinner), expectedPrize);

        vm.prank(address(maliciousWinner));
        raffle.claimPrize();
    }

    function testCanRetryClaimAfterTransferFailure() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);

        MaliciousWinnerRevertsOnClaim maliciousWinner = new MaliciousWinnerRevertsOnClaim();
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(address(maliciousWinner), 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);

        _enterRaffleAsPlayer(raffle, address(maliciousWinner), entranceFee);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);

        _runRound(raffle, interval, FIRST_ENTRY_WINS);

        maliciousWinner.shouldRevert(true);
        vm.prank(address(maliciousWinner));
        raffle.claimPrize();

        maliciousWinner.shouldRevert(false);
        vm.prank(address(maliciousWinner));
        raffle.claimPrize();

        assertEq(address(maliciousWinner).balance, 1 ether - entranceFee + entranceFee * 2);
    }

    function testCannotClaimPrizeTwice() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);

        _runRound(raffle, interval, FIRST_ENTRY_WINS);

        vm.prank(player1);
        raffle.claimPrize();

        vm.prank(player1);
        vm.expectRevert(Raffle.Raffle__NoUnclaimedPrize.selector);
        raffle.claimPrize();
    }

    function testMultipleWinnersCanClaimIndependently() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");
        address player3 = makeAddr("player3");

        _fundPlayerForRaffle(player1, 10 ether);
        _fundPlayerForRaffle(player2, 10 ether);
        _fundPlayerForRaffle(player3, 10 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);
        _runRound(raffle, interval, FIRST_ENTRY_WINS);

        _enterRaffleAsPlayer(raffle, player2, entranceFee);
        _enterRaffleAsPlayer(raffle, player3, entranceFee);
        _runRound(raffle, interval, FIRST_ENTRY_WINS);

        uint256 player1BalanceBefore = player1.balance;
        uint256 player2BalanceBefore = player2.balance;

        vm.prank(player1);
        raffle.claimPrize();
        assertEq(player1.balance, player1BalanceBefore + entranceFee * 2);

        vm.prank(player2);
        raffle.claimPrize();
        assertEq(player2.balance, player2BalanceBefore + entranceFee * 2);
    }

    // Chainlink Automation integration tests
    function testEntryWindowIsOpenWhenIntervalHasNotPassed() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);

        _assertEntryWindowIsOpen(raffle);
    }

    function testEntryWindowIsClosedWhenIntervalHasPassed() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);

        _waitForDrawTime(interval + 1);

        _assertEntryWindowIsClosed(raffle);
    }

    function testGetEntryDeadline() public {
        uint256 interval = 3600;
        Raffle raffle = _createRaffleWithInterval(interval);

        uint256 expectedDeadline = block.timestamp + interval;
        uint256 actualDeadline = raffle.getEntryDeadline();

        assertEq(actualDeadline, expectedDeadline);
    }

    function testPrizePoolIncreasesWhenPlayersEnter() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");
        address player3 = makeAddr("player3");

        _fundPlayerForRaffle(player1, 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);
        _fundPlayerForRaffle(player3, 1 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);
        _enterRaffleAsPlayer(raffle, player3, entranceFee);

        assertEq(
            raffle.getPrizePool(),
            entranceFee * 3,
            "Prize pool should be equal to the entrance fee multiplied by the number of players"
        );
    }

    function testGetEntriesCountReturnsNumberOfEntries() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);
        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);

        assertEq(raffle.getEntriesCount(), 3, "Entries count should be equal to the number of entries");
    }

    function testGetUnclaimedPrizeReturnsZeroForPlayerWithNoPrize() public {
        Raffle raffle = _createValidRaffle();
        address player = makeAddr("player");

        assertEq(raffle.getUnclaimedPrize(player), 0);
    }

    function testGetUnclaimedPrizeReturnsCorrectAmountForWinner() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        _fundPlayerForRaffle(player1, 1 ether);
        _fundPlayerForRaffle(player2, 1 ether);

        _enterRaffleAsPlayer(raffle, player1, entranceFee);
        _enterRaffleAsPlayer(raffle, player2, entranceFee);

        uint256 expectedPrize = entranceFee * 2;

        _runRound(raffle, 1, FIRST_ENTRY_WINS);

        assertEq(raffle.getUnclaimedPrize(player1), expectedPrize);
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
            entranceFee, interval, address(vrfCoordinatorMock), KEY_HASH, subscriptionId, CALLBACK_GAS_LIMIT
        );

        vrfCoordinatorMock.addConsumer(subscriptionId, address(raffle));

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
        vrfCoordinatorMock.simulateVrfCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), randomWord
        );

        return vm.getRecordedLogs().getWinner();
    }

    function _completeRoundWithFailedTransfer(Raffle raffle, uint256 interval) private {
        _waitForDrawTime(interval + 1);

        vm.recordLogs();
        _startDraw(raffle);
        vrfCoordinatorMock.simulateVrfCoordinatorCallback(
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
