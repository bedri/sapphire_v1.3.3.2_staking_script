 
wget http://sappexplorer.com/SAPP-1.4.0.0-Linux.zip
unzip SAPP-1.4.0.0-Linux.zip
rm SAPP-1.4.0.0-Linux.zip
mv sapphire* /usr/local/bin

systemctl stop sapphire
pkill -9 sapphired
rm -rf .sapphire
mkdir .sapphire
cp .sap/sap.conf .sapphire/sapphire.conf
sed -i 's/sap-cli/sapphire-cli/g' .sapphire/sapphire.conf
cd .sapphire
wget https://www.sappexplorer.com/bootstrap14.zip
unzip bootstrap14.zip
cd ..

wget https://www.sappexplorer.com/sapphire.service
mv sapphire.service /etc/systemd/system/sapphire.service
systemctl stop sapd
systemctl disable sapd
systemctl stop sap
systemctl disable sap
systemctl stop sapphire
systemctl enable sapphire
systemctl start sapphire

watch sapphire-cli getinfo
