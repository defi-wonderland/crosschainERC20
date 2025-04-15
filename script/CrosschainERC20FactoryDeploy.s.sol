// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Contracts
import {CrosschainERC20Factory} from 'contracts/CrosschainERC20Factory.sol';

// Script
import {Script} from 'forge-std/Script.sol';

// Utils
import {CREATE3} from 'solady/utils/CREATE3.sol';

/// @title DeployCrosschainERC20Factory
/// @notice Template for deploying a new `CrosschainERC20Factory`. Please replace the salt value as needed.
contract DeployCrosschainERC20Factory is Script {
  function run() public returns (CrosschainERC20Factory _factory) {
    vm.startBroadcast();
    bytes32 salt = keccak256(abi.encodePacked('superseed')); // Deploys at `0xc8BFbAeEc5699e1E7a9a47386310E1a6A1133055`
    _factory = CrosschainERC20Factory(CREATE3.deployDeterministic(type(CrosschainERC20Factory).creationCode, salt));
    vm.stopBroadcast();
  }
}
