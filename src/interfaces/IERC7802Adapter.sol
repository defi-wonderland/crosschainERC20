// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// Interfaces
import {IXERC20} from '@xERC20/interfaces/IXERC20.sol';
import {IERC7802} from 'interfaces/external/IERC7802.sol';

/// @title IERC7802Adapter
/// @notice This interface is available on the ERC7802Adapter contract.
interface IERC7802Adapter is IERC7802 {
  /// @notice Thrown when the caller is not the bridge.
  error Unauthorized();
  /**
   * @notice Returns the xERC20 contract.
   * @return _xerc20 The xERC20 contract.
   */

  function XERC20() external view returns (IXERC20 _xerc20);

  /**
   * @notice Returns the bridge address.
   * @return _bridge The bridge address.
   */
  function BRIDGE() external view returns (address _bridge);
}
