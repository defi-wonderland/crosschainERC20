// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Contracts
import {CrosschainERC20} from 'contracts/CrosschainERC20.sol';
import {CrosschainERC20Factory} from 'contracts/CrosschainERC20Factory.sol';

// Script
import {Script} from 'forge-std/Script.sol';

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
    _factory = CrosschainERC20Factory(0x0b1772D3f03f4f21Faf2Ca5aa8689e6d13337aF3); // Determined because of CREATE3 deployment

    uint256[] memory minterLimits = new uint256[](2);
    uint256[] memory burnerLimits = new uint256[](2);
    address[] memory bridges = new address[](2);

    minterLimits[0] = 10e25;
    burnerLimits[0] = 10e25;
    minterLimits[1] = 10e25;
    burnerLimits[1] = 10e25;

    bridges[0] = 0x5d9084F9abf00256B353db6ADD26b19E857C3E5C; // Result of `makeAddr('_erc7281Bridge')`
    bridges[1] = 0x6DE6A8af4D110939A00b9BE8D3B5361730e3AF24; // Result of `makeAddr('erc7802Bridge')`

    _deploymentParams[1] = DeploymentParams({
      _name: 'Test',
      _symbol: 'TST',
      _decimals: 18,
      _minterLimits: minterLimits,
      _burnerLimits: burnerLimits,
      _bridges: bridges,
      _owner: 0x555B1Ea88dD9B9DA96bc0E35805e1D1C6802552f
    });

    _deploymentParams[420_120_000] = DeploymentParams({
      _name: 'Test',
      _symbol: 'TST',
      _decimals: 18,
      _minterLimits: minterLimits,
      _burnerLimits: burnerLimits,
      _bridges: bridges,
      _owner: 0xF01fB1756DfE192d3DDD84318B7A37276ef41b5B
    });

    _deploymentParams[420_120_001] = DeploymentParams({
      _name: 'Test',
      _symbol: 'TST',
      _decimals: 18,
      _minterLimits: minterLimits,
      _burnerLimits: burnerLimits,
      _bridges: bridges,
      _owner: 0xF01fB1756DfE192d3DDD84318B7A37276ef41b5B
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
