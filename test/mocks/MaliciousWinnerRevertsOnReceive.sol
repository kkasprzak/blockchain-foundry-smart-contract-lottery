// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MaliciousWinnerRevertsOnReceive {
    receive() external payable {
        revert("Malicious winner refuses payment");
    }
}
