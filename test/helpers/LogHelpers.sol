// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Vm} from "forge-std/Vm.sol";

library LogHelpers {
    function getWinner(Vm.Log[] memory logs) internal pure returns (address) {
        return address(uint160(uint256(logs[0].topics[1])));
    }
}
