# EarnApp with GOST Proxy Integration

This is a containerized version of [BrightData's EarnApp](https://earnapp.com/) with integrated GOST transparent proxy support for automated container management and deployment.

## Overview

This Docker image combines:
- **EarnApp** - BrightData's bandwidth sharing application
- **GOST Proxy** (v3.2.5) - Transparent proxy for routing container traffic
- **Crontab** - Automated service restarts every 2 hours
- **iptables** - Traffic redirection through GOST proxy
- All services running in a single Ubuntu-based container

## Features

- ✅ Transparent proxy routing via GOST
- ✅ Automated service restarts (EarnApp & GOST every 2 hours)
- ✅ Multi-container deployment with static IP assignments
- ✅ Configurable proxy server with authentication
- ✅ Automated docker-compose.yml generation from configuration file

## Prerequisites

- Docker Engine
- Docker Compose
- Access to proxy server (SOCKS5)

## Quick Start

### 1. Prepare Configuration File

Create a `containers.txt` file with your container configurations:

```csv
HOSTNAME,PROXY_IP,UUID
earnapp-node-1,10.0.0.10,sdk-node-abc123def456
earnapp-node-2,10.0.0.11,sdk-node-ghi789jkl012
earnapp-node-3,10.0.0.12,sdk-node-mno345pqr678
```

**Format:**
- **HOSTNAME**: Container hostname (e.g., `earnapp-node-1`)
- **PROXY_IP**: Static IP address for container (e.g., `10.0.0.10`)
- **UUID**: EarnApp UUID (e.g., `sdk-node-abc123def456`)

### 2. Generate Docker Compose File

Use the generator script to create your `docker-compose.yml`:

```bash
./generate-compose.sh containers.txt [ADDR] [USERNAME] [PASSWORD] [TIMEZONE] > docker-compose.yml
```

**Parameters:**
- `containers.txt` - Path to your configuration file (required)
- `ADDR` - Proxy server address with port (default: `192.168.1.100:1080`)
- `USERNAME` - Proxy authentication username (default: `myuser`)
- `PASSWORD` - Proxy authentication password (default: `mypass123`)
- `TIMEZONE` - Container timezone (default: `Europe/London`)

**Example:**
```bash
./generate-compose.sh containers.txt 192.168.1.100:1080 proxyuser secretpass Europe/London > docker-compose.yml
```

### 3. Deploy Containers

Start all containers:

```bash
docker-compose up -d
```

### 4. Monitor Services

View logs:
```bash
docker-compose logs -f
```

Check running processes in a container:
```bash
docker exec earnapp-node-1 ps aux
```

View GOST logs:
```bash
docker exec earnapp-node-1 cat /var/log/gost.log
```

View EarnApp logs:
```bash
docker exec earnapp-node-1 cat /var/log/earnapp.log
```

## Environment Variables

All environment variables are configured in the generated `docker-compose.yml`:

| Variable | Description | Example |
|----------|-------------|---------|
| `ADDR` | Proxy server IP with port | `192.168.1.100:1080` |
| `USERNAME` | Proxy authentication username | `myuser` |
| `PASSWORD` | Proxy authentication password | `mypass123` |
| `TIMEZONE` | Container timezone | `Europe/London` |
| `HOSTNAME` | Container hostname | `earnapp-node-1` |
| `UUID` | EarnApp UUID | `sdk-node-abc123def456` |
| `PROXY_IP` | IP address for this container | `10.0.0.10` |

## How to Get EarnApp UUID

1. Generate a UUID (32 characters lowercase alphanumeric):
   ```bash
   echo -n sdk-node- && head -c 1024 /dev/urandom | md5sum | tr -d ' -'
   ```
   
   **Example output:**  
   `sdk-node-0123456789abcdeffedcba9876543210`

2. Start the container with the UUID, then register your device:
   ```
   https://earnapp.com/r/sdk-node-0123456789abcdeffedcba9876543210
   ```

## Architecture Details

### Container Structure
Each container runs:
- EarnApp application
- GOST proxy (running as user `gost` with UID 42069)
- Cron daemon for scheduled restarts
- iptables rules for traffic redirection

### Service Restart Schedule
Both services restart independently every 2 hours:
- EarnApp: `0 */2 * * *`
- GOST: `0 */2 * * *`

### Network Configuration
- Custom bridge network: `earnapp_network`
- Default subnet: `10.0.0.0/24`
- Static IP assignment per container
- Privileged mode required for iptables

### Traffic Redirection
All outbound TCP traffic is redirected through GOST proxy using iptables:
- Exception: Traffic from `gost` user (UID 42069) bypasses redirect
- Exception: Local network traffic (127.0.0.0/8, 10.0.0.0/8, etc.)

## Building the Image

> **Note:** This project uses a pre-built image (`killermantv/gostprod:latest`). 
> The Dockerfile is provided for reference and customization.

To build the image manually:

```bash
cd build/gost
docker build -t killermantv/gostprod:latest .
```

To push to Docker Hub:

```bash
docker push killermantv/gostprod:latest
```

## Directory Structure

```
/workspace/
├── build/gost/
│   ├── Dockerfile              # Image build configuration
│   ├── scripts/
│   │   ├── entrypoint.sh       # Container startup orchestration
│   │   ├── restart-earnapp.sh  # EarnApp restart logic
│   │   ├── restart-gost.sh     # GOST restart logic
│   │   └── setup-iptables.sh   # iptables configuration
│   └── README.md               # This file
├── generate-compose.sh         # Docker Compose generator
├── containers.txt.example      # Example configuration
└── docker-compose.yml.example  # Example generated compose file
```

## Container Internals

### Directory Structure (inside container)
```
/opt/earnapp/          # EarnApp installation
/opt/gost/             # GOST proxy binary
/scripts/              # Service management scripts
  ├── entrypoint.sh
  ├── restart-earnapp.sh
  ├── restart-gost.sh
  └── setup-iptables.sh
/etc/earnapp/          # EarnApp configuration
/var/log/              # Service logs
```

### Startup Sequence
1. Set timezone and hostname
2. Validate environment variables
3. Configure iptables rules
4. Save iptables configuration
5. Start GOST proxy
6. Start EarnApp
7. Setup crontab for restarts
8. Start cron daemon
9. Keep container running

## Troubleshooting

### Check if GOST is running
```bash
docker exec earnapp-node-1 pgrep -f gost
```

### Check if EarnApp is running
```bash
docker exec earnapp-node-1 pgrep -f earnapp
```

### View iptables rules
```bash
docker exec earnapp-node-1 iptables -t nat -L OUTPUT -n -v
```

### Test proxy connectivity
```bash
docker exec earnapp-node-1 curl -x socks5://localhost:1080 https://ifconfig.me
```

### Restart services manually
```bash
# Restart GOST
docker exec earnapp-node-1 /scripts/restart-gost.sh

# Restart EarnApp
docker exec earnapp-node-1 /scripts/restart-earnapp.sh
```

## Security Considerations

- **Privileged Mode**: Required for iptables manipulation. Consider using `cap_add: NET_ADMIN` as alternative.
- **Credentials**: Proxy credentials passed via environment variables. Consider using Docker secrets for production.
- **User Isolation**: GOST runs as non-root user (UID 42069) to prevent proxy traffic loops.

## References

- Original Project: [EarnApp-Docker](https://github.com/madereddy/EarnApp-Docker)
- GOST Proxy: [go-gost/gost](https://github.com/go-gost/gost)
- GOST Version: v3.2.5
- EarnApp: [earnapp.com](https://earnapp.com/)

## Credits

- [@fazalfarhan01](https://github.com/fazalfarhan01/EarnApp-Docker)
- [@cwlu2001](https://github.com/cwlu2001/EarnApp-Docker-lite)
- [@madereddy](https://github.com/madereddy/EarnApp-Docker)

## License

This is an unofficial containerized implementation. Use at your own risk.

---

**Last Updated:** 2025-10-21
