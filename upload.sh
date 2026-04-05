#!/bin/bash

# -----------------------------
# Configuration (edit these)
# -----------------------------
SERVER="92.113.151.200"
USER="b"                     # SSH user
REMOTE_XRAY_DIR="/home/$USER/xray"
LOCAL_XRAY_BINARY="./xray"   # path to your compiled binary
LOCAL_CONFIG="config.json" # path to your config.json
LOCAL_SERVICE="xray.service" # path to systemd service file
SSH_PORT=22                  # change if you use non-default SSH port
# -----------------------------

echo "Uploading Xray files to $USER@$SERVER..."

# 1️⃣ Create remote folder
ssh -p $SSH_PORT $USER@$SERVER "mkdir -p $REMOTE_XRAY_DIR"

# 2️⃣ Upload files
scp -P $SSH_PORT "$LOCAL_XRAY_BINARY" "$USER@$SERVER:$REMOTE_XRAY_DIR/"
scp -P $SSH_PORT "$LOCAL_CONFIG" "$USER@$SERVER:$REMOTE_XRAY_DIR/"
scp -P $SSH_PORT "$LOCAL_SERVICE" "$USER@$SERVER:~/xray.service.tmp"

# 3️⃣ Move service to systemd folder
ssh -p $SSH_PORT $USER@$SERVER "sudo mv ~/xray.service.tmp /etc/systemd/system/xray.service"

# 4️⃣ Set permissions
ssh -p $SSH_PORT $USER@$SERVER "chmod +x $REMOTE_XRAY_DIR/xray; chmod 600 $REMOTE_XRAY_DIR/config.json"

# 5️⃣ Reload systemd and start service
ssh -p $SSH_PORT $USER@$SERVER "
sudo systemctl daemon-reload &&
sudo systemctl enable xray &&
sudo systemctl start xray &&
sudo systemctl status xray --no-pager
"

echo "✅ Deployment finished. Xray should be running now."