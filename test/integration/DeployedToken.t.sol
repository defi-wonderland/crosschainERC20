// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Testing utilities
import {IntegrationBase} from './IntegrationBase.sol';

// Interfaces
import {IERC20} from 'forge-std/interfaces/IERC20.sol';

/// @title IntegrationCrosschainERC20_DeployedTokenPath
/// @notice Contract for testing the CrosschainERC20 deployed token path.
contract IntegrationCrosschainERC20_DeployedTokenPath is IntegrationBase {
  /// @notice Test setup.
  function setUp() public override {
    super.setUp();

    // Get the ERC20
    IERC20 erc20 = IERC20(_TOKEN_ADDRESS);

    (_crosschainERC20, _lockbox) = _crosschainERC20WithLockboxDeployer.run();

    // Deal base tokens
    deal(address(erc20), _alice, _BURN_LIMIT);

    // Wrap the ERC20
    vm.startPrank(_alice);
    erc20.approve(address(_lockbox), _BURN_LIMIT);
    _lockbox.deposit(_BURN_LIMIT);
    vm.stopPrank();
  }
}
