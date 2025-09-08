// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {RafflePickWinner} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    Raffle raffle;

    // Event declarations for testing
    event RaffleEntered(address indexed player);
    event WinnerSelected(address indexed winnerAddress, uint256 prizeAmount);

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        raffle = deployRaffle.run();
    }

    function test_MultiPlayerScenario() public {
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");
        address player3 = makeAddr("player3");
        uint256 entranceFee = raffle.getEntranceFee();

        vm.deal(player1, 1 ether);
        vm.deal(player2, 1 ether);
        vm.deal(player3, 1 ether);

        uint256 expectedPrizePool = entranceFee * 3;

        // Expect RaffleEntered events for each player
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(player1);
        vm.prank(player1);
        raffle.enterRaffle{value: entranceFee}();

        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(player2);
        vm.prank(player2);
        raffle.enterRaffle{value: entranceFee}();

        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(player3);
        vm.prank(player3);
        raffle.enterRaffle{value: entranceFee}();

        // Wait past the 300-second interval (5 minutes + 1 second to close entry window)
        vm.warp(block.timestamp + 301);

        // Expect WinnerSelected event (can't predict exact winner, so check data only)
        vm.expectEmit(false, false, false, true, address(raffle));
        emit WinnerSelected(address(0), expectedPrizePool);

        RafflePickWinner rafflePickWinner = new RafflePickWinner();
        address winner = rafflePickWinner.pickWinner(address(raffle));

        uint256 winnerFinalBalance = address(winner).balance;

        // Assert - Multi-player validation
        assertTrue(winner == player1 || winner == player2 || winner == player3);
        assertEq(winnerFinalBalance, 1 ether - entranceFee + expectedPrizePool);
        assertEq(address(raffle).balance, 0); // Prize pool should be fully distributed

        // Verify round reset
        assertFalse(raffle.isPlayerInRaffle(player1));
        assertFalse(raffle.isPlayerInRaffle(player2));
        assertFalse(raffle.isPlayerInRaffle(player3));
    }
}
