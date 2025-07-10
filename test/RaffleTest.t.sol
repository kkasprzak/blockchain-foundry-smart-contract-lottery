// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../src/Raffle.sol";

contract RaffleTest is Test {
    function test_RaffleInitializes() public {
        Raffle raffle = new Raffle(0.01 ether);
        assertTrue(address(raffle) != address(0));
    }

    function test_RaffleInitializes_WithEntranceFee() public {
        Raffle raffle = new Raffle(0.01 ether);

        assertEq(raffle.getEntranceFee(), 0.01 ether);
    }

    function test_RaffleRevertsWhenYouDontPayEnough() public {
        Raffle raffle = new Raffle(0.01 ether);

        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle{value: 0.001 ether}();
    }

    function test_RaffleAllowsUserToEnterWithEnoughFee() public {
        Raffle raffle = new Raffle(0.01 ether);

        raffle.enterRaffle{value: 0.01 ether}();
    }

    function test_RaffleAllowsUserToEnterWithMoreThanEnoughFee() public {
        Raffle raffle = new Raffle(0.01 ether);

        raffle.enterRaffle{value: 0.02 ether}();
    }

    function test_RaffleRecordsPlayerWhenTheyEnter() public {
        Raffle raffle = new Raffle(0.01 ether);
        
        address playerAddr = makeAddr("player");
        vm.deal(playerAddr, 1 ether);
        vm.prank(playerAddr);
        raffle.enterRaffle{value: 0.01 ether}();
        
        assertTrue(raffle.isPlayerInRaffle(playerAddr));
    }

    function test_RaffleReturnsFalseForPlayerNotInRaffle() public {
        Raffle raffle = new Raffle(0.01 ether);
        
        address playerAddr = makeAddr("player");
        
        assertFalse(raffle.isPlayerInRaffle(playerAddr));
    }
}