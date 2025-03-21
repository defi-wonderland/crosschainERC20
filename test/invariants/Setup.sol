// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {vm} from './VM.sol';
import {XERC20} from '@xERC20/contracts/XERC20.sol';
import {console} from 'forge-std/console.sol';
import {CrosschainERC20Factory} from 'src/contracts/CrosschainERC20Factory.sol';
import {ICrosschainERC20} from 'src/interfaces/ICrosschainERC20.sol';
import {IERC7802Adapter} from 'src/interfaces/IERC7802Adapter.sol';

contract Setup {
  //Actors
  address internal immutable _OWNER = makeAddr('Owner');
  address internal immutable _USER = makeAddr('User');
  address internal immutable _BRIDGE = makeAddr('Bridge');

  //Contracts
  CrosschainERC20Factory public factory;
  ICrosschainERC20[] public crosschainERC20s;
  XERC20 public xerc20;
  IERC7802Adapter public adapters;

  constructor() {
    xerc20 = new XERC20('Test', 'TEST', 18, _OWNER);
    factory = new CrosschainERC20Factory();
  }

  function makeAddr(string memory name) internal returns (address) {
    return vm.addr(uint256(keccak256(abi.encodePacked(name))));
  }
}
