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
  CrosschainERC20 internal _token;

  /// @notice Deployment parameters for each chain
  mapping(uint256 _chainId => BridgeLimits _params) internal _bridgeParams;

  function setUp() public {
    _token = CrosschainERC20(0xA317EEAC84FA88Da2064c222D3A13eA9087514ba);

    uint256[] memory minterLimits = new uint256[](1);
    uint256[] memory burnerLimits = new uint256[](1);
    address[] memory bridges = new address[](1);

    bridges[0] = 0x2245e51C7Ddd50E3E7b987d7661077d4ee61C682;
    minterLimits[0] = 10e25;
    burnerLimits[0] = 10e25;

    // _bridgeParams[8453] = BridgeLimits({_minterLimits: minterLimits, _burnerLimits: burnerLimits, _bridges: bridges});
    _bridgeParams[5330] = BridgeLimits({_minterLimits: minterLimits, _burnerLimits: burnerLimits, _bridges: bridges});
  }

  function run() public {
    BridgeLimits memory _params = _bridgeParams[block.chainid];
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
