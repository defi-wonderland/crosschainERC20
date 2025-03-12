// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Target contracts

import {IXERC20} from '@xERC20/interfaces/IXERC20.sol';
import {CrosschainERC20} from 'contracts/CrosschainERC20.sol';

import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {IERC165, IERC7802} from 'interfaces/external/IERC7802.sol';
import {ERC20} from 'solady/tokens/ERC20.sol';

// Testing utilities
import {Test} from 'forge-std/Test.sol';

/// @title CrosschainERC20Test
/// @notice Contract for testing the CrosschainERC20 contract.
contract CrosschainERC20Test is Test {
  CrosschainERC20 public crosschainERC20;
  address internal constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
  address internal constant ZERO_ADDRESS = address(0);
  address internal immutable owner = makeAddr('owner');

  /// @notice Sets up the test suite.
  function setUp() public {
    crosschainERC20 = new CrosschainERC20('Test', 'TST', 18, owner);
  }

  /// @notice Tests the `allowance` function when the spender is Permit2.
  function testFuzz_allowance_whenSpentFromPermit2_succeeds(address _user, address _user2, uint256 _amount) public {
    // Ensure the users are neither Permit2 nor the zero address
    vm.assume(_user != PERMIT2 && _user != ZERO_ADDRESS && _user != _user2);
    vm.assume(_user2 != PERMIT2 && _user2 != ZERO_ADDRESS);

    // Bound `amount`
    _amount = bound(_amount, 0, 1e40);

    // Assert that the allowance is the maximum when the owner is Permit2
    assertEq(crosschainERC20.allowance(_user, PERMIT2), type(uint256).max);

    // Mint tokens to the user
    deal(address(crosschainERC20), _user, _amount);

    // Prank Permit2 to transfer the tokens
    vm.prank(PERMIT2);
    crosschainERC20.transferFrom(_user, _user2, _amount);

    // Assert that the tokens were transferred
    assertEq(crosschainERC20.balanceOf(_user), 0);
    assertEq(crosschainERC20.balanceOf(_user2), _amount);
  }

  /// @notice Tests the `burn` function reverts when the allowance is insufficient.
  function testFuzz_burn_withoutApproval_reverts(uint256 _amount, address _tokenBridge, address _tokenOwner) public {
    // Bound `amount` to not surpass the xERC20 limits
    _amount = bound(_amount, 1, 1e40); // If `amount` is 0, the `burn` function will not revert as expected

    // Ensure `_tokenBridge` is not Permit2 or the zero address
    vm.assume(_tokenBridge != PERMIT2 && _tokenBridge != ZERO_ADDRESS);

    // Ensure `_tokenOwner` is not the zero address
    vm.assume(_tokenOwner != ZERO_ADDRESS);

    // Ensure `_tokenOwner` and `_tokenBridge` are not the same address
    vm.assume(_tokenOwner != _tokenBridge);

    // Set the limits for the Token Bridge
    vm.prank(owner);
    crosschainERC20.setLimits(_tokenBridge, _amount, _amount);

    // Expect the `burn` function to revert when the allowance is insufficient
    vm.expectRevert(ERC20.InsufficientAllowance.selector);

    // Burn the tokens without approval
    vm.prank(_tokenBridge);
    crosschainERC20.burn(_tokenOwner, _amount);

    // Assert that the balance of the token owner is 0
    assertEq(crosschainERC20.balanceOf(_tokenOwner), 0);
  }

  /// @notice Tests the `crosschainBurn` function reverts when the allowance is insufficient.
  function testFuzz_crosschainBurn_withoutApproval_reverts(
    uint256 _amount,
    address _tokenBridge,
    address _tokenOwner
  ) public {
    // Bound `amount` to not surpass the xERC20 limits
    _amount = bound(_amount, 1, 1e40); // If `amount` is 0, the `crosschainBurn` function will not revert as expected

    // Ensure `_tokenBridge` is not Permit2 or the zero address
    vm.assume(_tokenBridge != PERMIT2 && _tokenBridge != ZERO_ADDRESS);

    // Ensure `_tokenOwner` is not the zero address
    vm.assume(_tokenOwner != ZERO_ADDRESS);

    // Ensure `_tokenOwner` and `_tokenBridge` are not the same address
    vm.assume(_tokenOwner != _tokenBridge);

    // Set the limits for the Token Bridge
    vm.prank(owner);
    crosschainERC20.setLimits(_tokenBridge, _amount, _amount);

    // Expect the `burn` function to revert when the allowance is insufficient
    vm.expectRevert(ERC20.InsufficientAllowance.selector);

    // Burn the tokens without approval
    vm.prank(_tokenBridge);
    crosschainERC20.crosschainBurn(_tokenOwner, _amount);

    // Assert that the balance of the token owner is 0
    assertEq(crosschainERC20.balanceOf(_tokenOwner), 0);
  }

  /// @notice Tests the `burn` function works by expecting the allowance to be reduced.
  function testFuzz_burn_works(uint256 _amount, address _tokenBridge, address _tokenOwner) public {
    // Bound `amount` to not surpass the xERC20 limits
    _amount = bound(_amount, 1, 1e40);

    // Ensure `_tokenBridge` is not Permit2 or the zero address
    vm.assume(_tokenBridge != PERMIT2 && _tokenBridge != ZERO_ADDRESS);

    // Ensure `_tokenOwner` is not the zero address
    vm.assume(_tokenOwner != ZERO_ADDRESS);

    // Ensure `_tokenBridge` and `_tokenOwner` are not the same address
    vm.assume(_tokenBridge != _tokenOwner);

    // Set the limits for the Token Bridge
    vm.prank(owner);
    crosschainERC20.setLimits(_tokenBridge, _amount, _amount);

    // First mint tokens to the owner
    vm.prank(_tokenBridge);
    crosschainERC20.mint(_tokenOwner, _amount);

    // Record initial balance
    uint256 initialBalance = crosschainERC20.balanceOf(_tokenOwner);
    assertEq(initialBalance, _amount, 'Initial balance should match minted amount');

    // Approve exactly the amount to be burned
    vm.prank(_tokenOwner);
    crosschainERC20.approve(_tokenBridge, _amount);

    // Verify initial allowance
    assertEq(
      crosschainERC20.allowance(_tokenOwner, _tokenBridge), _amount, 'Initial allowance should match approved amount'
    );

    // Burn the tokens
    vm.prank(_tokenBridge);
    crosschainERC20.burn(_tokenOwner, _amount);

    // Assert final state
    assertEq(crosschainERC20.balanceOf(_tokenOwner), 0);
    assertEq(crosschainERC20.allowance(_tokenOwner, _tokenBridge), 0);
  }

  /// @notice Tests the `crosschainMint` succeeds.
  function testFuzz_crosschainMint_succeeds(address _to, uint256 _amount, address _bridge) public {
    // Ensure `_to` is not the zero address
    vm.assume(_to != ZERO_ADDRESS);

    // Ensure `_bridge` is not the zero address
    vm.assume(_bridge != ZERO_ADDRESS);

    // Bound `amount` to not surpass the xERC20 limits
    _amount = bound(_amount, 0, 1e40);

    // Set the limits for the Token Bridge
    vm.prank(owner);
    crosschainERC20.setLimits(_bridge, _amount, 0);

    // Mint the tokens using the ERC7802 interface
    vm.prank(_bridge);
    crosschainERC20.crosschainMint(_to, _amount);

    // Assert that the tokens were minted
    assertEq(crosschainERC20.balanceOf(_to), _amount);
  }

  /// @notice Tests the `crosschainBurn` succeeds.
  function testFuzz_crosschainBurn_succeeds(address _from, uint256 _amount, address _bridge) public {
    // Ensure `_from` is not the zero address
    vm.assume(_from != ZERO_ADDRESS);

    // Ensure `_bridge` is not the zero address
    vm.assume(_bridge != ZERO_ADDRESS && _bridge != PERMIT2);

    // Bound `amount` to not surpass the xERC20 limits
    _amount = bound(_amount, 0, 1e40);

    // Set the limits for the Token Bridge
    vm.prank(owner);
    crosschainERC20.setLimits(_bridge, _amount, _amount);

    // Mint the tokens using the ERC7802 interface
    vm.prank(_bridge);
    crosschainERC20.crosschainMint(_from, _amount);

    // Approve the Token Bridge to spend the tokens
    vm.prank(_from);
    crosschainERC20.approve(_bridge, _amount);

    // Burn the tokens using the ERC7802 interface
    vm.prank(_bridge);
    crosschainERC20.crosschainBurn(_from, _amount);

    // Assert that the tokens were burned
    assertEq(crosschainERC20.balanceOf(_from), 0);
  }

  /// @notice Tests that the `supportsInterface` function returns true for the `IERC7802`, `IERC165`, `IERC20`, and
  /// `IXERC20` interfaces.
  function test_supportInterface_succeeds() public view {
    assertTrue(crosschainERC20.supportsInterface(type(IERC165).interfaceId));
    assertTrue(crosschainERC20.supportsInterface(type(IERC7802).interfaceId));
    assertTrue(crosschainERC20.supportsInterface(type(IERC20).interfaceId));
    assertTrue(crosschainERC20.supportsInterface(type(IXERC20).interfaceId));
  }

  /// @notice Tests that the `supportsInterface` function returns false for any other interface than the
  /// `IERC7802`, `IERC165`, `IERC20`, and `IXERC20` ones.
  function testFuzz_supportInterface_works(bytes4 _interfaceId) public view {
    vm.assume(_interfaceId != type(IERC165).interfaceId);
    vm.assume(_interfaceId != type(IERC7802).interfaceId);
    vm.assume(_interfaceId != type(IERC20).interfaceId);
    vm.assume(_interfaceId != type(IXERC20).interfaceId);
    assertFalse(crosschainERC20.supportsInterface(_interfaceId));
  }
}
