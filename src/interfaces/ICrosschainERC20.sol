// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// Interfaces
import {IXERC20} from '@xERC20/interfaces/IXERC20.sol';
import {IERC7802} from 'interfaces/external/IERC7802.sol';

/// @title ICrosschainERC20
/// @notice This interface is available on the CrosschainERC20 contract.
interface ICrosschainERC20 is IXERC20, IERC7802 {
  /// @notice Thrown when trying to mint to the zero address or the token contract itself.
  error CrosschainERC20__InvalidReceiver(address to);
}
