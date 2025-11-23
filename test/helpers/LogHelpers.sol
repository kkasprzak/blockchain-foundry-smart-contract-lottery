// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Vm} from "forge-std/Vm.sol";

library LogHelpers {
    function getWinner(Vm.Log[] memory logs) internal pure returns (address) {
        bytes32 drawCompletedSig = keccak256("DrawCompleted(uint256,address,uint256)");
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics.length > 0 && logs[i].topics[0] == drawCompletedSig) {
                return address(uint160(uint256(logs[i].topics[2])));
            }
        }
        revert("DrawCompleted event not found");
    }

    function getVrfRequestId(Vm.Log[] memory logs) internal pure returns (uint256) {
        bytes32 randomWordsRequestedSig =
            keccak256("RandomWordsRequested(bytes32,uint256,uint256,uint256,uint16,uint32,uint32,bytes,address)");
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics.length > 0 && logs[i].topics[0] == randomWordsRequestedSig) {
                return abi.decode(logs[i].data, (uint256));
            }
        }
        revert("RandomWordsRequested event not found");
    }
}
