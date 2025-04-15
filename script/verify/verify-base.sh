#!/bin/bash

# Setup
forge fmt && forge clean && forge build && source .env

# Verify

forge verify-contract \
0xA317EEAC84FA88Da2064c222D3A13eA9087514ba \
src/contracts/CrosschainERC20.sol:CrosschainERC20 \
--rpc-url base \
--etherscan-api-key $API_KEY_BASESCAN \
--verifier-url https://api.basescan.org/api/

forge verify-contract \
0xA317EEAC84FA88Da2064c222D3A13eA9087514ba \
src/contracts/CrosschainERC20.sol:CrosschainERC20 \
--rpc-url base \
--verifier blockscout \
--verifier-url https://base.blockscout.com/api/
