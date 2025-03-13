// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Testing utilities
import {IntegrationBase} from './IntegrationBase.sol';

// Contracts
import {CrosschainERC20} from 'src/contracts/CrosschainERC20.sol';

/// @title IntegrationCrosschainERC20_NonDeployedTokenPath
/// @notice Contract for testing the CrosschainERC20 non-deployed token path.
contract IntegrationCrosschainERC20_NonDeployedTokenPath is IntegrationBase {
  /// @notice Test setup.
  function setUp() public override {
    super.setUp();

    // Get the bridges and limits
    (address[] memory _bridges, uint256[] memory _minterLimits, uint256[] memory _burnerLimits) =
      _getBridgeWithLimits(_get7281And7802Bridges(), MINT_LIMIT, BURN_LIMIT);

    // Deploy the _crosschainERC20
    _crosschainERC20 = CrosschainERC20(
      _crosschainERC20Factory.deployCrosschainERC20(
        NAME, SYMBOL, DECIMALS, _minterLimits, _burnerLimits, _bridges, owner
      )
    );

    // Deal tokens to alice
    deal(address(_crosschainERC20), alice, BURN_LIMIT);
  }
}
