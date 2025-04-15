#!/bin/bash

# ===============================================================
# ================== BASE SUPR DEPLOYMENT SCRIPTS ===============
# ===============================================================

# =============
# 1. Setup
# =============

forge fmt && forge clean && forge build && source .env


# =================
# 2. Simulation
# =================

forge script script/CrosschainERC20FactoryDeploy.s.sol --private-key $PRIVATE_KEY_STAGING --rpc-url base -vvvv
forge script script/CrosschainERC20Deploy.s.sol --private-key $PRIVATE_KEY_STAGING --rpc-url base -vvvv

# =================
# 3. Execute
# =================

forge script script/CrosschainERC20FactoryDeploy.s.sol \
--private-key $PRIVATE_KEY_STAGING \
--rpc-url base \
--slow \
--broadcast \
-vvvv

forge script script/CrosschainERC20Deploy.s.sol \
--private-key $PRIVATE_KEY_STAGING \
--rpc-url base \
--slow \
--broadcast \
-vvvv
