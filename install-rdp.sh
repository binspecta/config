#!/bin/bash

# Script by Node Farmer
# Medium: https://medium.com/@cryptonodefarmer_80672
# X: https://x.com/_node_farmer_
# Telegram: https://t.me/+Hrs33jHFE0liMWNk
# Discord: https://discord.gg/GXRvQByQ


# Define user and password variables for remote desktop
# Don't use root

USER="${RDP_USER:-ramses}"

# Read the password securely at runtime so it is never stored in the
# script or committed to git. Set RDP_PASSWORD in the environment to run
# non-interactively (e.g. for automation).
if [ -n "$RDP_PASSWORD" ]; then
    PASSWORD="$RDP_PASSWORD"
else
    read -rsp "Enter password for user '$USER': " PASSWORD
    echo
fi

if [ -z "$PASSWORD" ]; then
    echo "Password cannot be empty. Aborting." >&2
    exit 1
fi

# Update the package list
sudo apt update

# Installing GNOME Desktop
sudo apt install -y ubuntu-desktop

# Installing the remote desktop server (xrdp)
sudo apt install -y xrdp

# Adds the user USER with the password
sudo useradd -m -s /bin/bash "$USER"
echo "$USER:$PASSWORD" | sudo chpasswd

# Adds the user USER to the sudo group for administrative rights
sudo usermod -aG sudo "$USER"

# Configures xrdp to use the GNOME desktop
echo "gnome-session" > ~/.xsession

# Restarts the xrdp service
sudo systemctl restart xrdp

# Enables xrdp at startup
sudo systemctl enable xrdp

# Installs the necessary dependencies for Google Chrome
sudo apt install -y wget gnupg

# Adds the Google repository key to a dedicated keyring (apt-key is deprecated)
sudo install -m 0755 -d /etc/apt/keyrings
wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
    | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
sudo chmod a+r /etc/apt/keyrings/google-chrome.gpg

# Adds the Google Chrome repository (scoped to the key above, over https)
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

# Updates the package list again
sudo apt update

# Installs Google Chrome
sudo apt install -y google-chrome-stable

echo "Installation complete. GNOME Desktop, xrdp, and Google Chrome have been installed. You can now connect via Remote Desktop with the user $USER."
