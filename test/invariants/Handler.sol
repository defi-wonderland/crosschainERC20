// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Setup} from './Setup.sol';
import {vm} from './VM.sol';
import {console} from 'forge-std/console.sol';
import {ICrosschainERC20} from 'src/interfaces/ICrosschainERC20.sol';

contract Handler is Setup {
  uint256 ghost_IDcounter;
  mapping(bytes32 _salt => bool) internal _saltUsed;
  mapping(string _name => mapping(string _symbol => mapping(uint8 _decimals => bool _used))) internal _paramsUsed;

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                      LOCKBOX HANDLERS                      */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  function handler_lockbox_deposit(uint256 _amount) public {
    vm.prank(_USER);
    lockbox.deposit(_amount);
  }

  function handler_lockbox_withdraw(uint256 _amount) public {
    vm.prank(_USER);
    lockbox.withdraw(_amount);
  }
}
