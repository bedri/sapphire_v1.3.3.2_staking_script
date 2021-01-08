#!/bin/bash

# This script assumes either the user is root on root's home folder

clear

# Install wget
echo -e "\033[0;34m### Installing wget\033[0m\n"
sudo apt install wget zip unzip -y

# Install wget
echo -e "\033[0;34m### Bootstrapping\033[0m\n"
sudo systemctl stop jackpot
cd .jackpot
mv jackpot.conf ../
rm ../bootstrap.zip
mv bootstrap.zip ../
rm -rf *
mv ../bootstrap.zip ./
wget -N https://github.com/777-project/777/releases/download/v2.0.1.0/bootstrap.zip
unzip bootstrap.zip
mv ../jackpot.conf ./
cd ..
sudo systemctl start jackpot

# Start daemon
echo -e "\n\033[0;34m### Running the daemon. Please wait.\033[0m\n"

# Wait 5 seconds for the daemon starts
sleep 5

watch /usr/local/bin/jackpot-cli -conf=/root/.jackpot/jackpot.conf -datadir=/root/.jackpot getinfo
