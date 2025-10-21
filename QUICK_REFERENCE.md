# Quick Reference - EarnApp with GOST Proxy

## 🚀 Quick Commands

### Initial Setup
```bash
# 1. Copy example configuration
cp containers.txt.example containers.txt

# 2. Edit with your details
nano containers.txt

# 3. Generate docker-compose.yml
./generate-compose.sh containers.txt [PROXY_ADDR] [USERNAME] [PASSWORD] [TIMEZONE] > docker-compose.yml

# 4. Deploy
docker-compose up -d
```

### Container Management
```bash
# Start all containers
docker-compose up -d

# Stop all containers
docker-compose stop

# Restart all containers
docker-compose restart

# Remove all containers
docker-compose down

# Remove containers and volumes
docker-compose down -v

# Pull latest image
docker-compose pull

# Update containers with new image
docker-compose pull && docker-compose up -d
```

### Monitoring
```bash
# View all container status
docker-compose ps

# View logs (all containers)
docker-compose logs -f

# View logs (specific container)
docker-compose logs -f earnapp-node-1

# View container resource usage
docker stats

# Check running processes in container
docker exec earnapp-node-1 ps aux
```

### Service Management
```bash
# Check if GOST is running
docker exec earnapp-node-1 pgrep -f gost

# Check if EarnApp is running
docker exec earnapp-node-1 pgrep -f earnapp

# Manually restart GOST
docker exec earnapp-node-1 /scripts/restart-gost.sh

# Manually restart EarnApp
docker exec earnapp-node-1 /scripts/restart-earnapp.sh
```

### Log Viewing
```bash
# View GOST logs
docker exec earnapp-node-1 tail -f /var/log/gost.log

# View EarnApp logs
docker exec earnapp-node-1 tail -f /var/log/earnapp.log

# View GOST restart logs
docker exec earnapp-node-1 cat /var/log/gost-restart.log

# View EarnApp restart logs
docker exec earnapp-node-1 cat /var/log/earnapp-restart.log
```

### Network Troubleshooting
```bash
# View iptables rules
docker exec earnapp-node-1 iptables -t nat -L OUTPUT -n -v

# Check container IP
docker inspect earnapp-node-1 | grep IPAddress

# Inspect network
docker network inspect earnapp_network

# Test external IP (should show proxy IP)
docker exec earnapp-node-1 curl https://ifconfig.me

# Test DNS resolution
docker exec earnapp-node-1 nslookup google.com

# Ping test
docker exec earnapp-node-1 ping -c 3 8.8.8.8
```

### Configuration Verification
```bash
# View container environment variables
docker exec earnapp-node-1 env

# Check crontab configuration
docker exec earnapp-node-1 cat /etc/cron.d/service-restarts

# Check hostname
docker exec earnapp-node-1 hostname

# Check timezone
docker exec earnapp-node-1 date
```

## 📋 Configuration File Format

### containers.txt
```csv
HOSTNAME,PROXY_IP,UUID
earnapp-node-1,10.0.0.10,sdk-node-abc123def456
earnapp-node-2,10.0.0.11,sdk-node-ghi789jkl012
earnapp-node-3,10.0.0.12,sdk-node-mno345pqr678
```

## 🔑 Generate UUID

```bash
# Single UUID
echo -n sdk-node- && head -c 1024 /dev/urandom | md5sum | tr -d ' -'

# Multiple UUIDs
for i in {1..5}; do 
  echo -n sdk-node- && head -c 1024 /dev/urandom | md5sum | tr -d ' -'
done
```

## 🌐 Environment Variables

| Variable | Required | Default | Example |
|----------|----------|---------|---------|
| ADDR | ✅ | - | `192.168.1.100:1080` |
| USERNAME | ✅ | - | `myuser` |
| PASSWORD | ✅ | - | `mypass123` |
| TIMEZONE | ❌ | UTC | `Europe/London` |
| HOSTNAME | ✅ | - | `earnapp-node-1` |
| UUID | ✅ | - | `sdk-node-abc123` |
| PROXY_IP | ✅ | - | `10.0.0.10` |

## 🏗️ Build Image

```bash
cd build/gost
docker build -t killermantv/gostprod:latest .
docker push killermantv/gostprod:latest
```

## 📁 Important Paths

### Host
- `./containers.txt` - Container configuration
- `./docker-compose.yml` - Generated compose file
- `./generate-compose.sh` - Compose generator script

### Container
- `/opt/gost/gost` - GOST binary
- `/usr/bin/earnapp` - EarnApp binary
- `/scripts/` - Service scripts
- `/etc/earnapp/` - EarnApp config
- `/var/log/gost.log` - GOST logs
- `/var/log/earnapp.log` - EarnApp logs

## 🔧 Common Issues

### Container won't start
```bash
# Check logs
docker-compose logs earnapp-node-1

# Verify environment variables
docker-compose config
```

### Proxy not working
```bash
# Check GOST is running
docker exec earnapp-node-1 pgrep -f gost

# Check GOST logs
docker exec earnapp-node-1 cat /var/log/gost.log

# Restart GOST
docker exec earnapp-node-1 /scripts/restart-gost.sh
```

### EarnApp not connecting
```bash
# Check EarnApp is running
docker exec earnapp-node-1 pgrep -f earnapp

# Check EarnApp logs
docker exec earnapp-node-1 cat /var/log/earnapp.log

# Restart EarnApp
docker exec earnapp-node-1 /scripts/restart-earnapp.sh
```

### IP conflict
```bash
# Check network
docker network inspect earnapp_network

# Ensure IPs in containers.txt are unique
# Ensure IPs are within subnet (default: 10.0.0.0/24)
```

## 🔗 Register Device

After starting container, register at:
```
https://earnapp.com/r/sdk-node-<your-uuid>
```

Example:
```
https://earnapp.com/r/sdk-node-abc123def456
```

## ⏰ Service Restart Schedule

Both services restart every 2 hours:
- **EarnApp:** `0 */2 * * *`
- **GOST:** `0 */2 * * *`

View schedule:
```bash
docker exec earnapp-node-1 cat /etc/cron.d/service-restarts
```

## 📖 Documentation

- **Complete Guide:** `build/gost/README.md`
- **Deployment:** `GOST_DEPLOYMENT.md`
- **Specifications:** `transform.md`
- **Implementation:** `IMPLEMENTATION_SUMMARY.md`

## 🆘 Get Help

1. Check documentation in repository
2. Review Docker logs
3. Verify configuration files
4. Check GOST documentation: https://github.com/go-gost/gost
5. Check EarnApp docs: https://earnapp.com

---

**Quick Reference v1.0** | Last Updated: 2025-10-21
