#!/bin/bash

# Script by Node Farmer
# Medium: https://medium.com/@cryptonodefarmer_80672
# X: https://x.com/_node_farmer_
# Telegram: https://t.me/+Hrs33jHFE0liMWNk
# Discord: https://discord.gg/GXRvQByQ


# Define user and password variables for remote desktop
# Don't use root

USER="ramses"

PASSWORD="Clever47!!"

# Update the package list
sudo apt update

# Installing GNOME Desktop
sudo apt install -y ubuntu-desktop

# Installing the remote desktop server (xrdp)
sudo apt install -y xrdp

# Adds the user USER with the password
sudo useradd -m -s /bin/bash $USER
echo "$USER:$PASSWORD" | sudo chpasswd

# Adds the user USER to the sudo group for administrative rights
sudo usermod -aG sudo $USER

# Configures xrdp to use the GNOME desktop
echo "gnome-session" > ~/.xsession

# Restarts the xrdp service
sudo systemctl restart xrdp

# Enables xrdp at startup
sudo systemctl enable xrdp

# Installs the necessary dependencies for Google Chrome
sudo apt install -y wget gnupg

# Adds the Google repository key
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# Adds the Google Chrome repository
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

# Updates the package list again
sudo apt update

# Installs Google Chrome
sudo apt install -y google-chrome-stable

echo "Installation complete. GNOME Desktop, xrdp, and Google Chrome have been installed. You can now connect via Remote Desktop with the user $USER."
