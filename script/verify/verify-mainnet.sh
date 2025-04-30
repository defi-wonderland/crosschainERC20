#!/bin/bash

# Setup
forge fmt && forge clean && forge build && source .env

# Verify

## CrosschainERC20
### Etherscan
forge verify-contract \
0x17906b1Cd88aA8EfaEfC5e82891B52a22219BD45 \
src/contracts/CrosschainERC20.sol:CrosschainERC20 \
--rpc-url mainnet \
--etherscan-api-key $API_KEY_ETHERSCAN \
--verifier-url https://api.etherscan.io/api/

### Blockscout
forge verify-contract \
0x17906b1Cd88aA8EfaEfC5e82891B52a22219BD45 \
src/contracts/CrosschainERC20.sol:CrosschainERC20 \
--rpc-url mainnet \
--verifier blockscout \
--verifier-url https://eth.blockscout.com/api/
