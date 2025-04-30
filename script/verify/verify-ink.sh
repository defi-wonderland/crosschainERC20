#!/bin/bash

# Setup
forge fmt && forge clean && forge build && source .env

# Verify

## CrosschainERC20

### Blockscout
forge verify-contract \
0x17906b1Cd88aA8EfaEfC5e82891B52a22219BD45 \
src/contracts/CrosschainERC20.sol:CrosschainERC20 \
--rpc-url ink \
--verifier blockscout \
--verifier-url https://explorer.inkonchain.com/api/
