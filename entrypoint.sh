#!/bin/bash
set -e

# Starte validityd im Hintergrund
validityd -daemon -datadir=/home/validity/.validity

# Warte, bis validityd bereit ist
until validity-cli -datadir=/home/validity/.validity getinfo > /dev/null 2>&1; do
    sleep 1
done

# Entsperre das Wallet für Staking, wenn eine Passphrase angegeben ist
if [ -n "$WALLET_PASSPHRASE" ]; then
    validity-cli -datadir=/home/validity/.validity walletpassphrase "$WALLET_PASSPHRASE" 604800 true
fi

# Halte den Container am Laufen
exec tail -f /dev/null