#!/bin/bash

forge fmt && forge clean && forge build && source .env

forge script script/xERC20SetBridgeLimits.s.sol --private-key $PRIVATE_KEY_STAGING --rpc-url base -vvvv

forge script script/xERC20SetBridgeLimits.s.sol \
--private-key $PRIVATE_KEY_STAGING \
--rpc-url base \
--slow \
--broadcast \
-vvvv
