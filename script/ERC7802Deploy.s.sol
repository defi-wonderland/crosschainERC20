// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Contracts
import {CrosschainERC20Factory} from 'contracts/CrosschainERC20Factory.sol';
import {ERC7802Adapter} from 'contracts/ERC7802Adapter.sol';

// Script
import {Script} from 'forge-std/Script.sol';

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
    _factory = CrosschainERC20Factory(0x0b1772D3f03f4f21Faf2Ca5aa8689e6d13337aF3); // Determined by CREATE3 deployment

    _deploymentParams[1] = DeploymentParams({
      _xerc20: 0x9A32a40B7cD0316A57E93B73F977E42449c7B17f, // Determined by CREATE3 deployment
      _bridge: 0x6DE6A8af4D110939A00b9BE8D3B5361730e3AF24 // Result of `makeAddr('erc7802Bridge')`
    });

    _deploymentParams[420_120_000] = DeploymentParams({
      _xerc20: 0x9A32a40B7cD0316A57E93B73F977E42449c7B17f, // Determined by CREATE3 deployment
      _bridge: 0x6DE6A8af4D110939A00b9BE8D3B5361730e3AF24 // Result of `makeAddr('erc7802Bridge')`
    });

    _deploymentParams[420_120_001] = DeploymentParams({
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
