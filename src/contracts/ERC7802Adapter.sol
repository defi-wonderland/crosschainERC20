// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Interfaces

import {IXERC20} from '@xERC20/interfaces/IXERC20.sol';
import {IERC7802Adapter} from 'interfaces/IERC7802Adapter.sol';
import {IERC165, IERC7802} from 'interfaces/external/IERC7802.sol';

/// @title ERC7802Adapter
/// @notice Adapter for minting/burning xERC20 tokens using a bridge by implementing
/// the ERC7802 interface.
contract ERC7802Adapter is IERC7802Adapter {
  /// @inheritdoc IERC7802Adapter
  IXERC20 public immutable XERC20;

  /// @inheritdoc IERC7802Adapter
  address public immutable BRIDGE;

  /**
   * @notice Constructs the ERC7802Adapter.
   * @param _xerc20 The xERC20 contract to adapt.
   * @param _bridge The bridge address.
   */
  constructor(IXERC20 _xerc20, address _bridge) {
    XERC20 = _xerc20;
    BRIDGE = _bridge;
  }

  /// @inheritdoc IERC7802
  function crosschainMint(address _to, uint256 _amount) external {
    if (msg.sender != BRIDGE) revert Unauthorized();

    XERC20.mint(_to, _amount);

    emit CrosschainMint(_to, _amount, msg.sender);
  }

  /// @inheritdoc IERC7802
  function crosschainBurn(address _from, uint256 _amount) external {
    if (msg.sender != BRIDGE) revert Unauthorized();

    XERC20.burn(_from, _amount);

    emit CrosschainBurn(_from, _amount, msg.sender);
  }

  /// @inheritdoc IERC165
  function supportsInterface(bytes4 _interfaceId) public view virtual returns (bool) {
    return _interfaceId == type(IERC7802).interfaceId || _interfaceId == type(IERC165).interfaceId;
  }
}
