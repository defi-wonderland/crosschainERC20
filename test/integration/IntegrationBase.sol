// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Testing utilities
import {Test} from 'forge-std/Test.sol';

// Contracts
import {CrosschainERC20} from 'src/contracts/CrosschainERC20.sol';
import {CrosschainERC20Factory} from 'src/contracts/CrosschainERC20Factory.sol';
import {ERC7802Adapter} from 'src/contracts/ERC7802Adapter.sol';

// Interfaces
import {IXERC20Lockbox} from '@xERC20/interfaces/IXERC20Lockbox.sol';
import {IERC7802} from 'interfaces/external/IERC7802.sol';

// Script
import {DeployCrosschainERC20} from 'script/CrosschainERC20Deploy.s.sol';
import {DeployCrosschainERC20Factory} from 'script/CrosschainERC20FactoryDeploy.s.sol';
import {DeployCrosschainERC20WithLockbox} from 'script/CrosschainERC20WithLockboxDeploy.s.sol';
import {DeployERC7802Adapter} from 'script/ERC7802Deploy.s.sol';

/// @title IntegrationBase
/// @notice Base contract for integration testing of the CrosschainERC20 paths.
/// @dev This contract provides common setup and helper functions for CrosschainERC20 integration tests.
/// @dev Tests included in this contract should pass in every setup.
abstract contract IntegrationBase is Test, DeployCrosschainERC20Factory {
  // Deployers
  DeployCrosschainERC20Factory internal _factoryDeployer;
  DeployCrosschainERC20 internal _crosschainERC20Deployer;
  DeployCrosschainERC20WithLockbox internal _crosschainERC20WithLockboxDeployer;
  DeployERC7802Adapter internal _adapterDeployer;

  // Contracts
  CrosschainERC20Factory internal _crosschainERC20Factory;
  CrosschainERC20 internal _crosschainERC20;
  IXERC20Lockbox internal _lockbox;
  ERC7802Adapter internal _adapter;

  // Defaults
  address internal _erc7281Bridge = makeAddr('erc7281Bridge');
  address internal _erc7802Bridge = makeAddr('erc7802Bridge');
  address internal _owner = makeAddr('owner');
  address internal _alice = makeAddr('alice');
  address internal _bob = makeAddr('bob');

  // Constants
  string internal constant _NAME = 'Test';
  string internal constant _SYMBOL = 'TST';
  uint8 internal constant _DECIMALS = 18;
  uint256 internal constant _MINT_LIMIT = 10e25;
  uint256 internal constant _BURN_LIMIT = 10e25;
  address internal constant _TOKEN_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI

  /// @notice Test setup.
  function setUp() public virtual {
    vm.createSelectFork(vm.envString('MAINNET_RPC'));

    // Create deployers
    _factoryDeployer = new DeployCrosschainERC20Factory();
    _crosschainERC20Deployer = new DeployCrosschainERC20();
    _crosschainERC20WithLockboxDeployer = new DeployCrosschainERC20WithLockbox();
    _adapterDeployer = new DeployERC7802Adapter();

    // Deploy factory
    _crosschainERC20Factory = _factoryDeployer.run();

    // Setup deployers
    _crosschainERC20Deployer.setUp();
    _adapterDeployer.setUp();
    _crosschainERC20WithLockboxDeployer.setUp();
  }

  /// @notice Helper function to determine the correct address to approve for ERC7802 operations
  /// @return The address to approve (either bridge or adapter)
  function _getERC7802ApprovalTarget() internal view returns (address) {
    return address(_adapter) != address(0) ? address(_adapter) : _erc7802Bridge;
  }

  /// @notice Helper function to determine the correct contract to call for ERC7802 operations
  /// @return The contract to call (either adapter or token)
  function _getERC7802CallTarget() internal view returns (address) {
    return address(_adapter) != address(0) ? address(_adapter) : address(_crosschainERC20);
  }

  /// @notice Mints using ERC7281 interface.
  function test_MintERC7281() public {
    // Get balance before mint
    uint256 balanceBefore = _crosschainERC20.balanceOf(_alice);

    // Mint tokens
    vm.prank(_erc7281Bridge);
    _crosschainERC20.mint(_alice, _MINT_LIMIT);

    // Get balance after mint
    uint256 balanceAfter = _crosschainERC20.balanceOf(_alice);

    // Check the balance has increased by the minted amount
    assertEq(balanceAfter - balanceBefore, _MINT_LIMIT);

    // Check decimals
    assertEq(_crosschainERC20.decimals(), _DECIMALS);
  }

  /// @notice Burns using ERC7281 interface.
  function test_BurnERC7281() public {
    // Approve the bridge to burn
    vm.prank(_alice);
    _crosschainERC20.approve(_erc7281Bridge, _BURN_LIMIT);

    // Burn tokens
    vm.prank(_erc7281Bridge);
    _crosschainERC20.burn(_alice, _BURN_LIMIT);

    // Check the balance has decreased by the burned amount
    uint256 balance = _crosschainERC20.balanceOf(_alice);
    assertEq(balance, 0);

    // Check decimals
    assertEq(_crosschainERC20.decimals(), _DECIMALS);
  }

  /// @notice Mints using ERC7802 interface.
  function test_MintERC7802() public virtual {
    // Get balance before mint
    uint256 balanceBefore = _crosschainERC20.balanceOf(_alice);

    // Mint tokens
    vm.prank(_erc7802Bridge);
    IERC7802(_getERC7802CallTarget()).crosschainMint(_alice, _MINT_LIMIT);

    // Get balance after mint
    uint256 balanceAfter = _crosschainERC20.balanceOf(_alice);

    // Check the balance has increased by the minted amount
    assertEq(balanceAfter - balanceBefore, _MINT_LIMIT);

    // Check decimals
    assertEq(_crosschainERC20.decimals(), _DECIMALS);
  }

  /// @notice Burns using ERC7802 interface.
  function test_BurnERC7802() public virtual {
    // Approve the bridge to burn
    vm.prank(_alice);
    _crosschainERC20.approve(_getERC7802ApprovalTarget(), _BURN_LIMIT);

    // Burn tokens
    vm.prank(_erc7802Bridge);
    IERC7802(_getERC7802CallTarget()).crosschainBurn(_alice, _BURN_LIMIT);

    // Check the balance has decreased by the burned amount
    uint256 balance = _crosschainERC20.balanceOf(_alice);
    assertEq(balance, 0);

    // Check decimals
    assertEq(_crosschainERC20.decimals(), _DECIMALS);
  }
}
