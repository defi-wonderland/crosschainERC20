#!/bin/bash

# ===============================================================
# =============== SUPERSEED SUPR DEPLOYMENT SCRIPTS =============
# ===============================================================

# =============
# 1. Setup
# =============

forge fmt && forge clean && forge build && source .env


# =================
# 2. Simulation
# =================

forge script script/CrosschainERC20FactoryDeploy.s.sol --private-key $PRIVATE_KEY_STAGING --rpc-url superseed -vvvv
forge script script/CrosschainERC20WithLockboxDeploy.s.sol --private-key $PRIVATE_KEY_STAGING --rpc-url superseed -vvvv

# =================
# 3. Execute
# =================

forge script script/CrosschainERC20FactoryDeploy.s.sol \
--private-key $PRIVATE_KEY_STAGING \
--rpc-url superseed \
--slow \
--broadcast \
-vvvv

forge script script/CrosschainERC20WithLockboxDeploy.s.sol \
--private-key $PRIVATE_KEY_STAGING \
--rpc-url superseed \
--slow \
--broadcast \
-vvvv
