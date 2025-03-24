// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Setup} from './Setup.sol';
import {vm} from './VM.sol';
import {IXERC20} from '@xERC20/interfaces/IXERC20.sol';
import {console} from 'forge-std/console.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {ICrosschainERC20} from 'src/interfaces/ICrosschainERC20.sol';

contract Handler is Setup {
  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                 CrosschainERC20 HANDLERS                   */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  function handler_crosschainERC20_crosschainMint(uint256 _amount) public {
    vm.prank(_BRIDGE);
    try crosschainERC20.crosschainMint(_USER, _amount) {
      ghost_nonLockboxSupply += _amount;
    } catch {
      assertWithMsg(
        IERC20(address(crosschainERC20)).allowance(_USER, _BRIDGE) < _amount // InsufficientAllowance()
          || IXERC20(address(crosschainERC20)).mintingCurrentLimitOf(_BRIDGE) < _amount, // IXERC20_NotHighEnoughLimits()
        'revert not expected'
      );
    }
  }

  function handler_crosschainERC20_crosschainBurn(uint256 _amount) public {
    vm.prank(_USER);
    IERC20(address(crosschainERC20)).approve(_BRIDGE, _amount);

    vm.prank(_BRIDGE);
    try crosschainERC20.crosschainBurn(_USER, _amount) {
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
    vm.prank(_BRIDGE);
    try crosschainERC20.mint(_USER, _amount) {
      ghost_nonLockboxSupply += _amount;
    } catch {
      assertWithMsg(
        IERC20(address(crosschainERC20)).allowance(_USER, _BRIDGE) < _amount // InsufficientAllowance()
          || IXERC20(address(crosschainERC20)).mintingMaxLimitOf(_BRIDGE) < _amount, // IXERC20_NotHighEnoughLimits()
        'revert not expected'
      );
    }
  }

  function handler_crosschainERC20_burn(uint256 _amount) public {
    vm.prank(_USER);
    IERC20(address(crosschainERC20)).approve(_BRIDGE, _amount);

    vm.prank(_BRIDGE);
    try crosschainERC20.burn(_USER, _amount) {
      ghost_nonLockboxSupply -= _amount;
    } catch {
      assertWithMsg(
        IXERC20(address(crosschainERC20)).burningCurrentLimitOf(_BRIDGE) < _amount // IXERC20_NotHighEnoughLimits()
          || IERC20(address(crosschainERC20)).balanceOf(_USER) < _amount, // InsufficientBalance()
        'revert not expected'
      );
    }
  }

  function handler_crosschainERC20_crosschainMint(address _caller, uint256 _amount) public {
    require(_caller != _BRIDGE && _caller != address(lockbox) && _caller != address(0), 'invalid caller');

    _amount = clampGt(_amount, 0);

    vm.prank(_caller);
    try crosschainERC20.crosschainMint(_USER, _amount) {
      assert(false);
    } catch {
      assertWithMsg(
        IERC20(address(crosschainERC20)).allowance(_USER, _caller) < _amount // InsufficientAllowance()
          || IXERC20(address(crosschainERC20)).mintingMaxLimitOf(_caller) < _amount, // IXERC20_NotHighEnoughLimits()
        'revert not expected'
      );
    }
  }

  function handler_crosschainERC20_crosschainBurn(address _caller, uint256 _amount) public {
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

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                      LOCKBOX HANDLERS                      */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  function handler_lockbox_deposit(uint256 _amount) public {
    _amount = clampGt(_amount, 0);

    vm.prank(_USER);
    IERC20(address(xerc20)).approve(address(lockbox), _amount);

    vm.prank(_USER);
    try lockbox.deposit(_amount) {
      assert(false);
    } catch {
      assertWithMsg(
        IERC20(address(xerc20)).balanceOf(_USER) < _amount, // InsufficientBalance()
        'revert not expected'
      );
    }
  }

  function handler_lockbox_withdraw(uint256 _amount) public {
    _amount = clampGt(_amount, 0);

    vm.prank(_USER);
    IERC20(address(crosschainERC20)).approve(address(lockbox), _amount);

    vm.prank(_USER);
    try lockbox.withdraw(_amount) {}
    catch {
      assertWithMsg(
        IERC20(address(crosschainERC20)).balanceOf(_USER) < _amount // InsufficientBalance()
          || IERC20(address(xerc20)).balanceOf(address(lockbox)) < _amount, // InsufficientBalance()
        'revert not expected'
      );
    }
  }
}
