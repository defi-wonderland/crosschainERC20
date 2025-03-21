// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Contracts
import {CrosschainERC20Factory} from 'contracts/CrosschainERC20Factory.sol';
import {ERC7802Adapter} from 'contracts/ERC7802Adapter.sol';

// Script
import {Script} from 'forge-std/Script.sol';

/// @title DeployERC7802Adapter
/// @notice Template for deploying a new `ERC7802Adapter`. Please replace values as needed.
contract DeployERC7802Adapter is Script {
  struct DeploymentParams {
    address _xerc20;
    address _bridge;
  }

  /// @notice The factory to deploy the crosschain ERC20 from
  CrosschainERC20Factory internal _factory;

  /// @notice Deployment parameters for each chain
  mapping(uint256 _chainId => DeploymentParams _params) internal _deploymentParams;

  function setUp() public {
    _factory = CrosschainERC20Factory(0xe4c221582E95A0d84b29d294AF8235Fc74E1CF60); // Determined by CREATE3 deployment

    _deploymentParams[1] = DeploymentParams({
      _xerc20: 0x9A32a40B7cD0316A57E93B73F977E42449c7B17f, // Determined by CREATE3 deployment
      _bridge: 0x6DE6A8af4D110939A00b9BE8D3B5361730e3AF24 // Result of `makeAddr('erc7802Bridge')`
    });
  }

  function run() public returns (ERC7802Adapter _adapter) {
    DeploymentParams memory _params = _deploymentParams[block.chainid];

    vm.startBroadcast();
    _adapter = ERC7802Adapter(_factory.deployERC7802Adapter(_params._xerc20, _params._bridge));
    vm.stopBroadcast();
  }
}
