#!/bin/bash
validityd -daemon
until validityd -getinfo > /dev/null 2>&1; do
  sleep 1
done
validity-cli -rpcuser=user -rpcpassword=password walletpassphrase "$WALLET_PASSPHRASE" 604800
tail -f /dev/null