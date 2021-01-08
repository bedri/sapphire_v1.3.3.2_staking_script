#!/bin/bash

# This script assumes that the user is root and the shell is at root's home

clear

# Install wget
echo -e "\033[0;34m### Installing required packages\033[0m\n"
sudo apt install wget zip unzip jq curl -y

# Create directory for binaries zip file and bootstrap.zip and change directory to it
mkdir tmp
cd tmp

# Download Jackpot 777 binaries and extract them
echo -e "\n\033[0;34m### Downloading Jackpot 777 binaries and installing them\033[0m\n"
wget https://github.com/777-project/777/releases/download/v2.0.1.1/Jackpot-2.0.1.1-Linux.zip
unzip Jackpot-2.0.1.1-Linux.zip

# Install Jackpot 777 binaries to /usr/local/bin and create $HOME/.jackpot (Jackpot data directory)
sudo mv jackpotd jackpot-cli jackpot-tx jackpot-qt /usr/local/bin/
mkdir $HOME/.jackpot

# Download bootstrap and extract it into Jackpot data directory
echo -e "\n\033[0;34m### Downloading bootstrap and extracting it into Sapphire data directory\033[0m\n"
wget https://github.com/777-project/777/releases/download/v2.0.1.0/bootstrap.zip
unzip -q bootstrap.zip -d $HOME/.jackpot

# Change directory to $HOME and remove tmp directory
cd $HOME
rm -fr tmp

# Install blocknotify.sh script
sudo curl -sL https://raw.githubusercontent.com/pedro-at-decenomy/seed_scripts/master/blocknotify.sh > /usr/local/bin/blocknotify.sh
chmod +x /usr/local/bin/blocknotify.sh

# Create empty jackpot.conf file and fill it with arguments
echo -e "\n\033[0;34m### Creating jackpot.conf and populating it\033[0m\n"

echo -e "\n\033[0;33m### Please enter node ID (Example: TSEED01)\033[0m\n"
read -e ID
#echo -e "\n\033[0;33m### Please enter node TICKER (Example: SAPP)\033[0m\n"
#read -e TICKER
#echo -e "\n\033[0;33m### Please enter node cli name (Example: sap-cli)\033[0m\n"
#read -e CLI
# Run blocknotify once
#/usr/local/bin/blocknotify.sh $ID $TICKER $CLI

touch $HOME/.jackpot/jackpot.conf
echo "daemon=1" >> $HOME/.jackpot/jackpot.conf
echo "server=1" >> $HOME/.jackpot/jackpot.conf
echo "addnode=seed1.777coin.win" >> $HOME/.jackpot/jackpot.conf
echo "addnode=seed2.777coin.win" >> $HOME/.jackpot/jackpot.conf
echo "addnode=seed3.777coin.win" >> $HOME/.jackpot/jackpot.conf
echo "addnode=seed4.777coin.win" >> $HOME/.jackpot/jackpot.conf
echo "addnode=seed5.777coin.win" >> $HOME/.jackpot/jackpot.conf
echo "addnode=seed6.777coin.win" >> $HOME/.jackpot/jackpot.conf
echo "addnode=seed7.777coin.win" >> $HOME/.jackpot/jackpot.conf
echo "addnode=seed8.777coin.win" >> $HOME/.jackpot/jackpot.conf
echo "blocknotify=/usr/local/bin/blocknotify.sh $ID 777 jackpot-cli" >> $HOME/.jackpot/jackpot.conf

# Install as a service
sudo cat << EOF > /etc/systemd/system/jackpot.service
[Unit]
Description=Jackpot service
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart=/usr/local/bin/jackpotd -daemon -conf=/root/.jackpot/jackpot.conf -datadir=/root/.jackpot
ExecStop=-/usr/local/bin/jackpot-cli -conf=/root/.jackpot/jackpot.conf -datadir=/root/.jackpot stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start jackpot.service
sudo systemctl enable jackpot.service >/dev/null 2>&1

# Start  Jackpot daemon
echo -e "\n\033[0;34m### Running the daemon. Please wait.\033[0m\n"

# Wait 5 seconds for the daemon starts
sleep 5

watch /usr/local/bin/jackpot-cli -conf=/root/.jackpot/jackpot.conf -datadir=/root/.jackpot getinfo
