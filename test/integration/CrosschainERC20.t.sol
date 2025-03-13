// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from 'forge-std/Test.sol';

// Contracts
import {XERC20} from '@xERC20/contracts/XERC20.sol';

import {CrosschainERC20} from 'src/contracts/CrosschainERC20.sol';
import {CrosschainERC20Factory} from 'src/contracts/CrosschainERC20Factory.sol';
import {ERC7802Adapter} from 'src/contracts/ERC7802Adapter.sol';

// Interfaces
import {IXERC20Lockbox} from '@xERC20/interfaces/IXERC20Lockbox.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {ICrosschainERC20Factory} from 'interfaces/ICrosschainERC20Factory.sol';
import {IERC7802} from 'interfaces/external/IERC7802.sol';

/// @title CrosschainERC20_e2e_Base
/// @notice Base contract for end-to-end testing of the CrosschainERC20 paths.
/// @dev This contract provides common setup and helper functions for CrosschainERC20 e2e tests.
/// @dev Tests included in this contract should pass in every setup.
abstract contract CrosschainERC20_e2e_Base is Test {
  // Contracts
  CrosschainERC20Factory internal _crosschainERC20Factory;
  CrosschainERC20 internal _crosschainERC20;
  IXERC20Lockbox internal _lockbox;
  ERC7802Adapter internal _adapter;

  // Defaults
  address internal erc7281Bridge = makeAddr('erc7281Bridge');
  address internal erc7802Bridge = makeAddr('erc7802Bridge');
  address internal owner = makeAddr('owner');
  address internal alice = makeAddr('alice');
  address internal bob = makeAddr('bob');

  // Constants
  string internal constant NAME = 'Test';
  string internal constant SYMBOL = 'TST';
  uint8 internal constant DECIMALS = 18;
  uint256 internal constant MINT_LIMIT = 10e25;
  uint256 internal constant BURN_LIMIT = 10e25;
  address internal constant TOKEN_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI

  /// @notice Test setup.
  function setUp() public virtual {
    vm.createSelectFork(vm.envString('MAINNET_RPC'));
    _crosschainERC20Factory = CrosschainERC20Factory(address(new CrosschainERC20Factory()));
  }

  /// @notice Helper function to get the 7281 and 7802 bridges.
  /// @return bridges_ The bridges.
  function _get7281And7802Bridges() internal view returns (address[] memory bridges_) {
    bridges_ = new address[](2);
    bridges_[0] = erc7281Bridge;
    bridges_[1] = erc7802Bridge;
  }

  /// @notice Helper function to get the bridge with limits.
  /// @param _minterLimit The minter limit.
  /// @param _burnerLimit The burner limit.
  /// @return bridges_ The bridges.
  /// @return minterLimits_ The minter limits.
  /// @return burnerLimits_ The burner limits.
  function _getBridgeWithLimits(
    address[] memory bridges,
    uint256 _minterLimit,
    uint256 _burnerLimit
  ) internal view returns (address[] memory bridges_, uint256[] memory minterLimits_, uint256[] memory burnerLimits_) {
    // Create the arrays with length matching input bridges
    uint256 length = bridges.length;
    bridges_ = new address[](length);
    minterLimits_ = new uint256[](length);
    burnerLimits_ = new uint256[](length);

    // Set the values for each bridge
    for (uint256 i = 0; i < length; i++) {
      bridges_[i] = bridges[i];
      minterLimits_[i] = _minterLimit;
      burnerLimits_[i] = _burnerLimit;
    }
  }

  /// @notice Helper function to get the target address for ERC7802 operations
  function _getERC7802Target() internal view returns (address) {
    return address(_adapter) != address(0) ? address(_adapter) : address(_crosschainERC20);
  }

  /// @notice Helper function to determine the correct address to approve for ERC7802 operations
  /// @return The address to approve (either bridge or adapter)
  function _getERC7802ApprovalTarget() internal view returns (address) {
    return address(_adapter) != address(0) ? address(_adapter) : erc7802Bridge;
  }

  /// @notice Helper function to determine the correct contract to call for ERC7802 operations
  /// @return The contract to call (either adapter or token)
  function _getERC7802CallTarget() internal view returns (address) {
    return address(_adapter) != address(0) ? address(_adapter) : address(_crosschainERC20);
  }

  /// @notice Mints using ERC7281 interface.
  function test_mintERC7281_succeeds() public {
    // Get balance before mint
    uint256 balanceBefore = _crosschainERC20.balanceOf(alice);

    // Mint tokens
    vm.prank(erc7281Bridge);
    _crosschainERC20.mint(alice, MINT_LIMIT);

    // Get balance after mint
    uint256 balanceAfter = _crosschainERC20.balanceOf(alice);

    // Check the balance has increased by the minted amount
    assertEq(balanceAfter - balanceBefore, MINT_LIMIT);

    // Check decimals
    assertEq(_crosschainERC20.decimals(), DECIMALS);
  }

  /// @notice Burns using ERC7281 interface.
  function test_burnERC7281_succeeds() public {
    // Approve the bridge to burn
    vm.prank(alice);
    _crosschainERC20.approve(erc7281Bridge, BURN_LIMIT);

    // Burn tokens
    vm.prank(erc7281Bridge);
    _crosschainERC20.burn(alice, BURN_LIMIT);

    // Check the balance has decreased by the burned amount
    uint256 balance = _crosschainERC20.balanceOf(alice);
    assertEq(balance, 0);

    // Check decimals
    assertEq(_crosschainERC20.decimals(), DECIMALS);
  }

  /// @notice Mints using ERC7802 interface.
  function test_mintERC7802_succeeds() public virtual {
    // Get balance before mint
    uint256 balanceBefore = _crosschainERC20.balanceOf(alice);

    // Mint tokens
    vm.prank(erc7802Bridge);
    IERC7802(_getERC7802CallTarget()).crosschainMint(alice, MINT_LIMIT);

    // Get balance after mint
    uint256 balanceAfter = _crosschainERC20.balanceOf(alice);

    // Check the balance has increased by the minted amount
    assertEq(balanceAfter - balanceBefore, MINT_LIMIT);

    // Check decimals
    assertEq(_crosschainERC20.decimals(), DECIMALS);
  }

  /// @notice Burns using ERC7802 interface.
  function test_burnERC7802_succeeds() public virtual {
    // Approve the bridge to burn
    vm.prank(alice);
    _crosschainERC20.approve(_getERC7802ApprovalTarget(), BURN_LIMIT);

    // Burn tokens
    vm.prank(erc7802Bridge);
    IERC7802(_getERC7802CallTarget()).crosschainBurn(alice, BURN_LIMIT);

    // Check the balance has decreased by the burned amount
    uint256 balance = _crosschainERC20.balanceOf(alice);
    assertEq(balance, 0);

    // Check decimals
    assertEq(_crosschainERC20.decimals(), DECIMALS);
  }
}

/// @title IntegrationCrosschainERC20_NonDeployedTokenPath
/// @notice Contract for testing the CrosschainERC20 non-deployed token path.
contract IntegrationCrosschainERC20_NonDeployedTokenPath is CrosschainERC20_e2e_Base {
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

/// @title IntegrationCrosschainERC20_DeployedTokenPath
/// @notice Contract for testing the CrosschainERC20 deployed token path.
contract IntegrationCrosschainERC20_DeployedTokenPath is CrosschainERC20_e2e_Base {
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

/// @title IntegrationCrosschainERC20_DeployedXERC20Path
/// @notice Contract for testing the CrosschainERC20 deployed XERC20 path.
contract IntegrationCrosschainERC20_DeployedXERC20Path is CrosschainERC20_e2e_Base {
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
