// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Setup} from './Setup.sol';
import {console} from 'forge-std/console.sol';
import {ICrosschainERC20} from 'src/interfaces/ICrosschainERC20.sol';

contract Handler is Setup {
  mapping(bytes32 _salt => bool) internal _saltUsed;
  mapping(string _name => mapping(string _symbol => mapping(uint8 _decimals => bool _used))) internal _paramsUsed;

  function handler_deployCrosschainERC20(string memory _name, string memory _symbol, uint8 _decimals) public {
    require(bytes(_name).length < 100, 'Name too long');
    require(bytes(_symbol).length < 100, 'Symbol too long');

    uint256[] memory _minterLimits = new uint256[](1);
    uint256[] memory _burnerLimits = new uint256[](1);
    address[] memory _bridges = new address[](1);

    _minterLimits[0] = 1000e18;
    _burnerLimits[0] = 1000e18;
    _bridges[0] = _BRIDGE;

    factory.deployCrosschainERC20(_name, _symbol, _decimals, _minterLimits, _burnerLimits, _bridges, _OWNER);
  }

  function handler_deployCrosschainERC20Factory(string memory _name, string memory _symbol, uint8 _decimals) public {
    require(bytes(_name).length < 100, 'Name too long');
    require(bytes(_symbol).length < 100, 'Symbol too long');

    uint256[] memory _minterLimits = new uint256[](1);
    uint256[] memory _burnerLimits = new uint256[](1);
    address[] memory _bridges = new address[](1);

    _minterLimits[0] = 1000e18;
    _burnerLimits[0] = 1000e18;
    _bridges[0] = _BRIDGE;

    factory.deployCrosschainERC20WithLockbox(
      _name, _symbol, _decimals, _minterLimits, _burnerLimits, _bridges, _OWNER, address(xerc20)
    );
  }
}
