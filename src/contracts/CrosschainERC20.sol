// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Contracts
import {XERC20} from '@xERC20/contracts/XERC20.sol';

// Interfaces

import {IXERC20} from '@xERC20/interfaces/IXERC20.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {IERC165, IERC7802} from 'interfaces/external/IERC7802.sol';

/// @title CrosschainERC20
/// @notice A standard ERC20 extension implementing IERC7281 and IERC7802 for
///         unified cross-chain fungibility across any bridge.
contract CrosschainERC20 is XERC20, IERC7802 {
  /// @notice Constructs the CrosschainERC20 contract.
  /// @param _name    Name of the token.
  /// @param _symbol  Symbol of the token.
  /// @param _decimals Decimals of the token.
  /// @param _factory Address of the factory contract.
  constructor(
    string memory _name,
    string memory _symbol,
    uint8 _decimals,
    address _factory
  ) XERC20(_name, _symbol, _decimals, _factory) {}

  /// @notice Allows a bridge to mint tokens.
  /// @param _to     Address to mint tokens to.
  /// @param _amount Amount of tokens to mint.
  function crosschainMint(address _to, uint256 _amount) external {
    _mintWithCaller(msg.sender, _to, _amount);

    emit CrosschainMint(_to, _amount, msg.sender);
  }

  /// @notice Allows a bridge to burn tokens.
  /// @param _from   Address to burn tokens from.
  /// @param _amount Amount of tokens to burn.
  function crosschainBurn(address _from, uint256 _amount) external {
    _burnWithCaller(msg.sender, _from, _amount);

    emit CrosschainBurn(_from, _amount, msg.sender);
  }

  /// @inheritdoc IERC165
  function supportsInterface(bytes4 _interfaceId) public view virtual returns (bool) {
    return _interfaceId == type(IERC7802).interfaceId || _interfaceId == type(IERC20).interfaceId
      || _interfaceId == type(IERC165).interfaceId || _interfaceId == type(IXERC20).interfaceId;
  }
}
