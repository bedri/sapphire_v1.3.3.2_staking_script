#!/bin/bash

# This script assumes that the user is root and the shell is at root's home

clear

# Install wget
echo -e "\033[0;34m### Installing required packages\033[0m\n"
sudo apt install wget zip unzip jq curl -y

# Create directory for binaries zip file and bootstrap.zip and change directory to it
mkdir tmp
cd tmp

# Download Sapphire v1.3.3.2 binaries and extract them
echo -e "\n\033[0;34m### Downloading Sapphire v1.3.3.2 binaries and installing them\033[0m\n"
wget https://github.com/sappcoin-com/SAPP/releases/download/v1.3.3.2/SAPP-1.3.3.2-Linux.zip
unzip SAPP-1.3.3.2-Linux.zip

# Install Sapphire v1.3.3.2 binaries to /usr/local/bin and create $HOME/.sap (Sapphire data directory)
sudo mv sapd sap-cli sap-tx sap-qt /usr/local/bin/
mkdir $HOME/.sap

# Download bootstrap and extract it into Sapphire data directory
echo -e "\n\033[0;34m### Downloading bootstrap and extracting it into Sapphire data directory\033[0m\n"
wget http://sappexplorer.com/bootstrap.zip
unzip -q bootstrap.zip -d $HOME/.sap

# Change directory to $HOME and remove tmp directory
cd $HOME
rm -fr tmp

# Install blocknotify.sh script
sudo curl -sL https://raw.githubusercontent.com/pedro-at-decenomy/seed_scripts/master/blocknotify.sh > /usr/local/bin/blocknotify.sh
chmod +x /usr/local/bin/blocknotify.sh

# Create empty sap.conf file and fill it with arguments
echo -e "\n\033[0;34m### Creating sap.conf and populating it\033[0m\n"

echo -e "\n\033[0;33m### Please enter node ID (Example: SAPP01)\033[0m\n"
read -e ID
#echo -e "\n\033[0;33m### Please enter node TICKER (Example: SAPP)\033[0m\n"
#read -e TICKER
#echo -e "\n\033[0;33m### Please enter node cli name (Example: sap-cli)\033[0m\n"
#read -e CLI
# Run blocknotify once
#/usr/local/bin/blocknotify.sh $ID $TICKER $CLI

touch $HOME/.sap/sap.conf
echo "daemon=1" >> $HOME/.sap/sap.conf
echo "server=1" >> $HOME/.sap/sap.conf
echo "addnode=seed1.sappcoin.com" >> $HOME/.sap/sap.conf
echo "addnode=seed2.sappcoin.com" >> $HOME/.sap/sap.conf
echo "addnode=seed3.sappcoin.com" >> $HOME/.sap/sap.conf
echo "addnode=seed4.sappcoin.com" >> $HOME/.sap/sap.conf
echo "addnode=seed5.sappcoin.com" >> $HOME/.sap/sap.conf
echo "addnode=seed6.sappcoin.com" >> $HOME/.sap/sap.conf
echo "addnode=seed7.sappcoin.com" >> $HOME/.sap/sap.conf
echo "addnode=seed8.sappcoin.com" >> $HOME/.sap/sap.conf
echo "banaddressmempool=SfFQ3twBcziZAHMeULnrDSemaqZqHUpmj4" >> $HOME/.sap/sap.conf
echo "banaddressmempool=SPixuKa8Vnyi6RpcB8XTXh7TBqq6TqZ43b" >> $HOME/.sap/sap.conf
#echo "alertnotify=echo %s | mail -s \"Kyanite-testnet alert!\" bedriguler@gmail.com" >> $HOME/.sap/sap.conf
echo "blocknotify=/usr/local/bin/blocknotify.sh $ID SAPP sap-cli" >> $HOME/.sap/sap.conf


# Install as a service
sudo cat << EOF > /etc/systemd/system/sap.service
[Unit]
Description=Sapphire service
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart=/usr/local/bin/sapd -daemon -conf=/root/.sap/sap.conf -datadir=/root/.sap
ExecStop=-/usr/local/bin/sap-cli -conf=/root/.sap/sap.conf -datadir=/root/.sap stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start sap.service
sudo systemctl enable sap.service >/dev/null 2>&1

# Start  Sapphire v1.3.3.2 daemon
echo -e "\n\033[0;34m### Running the daemon. Please wait.\033[0m\n"

# Wait 5 seconds for the daemon starts
sleep 5

watch /usr/local/bin/sap-cli -conf=/root/.sap/sap.conf -datadir=/root/.sap getinfo
