// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/// @title IERC20Solady
/// @notice Interface for the ERC20 standard as defined in the EIP.
/// @dev This interface is a subset of the Solady ERC20 implementation.
interface IERC20Solady {
  // Events
  event Transfer(address indexed from, address indexed to, uint256 amount);
  event Approval(address indexed owner, address indexed spender, uint256 amount);

  // Errors
  error PermitDeadlineExpired();
  error InvalidSigner();
  error InsufficientAllowance();
  error InsufficientBalance();

  // Functions - View functions first
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
  function totalSupply() external view returns (uint256 result);
  function balanceOf(address account) external view returns (uint256 result);
  function allowance(address owner, address spender) external view returns (uint256 result);

  // Functions - Non-view functions next
  function transfer(address to, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
