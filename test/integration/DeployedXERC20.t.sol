// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Testing utilities
import {IntegrationBase} from './IntegrationBase.sol';

// Contracts
import {XERC20} from '@xERC20/contracts/XERC20.sol';
import {CrosschainERC20} from 'src/contracts/CrosschainERC20.sol';

// Utils
import {CREATE3} from 'solady/utils/CREATE3.sol';

/// @title IntegrationCrosschainERC20_DeployedXERC20Path
/// @notice Contract for testing the CrosschainERC20 deployed XERC20 path.
contract IntegrationCrosschainERC20_DeployedXERC20Path is IntegrationBase {
  /// @notice Test setup.
  function setUp() public override {
    super.setUp();

    // Deploy the XERC20
    bytes32 salt = keccak256(abi.encodePacked('Token', 'TKN', _DECIMALS, _bob));
    bytes memory creation = type(XERC20).creationCode;
    bytes memory bytecode = abi.encodePacked(creation, abi.encode('Token', 'TKN', _DECIMALS, _bob));
    XERC20 xerc20 = XERC20(CREATE3.deployDeterministic(bytecode, salt));

    // Deploy adapter
    _adapter = _adapterDeployer.run();

    // Set limits for the bridges
    vm.startPrank(_bob);
    xerc20.setLimits(_erc7281Bridge, _MINT_LIMIT, _BURN_LIMIT);
    xerc20.setLimits(address(_adapter), _MINT_LIMIT, _BURN_LIMIT);
    vm.stopPrank();

    // Set the _crosschainERC20
    _crosschainERC20 = CrosschainERC20(address(xerc20));

    // Deal tokens
    deal(address(xerc20), _alice, _BURN_LIMIT);
  }
}
