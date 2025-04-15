// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Contracts
import {CrosschainERC20} from 'contracts/CrosschainERC20.sol';
import {CrosschainERC20Factory} from 'contracts/CrosschainERC20Factory.sol';

// Script
import {Script} from 'forge-std/Script.sol';

/// @title DeployCrosschainERC20
/// @notice Template for deploying a new `CrosschainERC20` token. Please replace values as needed.
contract DeployCrosschainERC20 is Script {
  struct DeploymentParams {
    string _name;
    string _symbol;
    uint8 _decimals;
    uint256[] _minterLimits;
    uint256[] _burnerLimits;
    address[] _bridges;
    address _owner;
  }

  /// @notice The factory to deploy the crosschain ERC20 from
  CrosschainERC20Factory internal _factory;

  /// @notice Deployment parameters for each chain
  mapping(uint256 _chainId => DeploymentParams _params) internal _deploymentParams;

  function setUp() public {
    _factory = CrosschainERC20Factory(0xc8BFbAeEc5699e1E7a9a47386310E1a6A1133055); // Determined because of CREATE3 deployment

    uint256[] memory minterLimits = new uint256[](2);
    uint256[] memory burnerLimits = new uint256[](2);
    address[] memory bridges = new address[](2);

    _deploymentParams[8453] = DeploymentParams({
      _name: 'Superseed',
      _symbol: 'SUPR',
      _decimals: 18,
      _minterLimits: minterLimits,
      _burnerLimits: burnerLimits,
      _bridges: bridges,
      _owner: 0x6418A646Ed5D55D41d9aD8d0B662bEb8db84e995
    });
  }

  function run() public returns (CrosschainERC20 _crosschainERC20) {
    DeploymentParams memory _params = _deploymentParams[block.chainid];

    vm.startBroadcast();
    _crosschainERC20 = CrosschainERC20(
      _factory.deployCrosschainERC20(
        _params._name,
        _params._symbol,
        _params._decimals,
        _params._minterLimits,
        _params._burnerLimits,
        _params._bridges,
        _params._owner
      )
    );
    vm.stopBroadcast();
  }
}
