// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from 'forge-std/Test.sol';

// Contracts
import {XERC20} from '@xERC20/contracts/XERC20.sol';
import {CrosschainERC20Factory} from 'src/contracts/CrosschainERC20Factory.sol';

// Interfaces

import {IXERC20Lockbox} from '@xERC20/interfaces/IXERC20Lockbox.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {ICrosschainERC20} from 'interfaces/ICrosschainERC20.sol';
import {ICrosschainERC20Factory} from 'interfaces/ICrosschainERC20Factory.sol';
import {IERC7802Adapter} from 'interfaces/IERC7802Adapter.sol';

/// @title CrosschainERC20_e2e_Base
/// @notice Base contract for end-to-end testing of the CrosschainERC20 paths.
/// @dev This contract provides common setup and helper functions for CrosschainERC20 e2e tests.
/// @dev Tests included in this contract should pass in every setup.
abstract contract CrosschainERC20_e2e_Base is Test {
  // Contracts
  ICrosschainERC20Factory public crosschainERC20Factory;
  ICrosschainERC20 public crosschainERC20;
  IXERC20Lockbox public lockbox;
  IERC7802Adapter public ERC7802Adapter;

  // Defaults
  address public erc7281Bridge = makeAddr('erc7281Bridge');
  address public erc7802Bridge = makeAddr('erc7802Bridge');
  address public owner = makeAddr('owner');
  address public alice = makeAddr('alice');
  address public bob = makeAddr('bob');

  // Constants
  string public constant NAME = 'Test';
  string public constant SYMBOL = 'TST';
  uint8 public constant DECIMALS = 18;
  uint256 public constant MINT_LIMIT = 10e25;
  uint256 public constant BURN_LIMIT = 10e25;
  address public constant TOKEN_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI

  /// @notice Test setup.
  function setUp() public virtual {
    vm.createSelectFork(vm.envString('MAINNET_RPC_URL'));
    crosschainERC20Factory = ICrosschainERC20Factory(address(new CrosschainERC20Factory()));
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
    return address(ERC7802Adapter) != address(0) ? address(ERC7802Adapter) : address(crosschainERC20);
  }

  /// @notice Mints using ERC7281 interface.
  function test_mintERC7281_succeeds() public {
    // Get balance before mint
    uint256 balanceBefore = crosschainERC20.balanceOf(alice);

    // Mint tokens
    vm.prank(erc7281Bridge);
    crosschainERC20.mint(alice, MINT_LIMIT);

    // Get balance after mint
    uint256 balanceAfter = crosschainERC20.balanceOf(alice);

    // Check the balance has increased by the minted amount
    assertEq(balanceAfter - balanceBefore, MINT_LIMIT);

    // Check decimals
    assertEq(crosschainERC20.decimals(), DECIMALS);
  }

  /// @notice Burns using ERC7281 interface.
  function test_burnERC7281_succeeds() public {
    // Approve the bridge to burn
    vm.prank(alice);
    crosschainERC20.approve(erc7281Bridge, BURN_LIMIT);

    // Burn tokens
    vm.prank(erc7281Bridge);
    crosschainERC20.burn(alice, BURN_LIMIT);

    // Check the balance has decreased by the burned amount
    uint256 balance = crosschainERC20.balanceOf(alice);
    assertEq(balance, 0);

    // Check decimals
    assertEq(crosschainERC20.decimals(), DECIMALS);
  }

  /// @notice Mints using ERC7802 interface.
  function test_mintERC7802_succeeds() public virtual {
    // Get balance before mint
    uint256 balanceBefore = crosschainERC20.balanceOf(alice);

    // Mint tokens
    vm.prank(erc7802Bridge);
    crosschainERC20.crosschainMint(alice, MINT_LIMIT);

    // Get balance after mint
    uint256 balanceAfter = crosschainERC20.balanceOf(alice);

    // Check the balance has increased by the minted amount
    assertEq(balanceAfter - balanceBefore, MINT_LIMIT);

    // Check decimals
    assertEq(crosschainERC20.decimals(), DECIMALS);
  }

  /// @notice Burns using ERC7802 interface.
  function test_burnERC7802_succeeds() public virtual {
    // Approve the bridge to burn
    vm.prank(alice);
    crosschainERC20.approve(erc7802Bridge, BURN_LIMIT);

    // Burn tokens
    vm.prank(erc7802Bridge);
    crosschainERC20.crosschainBurn(alice, BURN_LIMIT);

    // Check the balance has decreased by the burned amount
    uint256 balance = crosschainERC20.balanceOf(alice);
    assertEq(balance, 0);

    // Check decimals
    assertEq(crosschainERC20.decimals(), DECIMALS);
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

    // Deploy the crosschainERC20
    crosschainERC20 = ICrosschainERC20(
      crosschainERC20Factory.deployCrosschainERC20(
        NAME, SYMBOL, DECIMALS, _minterLimits, _burnerLimits, _bridges, owner
      )
    );

    // Deal tokens to alice
    deal(address(crosschainERC20), alice, BURN_LIMIT);
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

    // Deploy the crosschainERC20 with lockbox
    (address _crosschainERC20, address _lockbox) = crosschainERC20Factory.deployCrosschainERC20WithLockbox(
      NAME, SYMBOL, DECIMALS, _minterLimits, _burnerLimits, _bridges, address(erc20), owner
    );
    crosschainERC20 = ICrosschainERC20(_crosschainERC20);
    lockbox = IXERC20Lockbox(_lockbox);

    // Deal base tokens
    deal(address(erc20), alice, BURN_LIMIT);

    // Wrap the ERC20
    vm.startPrank(alice);
    erc20.approve(address(lockbox), BURN_LIMIT);
    lockbox.deposit(BURN_LIMIT);
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
    ERC7802Adapter = IERC7802Adapter(crosschainERC20Factory.deployERC7802Adapter(address(xerc20), erc7802Bridge));

    // Set limits for the bridges
    vm.startPrank(bob);
    xerc20.setLimits(erc7281Bridge, MINT_LIMIT, BURN_LIMIT);
    xerc20.setLimits(address(ERC7802Adapter), MINT_LIMIT, BURN_LIMIT);
    vm.stopPrank();

    // Set the crosschainERC20
    crosschainERC20 = ICrosschainERC20(address(xerc20));

    // Deal tokens
    deal(address(xerc20), alice, BURN_LIMIT);
  }
}
