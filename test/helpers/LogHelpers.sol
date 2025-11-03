// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Vm} from "forge-std/Vm.sol";

library LogHelpers {
    function getWinner(Vm.Log[] memory logs) internal pure returns (address) {
        // RoundCompleted is now emitted before WinnerSelected, so winner is in logs[1]
        return address(uint160(uint256(logs[1].topics[1])));
    }

    function getVrfRequestId(Vm.Log[] memory logs) internal pure returns (uint256) {
        return abi.decode(logs[0].data, (uint256));
    }
}
