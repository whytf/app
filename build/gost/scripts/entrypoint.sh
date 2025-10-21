#!/bin/bash
set -e

echo "====================================="
echo "EarnApp with GOST Proxy - Starting"
echo "====================================="

# Set timezone
if [ -n "$TIMEZONE" ]; then
    echo "Setting timezone to: $TIMEZONE"
    ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    echo $TIMEZONE > /etc/timezone
else
    echo "No timezone specified, using UTC"
fi

# Set hostname
if [ -n "$HOSTNAME" ]; then
    echo "Setting hostname to: $HOSTNAME"
    echo "$HOSTNAME" > /etc/hostname
    hostname "$HOSTNAME"
fi

# Validate required environment variables
if [ -z "$UUID" ]; then
    echo "ERROR: UUID environment variable is required"
    exit 1
fi

if [ -z "$ADDR" ]; then
    echo "ERROR: ADDR environment variable is required (proxy server address)"
    exit 1
fi

if [ -z "$USERNAME" ]; then
    echo "ERROR: USERNAME environment variable is required (proxy username)"
    exit 1
fi

if [ -z "$PASSWORD" ]; then
    echo "ERROR: PASSWORD environment variable is required (proxy password)"
    exit 1
fi

# Setup iptables rules for traffic redirection
echo "Setting up iptables rules..."
/scripts/setup-iptables.sh

# Save iptables configuration
echo "Saving iptables configuration..."
iptables-save > /etc/iptables/rules.v4

# Start GOST proxy
echo "Starting GOST proxy..."
/scripts/restart-gost.sh

# Wait a moment for GOST to initialize
sleep 2

# Start EarnApp
echo "Starting EarnApp with UUID: $UUID"
/scripts/restart-earnapp.sh

# Setup crontab for service restarts (every 2 hours)
echo "Setting up crontab for service restarts..."
cat > /etc/cron.d/service-restarts << EOF
# Restart EarnApp every 2 hours
0 */2 * * * root /scripts/restart-earnapp.sh >> /var/log/earnapp-restart.log 2>&1

# Restart GOST proxy every 2 hours
0 */2 * * * root /scripts/restart-gost.sh >> /var/log/gost-restart.log 2>&1
EOF

chmod 0644 /etc/cron.d/service-restarts

# Start cron daemon
echo "Starting cron daemon..."
cron

echo "====================================="
echo "All services started successfully!"
echo "====================================="
echo "GOST Proxy: Running as user 'gost' (UID 42069)"
echo "EarnApp: Running with UUID $UUID"
echo "Proxy Server: $ADDR"
echo "Timezone: ${TIMEZONE:-UTC}"
echo "Hostname: ${HOSTNAME:-default}"
echo "====================================="

# Keep container running and tail logs
tail -f /var/log/earnapp-restart.log /var/log/gost-restart.log 2>/dev/null &

# Wait for any process to exit
wait
