#!/bin/bash

# VNC server install — runs the desktop as a dedicated NON-root user and
# binds VNC to localhost only. You reach it over an SSH tunnel (see the end
# of this script), so the VNC port is never exposed to the internet.

# --- user / password (never hardcoded) -------------------------------------

# Dedicated unprivileged account that owns the VNC desktop. Override with
# VNC_USER=... if you want a different name.
VNC_USER="${VNC_USER:-vncuser}"

# VNC password. Read at runtime so it is never stored in the script or git.
# Set VNC_PASSWORD in the environment to run non-interactively.
# (VNC passwords are limited to 8 characters; 6-8 recommended.)
if [ -n "$VNC_PASSWORD" ]; then
    PASSWORD="$VNC_PASSWORD"
else
    read -rsp "Set a VNC password for user '$VNC_USER' (6-8 chars): " PASSWORD
    echo
fi

if [ -z "$PASSWORD" ]; then
    echo "Password cannot be empty. Aborting." >&2
    exit 1
fi

# --- packages --------------------------------------------------------------

sudo apt update
sudo apt install -y tigervnc-standalone-server net-tools lxde

# --- dedicated user --------------------------------------------------------

# Create the account if it does not exist. Intentionally NOT added to sudo:
# a compromised browser/VNC session should not yield root.
if ! id "$VNC_USER" >/dev/null 2>&1; then
    sudo useradd -m -s /bin/bash "$VNC_USER"
fi
VNC_HOME="$(getent passwd "$VNC_USER" | cut -d: -f6)"

# --- VNC password file (mode 0600, owned by the user) ----------------------

sudo -u "$VNC_USER" mkdir -p "$VNC_HOME/.vnc"
tmp_pw="$(mktemp)"
printf '%s\n' "$PASSWORD" | vncpasswd -f > "$tmp_pw"
sudo install -o "$VNC_USER" -g "$VNC_USER" -m 600 "$tmp_pw" "$VNC_HOME/.vnc/passwd"
rm -f "$tmp_pw"

# --- xstartup (single-quoted heredoc: $HOME resolves at runtime) ------------

sudo tee "$VNC_HOME/.vnc/xstartup" > /dev/null <<'EOF'
#!/bin/bash
xrdb "$HOME/.Xresources" 2>/dev/null
startlxde &
EOF
sudo chmod +x "$VNC_HOME/.vnc/xstartup"
sudo chown -R "$VNC_USER:$VNC_USER" "$VNC_HOME/.vnc"

# --- systemd service (runs as $VNC_USER, localhost-only) -------------------

sudo tee /etc/systemd/system/vncserver@.service > /dev/null <<EOF
[Unit]
Description=TigerVNC server (localhost only) for $VNC_USER
After=syslog.target network.target

[Service]
Type=forking
User=$VNC_USER
PAMName=login
PIDFile=$VNC_HOME/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -geometry 1024x768 -depth 16 -dpi 96 -localhost yes :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable vncserver@1.service
sudo systemctl start vncserver@1

# --- Google Chrome (signed-by keyring, not deprecated apt-key) -------------

sudo apt install -y wget gnupg
sudo install -m 0755 -d /etc/apt/keyrings
wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
    | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
sudo chmod a+r /etc/apt/keyrings/google-chrome.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
    | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
sudo apt update
sudo apt install -y google-chrome-stable

# Desktop launcher — no --no-sandbox needed now that we run as a normal user.
sudo -u "$VNC_USER" mkdir -p "$VNC_HOME/Desktop"
sudo tee "$VNC_HOME/Desktop/chrome.sh" > /dev/null <<'EOF'
#!/bin/bash
google-chrome-stable https://ramses.kr/ip
EOF
sudo chmod +x "$VNC_HOME/Desktop/chrome.sh"
sudo chown -R "$VNC_USER:$VNC_USER" "$VNC_HOME/Desktop"

# --- how to connect --------------------------------------------------------

cat <<EOF

Done. VNC for '$VNC_USER' is listening on localhost:5901 only (display :1).
It is NOT reachable from the internet. Connect from your local machine via an
SSH tunnel:

  ssh -L 5901:localhost:5901 <your-ssh-user>@<server-ip>

then point your VNC client at:  localhost:5901
EOF
