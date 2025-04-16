// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Contracts
import {CrosschainERC20} from 'contracts/CrosschainERC20.sol';
import {CrosschainERC20Factory} from 'contracts/CrosschainERC20Factory.sol';

// Interfaces
import {IXERC20Lockbox} from '@xERC20/interfaces/IXERC20Lockbox.sol';

// Script
import {Script} from 'forge-std/Script.sol';

/// @title DeployCrosschainERC20WithLockbox
/// @notice Template for deploying a new `CrosschainERC20` paired with a `Lockbox`. Please replace values as needed.
contract DeployCrosschainERC20WithLockbox is Script {
  struct DeploymentParams {
    string _name;
    string _symbol;
    uint256[] _minterLimits;
    uint256[] _burnerLimits;
    address[] _bridges;
    address _baseToken;
    address _owner;
  }

  /// @notice The factory to deploy the crosschain ERC20 from
  CrosschainERC20Factory internal _factory;

  /// @notice Deployment parameters for each chain
  mapping(uint256 _chainId => DeploymentParams _params) internal _deploymentParams;

  function setUp() public {
    _factory = CrosschainERC20Factory(0xc8BFbAeEc5699e1E7a9a47386310E1a6A1133055); // Determined because of CREATE3 deployment

    uint256[] memory minterLimits = new uint256[](0);
    uint256[] memory burnerLimits = new uint256[](0);
    address[] memory bridges = new address[](0);

    _deploymentParams[5330] = DeploymentParams({
      _name: 'Superseed Crosschain Token',
      _symbol: 'XSUPR',
      _minterLimits: minterLimits,
      _burnerLimits: burnerLimits,
      _bridges: bridges,
      _baseToken: 0x6EA1fFcbD7F5D210dB07D9E773862B0512fA219B, // SUPR
      _owner: 0xeF0834C8D531DA628E5f3985AdbaC44aaAfF4148
    });
  }

  function run() public returns (CrosschainERC20 _crosschainERC20, IXERC20Lockbox _lockbox) {
    DeploymentParams memory _params = _deploymentParams[block.chainid];

    vm.startBroadcast();
    (address _crosschainERC20Address, address _lockboxAddress) = _factory.deployCrosschainERC20WithLockbox(
      _params._name,
      _params._symbol,
      _params._minterLimits,
      _params._burnerLimits,
      _params._bridges,
      _params._baseToken,
      _params._owner
    );
    vm.stopBroadcast();

    _crosschainERC20 = CrosschainERC20(_crosschainERC20Address);
    _lockbox = IXERC20Lockbox(payable(_lockboxAddress));
  }
}
