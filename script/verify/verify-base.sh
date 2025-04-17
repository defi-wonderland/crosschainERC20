#!/bin/bash

# Setup
forge fmt && forge clean && forge build && source .env

# Verify

## CrosschainERC20
### Basescan
forge verify-contract \
0x17906b1Cd88aA8EfaEfC5e82891B52a22219BD45 \
src/contracts/CrosschainERC20.sol:CrosschainERC20 \
--rpc-url base \
--etherscan-api-key $API_KEY_BASESCAN \
--verifier-url https://api.basescan.org/api/

### Blockscout
forge verify-contract \
0x17906b1Cd88aA8EfaEfC5e82891B52a22219BD45 \
src/contracts/CrosschainERC20.sol:CrosschainERC20 \
--rpc-url base \
--verifier blockscout \
--verifier-url https://base.blockscout.com/api/
