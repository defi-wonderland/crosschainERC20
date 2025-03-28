// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Setup} from './Setup.sol';
import {vm} from './utils/VM.sol';
import {IXERC20} from '@xERC20/interfaces/IXERC20.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {ICrosschainERC20} from 'src/interfaces/ICrosschainERC20.sol';

contract Handler is Setup {
  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                 CrosschainERC20 HANDLERS                   */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  function handler_crosschainERC20_crosschainMint(uint256 _amount) public {
    uint256 _userBalanceBefore = IERC20(address(crosschainERC20)).balanceOf(_USER);

    vm.prank(_BRIDGE);
    try crosschainERC20.crosschainMint(_USER, _amount) {
      assertEq(_userBalanceBefore + _amount, IERC20(address(crosschainERC20)).balanceOf(_USER), 'Unexpected Balance');
      ghost_nonLockboxSupply += _amount;
    } catch {
      assertWithMsg(
        IERC20(address(crosschainERC20)).allowance(_USER, _BRIDGE) < _amount // InsufficientAllowance()
          || IERC20(address(crosschainERC20)).totalSupply() > type(uint256).max - _amount // TotalSupplyOverflow()
          || IXERC20(address(crosschainERC20)).mintingCurrentLimitOf(_BRIDGE) < _amount, // IXERC20_NotHighEnoughLimits()
        'revert not expected'
      );
    }
  }

  function handler_crosschainERC20_crosschainBurn(uint256 _amount) public {
    uint256 _userBalanceBefore = IERC20(address(crosschainERC20)).balanceOf(_USER);

    vm.prank(_USER);
    IERC20(address(crosschainERC20)).approve(_BRIDGE, _amount);

    vm.prank(_BRIDGE);
    try crosschainERC20.crosschainBurn(_USER, _amount) {
      assertEq(_userBalanceBefore - _amount, IERC20(address(crosschainERC20)).balanceOf(_USER), 'Unexpected Balance');
      ghost_nonLockboxSupply -= _amount;
    } catch {
      assertWithMsg(
        IXERC20(address(crosschainERC20)).burningCurrentLimitOf(_BRIDGE) < _amount // IXERC20_NotHighEnoughLimits()
          || IERC20(address(crosschainERC20)).balanceOf(_USER) < _amount, // InsufficientBalance()
        'revert not expected'
      );
    }
  }

  function handler_crosschainERC20_mint(uint256 _amount) public {
    uint256 _userBalanceBefore = IERC20(address(crosschainERC20)).balanceOf(_USER);

    vm.prank(_BRIDGE);
    try crosschainERC20.mint(_USER, _amount) {
      assertEq(_userBalanceBefore + _amount, IERC20(address(crosschainERC20)).balanceOf(_USER), 'Unexpected Balance');
      ghost_nonLockboxSupply += _amount;
    } catch {
      assertWithMsg(
        IERC20(address(crosschainERC20)).allowance(_USER, _BRIDGE) < _amount // InsufficientAllowance()
          || IERC20(address(crosschainERC20)).totalSupply() > type(uint256).max - _amount // TotalSupplyOverflow()
          || IXERC20(address(crosschainERC20)).mintingCurrentLimitOf(_BRIDGE) < _amount, // IXERC20_NotHighEnoughLimits()
        'revert not expected'
      );
    }
  }

  function handler_crosschainERC20_burn(uint256 _amount) public {
    uint256 _userBalanceBefore = IERC20(address(crosschainERC20)).balanceOf(_USER);

    vm.prank(_USER);
    IERC20(address(crosschainERC20)).approve(_BRIDGE, _amount);

    vm.prank(_BRIDGE);
    try crosschainERC20.burn(_USER, _amount) {
      assertEq(_userBalanceBefore - _amount, IERC20(address(crosschainERC20)).balanceOf(_USER), 'Unexpected Balance');
      ghost_nonLockboxSupply -= _amount;
    } catch {
      assertWithMsg(
        IXERC20(address(crosschainERC20)).burningCurrentLimitOf(_BRIDGE) < _amount // IXERC20_NotHighEnoughLimits()
          || IERC20(address(crosschainERC20)).balanceOf(_USER) < _amount, // InsufficientBalance()
        'revert not expected'
      );
    }
  }

  function handler_crosschainERC20_crosschainMintRevert(address _caller, uint256 _amount) public {
    // solhint-disable-next-line custom-errors
    require(_caller != _BRIDGE && _caller != address(lockbox) && _caller != address(0), 'invalid caller');

    _amount = clampGt(_amount, 0);

    vm.prank(_caller);
    try crosschainERC20.crosschainMint(_USER, _amount) {
      assert(false);
    } catch {
      assertWithMsg(
        IERC20(address(crosschainERC20)).allowance(_USER, _caller) < _amount // InsufficientAllowance()
          || IXERC20(address(crosschainERC20)).mintingCurrentLimitOf(_caller) < _amount, // IXERC20_NotHighEnoughLimits()
        'revert not expected'
      );
    }
  }

  function handler_crosschainERC20_crosschainBurnRevert(address _caller, uint256 _amount) public {
    // solhint-disable-next-line custom-errors
    require(_caller != _BRIDGE && _caller != address(lockbox) && _caller != address(0), 'invalid caller');

    _amount = clampGt(_amount, 0);

    vm.prank(_caller);
    try crosschainERC20.crosschainBurn(_USER, _amount) {
      assert(false);
    } catch {
      assertWithMsg(
        IXERC20(address(crosschainERC20)).burningCurrentLimitOf(_caller) < _amount // IXERC20_NotHighEnoughLimits()
          || IERC20(address(crosschainERC20)).balanceOf(_USER) < _amount, // InsufficientBalance()
        'revert not expected'
      );
    }
  }

  function handler_crosschainERC20_setLimits(uint256 _minterLimit, uint256 _burnerLimit) public {
    vm.prank(_OWNER);
    try crosschainERC20.setLimits(_BRIDGE, _minterLimit, _burnerLimit) {
      assert(
        crosschainERC20.mintingMaxLimitOf(_BRIDGE) == _minterLimit
          && crosschainERC20.burningMaxLimitOf(_BRIDGE) == _burnerLimit
      );
    } catch {
      assertWithMsg(
        _minterLimit > type(uint256).max >> 1 || _burnerLimit > type(uint256).max >> 1, // IXERC20_LimitsTooHigh()
        'revert not expected'
      );
    }
  }

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                      LOCKBOX HANDLERS                      */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  function handler_lockbox_depositTo(uint256 _amount, address _to) public {
    _amount = clampGt(_amount, 0);

    vm.prank(_USER);
    IERC20(address(xerc20)).approve(address(lockbox), _amount);

    vm.prank(_USER);
    try lockbox.depositTo(_to, _amount) {}
    catch {
      assertWithMsg(
        IERC20(address(xerc20)).balanceOf(_USER) < _amount, // InsufficientBalance()
        'revert not expected'
      );
    }
  }

  function handler_lockbox_withdrawTo(uint256 _amount, address _to) public {
    _amount = clampGt(_amount, 0);

    vm.prank(_USER);
    IERC20(address(crosschainERC20)).approve(address(lockbox), _amount);

    vm.prank(_USER);
    try lockbox.withdrawTo(_to, _amount) {
      if (_to == address(lockbox)) {
        ghost_lockboxSelfTransfer += _amount;
      }
    } catch {
      assertWithMsg(
        IERC20(address(crosschainERC20)).balanceOf(_USER) < _amount // InsufficientBalance()
          || IERC20(address(xerc20)).balanceOf(address(lockbox)) < _amount, // InsufficientBalance()
        'revert not expected'
      );
    }
  }

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                      Adapter HANDLERS                      */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  function handler_adapter_crosschainMint(uint256 _amount) public {
    vm.prank(_BRIDGE);
    try adapter.crosschainMint(_USER, _amount) {}
    catch {
      assertWithMsg(
        xerc20.mintingCurrentLimitOf(address(adapter)) < _amount, // IXERC20_NotHighEnoughLimits()
        'revert not expected'
      );
    }
  }

  function handler_adapter_crosschainBurn(uint256 _amount) public {
    vm.prank(_USER);
    IERC20(address(xerc20)).approve(address(adapter), _amount);

    vm.prank(_BRIDGE);
    try adapter.crosschainBurn(_USER, _amount) {}
    catch {
      assertWithMsg(
        xerc20.burningCurrentLimitOf(address(adapter)) < _amount // IXERC20_NotHighEnoughLimits()
          || IERC20(address(xerc20)).balanceOf(_USER) < _amount, // InsufficientBalance()
        'revert not expected'
      );
    }
  }
}
