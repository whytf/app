#!/bin/bash

# Docker Compose Generator for EarnApp with GOST Proxy
# Usage: ./generate-compose.sh <containers.txt> [ADDR] [USERNAME] [PASSWORD] [TIMEZONE]

set -e

# Configuration file path
CONFIG_FILE="${1:-containers.txt}"

# Common environment variables (can be overridden by command-line arguments)
ADDR="${2:-192.168.1.100:1080}"
USERNAME="${3:-myuser}"
PASSWORD="${4:-mypass123}"
TIMEZONE="${5:-Europe/London}"

# Network configuration
NETWORK_NAME="earnapp_network"
SUBNET="10.0.0.0/24"

# Docker image
IMAGE="killermantv/gostprod:latest"

# Check if configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found!"
    echo ""
    echo "Usage: $0 <containers.txt> [ADDR] [USERNAME] [PASSWORD] [TIMEZONE]"
    echo ""
    echo "Example containers.txt format:"
    echo "HOSTNAME,PROXY_IP,UUID"
    echo "earnapp-node-1,10.0.0.10,sdk-node-abc123def456"
    echo "earnapp-node-2,10.0.0.11,sdk-node-ghi789jkl012"
    exit 1
fi

# Start generating docker-compose.yml
cat << EOF
version: '3.8'

networks:
  ${NETWORK_NAME}:
    driver: bridge
    ipam:
      config:
        - subnet: ${SUBNET}

services:
EOF

# Read configuration file and generate services
FIRST_LINE=true
while IFS=',' read -r hostname proxy_ip uuid; do
    # Skip empty lines
    if [ -z "$hostname" ]; then
        continue
    fi
    
    # Skip header line if present
    if [ "$hostname" = "HOSTNAME" ]; then
        continue
    fi
    
    # Trim whitespace
    hostname=$(echo "$hostname" | xargs)
    proxy_ip=$(echo "$proxy_ip" | xargs)
    uuid=$(echo "$uuid" | xargs)
    
    # Validate input
    if [ -z "$hostname" ] || [ -z "$proxy_ip" ] || [ -z "$uuid" ]; then
        echo "Warning: Skipping invalid line: $hostname,$proxy_ip,$uuid" >&2
        continue
    fi
    
    # Generate service definition
    cat << EOF
  ${hostname}:
    image: ${IMAGE}
    container_name: ${hostname}
    hostname: ${hostname}
    environment:
      - ADDR=${ADDR}
      - USERNAME=${USERNAME}
      - PASSWORD=${PASSWORD}
      - TIMEZONE=${TIMEZONE}
      - HOSTNAME=${hostname}
      - UUID=${uuid}
      - PROXY_IP=${proxy_ip}
    networks:
      ${NETWORK_NAME}:
        ipv4_address: ${proxy_ip}
    restart: unless-stopped
    privileged: true
    cap_add:
      - NET_ADMIN
    volumes:
      - ${hostname}_data:/etc/earnapp
EOF

done < "$CONFIG_FILE"

# Generate volumes section
echo ""
echo "volumes:"
FIRST_LINE=true
while IFS=',' read -r hostname proxy_ip uuid; do
    # Skip empty lines and header
    if [ -z "$hostname" ] || [ "$hostname" = "HOSTNAME" ]; then
        continue
    fi
    
    hostname=$(echo "$hostname" | xargs)
    
    if [ -n "$hostname" ]; then
        echo "  ${hostname}_data:"
    fi
done < "$CONFIG_FILE"

echo ""
echo "# Generated on $(date)" >&2
echo "# Configuration file: $CONFIG_FILE" >&2
echo "# Proxy server: $ADDR" >&2
echo "# Timezone: $TIMEZONE" >&2
