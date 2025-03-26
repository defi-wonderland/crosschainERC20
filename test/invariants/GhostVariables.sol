// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GhostVariables {
  mapping(bytes32 _salt => bool) internal ghost_saltUsed;
  mapping(string _name => mapping(string _symbol => mapping(uint8 _decimals => bool _used))) internal ghost_paramsUsed;
  uint256 internal ghost_nonLockboxSupply;
  uint256 internal ghost_lockboxSelfTransfer;
}
