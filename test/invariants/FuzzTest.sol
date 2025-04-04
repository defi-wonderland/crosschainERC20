// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Handler} from './Handler.sol';
import {vm} from './utils/VM.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {CREATE3} from 'solady/utils/CREATE3.sol';

contract FuzzTest is Handler {
  uint256 private constant _MAX_LIMIT = type(uint256).max >> 1;

  /// @custom:property-id 1
  /// @notice The same msg.sender MUST NOT be able to deploy a CrosschainERC20 on the same address as one that he
  /// already deployed one using different params.
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

    bytes32 _salt = keccak256(abi.encode(_name, _symbol, _decimals, address(this)));

    address _predictedAddress = CREATE3.predictDeterministicAddress(_salt, address(factory));

    try factory.deployCrosschainERC20(_name, _symbol, _decimals, _minterLimits, _burnerLimits, _bridges, _OWNER)
    returns (address _crosschainERC20) {
      ghost_paramsUsed[_name][_symbol][_decimals] = true;
      ghost_saltUsed[_salt] = address(this);
      assert(_crosschainERC20 == _predictedAddress);
      ghost_addressUsed[_crosschainERC20] = true;
    } catch {
      // If the deployment fails, the params must have been used
      assert(ghost_paramsUsed[_name][_symbol][_decimals]);
    }
  }

  /// @custom:property-id 2
  /// @notice Different msg.sender's MUST NOT be able to deploy a CrosschainERC20 on the same address on different
  /// chains using different params.
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

    bytes32 _salt = keccak256(abi.encode(_name, _symbol, _decimals, _caller));

    address _predictedAddress = CREATE3.predictDeterministicAddress(_salt, address(factory));

    vm.prank(_caller);
    try factory.deployCrosschainERC20(_name, _symbol, _decimals, _minterLimits, _burnerLimits, _bridges, _OWNER)
    returns (address _crosschainERC20) {
      ghost_paramsUsed[_name][_symbol][_decimals] = true;
      ghost_saltUsed[_salt] = _caller;
      assert(_crosschainERC20 == _predictedAddress);
      ghost_addressUsed[_crosschainERC20] = true;
    } catch {
      // If the deployment fails, the salt must have been used by the caller before
      // If a different caller was used, the salt would have been different and the deployment would have succeeded
      assert(ghost_saltUsed[_salt] == _caller);
    }
  }

  /// @custom:property-id 3
  /// @notice A CrosschainERC20 MUST NOT be able to be deployed on the same address on different chains using
  /// different params.
  function property_cantReuseSameParamsFromDifferentChain(
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

    bytes32 _salt = keccak256(abi.encode(_name, _symbol, _decimals, address(this)));

    address _predictedAddress = CREATE3.predictDeterministicAddress(_salt, address(factory));

    try factory.deployCrosschainERC20(_name, _symbol, _decimals, _minterLimits, _burnerLimits, _bridges, _OWNER)
    returns (address _crosschainERC20) {
      ghost_paramsUsed[_name][_symbol][_decimals] = true;
      ghost_saltUsed[_salt] = address(this);
      assert(_crosschainERC20 == _predictedAddress);
      ghost_addressUsed[address(_crosschainERC20)] = true;
    } catch {
      // If the deployment fails, the params must have been used
      // And the salt must have been used by the caller before
      assert(
        ghost_paramsUsed[_name][_symbol][_decimals] && ghost_saltUsed[_salt] == address(this)
          && ghost_addressUsed[_predictedAddress]
      );
    }
  }

  /// @custom:property-id 4
  /// @notice The total supply of the CrosschainERC20 equals the ERC20 deposited in the lockbox +/- bridged
  /// CrosschainERC20 tokens.
  function property_totalSupplyIsSameAsXERC20LockedInLockbox() public view {
    assert(
      IERC20(address(crosschainERC20)).totalSupply() - ghost_nonLockboxSupply
        == IERC20(address(xerc20)).balanceOf(address(lockbox)) - ghost_lockboxSelfTransfer
    );
  }

  /// @custom:property-id 5
  /// @notice The bridge limits MUST NOT be set to a value greater than the max allowed.
  function property_bridgeLimitsCannotBeGreaterThanMaxAllowed() public view {
    assert(
      crosschainERC20.mintingMaxLimitOf(_BRIDGE) < _MAX_LIMIT && crosschainERC20.burningMaxLimitOf(_BRIDGE) < _MAX_LIMIT
    );
  }
}
