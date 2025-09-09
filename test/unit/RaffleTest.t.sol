// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";

contract RaffleTest is Test {
    event RaffleEntered(address indexed player);
    event WinnerSelected(address indexed winnerAddress, uint256 prizeAmount);
    event PrizeTransferFailed(address indexed winnerAddress, uint256 prizeAmount);

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
        new Raffle(invalidEntranceFee, validInterval, address(0));
    }

    function test_RaffleRevertsWithInvalidInterval() public {
        uint256 validEntranceFee = 0.01 ether;
        uint256 invalidInterval = 0;

        vm.expectRevert(Raffle.Raffle__InvalidInterval.selector);
        new Raffle(validEntranceFee, invalidInterval, address(0));
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

        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(player);

        _enterRaffleAsPlayer(raffle, player, entranceFee);
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

        address winner = raffle.pickWinner();

        assertTrue(winner == player1 || winner == player2);
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

        address winner = raffle.pickWinner();
        uint256 expectedWinnerBalance = 1 ether - entranceFee + totalPrizePool;

        assertEq(winner.balance, expectedWinnerBalance);
    }

    function test_PickWinnerEmitsWinnerSelectedEvent() public {
        uint256 entranceFee = 0.01 ether;
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithEntranceFeeAndInterval(entranceFee, interval);
        address player = makeAddr("player");

        _fundPlayerForRaffle(player, 1 ether);
        _enterRaffleAsPlayer(raffle, player, entranceFee);

        _waitForDrawTime(interval + 1);

        uint256 expectedPrizeAmount = entranceFee;

        vm.expectEmit(true, false, false, true, address(raffle));
        emit WinnerSelected(player, expectedPrizeAmount);

        raffle.pickWinner();
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

        raffle.pickWinner();

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
        raffle.pickWinner();

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

        address winner = raffle.pickWinner();

        assertEq(winner, address(0));
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

        raffle.pickWinner();

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

        vm.expectEmit(true, false, false, true, address(raffle));
        emit PrizeTransferFailed(address(maliciousWinner), expectedPrizeAmount);

        raffle.pickWinner();
    }

    function _createValidRaffle() private returns (Raffle) {
        return new Raffle(1 ether, 1, address(0));
    }

    function _createRaffleWithInterval(uint256 interval) private returns (Raffle) {
        return new Raffle(1 ether, interval, address(0));
    }

    function _createRaffleWithEntranceFee(uint256 entranceFee) private returns (Raffle) {
        return new Raffle(entranceFee, 1, address(0));
    }

    function _createRaffleWithEntranceFeeAndInterval(uint256 entranceFee, uint256 interval) private returns (Raffle) {
        return new Raffle(entranceFee, interval, address(0));
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
