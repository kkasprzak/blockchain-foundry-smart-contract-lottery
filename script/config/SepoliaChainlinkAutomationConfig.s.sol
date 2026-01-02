// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ChainlinkAutomationConfig} from "./ChainlinkAutomationConfig.s.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {
    IKeeperRegistryMaster
} from "@chainlink/contracts/src/v0.8/automation/interfaces/v2_1/IKeeperRegistryMaster.sol";

struct RegistrationParams {
    string name;
    bytes encryptedEmail;
    address upkeepContract;
    uint32 gasLimit;
    address adminAddress;
    uint8 triggerType;
    bytes checkData;
    bytes triggerConfig;
    bytes offchainConfig;
    uint96 amount;
}

interface IAutomationRegistrar {
    function registerUpkeep(RegistrationParams calldata requestParams) external returns (uint256);
}

contract SepoliaChainlinkAutomationConfig is ChainlinkAutomationConfig {
    address private constant AUTOMATION_REGISTRAR = 0xb0E49c5D0d05cbc241d68c05BC5BA1d1B7B72976;
    address private constant AUTOMATION_REGISTRY = 0x86EFBD0b6736Bed994962f9797049422A3A8E8Ad;
    address private constant LINK_TOKEN = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    function registerUpkeep(string calldata name, address upkeepContract, uint32 gasLimit, uint96 amount)
        external
        override
        returns (uint256)
    {
        vm.startBroadcast();

        LinkTokenInterface(LINK_TOKEN).approve(AUTOMATION_REGISTRAR, amount);

        RegistrationParams memory params = RegistrationParams({
            name: name,
            encryptedEmail: "",
            upkeepContract: upkeepContract,
            gasLimit: gasLimit,
            adminAddress: msg.sender,
            triggerType: 0,
            checkData: "",
            triggerConfig: "",
            offchainConfig: "",
            amount: amount
        });

        uint256 upkeepId = IAutomationRegistrar(AUTOMATION_REGISTRAR).registerUpkeep(params);

        vm.stopBroadcast();

        return upkeepId;
    }

    function fundUpkeep(uint256 upkeepId, uint96 amount) external override {
        vm.startBroadcast();

        LinkTokenInterface(LINK_TOKEN).approve(AUTOMATION_REGISTRY, amount);
        IKeeperRegistryMaster(AUTOMATION_REGISTRY).addFunds(upkeepId, amount);

        vm.stopBroadcast();
    }
}
