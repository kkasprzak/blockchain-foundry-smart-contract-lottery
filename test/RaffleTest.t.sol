// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../src/Raffle.sol";

contract RaffleTest is Test {
    event RaffleEntered(address indexed player);

    function test_RaffleInitializes() public {
        Raffle raffle = new Raffle(0.01 ether, 30);
        assertTrue(address(raffle) != address(0));
    }

    function test_RaffleInitializes_WithEntranceFee() public {
        Raffle raffle = new Raffle(0.01 ether, 30);

        assertEq(raffle.getEntranceFee(), 0.01 ether);
    }

    function test_RaffleRevertsWhenYouDontPayEnough() public {
        Raffle raffle = new Raffle(0.01 ether, 30);

        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle{value: 0.001 ether}();
    }

    function test_RaffleAllowsUserToEnterWithEnoughFee() public {
        Raffle raffle = new Raffle(0.01 ether, 30);

        raffle.enterRaffle{value: 0.01 ether}();
    }

    function test_RaffleAllowsUserToEnterWithMoreThanEnoughFee() public {
        Raffle raffle = new Raffle(0.01 ether, 30);

        raffle.enterRaffle{value: 0.02 ether}();
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
        Raffle raffle = new Raffle(0.01 ether, 30);

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
        Raffle raffle = new Raffle(0.01 ether, 30);

        vm.expectRevert(Raffle.Raffle__NotEnoughTimeHasPassed.selector);
        raffle.pickWinner();
    }
}
