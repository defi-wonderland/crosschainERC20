#!/bin/bash

# Verify

# Lockbox
forge verify-contract \
  --rpc-url https://mainnet.superseed.xyz \
  --verifier blockscout \
  --verifier-url 'https://explorer.superseed.xyz/api/' \
  0xD87FF9E40366A7D43035023c9347776c702B504C \
  node_modules/@defi-wonderland/xerc20/solidity/contracts/XERC20Lockbox.sol:XERC20Lockbox


# CrosschainERC20
forge verify-contract \
  --rpc-url https://mainnet.superseed.xyz \
  --verifier blockscout \
  --verifier-url 'https://explorer.superseed.xyz/api/' \
  0xA317EEAC84FA88Da2064c222D3A13eA9087514ba \
  src/contracts/CrosschainERC20.sol:CrosschainERC20