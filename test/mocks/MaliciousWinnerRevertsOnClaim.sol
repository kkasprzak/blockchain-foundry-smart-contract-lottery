// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MaliciousWinnerRevertsOnClaim {
    bool private revertOnReceive;

    function shouldRevert(bool _shouldRevert) external {
        revertOnReceive = _shouldRevert;
    }

    receive() external payable {
        if (revertOnReceive) {
            revert("Transfer failed");
        }
    }
}
