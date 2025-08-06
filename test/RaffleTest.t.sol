// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../src/Raffle.sol";

contract RaffleTest is Test {
    event RaffleEntered(address indexed player);

    function test_RaffleInitializes() public {
        Raffle raffle = _createValidRaffle();
        assertTrue(address(raffle) != address(0));
    }

    function test_RaffleInitializes_WithEntranceFee() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);

        assertEq(raffle.getEntranceFee(), entranceFee);
    }

    function test_RaffleRevertsWhenYouDontPayEnough() public {
        uint256 entranceFee = 0.01 ether;
        uint256 insufficientPayment = entranceFee / 10;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);

        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle{value: insufficientPayment}();
    }

    function test_RaffleAllowsUserToEnterWithEnoughFee() public {
        uint256 entranceFee = 0.01 ether;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);

        raffle.enterRaffle{value: entranceFee}();
    }

    function test_RaffleAllowsUserToEnterWithMoreThanEnoughFee() public {
        uint256 entranceFee = 0.01 ether;
        uint256 overpayment = entranceFee * 2;
        Raffle raffle = _createRaffleWithEntranceFee(entranceFee);

        raffle.enterRaffle{value: overpayment}();
    }

    function test_RaffleRecordsPlayerWhenTheyEnter() public {
        Raffle raffle = new Raffle(0.01 ether, 30);

        address playerAddr = makeAddr("player");
        vm.deal(playerAddr, 1 ether);
        vm.prank(playerAddr);
        raffle.enterRaffle{value: 0.01 ether}();

        assertTrue(raffle.isPlayerInRaffle(playerAddr));
    }

    function test_RaffleReturnsFalseForPlayerNotInRaffle() public {
        Raffle raffle = _createValidRaffle();
        address playerAddr = makeAddr("player");

        assertFalse(raffle.isPlayerInRaffle(playerAddr));
    }

    function test_RaffleEmitsEventOnEntrance() public {
        Raffle raffle = new Raffle(0.01 ether, 30);
        address playerAddr = makeAddr("player");
        vm.deal(playerAddr, 1 ether);

        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(playerAddr);

        vm.prank(playerAddr);
        raffle.enterRaffle{value: 0.01 ether}();
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

    function test_PickWinnerRevertsWhenNoParticipants() public {
        uint256 interval = 30;
        Raffle raffle = _createRaffleWithInterval(interval);
        _waitForDrawTime(interval + 1);

        vm.expectRevert(Raffle.Raffle__NoParticipants.selector);
        raffle.pickWinner();
    }

    function test_PickWinnerSelectsWinnerFromParticipants() public {
        Raffle raffle = new Raffle(0.01 ether, 30);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        vm.deal(player1, 1 ether);
        vm.deal(player2, 1 ether);

        vm.prank(player1);
        raffle.enterRaffle{value: 0.01 ether}();

        vm.prank(player2);
        raffle.enterRaffle{value: 0.01 ether}();

        vm.warp(block.timestamp + 31);

        address winner = raffle.pickWinner();

        assertTrue(winner == player1 || winner == player2);
    }

    function _createValidRaffle() private returns (Raffle) {
        return new Raffle(1 ether, 1);
    }

    function _createRaffleWithInterval(uint256 interval) private returns (Raffle) {
        return new Raffle(1 ether, interval);
    }

    function _createRaffleWithEntranceFee(uint256 entranceFee) private returns (Raffle) {
        return new Raffle(entranceFee, 1);
    }

    function _waitForDrawTime(uint256 timeToWait) private {
        vm.warp(block.timestamp + timeToWait);
    }
}
