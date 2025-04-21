// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract GhostVariables {
  mapping(bytes32 _salt => address _caller) internal ghost_saltUsed;
  mapping(address _deployedAt => bool _isDeployed) internal ghost_addressUsed;
  mapping(string _name => mapping(string _symbol => mapping(uint8 _decimals => bool _used))) internal ghost_paramsUsed;
  uint256 internal ghost_nonLockboxSupply;
  uint256 internal ghost_lockboxSelfTransfer;
}
