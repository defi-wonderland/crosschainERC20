// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Contracts
import {XERC20Lockbox} from '@xERC20/contracts/XERC20Lockbox.sol';
import {CrosschainERC20} from 'contracts/CrosschainERC20.sol';
import {ERC7802Adapter} from 'contracts/ERC7802Adapter.sol';

// Libraries
import {CREATE3} from 'solady/utils/CREATE3.sol';

contract CrosschainERC20Factory {
  /// @notice Thrown when the length of the minter limits, burner limits, or bridges arrays are not equal
  error InvalidLength();

  /// @notice Deploys a new CrosschainERC20 contract and returns the address
  /// @param _name The name of the token
  /// @param _symbol The symbol of the token
  /// @param _minterLimits The minter limits for the token
  /// @param _burnerLimits The burner limits for the token
  /// @param _bridges The bridges for the token
  /// @return crosschainERC20_ The address of the new CrosschainERC20 contract
  function deployCrosschainERC20(
    string memory _name,
    string memory _symbol,
    uint256[] memory _minterLimits,
    uint256[] memory _burnerLimits,
    address[] memory _bridges,
    address _owner
  ) external returns (address crosschainERC20_) {
    crosschainERC20_ = _deployCrosschainERC20(_name, _symbol, _minterLimits, _burnerLimits, _bridges, _owner);
  }

  /// @notice Deploys a new CrosschainERC20Lockbox and CrosschainERC20
  /// @param _name The name of the token
  /// @param _symbol The symbol of the token
  /// @param _minterLimits The minter limits for the token
  /// @param _burnerLimits The burner limits for the token
  /// @param _bridges The bridges for the token
  /// @param _baseToken The address of the base token
  /// @return crosschainERC20_ The address of the new CrosschainERC20 contract
  /// @return crosschainERC20Lockbox_ The address of the new crosschainERC20Lockbox contract
  function deployCrosschainERC20WithLockbox(
    string memory _name,
    string memory _symbol,
    uint256[] memory _minterLimits,
    uint256[] memory _burnerLimits,
    address[] memory _bridges,
    address _baseToken,
    address _owner
  ) external returns (address crosschainERC20_, address crosschainERC20Lockbox_) {
    crosschainERC20_ = _deployCrosschainERC20(_name, _symbol, _minterLimits, _burnerLimits, _bridges, _owner);
    crosschainERC20Lockbox_ = _deployLockbox(crosschainERC20_, _baseToken);
  }

  /// @notice Deploys a new ERC7802Adapter
  /// @param _xerc20 The address of the xERC20 contract
  /// @param _bridge The address of the bridge
  /// @return erc7802Adapter_ The address of the new ERC7802Adapter contract
  function deployERC7802Adapter(address _xerc20, address _bridge) external returns (address erc7802Adapter_) {
    erc7802Adapter_ = _deployERC7802Adapter(_xerc20, _bridge);
  }

  /// @notice Deploys a new CrosschainERC20 contract and returns the address
  /// @param _name The name of the token
  /// @param _symbol The symbol of the token
  /// @param _minterLimits The minter limits for the token
  /// @param _burnerLimits The burner limits for the token
  /// @param _bridges The bridges for the token
  /// @return crosschainERC20_ The address of the new CrosschainERC20 contract
  function _deployCrosschainERC20(
    string memory _name,
    string memory _symbol,
    uint256[] memory _minterLimits,
    uint256[] memory _burnerLimits,
    address[] memory _bridges,
    address _owner
  ) internal returns (address crosschainERC20_) {
    uint256 _bridgesLength = _bridges.length;

    if (_minterLimits.length & _bridgesLength != _bridgesLength) revert InvalidLength();

    bytes32 salt = keccak256(abi.encodePacked(_name, _symbol, msg.sender));
    bytes memory creation = type(CrosschainERC20).creationCode;
    bytes memory bytecode = abi.encodePacked(creation, abi.encode(_name, _symbol, address(this)));

    crosschainERC20_ = CREATE3.deployDeterministic(bytecode, salt);

    for (uint256 _i; _i < _bridgesLength; ++_i) {
      CrosschainERC20(crosschainERC20_).setLimits(_bridges[_i], _minterLimits[_i], _burnerLimits[_i]);
    }

    CrosschainERC20(crosschainERC20_).transferOwnership(_owner);
  }

  /// @notice Deploys a new CrosschainERC20Lockbox contract
  /// @param _crosschainERC20 The address of the CrosschainERC20 contract
  /// @param _baseToken The address of the base token
  /// @return lockbox_ The address of the new CrosschainERC20Lockbox contract
  function _deployLockbox(address _crosschainERC20, address _baseToken) internal returns (address payable lockbox_) {
    bytes32 salt = keccak256(abi.encodePacked(_crosschainERC20, _baseToken, msg.sender));
    bytes memory creation = type(XERC20Lockbox).creationCode;
    bytes memory bytecode = abi.encodePacked(creation, abi.encode(_crosschainERC20, _baseToken, false));

    lockbox_ = payable(CREATE3.deployDeterministic(bytecode, salt));

    CrosschainERC20(_crosschainERC20).setLockbox(address(lockbox_));
  }

  /// @notice Deploys a new ERC7802Adapter
  /// @param _xerc20 The address of the xERC20 contract
  /// @param _bridge The address of the bridge
  /// @return erc7802Adapter_ The address of the new ERC7802Adapter contract
  function _deployERC7802Adapter(address _xerc20, address _bridge) internal returns (address erc7802Adapter_) {
    bytes32 salt = keccak256(abi.encodePacked(_xerc20, _bridge, msg.sender));
    bytes memory creation = type(ERC7802Adapter).creationCode;
    bytes memory bytecode = abi.encodePacked(creation, abi.encode(_xerc20, _bridge));

    erc7802Adapter_ = CREATE3.deployDeterministic(bytecode, salt);
  }
}
