#!/bin/bash

TOKEN_ADDRESS=0x17906b1Cd88aA8EfaEfC5e82891B52a22219BD45
ETHERSCAN_VERIFIER_URL=https://api.etherscan.io/api/
CONSTRUCTOR_ARGS=$(cast ae "constructor(string,string,uint8,address)" "Superseed" "SUPR" 18 0xeF0834C8D531DA628E5f3985AdbaC44aaAfF4148)

# Verify

## CrosschainERC20
### Etherscan
forge verify-contract \
    $TOKEN_ADDRESS \
    src/contracts/CrosschainERC20.sol:CrosschainERC20 \
    --chain-id 1 \
    --watch \
    --compiler-version "v0.8.25" \
    --constructor-args $CONSTRUCTOR_ARGS \
    --verifier-url $ETHERSCAN_VERIFIER_URL \
    --etherscan-api-key $API_KEY_ETHERSCAN
