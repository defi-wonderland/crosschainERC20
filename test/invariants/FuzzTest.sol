// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Handler} from './Handler.sol';
import {console} from 'forge-std/console.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {ICrosschainERC20} from 'src/interfaces/ICrosschainERC20.sol';

contract FuzzTest is Handler {
  /// @notice Fuzz test for the property that the factory cannot deploy a CrosschainERC20 with the same params.
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

    try factory.deployCrosschainERC20(_name, _symbol, _decimals, _minterLimits, _burnerLimits, _bridges, _OWNER) {
      ghost_saltUsed[_salt] = true;
      ghost_paramsUsed[_name][_symbol][_decimals] = true;
    } catch {
      assert(ghost_paramsUsed[_name][_symbol][_decimals]);
    }
  }

  function property_cantReuseSameParamsWithLockbox(string memory _name, string memory _symbol, uint8 _decimals) public {
    require(bytes(_name).length < 100, 'Name too long');
    require(bytes(_symbol).length < 100, 'Symbol too long');

    uint256[] memory _minterLimits = new uint256[](1);
    uint256[] memory _burnerLimits = new uint256[](1);
    address[] memory _bridges = new address[](1);

    _minterLimits[0] = 1000e18;
    _burnerLimits[0] = 1000e18;
    _bridges[0] = _BRIDGE;

    bytes32 _salt = keccak256(abi.encodePacked(_name, _symbol, _decimals, msg.sender));

    try factory.deployCrosschainERC20WithLockbox(
      _name, _symbol, _decimals, _minterLimits, _burnerLimits, _bridges, _OWNER, address(xerc20)
    ) {
      ghost_saltUsed[_salt] = true;
      ghost_paramsUsed[_name][_symbol][_decimals] = true;
    } catch {
      assert(ghost_paramsUsed[_name][_symbol][_decimals]);
    }
  }

  /// @notice CrosschainERC20 total supply is the same as the XERC20 locked in the lockbox.
  function property_totalSupplyIsSameAsXERC20LockedInLockbox() public view {
    assert(
      IERC20(address(crosschainERC20)).totalSupply() - ghost_nonLockboxSupply
        == IERC20(address(xerc20)).balanceOf(address(lockbox)) - ghost_lockboxSelfTransfer
    );
  }
}
