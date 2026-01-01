// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, AutomationConfig} from "./HelperConfig.s.sol";

contract FundUpkeep is Script {
    uint96 public constant DEFAULT_FUND_AMOUNT = 2e18;

    function run() external {
        uint256 upkeepId = vm.envUint("AUTOMATION_UPKEEP_ID");
        uint96 amount = uint96(vm.envOr("UPKEEP_FUND_AMOUNT", uint256(DEFAULT_FUND_AMOUNT)));

        fundUpkeep(upkeepId, amount);
    }

    function fundUpkeep(uint256 upkeepId, uint96 amount) public {
        HelperConfig helperConfig = new HelperConfig();
        AutomationConfig automationConfig = helperConfig.automationConfigForChain(block.chainid);

        console.log("Funding upkeep:", upkeepId);
        console.log("Amount (LINK wei):", amount);

        automationConfig.fundUpkeep(upkeepId, amount);

        console.log("Upkeep funded successfully!");
        console.log("View at: https://automation.chain.link/sepolia/", upkeepId);
    }
}
