// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Contracts
import {CrosschainERC20Factory} from 'contracts/CrosschainERC20Factory.sol';

// Script
import {Script} from 'forge-std/Script.sol';

// Utils
import {CREATE3} from 'solady/utils/CREATE3.sol';

contract DeployCrosschainERC20Factory is Script {
  function run() public returns (CrosschainERC20Factory _factory) {
    vm.startBroadcast();
    bytes32 salt = keccak256(abi.encodePacked('wonderland')); // Deploys at `0xe4c221582E95A0d84b29d294AF8235Fc74E1CF60`
    _factory = CrosschainERC20Factory(CREATE3.deployDeterministic(type(CrosschainERC20Factory).creationCode, salt));
    vm.stopBroadcast();
  }
}
