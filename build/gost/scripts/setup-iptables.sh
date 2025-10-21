#!/bin/bash

echo "Configuring iptables for transparent proxy..."

# Flush existing NAT rules
iptables -t nat -F OUTPUT 2>/dev/null || true

# GOST proxy listens on port 1080
GOST_PORT=1080

# GOST user UID (to prevent proxy loops)
GOST_UID=42069

# Rule 1: Allow traffic from gost user to bypass redirect (prevent loops)
iptables -t nat -A OUTPUT -m owner --uid-owner $GOST_UID -j RETURN

# Rule 2: Allow local traffic to bypass redirect
iptables -t nat -A OUTPUT -d 127.0.0.0/8 -j RETURN
iptables -t nat -A OUTPUT -d 10.0.0.0/8 -j RETURN
iptables -t nat -A OUTPUT -d 172.16.0.0/12 -j RETURN
iptables -t nat -A OUTPUT -d 192.168.0.0/16 -j RETURN

# Rule 3: Redirect all TCP traffic to GOST proxy
iptables -t nat -A OUTPUT -p tcp -j REDIRECT --to-ports $GOST_PORT

echo "iptables rules configured:"
iptables -t nat -L OUTPUT -n -v
