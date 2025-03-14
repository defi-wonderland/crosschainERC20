// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Testing utilities
import {IntegrationBase} from './IntegrationBase.sol';

/// @title IntegrationCrosschainERC20_NonDeployedTokenPath
/// @notice Contract for testing the CrosschainERC20 non-deployed token path.
contract IntegrationCrosschainERC20_NonDeployedTokenPath is IntegrationBase {
  /// @notice Test setup.
  function setUp() public override {
    super.setUp();

    // Deploy the _crosschainERC20
    _crosschainERC20 = _crosschainERC20Deployer.run();

    // Deal tokens to _alice
    deal(address(_crosschainERC20), _alice, _BURN_LIMIT);
  }
}
