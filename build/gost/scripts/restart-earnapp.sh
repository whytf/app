#!/bin/bash

echo "[$(date)] Restarting EarnApp..."

# Stop EarnApp if running
pkill -f earnapp || true
sleep 2

# Ensure UUID is set
if [ -z "$UUID" ]; then
    echo "[$(date)] ERROR: UUID environment variable not set"
    exit 1
fi

# Start EarnApp
echo "[$(date)] Starting EarnApp with UUID: $UUID"
nohup earnapp run "$UUID" >> /var/log/earnapp.log 2>&1 &

# Wait a moment and check if process started
sleep 2
if pgrep -f earnapp > /dev/null; then
    echo "[$(date)] EarnApp started successfully (PID: $(pgrep -f earnapp))"
else
    echo "[$(date)] ERROR: Failed to start EarnApp"
    exit 1
fi
