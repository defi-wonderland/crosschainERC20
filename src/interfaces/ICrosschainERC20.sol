// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// Interfaces
import {IXERC20} from '@xERC20/interfaces/IXERC20.sol';
import {IERC7802} from 'interfaces/external/IERC7802.sol';

/// @title ICrosschainERC20
/// @notice This interface is available on the CrosschainERC20 contract.
interface ICrosschainERC20 is IXERC20, IERC7802 {
  /// @notice Allows a bridge to mint tokens.
  /// @param _to     Address to mint tokens to.
  /// @param _amount Amount of tokens to mint.
  function crosschainMint(address _to, uint256 _amount) external;

  /// @notice Allows a bridge to burn tokens.
  /// @param _from   Address to burn tokens from.
  /// @param _amount Amount of tokens to burn.
  function crosschainBurn(address _from, uint256 _amount) external;
}
