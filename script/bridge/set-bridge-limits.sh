#!/bin/bash

# Setup
forge fmt && forge clean && forge build && source .env

# Verify

## Superseed
forge script script/xERC20SetBridgeLimits.s.sol \
--private-key $PRIVATE_KEY_PROD \
--rpc-url superseed \
--slow \
--broadcast \
-vvvv

## Mainnet
forge script script/xERC20SetBridgeLimits.s.sol \
--private-key $PRIVATE_KEY_PROD \
--rpc-url mainnet \
--slow \
--broadcast \
-vvvv

## Optimism
forge script script/xERC20SetBridgeLimits.s.sol \
--private-key $PRIVATE_KEY_PROD \
--rpc-url optimism \
--slow \
--broadcast \
-vvvv

## Base
forge script script/xERC20SetBridgeLimits.s.sol \
--private-key $PRIVATE_KEY_PROD \
--rpc-url base \
--slow \
--broadcast \
-vvvv

## Ink
forge script script/xERC20SetBridgeLimits.s.sol \
--private-key $PRIVATE_KEY_PROD \
--rpc-url ink \
--slow \
--broadcast \
-vvvv
