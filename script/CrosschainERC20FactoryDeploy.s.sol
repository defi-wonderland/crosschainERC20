// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {CrosschainERC20Factory} from 'contracts/CrosschainERC20Factory.sol';
import {Script} from 'forge-std/Script.sol';

contract DeployCrosschainERC20Factory is Script {
  function run() public returns (CrosschainERC20Factory _factory) {
    vm.startBroadcast();
    _factory = new CrosschainERC20Factory();
    vm.stopBroadcast();
  }
}
