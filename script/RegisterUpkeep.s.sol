// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, AutomationConfig} from "./HelperConfig.s.sol";

contract RegisterUpkeep is Script {
    uint32 public constant DEFAULT_GAS_LIMIT = 200000;
    uint96 public constant DEFAULT_FUND_AMOUNT = 2e18;

    function run() external {
        address raffleAddress = vm.envAddress("RAFFLE_CONTRACT_ADDRESS");
        string memory upkeepName = vm.envOr("UPKEEP_NAME", string("Raffle Auto Draw"));
        uint32 gasLimit = uint32(vm.envOr("UPKEEP_GAS_LIMIT", uint256(DEFAULT_GAS_LIMIT)));
        uint96 fundAmount = uint96(vm.envOr("UPKEEP_FUND_AMOUNT", uint256(DEFAULT_FUND_AMOUNT)));

        registerUpkeep(raffleAddress, upkeepName, gasLimit, fundAmount);
    }

    function registerUpkeep(address raffleAddress, string memory upkeepName, uint32 gasLimit, uint96 fundAmount)
        public
        returns (uint256)
    {
        HelperConfig helperConfig = new HelperConfig();
        AutomationConfig automationConfig = helperConfig.automationConfigForChain(block.chainid);

        console.log("Registering upkeep for contract:", raffleAddress);
        console.log("Upkeep name:", upkeepName);
        console.log("Gas limit:", gasLimit);
        console.log("Fund amount (LINK wei):", fundAmount);

        uint256 upkeepId = automationConfig.registerUpkeep(upkeepName, raffleAddress, gasLimit, fundAmount);

        console.log("Upkeep registered successfully!");
        console.log("Upkeep ID:", upkeepId);
        console.log("Add this to your .env file:");
        console.log("  AUTOMATION_UPKEEP_ID=<upkeep_id_above>");
        console.log("");
        console.log("View at: https://automation.chain.link/sepolia/<upkeep_id>");

        return upkeepId;
    }
}
