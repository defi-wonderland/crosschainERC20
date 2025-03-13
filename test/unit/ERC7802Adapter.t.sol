// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Testing utilities
import {Test} from 'forge-std/Test.sol';

// Interfaces
import {IXERC20} from '@xERC20/interfaces/IXERC20.sol';

import {IERC7802Adapter} from 'interfaces/IERC7802Adapter.sol';
import {IERC165, IERC7802} from 'interfaces/external/IERC7802.sol';

// Target contract
import {ERC7802Adapter} from 'src/contracts/ERC7802Adapter.sol';

/// @title UnitERC7802Adapter
/// @notice Contract for testing the ERC7802Adapter contract.
contract UnitERC7802Adapter is Test {
  address internal _bridge = makeAddr('bridge');
  address internal _xerc20 = makeAddr('XERC20');

  ERC7802Adapter internal _adapter;

  /// @notice Sets up the test suite.
  function setUp() public {
    _adapter = new ERC7802Adapter(IXERC20(_xerc20), _bridge);
  }

  /// @notice Helper function to setup a mock and expect a call to it.
  function _mockAndExpect(address _receiver, bytes memory _calldata, bytes memory _returned) internal {
    vm.mockCall(_receiver, _calldata, _returned);
    vm.expectCall(_receiver, _calldata);
  }

  /// @notice Tests the `constructor` sets the `XERC20` contract.
  function test_ConstructorSetsXERC20() public view {
    // Ensure the `XERC20` contract is set
    assertEq(address(_adapter.XERC20()), _xerc20);
  }

  /// @notice Tests the `constructor` sets the `BRIDGE` address.
  function test_ConstructorSetsBridge() public view {
    // Ensure the `BRIDGE` address is set
    assertEq(address(_adapter.BRIDGE()), _bridge);
  }

  /// @notice Tests the `crosschainMint` reverts when the caller is not the bridge.
  function test_CrosschainMintRevertWhenCallerNotBridge(address _caller) public {
    // Ensure the caller is not the bridge
    vm.assume(_caller != _bridge);

    // Expect the `crosschainMint` function to revert
    vm.expectRevert(IERC7802Adapter.Unauthorized.selector);
    vm.prank(_caller);
    _adapter.crosschainMint(address(0), 100);
  }

  /// @notice Tests the `crosschainMint` succeeds and emits the `CrosschainMint` event.
  function test_CrosschainMintSucceedsAndEmitsEvent(address _to, uint256 _amount) public {
    // Look for the emit of the `CrosschainMint` event
    vm.expectEmit(address(_adapter));
    emit IERC7802.CrosschainMint(_to, _amount, _bridge);

    // Ensure the adapter successfully calls the `mint` function of the `XERC20` contract
    _mockAndExpect(_xerc20, abi.encodeCall(IXERC20.mint, (_to, _amount)), '');

    // Call the `mint` function with the bridge caller
    vm.prank(_bridge);
    _adapter.crosschainMint(_to, _amount);
  }

  /// @notice Tests the `crosschainBurn` reverts when the caller is not the bridge.
  function test_CrosschainBurnRevertWhenCallerNotBridge(address _caller) public {
    // Ensure the caller is not the bridge
    vm.assume(_caller != _bridge);

    // Expect the `crosschainBurn` function to revert
    vm.expectRevert(IERC7802Adapter.Unauthorized.selector);
    vm.prank(_caller);
    _adapter.crosschainBurn(address(0), 100);
  }

  /// @notice Tests the `crosschainBurn` succeeds and emits the `CrosschainBurn` event.
  function test_CrosschainBurnSucceedsAndEmitsEvent(address _from, uint256 _amount) public {
    // Look for the emit of the `CrosschainBurn` event
    vm.expectEmit(address(_adapter));
    emit IERC7802.CrosschainBurn(_from, _amount, _bridge);

    // Ensure the adapter successfully calls the `burn` function of the `XERC20` contract
    _mockAndExpect(_xerc20, abi.encodeCall(IXERC20.burn, (_from, _amount)), '');

    // Call the `burn` function with the bridge caller
    vm.prank(_bridge);
    _adapter.crosschainBurn(_from, _amount);
  }

  /// @notice Tests that the `supportsInterface` function returns true for the `IERC7802` interface.
  function test_SupportsInterfaceWhenSupported() public view {
    assertTrue(_adapter.supportsInterface(type(IERC165).interfaceId));
    assertTrue(_adapter.supportsInterface(type(IERC7802).interfaceId));
  }

  /// @notice Tests that the `supportsInterface` function returns false for any other interface.
  function test_SupportsInterfaceWhenUnsupported(bytes4 _interfaceId) public view {
    // Ensure the interface is not the `IERC165` or `IERC7802` interface
    vm.assume(_interfaceId != type(IERC165).interfaceId && _interfaceId != type(IERC7802).interfaceId);

    // Ensure the `supportsInterface` function returns false for the given interface
    assertFalse(_adapter.supportsInterface(_interfaceId));
  }
}
