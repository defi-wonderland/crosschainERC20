// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Handler} from './Handler.sol';
import {console} from 'forge-std/console.sol';
import {ICrosschainERC20} from 'src/interfaces/ICrosschainERC20.sol';

contract FuzzTest is Handler {
  function property_cantReuseSameParams(string memory _name, string memory _symbol, uint8 _decimals) public {
    require(bytes(_name).length < 100, 'Name too long');
    require(bytes(_symbol).length < 100, 'Symbol too long');

    uint256[] memory _minterLimits = new uint256[](1);
    uint256[] memory _burnerLimits = new uint256[](1);
    address[] memory _bridges = new address[](1);

    _minterLimits[0] = 1000e18;
    _burnerLimits[0] = 1000e18;
    _bridges[0] = _BRIDGE;

    bytes32 _salt = keccak256(abi.encodePacked(_name, _symbol, _decimals, msg.sender));

    try factory.deployCrosschainERC20(_name, _symbol, _decimals, _minterLimits, _burnerLimits, _bridges, _OWNER)
    returns (address crosschainERC20) {
      crosschainERC20s.push(ICrosschainERC20(crosschainERC20));

      _saltUsed[_salt] = true;
      _paramsUsed[_name][_symbol][_decimals] = true;
    } catch {
      assert(_paramsUsed[_name][_symbol][_decimals]);
    }
  }
}
