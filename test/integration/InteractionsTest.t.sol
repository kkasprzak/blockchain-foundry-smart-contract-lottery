// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {PerformUpkeep} from "../../script/Interactions.s.sol";
import {MyVrfCoordinatorV25Mock} from "../mocks/MyVrfCoordinatorV25Mock.sol";
import {LogHelpers} from "../helpers/LogHelpers.sol";

contract InteractionsTest is Test {
    using LogHelpers for Vm.Log[];

    Raffle private raffle;
    DeployRaffle private deployRaffle;
    MyVrfCoordinatorV25Mock private vrfCoordinatorMock;

    event RaffleEntered(uint256 indexed roundNumber, address indexed player);
    event DrawCompleted(uint256 indexed roundNumber, address indexed winner, uint256 prize);

    function setUp() external {
        deployRaffle = new DeployRaffle();
        raffle = deployRaffle.run();
        vrfCoordinatorMock = MyVrfCoordinatorV25Mock(address(raffle.s_vrfCoordinator()));
    }

    function testMultiPlayerScenario() public {
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");
        address player3 = makeAddr("player3");
        uint256 entranceFee = raffle.getEntranceFee();

        vm.deal(player1, 1 ether);
        vm.deal(player2, 1 ether);
        vm.deal(player3, 1 ether);

        uint256 entranceFees = entranceFee * 3;
        uint256 expectedPrizePool = entranceFees + address(raffle).balance;

        vm.expectEmit(true, true, false, false, address(raffle));
        emit RaffleEntered(1, player1);
        vm.prank(player1);
        raffle.enterRaffle{value: entranceFee}();

        vm.expectEmit(true, true, false, false, address(raffle));
        emit RaffleEntered(1, player2);
        vm.prank(player2);
        raffle.enterRaffle{value: entranceFee}();

        vm.expectEmit(true, true, false, false, address(raffle));
        emit RaffleEntered(1, player3);
        vm.prank(player3);
        raffle.enterRaffle{value: entranceFee}();

        vm.warp(block.timestamp + deployRaffle.DEFAULT_INTERVAL() + 1);

        vm.recordLogs();
        PerformUpkeep performUpkeepScript = new PerformUpkeep();
        performUpkeepScript.performUpkeep(address(raffle));

        vm.expectEmit(true, true, false, true, address(raffle));
        emit DrawCompleted(1, player2, expectedPrizePool);

        vrfCoordinatorMock.simulateVrfCoordinatorCallback(vm.getRecordedLogs().getVrfRequestId(), address(raffle), 1);

        address winner = vm.getRecordedLogs().getWinner();
        uint256 balanceBeforeClaim = winner.balance;

        vm.prank(winner);
        raffle.claimPrize();

        assertTrue(winner == player2);
        assertEq(winner.balance, balanceBeforeClaim + expectedPrizePool);
        assertEq(address(raffle).balance, 0);
    }
}
