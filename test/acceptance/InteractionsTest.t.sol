// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {RaffleEnterRaffle} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    Raffle raffle;

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        raffle = deployRaffle.run();
    }

    function test_PlayerCanEnterRaffle() public {
        // Arrange - Create player and fund them (following Cyfrin pattern)
        address player = makeAddr("player");
        uint256 entranceFee = raffle.getEntranceFee();
        vm.deal(player, 1 ether);

        uint256 prePlayerBalance = address(player).balance;

        // Act - Player directly enters raffle (not through script)
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();

        uint256 afterPlayerBalance = address(player).balance;

        // Assert - Verify player is registered and balance was deducted
        assertTrue(raffle.isPlayerInRaffle(player));
        assertEq(afterPlayerBalance + entranceFee, prePlayerBalance);
    }
}
