#!/bin/bash

# Setup
forge fmt && forge clean && forge build && source .env

# Verify
forge verify-contract \
0xA317EEAC84FA88Da2064c222D3A13eA9087514ba \
src/contracts/CrosschainERC20.sol:CrosschainERC20 \
--rpc-url superseed \
--verifier blockscout \
--verifier-url https://explorer.superseed.xyz/api/
