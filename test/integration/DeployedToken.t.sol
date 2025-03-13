// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Testing utilities
import {IntegrationBase} from './IntegrationBase.sol';

// Interfaces

import {IXERC20Lockbox} from '@xERC20/interfaces/IXERC20Lockbox.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';

// Contracts
import {CrosschainERC20} from 'src/contracts/CrosschainERC20.sol';

/// @title IntegrationCrosschainERC20_DeployedTokenPath
/// @notice Contract for testing the CrosschainERC20 deployed token path.
contract IntegrationCrosschainERC20_DeployedTokenPath is IntegrationBase {
  /// @notice Test setup.
  function setUp() public override {
    super.setUp();

    // Get the ERC20
    IERC20 erc20 = IERC20(TOKEN_ADDRESS);

    // Get the bridges and limits
    (address[] memory _bridges, uint256[] memory _minterLimits, uint256[] memory _burnerLimits) =
      _getBridgeWithLimits(_get7281And7802Bridges(), MINT_LIMIT, BURN_LIMIT);

    // Deploy the _crosschainERC20 with lockbox
    (address _crosschainERC20Address, address _lockboxAddress) = _crosschainERC20Factory
      .deployCrosschainERC20WithLockbox(
      NAME, SYMBOL, DECIMALS, _minterLimits, _burnerLimits, _bridges, address(erc20), owner
    );
    _crosschainERC20 = CrosschainERC20(_crosschainERC20Address);
    _lockbox = IXERC20Lockbox(_lockboxAddress);

    // Deal base tokens
    deal(address(erc20), alice, BURN_LIMIT);

    // Wrap the ERC20
    vm.startPrank(alice);
    erc20.approve(address(_lockbox), BURN_LIMIT);
    _lockbox.deposit(BURN_LIMIT);
    vm.stopPrank();
  }
}
