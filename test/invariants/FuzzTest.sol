// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Handler} from './Handler.sol';
import {vm} from './utils/VM.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {ICrosschainERC20} from 'src/interfaces/ICrosschainERC20.sol';

contract FuzzTest is Handler {
  /// @custom:property-id 1
  /// @notice Is not possible to deploy a CrosschainERC20 on the same address as an already deployed one using
  /// different params and the same msg.sender.
  function property_cantReuseSameParamsFromSameCaller(
    string memory _name,
    string memory _symbol,
    uint8 _decimals
  ) public {
    // solhint-disable-next-line custom-errors
    require(bytes(_name).length < 100, 'Name too long');
    // solhint-disable-next-line custom-errors
    require(bytes(_symbol).length < 100, 'Symbol too long');

    uint256[] memory _minterLimits = new uint256[](1);
    uint256[] memory _burnerLimits = new uint256[](1);
    address[] memory _bridges = new address[](1);

    bytes32 _salt = keccak256(abi.encodePacked(_name, _symbol, _decimals, msg.sender));

    try factory.deployCrosschainERC20(_name, _symbol, _decimals, _minterLimits, _burnerLimits, _bridges, _OWNER) {
      ghost_paramsUsed[_name][_symbol][_decimals] = true;
      ghost_saltUsed[_salt] = msg.sender;
    } catch {
      // If the deployment fails, the params must have been used
      assert(ghost_paramsUsed[_name][_symbol][_decimals]);
    }
  }

  /// @custom:property-id 2
  /// @notice Is not possible to deploy a CrosschainERC20 on the same address as an already deployed one using
  /// different params and a different msg.sender.
  function property_cantReuseSameParamsFromDifferentCaller(
    string memory _name,
    string memory _symbol,
    uint8 _decimals,
    address _caller
  ) public {
    // solhint-disable-next-line custom-errors
    require(bytes(_name).length < 100, 'Name too long');
    // solhint-disable-next-line custom-errors
    require(bytes(_symbol).length < 100, 'Symbol too long');

    uint256[] memory _minterLimits = new uint256[](1);
    uint256[] memory _burnerLimits = new uint256[](1);
    address[] memory _bridges = new address[](1);

    bytes32 _salt = keccak256(abi.encodePacked(_name, _symbol, _decimals, _caller));

    vm.prank(_caller);
    try factory.deployCrosschainERC20(_name, _symbol, _decimals, _minterLimits, _burnerLimits, _bridges, _OWNER) {
      ghost_paramsUsed[_name][_symbol][_decimals] = true;
      ghost_saltUsed[_salt] = _caller;
    } catch {
      // If the deployment fails, the salt must have been used by the caller before
      // If a different caller was used, the salt would have been different and the deployment would have succeeded
      assert(ghost_saltUsed[_salt] == _caller);
    }
  }

  /// @custom:property-id 3
  /// @notice The total supply of the CrosschainERC20 equals the ERC20 locked in the lockbox (without considering
  /// transfers to its own address) +/- bridged CrosschainERC20 tokens.
  function property_totalSupplyIsSameAsXERC20LockedInLockbox() public view {
    assert(
      IERC20(address(crosschainERC20)).totalSupply() - ghost_nonLockboxSupply
        == IERC20(address(xerc20)).balanceOf(address(lockbox)) - ghost_lockboxSelfTransfer
    );
  }

  /// @custom:property-id 4
  /// @notice The bridge cannot set the limits to a value greater than the max allowed.
  function property_bridgeLimitsCannotBeGreaterThanMaxAllowed() public view {
    assert(
      crosschainERC20.mintingMaxLimitOf(_BRIDGE) < type(uint256).max >> 1
        && crosschainERC20.burningMaxLimitOf(_BRIDGE) < type(uint256).max >> 1
    );
  }

  /// @custom:property-id 5
  /// @notice Current limit can not be reset by setting new limits.
  // function property_currentLimitCannotBeResetBySettingNewLimits() public {
  //   // Get the current limits
  //   uint256 _mintingCurrentLimit = crosschainERC20.mintingCurrentLimitOf(_BRIDGE);
  //   uint256 _burningCurrentLimit = crosschainERC20.burningCurrentLimitOf(_BRIDGE);

  //   // Get max limits
  //   uint256 _mintingMaxLimit = crosschainERC20.mintingMaxLimitOf(_BRIDGE);
  //   uint256 _burningMaxLimit = crosschainERC20.burningMaxLimitOf(_BRIDGE);

  //   // Set new limits to zero
  //   vm.prank(_OWNER);
  //   crosschainERC20.setLimits(_BRIDGE, 0, 0);

  //   // Set limits back to the original values
  //   vm.prank(_OWNER);
  //   crosschainERC20.setLimits(_BRIDGE, _mintingMaxLimit, _burningMaxLimit);

  //   // Check that the current limits are equal to the original values
  //   assert(crosschainERC20.mintingCurrentLimitOf(_BRIDGE) == _mintingCurrentLimit);
  //   assert(crosschainERC20.burningCurrentLimitOf(_BRIDGE) == _burningCurrentLimit);
  // }
}
