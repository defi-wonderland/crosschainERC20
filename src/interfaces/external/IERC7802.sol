// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {IERC165} from 'forge-std/interfaces/IERC165.sol';

/// @title ERC-7802 Crosschain Fungibility Extension for ERC-20
/// @dev See https://eips.ethereum.org/EIPS/eip-7802
/// @dev Note: the ERC-165 identifier for this interface is 0x3333199400000000000000000000000000000000000000000000000000000000.
interface IERC7802 is IERC165 {
  /// @notice Emitted when tokens are minted by a bridge.
  /// @param to The address of the recipient.
  /// @param amount The amount of tokens minted.
  /// @param bridge The address of the bridge that minted the tokens.
  event CrosschainMint(address indexed to, uint256 amount, address indexed bridge);

  /// @notice Emitted when tokens are burned by a bridge.
  /// @param from The address of the sender.
  /// @param amount The amount of tokens burned.
  /// @param bridge The address of the bridge that burned the tokens.
  event CrosschainBurn(address indexed from, uint256 amount, address indexed bridge);

  /// @notice Mints tokens to the recipient.
  /// @param to The address of the recipient.
  /// @param amount The amount of tokens to mint.
  function crosschainMint(address to, uint256 amount) external;

  /// @notice Burns tokens from the sender.
  /// @param from The address of the sender.
  /// @param amount The amount of tokens to burn.
  function crosschainBurn(address from, uint256 amount) external;
}
