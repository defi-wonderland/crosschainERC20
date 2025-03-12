// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// Interfaces
import {IXERC20} from '@xERC20/interfaces/IXERC20.sol';
import {IERC20Solady} from 'interfaces/external/IERC20Solady.sol';
import {IERC7802} from 'interfaces/external/IERC7802.sol';

/// @title ICrosschainERC20
/// @notice This interface is available on the CrosschainERC20 contract.
interface ICrosschainERC20 is IERC20Solady, IXERC20, IERC7802 {
  // External dependencies events
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event EIP712DomainChanged();

  // External dependencies errors
  error InvalidShortString();
  error StringTooLong(string str);

  // XERC20 functions
  function FACTORY() external view returns (address);
  function bridges(address)
    external
    view
    returns (BridgeParameters memory minterParams, BridgeParameters memory burnerParams);
  function lockbox() external view returns (address);
  function mintingCurrentLimitOf(address _bridge) external view returns (uint256 _limit);
  function mintingMaxLimitOf(address _bridge) external view returns (uint256 _limit);

  // Ownable functions
  function owner() external view returns (address);
  function renounceOwnership() external;

  // ERC20Permit functions
  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;
  function nonces(address owner) external view returns (uint256);
  function DOMAIN_SEPARATOR() external view returns (bytes32);

  // Contract functions
  function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}
