#!/bin/bash

# This script assumes either the user is root or it has a sudo permission

clear

# Install wget
echo -e "\033[0;34m### Installing wget\033[0m\n"
sudo apt install wget zip unzip -y

# Install wget
echo -e "\033[0;34m### Bootstrapping\033[0m\n"
sudo systemctl stop sap
cd .sap
mv sap.conf ../
rm ../bootstrap.zip
mv bootstrap.zip ../
rm -rf *
mv ../bootstrap.zip ./
wget -N https://www.sappexplorer.com/bootstrap.zip
unzip bootstrap.zip
mv ../sap.conf ./
cd ..
sudo systemctl start sap

# Start  Sapphire v1.3.3.2 daemon
echo -e "\n\033[0;34m### Running the daemon. Please wait.\033[0m\n"

# Wait 5 seconds for the daemon starts
sleep 5

watch /usr/local/bin/sap-cli -conf=/root/.sap/sap.conf -datadir=/root/.sap getinfo
