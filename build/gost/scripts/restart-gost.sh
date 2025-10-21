#!/bin/bash

echo "[$(date)] Restarting GOST proxy..."

# Stop GOST if running
pkill -f gost || true
sleep 2

# Validate environment variables
if [ -z "$ADDR" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "[$(date)] ERROR: ADDR, USERNAME, and PASSWORD environment variables must be set"
    exit 1
fi

# Start GOST proxy as gost user
echo "[$(date)] Starting GOST proxy connecting to: $ADDR"
su - gost -c "nohup /opt/gost/gost -L=:1080 -F=socks5://$USERNAME:$PASSWORD@$ADDR >> /var/log/gost.log 2>&1 &"

# Wait a moment and check if process started
sleep 2
if pgrep -f gost > /dev/null; then
    echo "[$(date)] GOST proxy started successfully (PID: $(pgrep -f gost))"
else
    echo "[$(date)] ERROR: Failed to start GOST proxy"
    exit 1
fi
