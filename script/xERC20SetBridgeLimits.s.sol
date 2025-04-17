// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Contracts
import {CrosschainERC20} from 'contracts/CrosschainERC20.sol';

// Script
import {Script} from 'forge-std/Script.sol';

contract XERC20SetBridgeLimits is Script {
  struct BridgeLimits {
    uint256[] _minterLimits;
    uint256[] _burnerLimits;
    address[] _bridges;
  }

  error InvalidLength();

  /// @notice The factory to deploy the crosschain ERC20 from
  mapping(uint256 _chainId => CrosschainERC20 _token) internal _tokens;

  /// @notice Deployment parameters for each chain
  mapping(uint256 _chainId => BridgeLimits _params) internal _bridgeParams;

  function setUp() public {
    // Superseed
    _tokens[5330] = CrosschainERC20(0xFED85A05C1eeDEae2280777334D34b890b6381e2);
    _bridgeParams[5330] =
      BridgeLimits({_minterLimits: new uint256[](1), _burnerLimits: new uint256[](1), _bridges: new address[](1)});
    _bridgeParams[5330]._minterLimits[0] = 500_000_000 * 1e18;
    _bridgeParams[5330]._burnerLimits[0] = 500_000_000 * 1e18;
    _bridgeParams[5330]._bridges[0] = 0xA1863B4b02b7DCd7429F62C775816328D63020F4;

    // Mainnet
    _tokens[1] = CrosschainERC20(0x17906b1Cd88aA8EfaEfC5e82891B52a22219BD45);
    _bridgeParams[1] =
      BridgeLimits({_minterLimits: new uint256[](1), _burnerLimits: new uint256[](1), _bridges: new address[](1)});
    _bridgeParams[1]._minterLimits[0] = 300_000_000 * 1e18;
    _bridgeParams[1]._burnerLimits[0] = 300_000_000 * 1e18;
    _bridgeParams[1]._bridges[0] = 0xbc808c98beA0a097346273A9Fd7a5B231fc2d889;

    // Optimism
    _tokens[10] = CrosschainERC20(0x17906b1Cd88aA8EfaEfC5e82891B52a22219BD45);
    _bridgeParams[10] =
      BridgeLimits({_minterLimits: new uint256[](1), _burnerLimits: new uint256[](1), _bridges: new address[](1)});
    _bridgeParams[10]._minterLimits[0] = 50_000_000 * 1e18;
    _bridgeParams[10]._burnerLimits[0] = 50_000_000 * 1e18;
    _bridgeParams[10]._bridges[0] = 0xae1E04F18D1323d8EaC7Ba5b2c683c95DC3baC97;

    // Base
    _tokens[8453] = CrosschainERC20(0x17906b1Cd88aA8EfaEfC5e82891B52a22219BD45);
    _bridgeParams[8453] =
      BridgeLimits({_minterLimits: new uint256[](1), _burnerLimits: new uint256[](1), _bridges: new address[](1)});
    _bridgeParams[8453]._minterLimits[0] = 100_000_000 * 1e18;
    _bridgeParams[8453]._burnerLimits[0] = 100_000_000 * 1e18;
    _bridgeParams[8453]._bridges[0] = 0x458BDDd0793fe4f70912535f172466a5473f2e77;

    // Ink
    _tokens[57_073] = CrosschainERC20(0x17906b1Cd88aA8EfaEfC5e82891B52a22219BD45);
    _bridgeParams[57_073] =
      BridgeLimits({_minterLimits: new uint256[](1), _burnerLimits: new uint256[](1), _bridges: new address[](1)});
    _bridgeParams[57_073]._minterLimits[0] = 50_000_000 * 1e18;
    _bridgeParams[57_073]._burnerLimits[0] = 50_000_000 * 1e18;
    _bridgeParams[57_073]._bridges[0] = 0x6cfDDfa3e0867A873675B80FDEBeB94e9262b5F0;
  }

  function run() public {
    BridgeLimits memory _params = _bridgeParams[block.chainid];
    CrosschainERC20 _token = _tokens[block.chainid];

    uint256 _bridgesLength = _params._bridges.length;
    if (_params._minterLimits.length != _bridgesLength || _params._burnerLimits.length != _bridgesLength) {
      revert InvalidLength();
    }

    vm.startBroadcast();

    for (uint256 _i; _i < _bridgesLength; ++_i) {
      _token.setLimits(_params._bridges[_i], _params._minterLimits[_i], _params._burnerLimits[_i]);
    }

    vm.stopBroadcast();
  }
}
