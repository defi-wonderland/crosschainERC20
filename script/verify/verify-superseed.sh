#!/bin/bash

# Verify

# Lockbox
forge verify-contract \
  --rpc-url https://mainnet.superseed.xyz \
  --verifier blockscout \
  --verifier-url 'https://explorer.superseed.xyz/api/' \
  0xEe64bC3f4A58D638D0845b24e2f51534d01b6549 \
  node_modules/@defi-wonderland/xerc20/solidity/contracts/XERC20Lockbox.sol:XERC20Lockbox


# CrosschainERC20
forge verify-contract \
  --rpc-url https://mainnet.superseed.xyz \
  --verifier blockscout \
  --verifier-url 'https://explorer.superseed.xyz/api/' \
  0xFED85A05C1eeDEae2280777334D34b890b6381e2 \
  src/contracts/CrosschainERC20.sol:CrosschainERC20