// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {GhostVariables} from './GhostVariables.sol';
import {PropertiesAsserts} from './utils/PropertiesAsserts.sol';
import {vm} from './utils/VM.sol';
import {XERC20} from '@xERC20/contracts/XERC20.sol';
import {XERC20Lockbox} from '@xERC20/contracts/XERC20Lockbox.sol';
import {CrosschainERC20Factory} from 'src/contracts/CrosschainERC20Factory.sol';
import {ICrosschainERC20} from 'src/interfaces/ICrosschainERC20.sol';
import {IERC7802Adapter} from 'src/interfaces/IERC7802Adapter.sol';

contract Setup is PropertiesAsserts, GhostVariables {
  //Actors
  address internal immutable _OWNER = makeAddr('Owner');
  address internal immutable _USER = makeAddr('User');
  address internal immutable _BRIDGE = makeAddr('Bridge');

  //Contracts
  CrosschainERC20Factory public factory;
  ICrosschainERC20 public crosschainERC20;
  MockXERC20 public xerc20;
  IERC7802Adapter public adapter;
  XERC20Lockbox public lockbox;

  constructor() {
    // Deploy the mock XERC20 to use with lockbox and adapter.
    xerc20 = new MockXERC20(_OWNER);
    // Deploy factory to deploy the CrosschainERC20, Lockbox and Adapter.
    factory = new CrosschainERC20Factory();
    // Deal 1000e18 to the user to use as liquidity.
    vm.prank(_OWNER);
    xerc20.deal(_USER, 1000e18);

    uint256[] memory _minterLimits = new uint256[](1);
    uint256[] memory _burnerLimits = new uint256[](1);
    address[] memory _bridges = new address[](1);

    _minterLimits[0] = 1000e18;
    _burnerLimits[0] = 1000e18;
    _bridges[0] = _BRIDGE;

    (address _crosschainERC20, address _lockbox) = factory.deployCrosschainERC20WithLockbox(
      'Test', 'TEST', _minterLimits, _burnerLimits, _bridges, address(xerc20), _OWNER
    );

    crosschainERC20 = ICrosschainERC20(_crosschainERC20);
    lockbox = XERC20Lockbox(payable(_lockbox));

    adapter = IERC7802Adapter(factory.deployERC7802Adapter(address(xerc20), _BRIDGE));

    vm.prank(_OWNER);
    xerc20.setLimits(address(adapter), 1000e18, 1000e18);
  }

  function makeAddr(string memory name) internal returns (address) {
    return vm.addr(uint256(keccak256(abi.encodePacked(name))));
  }
}

contract MockXERC20 is XERC20 {
  constructor(address factory) XERC20('Test', 'TEST', 18, factory) {}

  function deal(address to, uint256 amount) external onlyOwner {
    _mint(to, amount);
  }
}
