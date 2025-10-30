// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {RafflePickWinner} from "../../script/Interactions.s.sol";
import {MyVRFCoordinatorV2_5Mock} from "../mocks/MyVRFCoordinatorV2_5Mock.sol";
import {LogHelpers} from "../helpers/LogHelpers.sol";

contract InteractionsTest is Test {
    using LogHelpers for Vm.Log[];

    Raffle raffle;
    MyVRFCoordinatorV2_5Mock myVRFCoordinatorV2_5Mock;

    event RaffleEntered(address indexed player);
    event WinnerSelected(address indexed winnerAddress, uint256 prizeAmount);

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        raffle = deployRaffle.run();
        myVRFCoordinatorV2_5Mock = MyVRFCoordinatorV2_5Mock(address(raffle.s_vrfCoordinator()));
    }

    function test_MultiPlayerScenario() public {
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");
        address player3 = makeAddr("player3");
        uint256 entranceFee = raffle.getEntranceFee();

        vm.deal(player1, 1 ether);
        vm.deal(player2, 1 ether);
        vm.deal(player3, 1 ether);

        uint256 entranceFees = entranceFee * 3;
        uint256 expectedPrizePool = entranceFees + address(raffle).balance;

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

        vm.warp(block.timestamp + 301);

        vm.recordLogs();
        RafflePickWinner rafflePickWinner = new RafflePickWinner();
        rafflePickWinner.pickWinner(address(raffle));

        vm.expectEmit(false, false, false, true, address(raffle));
        emit WinnerSelected(address(0), expectedPrizePool);

        myVRFCoordinatorV2_5Mock.simulateVRFCoordinatorCallback(
            vm.getRecordedLogs().getVrfRequestId(), address(raffle), 1
        );

        address winner = vm.getRecordedLogs().getWinner();
        uint256 actualPrizeTransferred = address(winner).balance - (1 ether - entranceFee);

        assertTrue(winner == player2);
        assertEq(actualPrizeTransferred, expectedPrizePool);
        assertEq(address(raffle).balance, 0);

        assertFalse(raffle.isPlayerInRaffle(player1));
        assertFalse(raffle.isPlayerInRaffle(player2));
        assertFalse(raffle.isPlayerInRaffle(player3));
    }
}
