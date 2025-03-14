// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/// @title ICrosschainERC20Factory
/// @notice This interface is available on the CrosschainERC20Factory contract.
interface ICrosschainERC20Factory {
  /// @notice Thrown when minter limits, burner limits, or bridges arrays have mismatched lengths.
  error InvalidLength();

  /**
   * @notice Deploys a new CrosschainERC20 contract and returns the address
   * @param _name The name of the token
   * @param _symbol The symbol of the token
   * @param _decimals The decimals of the token
   * @param _minterLimits The minter limits for the token
   * @param _burnerLimits The burner limits for the token
   * @param _bridges The bridges for the token
   * @param _owner The owner of the new token
   * @return crosschainERC20_ The address of the new CrosschainERC20 contract
   */
  function deployCrosschainERC20(
    string memory _name,
    string memory _symbol,
    uint8 _decimals,
    uint256[] memory _minterLimits,
    uint256[] memory _burnerLimits,
    address[] memory _bridges,
    address _owner
  ) external returns (address crosschainERC20_);

  /**
   * @notice Deploys a new CrosschainERC20Lockbox and CrosschainERC20
   * @param _name The name of the token
   * @param _symbol The symbol of the token
   * @param _decimals The decimals of the token
   * @param _minterLimits The minter limits for the token
   * @param _burnerLimits The burner limits for the token
   * @param _bridges The bridges for the token
   * @param _baseToken The address of the base token
   * @param _owner The owner of the new token
   * @return crosschainERC20_ The address of the new CrosschainERC20 contract
   * @return crosschainERC20Lockbox_ The address of the new crosschainERC20Lockbox contract
   */
  function deployCrosschainERC20WithLockbox(
    string memory _name,
    string memory _symbol,
    uint8 _decimals,
    uint256[] memory _minterLimits,
    uint256[] memory _burnerLimits,
    address[] memory _bridges,
    address _baseToken,
    address _owner
  ) external returns (address crosschainERC20_, address crosschainERC20Lockbox_);

  /**
   * @notice Deploys a new ERC7802Adapter
   * @param _xerc20 The address of the xERC20 contract
   * @param _bridge The address of the bridge
   * @return erc7802Adapter_ The address of the new ERC7802Adapter contract
   */
  function deployERC7802Adapter(address _xerc20, address _bridge) external returns (address erc7802Adapter_);
}
