// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Testing utilities
import {IntegrationBase} from './IntegrationBase.sol';

// Contracts
import {XERC20} from '@xERC20/contracts/XERC20.sol';

import {CrosschainERC20} from 'src/contracts/CrosschainERC20.sol';
import {ERC7802Adapter} from 'src/contracts/ERC7802Adapter.sol';

/// @title IntegrationCrosschainERC20_DeployedXERC20Path
/// @notice Contract for testing the CrosschainERC20 deployed XERC20 path.
contract IntegrationCrosschainERC20_DeployedXERC20Path is IntegrationBase {
  /// @notice Test setup.
  function setUp() public override {
    super.setUp();

    // Deploy the XERC20
    XERC20 xerc20 = new XERC20('Token', 'TKN', DECIMALS, bob);

    // Deploy adapter
    _adapter = ERC7802Adapter(_crosschainERC20Factory.deployERC7802Adapter(address(xerc20), erc7802Bridge));

    // Set limits for the bridges
    vm.startPrank(bob);
    xerc20.setLimits(erc7281Bridge, MINT_LIMIT, BURN_LIMIT);
    xerc20.setLimits(address(_adapter), MINT_LIMIT, BURN_LIMIT);
    vm.stopPrank();

    // Set the _crosschainERC20
    _crosschainERC20 = CrosschainERC20(address(xerc20));

    // Deal tokens
    deal(address(xerc20), alice, BURN_LIMIT);
  }
}
