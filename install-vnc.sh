#!/bin/bash

sudo apt install xfce4 xfce4-goodies -y
sudo apt install tightvncserver -y
sudo apt install -y net-tools

vncserver
vncserver -kill :1

mkdir -p /root/.vnc

cat <<EOF > ~/.vnc/xstartup
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOF

chmod +x ~/.vnc/xstartup

cat <<EOF > /etc/systemd/system/vncserver@.service
[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=root
PAMName=login
PIDFile=/root/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable vncserver@1.service
sudo systemctl start vncserver@1

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


