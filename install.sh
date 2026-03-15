#!/bin/bash
set -e

echo "Installing qrencode..."
sudo apt update -y
sudo apt install -y qrencode

# 1️⃣ Create dedicated system user
sudo useradd -r -s /bin/false xray || echo "User xray already exists"

# 2️⃣ Create install directory
sudo mkdir -p /opt/xray
sudo chown xray:xray /opt/xray

# 3️⃣ Download Xray binary
XRAY_URL="https://raw.githubusercontent.com/berserkkv/xray/refs/heads/main/xray"
sudo wget -O /opt/xray/xray $XRAY_URL
sudo chmod +x /opt/xray/xray
sudo chown xray:xray /opt/xray/xray

# 4️⃣ Download config file
CONFIG_URL="https://raw.githubusercontent.com/berserkkv/xray/refs/heads/main/config.json"
sudo wget -O /opt/xray/config.json $CONFIG_URL
sudo chown xray:xray /opt/xray/config.json

# 5️⃣ Create systemd service file
sudo tee /etc/systemd/system/xray.service > /dev/null <<EOL
[Unit]
Description=Xray Service
After=network.target

[Service]
Type=simple
User=xray
WorkingDirectory=/opt/xray
ExecStart=/opt/xray/xray run -config /opt/xray/config.json
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOL

# 6️⃣ Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl enable xray
sudo systemctl start xray

# 7️⃣ Show status
sudo systemctl status xray --no-pager

echo "✅ Xray installed under /opt/xray and running as user xray"

# 8️⃣ Get external IP
SERVER_IP=$(curl -s https://api.ipify.org)

# 9️⃣ Generate VLESS connection string
UUID="6b75ec14-bdb8-401b-a034-31b86a37213e"
PORT="443"

VLESS_LINK="vless://${UUID}@${SERVER_IP}:${PORT}?type=tcp&security=none#xray-server"

echo ""
echo "✅ Xray installed under /opt/xray and running as user xray"
echo ""
echo "📡 Your VLESS connection link:"
echo "$VLESS_LINK"
echo ""
qrencode -t ANSIUTF8 "$VLESS_LINK"
echo ""

