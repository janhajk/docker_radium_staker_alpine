#!/bin/bash -e

echo "Starting Radium Daemon..."
radiumcli=/home/radium/radium/radium-0.11-1.5.1.0/src/radiumd
# cp /home/radium/radium.conf /home/radium/.radium/radium.conf
/home/radium/radium/radium-0.11-1.5.1.0/src/radiumd -datadir=/home/radium/.radium & 

while true; do sleep 1000; done


# echo "Waiting for daemon..."
# sleep 60


# n=0
# until [ $n -ge 60 ]
# do
#   echo "Attempting to unlock wallet for staking..."
#    $radiumcli walletpassphrase $PASSPHRASE 9999999 true && break
#   n=$[$n+1]

#   echo "Unable to unlock wallet, retrying in a few seconds..."
#   sleep 5
# done

# if [ "$?" -eq 0 ]; then
#   echo "Wallet unlocked successfully."
# else
#   echo "Unable to unlock wallet after 5 minutes."
#   exit 1
# fi
