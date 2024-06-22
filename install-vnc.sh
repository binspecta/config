#!/bin/bash

sudo apt install xfce4 xfce4-goodies -y
sudo apt install tightvncserver -y

mypasswd="Clever47!!"

echo $mypasswd | vncpasswd -f > /root/.vnc/passwd

cat <<EOF ~/.vnc/xstartup
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOF

chmod +x ~/.vnc/xstartup

cat <<EOF /etc/systemd/system/vncserver@.service
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
