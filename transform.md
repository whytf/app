# EarnApp with GOST Proxy Integration - Project Specifications

## Overview
Transform the [EarnApp-Docker](https://github.com/madereddy/EarnApp-Docker) project to include GOST transparent proxy integration with automated container management and deployment.

## Architecture

### Container Structure
- **Single container per instance** containing:
  - EarnApp application
  - GOST proxy (v3.2.5)
  - Crontab for service restarts
  - iptables for traffic redirection
  - All services running in one Ubuntu-based container

### Base Image
- Source: `killermantv/gostprod:latest` (private Docker Hub repository)
- Base OS: Ubuntu (from original EarnApp-Docker project)
- Pre-built image (manual build process, not automated)

## Required Features

### 1. Service Management
**Crontab Configuration:**
- Restart EarnApp every 2 hours
- Restart GOST proxy every 2 hours
- Both services should restart independently

**Schedule Example:**
```
0 */2 * * * /restart-earnapp.sh
0 */2 * * * /restart-gost.sh
```

### 2. GOST Proxy Configuration
**User Setup:**
- Service runs as user: `gost`
- UID: `42069`
- GID: `42069` (recommended)

**Proxy Mode:**
- Transparent proxy configuration
- Route all container traffic through GOST

**Connection Details:**
- Proxy server address and port (configurable)
- Authentication support (username/password)

### 3. Network Traffic Redirection
**iptables Rules:**
- Redirect all outbound traffic through GOST proxy
- Implementation using `iptables-save` for persistence
- Rules should survive container restarts

**Typical Rule Structure:**
```bash
# Redirect all TCP traffic to GOST proxy
iptables -t nat -A OUTPUT -p tcp -j REDIRECT --to-ports <GOST_PORT>
# Except traffic from gost user (to prevent loops)
iptables -t nat -A OUTPUT -m owner --uid-owner 42069 -j RETURN
```

### 4. Environment Variables
Required variables for docker-compose configuration:

| Variable | Description | Example |
|----------|-------------|---------|
| `ADDR` | Proxy server IP with port | `192.168.1.100:1080` |
| `USERNAME` | Proxy authentication username | `myuser` |
| `PASSWORD` | Proxy authentication password | `mypass123` |
| `TIMEZONE` | Container timezone | `Europe/London` |
| `HOSTNAME` | Container hostname | `earnapp-node-1` |
| `UUID` | EarnApp UUID | `sdk-node-abc123def456` |
| `PROXY_IP` | IP address for this container | `10.0.0.10` |

**Note:** No `.env.example` file - all configuration via docker-compose.yml

## Deployment System

### Input Configuration File
**Format:** Text file with container configurations

**Structure:**
```
HOSTNAME,PROXY_IP,UUID
earnapp-node-1,10.0.0.10,sdk-node-abc123def456
earnapp-node-2,10.0.0.11,sdk-node-ghi789jkl012
earnapp-node-3,10.0.0.12,sdk-node-mno345pqr678
```

### Generator Script Requirements
**Script Name:** `generate-compose.sh` (or similar)

**Functionality:**
1. Read input text file with container configurations
2. Parse each line: hostname, IP address, UUID
3. Generate complete `docker-compose.yml` with:
   - One service per line in input file
   - Unique container names
   - Individual environment variable sets
   - Network configuration with specified IPs
   - Volume mappings (if needed)

**Output:** Single `docker-compose.yml` file ready for deployment

**Example Generated Service:**
```yaml
services:
  earnapp-node-1:
    image: killermantv/gostprod:latest
    container_name: earnapp-node-1
    hostname: earnapp-node-1
    environment:
      - ADDR=192.168.1.100:1080
      - USERNAME=myuser
      - PASSWORD=mypass123
      - TIMEZONE=Europe/London
      - HOSTNAME=earnapp-node-1
      - UUID=sdk-node-abc123def456
    networks:
      earnapp_network:
        ipv4_address: 10.0.0.10
    restart: unless-stopped
    privileged: true  # Required for iptables
    cap_add:
      - NET_ADMIN  # Required for network manipulation
```

## Container Internals

### Directory Structure
```
/opt/earnapp/          # EarnApp installation
/opt/gost/             # GOST proxy binary
/scripts/
  ├── entrypoint.sh    # Container startup script
  ├── restart-earnapp.sh
  ├── restart-gost.sh
  └── setup-iptables.sh
/etc/cron.d/           # Crontab configuration
```

### Startup Sequence (entrypoint.sh)
1. Create `gost` user with UID 42069
2. Configure timezone from `$TIMEZONE`
3. Set hostname from `$HOSTNAME`
4. Setup iptables rules using `$ADDR`
5. Save iptables configuration
6. Start GOST proxy with credentials
7. Start EarnApp with `$UUID`
8. Setup crontab for restarts
9. Keep container running

### GOST Configuration
**Command Example:**
```bash
su - gost -c "/opt/gost/gost -L=:1080 -F=socks5://$USERNAME:$PASSWORD@$ADDR"
```

### EarnApp Configuration
**Start Command:**
```bash
earnapp run -d $UUID
```

## Network Configuration

### Docker Network
- Custom bridge network: `earnapp_network`
- Subnet definition required for static IPs
- Example: `10.0.0.0/24`

### IP Address Assignment
- Each container gets unique IP from input file
- IPs must be within defined subnet
- No DHCP - all static assignments

## Security Considerations

### Privileged Mode
- Required for iptables manipulation
- Consider security implications
- Use `cap_add: NET_ADMIN` as alternative if possible

### Credentials
- Proxy credentials passed via environment variables
- Consider using Docker secrets for production
- No hardcoded credentials in image

### User Isolation
- GOST runs as non-root user (UID 42069)
- Prevents proxy traffic loops with iptables owner match

## Implementation Checklist

### Dockerfile Requirements
- [ ] Install EarnApp dependencies
- [ ] Download and install GOST v3.2.5 binary
- [ ] Create gost user with UID 42069
- [ ] Install iptables and iptables-persistent
- [ ] Install cron daemon
- [ ] Copy startup scripts
- [ ] Setup entrypoint script
- [ ] Configure proper permissions

### Script Requirements
- [ ] entrypoint.sh - Main startup orchestration
- [ ] restart-earnapp.sh - EarnApp restart logic
- [ ] restart-gost.sh - GOST restart logic
- [ ] setup-iptables.sh - iptables rule configuration
- [ ] generate-compose.sh - Docker compose generator

### Testing Requirements
- [ ] Verify GOST proxy connectivity
- [ ] Confirm traffic routing through proxy
- [ ] Test crontab restarts
- [ ] Validate iptables persistence
- [ ] Check multi-container deployment
- [ ] Verify unique hostnames/IPs per container

## Usage Workflow

### 1. Prepare Configuration
Create `containers.txt`:
```
node-1,10.0.0.10,sdk-node-abc123
node-2,10.0.0.11,sdk-node-def456
node-3,10.0.0.12,sdk-node-ghi789
```

### 2. Generate Docker Compose
```bash
./generate-compose.sh containers.txt > docker-compose.yml
```

### 3. Deploy Containers
```bash
docker-compose up -d
```

### 4. Monitor Services
```bash
docker-compose logs -f
docker exec earnapp-node-1 ps aux  # Check running processes
```

## Notes

- Manual image building process (not covered in this workflow)
- Image should be pushed to `killermantv/gostprod` repository
- Each deployment pulls latest image from registry
- No local Dockerfile in deployment repository
- Generator script is the only automation tool needed for deployment

## References

- Original Project: https://github.com/madereddy/EarnApp-Docker
- GOST Proxy: https://github.com/go-gost/gost
- GOST Version: v3.2.5
- Docker Hub: killermantv/gostprod (private)

---

**Document Version:** 1.0  
**Last Updated:** 2025-10-21
