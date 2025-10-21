# EarnApp with GOST Proxy - Deployment Guide

This guide provides step-by-step instructions for deploying EarnApp with GOST proxy integration.

## Prerequisites

Before you begin, ensure you have:

- [ ] Docker Engine installed
- [ ] Docker Compose installed
- [ ] Access to a SOCKS5 proxy server
- [ ] Proxy server address, username, and password
- [ ] EarnApp UUIDs for each container you want to deploy

## Step-by-Step Deployment

### Step 1: Clone or Download Repository

```bash
git clone <repository-url>
cd <repository-directory>
```

### Step 2: Prepare Container Configuration

Create a `containers.txt` file with your container configurations. You can use the example file as a template:

```bash
cp containers.txt.example containers.txt
```

Edit `containers.txt` with your actual configuration:

```csv
HOSTNAME,PROXY_IP,UUID
earnapp-node-1,10.0.0.10,sdk-node-abc123def456
earnapp-node-2,10.0.0.11,sdk-node-ghi789jkl012
earnapp-node-3,10.0.0.12,sdk-node-mno345pqr678
```

**Important:**
- Each line represents one container
- PROXY_IP must be within the subnet defined in the network (default: 10.0.0.0/24)
- UUID must be unique for each container

### Step 3: Generate UUIDs (if needed)

If you need to generate new EarnApp UUIDs:

```bash
# Generate a single UUID
echo -n sdk-node- && head -c 1024 /dev/urandom | md5sum | tr -d ' -'

# Generate multiple UUIDs
for i in {1..5}; do echo -n sdk-node- && head -c 1024 /dev/urandom | md5sum | tr -d ' -'; done
```

### Step 4: Set Proxy Configuration

Set your proxy configuration as environment variables or prepare to pass them to the generator script:

```bash
export PROXY_ADDR="192.168.1.100:1080"
export PROXY_USERNAME="your-username"
export PROXY_PASSWORD="your-password"
export TIMEZONE="Europe/London"
```

### Step 5: Generate Docker Compose File

Run the generator script to create your `docker-compose.yml`:

```bash
./generate-compose.sh containers.txt "$PROXY_ADDR" "$PROXY_USERNAME" "$PROXY_PASSWORD" "$TIMEZONE" > docker-compose.yml
```

Or with inline values:

```bash
./generate-compose.sh containers.txt 192.168.1.100:1080 myuser mypass Europe/London > docker-compose.yml
```

### Step 6: Review Generated Configuration

Review the generated `docker-compose.yml` to ensure all settings are correct:

```bash
cat docker-compose.yml
```

Verify:
- [ ] All hostnames are correct
- [ ] IP addresses are unique and within subnet
- [ ] UUIDs are present for each service
- [ ] Proxy credentials are correct
- [ ] Timezone is set correctly

### Step 7: Pull Docker Image

Pull the latest image from Docker Hub:

```bash
docker-compose pull
```

### Step 8: Deploy Containers

Start all containers in detached mode:

```bash
docker-compose up -d
```

### Step 9: Verify Deployment

Check that all containers are running:

```bash
docker-compose ps
```

View logs from all containers:

```bash
docker-compose logs
```

View logs from a specific container:

```bash
docker-compose logs earnapp-node-1
```

### Step 10: Verify Services Inside Container

Connect to a container and verify services:

```bash
# Check running processes
docker exec earnapp-node-1 ps aux

# Check GOST is running
docker exec earnapp-node-1 pgrep -f gost

# Check EarnApp is running
docker exec earnapp-node-1 pgrep -f earnapp

# View GOST logs
docker exec earnapp-node-1 tail -f /var/log/gost.log

# View EarnApp logs
docker exec earnapp-node-1 tail -f /var/log/earnapp.log
```

### Step 11: Verify Network Connectivity

Test that traffic is routed through the proxy:

```bash
# Check iptables rules
docker exec earnapp-node-1 iptables -t nat -L OUTPUT -n -v

# Test external IP (should show proxy IP if configured correctly)
docker exec earnapp-node-1 curl https://ifconfig.me
```

### Step 12: Register EarnApp Devices

For each container, register the device with EarnApp:

1. Get the UUID from your `containers.txt` file
2. Visit: `https://earnapp.com/r/sdk-node-<your-uuid>`
3. Complete the registration process

Example:
```
https://earnapp.com/r/sdk-node-abc123def456
```

## Post-Deployment Monitoring

### Monitor Container Status

```bash
# View all container statuses
docker-compose ps

# View container resource usage
docker stats

# View logs continuously
docker-compose logs -f
```

### Check Automatic Restarts

Services are configured to restart every 2 hours. Check restart logs:

```bash
# View EarnApp restart logs
docker exec earnapp-node-1 cat /var/log/earnapp-restart.log

# View GOST restart logs
docker exec earnapp-node-1 cat /var/log/gost-restart.log
```

### Check Cron Jobs

Verify crontab is configured:

```bash
docker exec earnapp-node-1 cat /etc/cron.d/service-restarts
```

## Managing Deployment

### Stop All Containers

```bash
docker-compose stop
```

### Start All Containers

```bash
docker-compose start
```

### Restart All Containers

```bash
docker-compose restart
```

### Stop and Remove All Containers

```bash
docker-compose down
```

### Stop and Remove All Containers + Volumes

```bash
docker-compose down -v
```

### Update Containers

```bash
# Pull latest image
docker-compose pull

# Recreate containers with new image
docker-compose up -d
```

## Scaling Deployment

### Adding New Containers

1. Add new entries to `containers.txt`:
   ```csv
   earnapp-node-4,10.0.0.13,sdk-node-new123uuid456
   ```

2. Regenerate docker-compose.yml:
   ```bash
   ./generate-compose.sh containers.txt "$PROXY_ADDR" "$PROXY_USERNAME" "$PROXY_PASSWORD" "$TIMEZONE" > docker-compose.yml
   ```

3. Apply changes:
   ```bash
   docker-compose up -d
   ```

### Removing Containers

1. Remove entries from `containers.txt`
2. Regenerate docker-compose.yml
3. Apply changes:
   ```bash
   docker-compose up -d
   ```
4. Remove old containers:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

## Troubleshooting

### Container Won't Start

Check logs:
```bash
docker-compose logs earnapp-node-1
```

Common issues:
- Missing environment variables
- Invalid UUID
- Proxy server unreachable
- IP address conflict

### GOST Proxy Not Working

```bash
# Check if GOST is running
docker exec earnapp-node-1 pgrep -f gost

# View GOST logs
docker exec earnapp-node-1 cat /var/log/gost.log

# Test GOST manually
docker exec earnapp-node-1 /scripts/restart-gost.sh
```

### EarnApp Not Working

```bash
# Check if EarnApp is running
docker exec earnapp-node-1 pgrep -f earnapp

# View EarnApp logs
docker exec earnapp-node-1 cat /var/log/earnapp.log

# Restart EarnApp manually
docker exec earnapp-node-1 /scripts/restart-earnapp.sh
```

### iptables Issues

```bash
# View current iptables rules
docker exec earnapp-node-1 iptables -t nat -L OUTPUT -n -v

# Reset and reapply iptables rules
docker exec earnapp-node-1 /scripts/setup-iptables.sh
docker exec earnapp-node-1 iptables-save > /etc/iptables/rules.v4
```

### Network Issues

```bash
# Check container network
docker network inspect earnapp_network

# Check container IP
docker inspect earnapp-node-1 | grep IPAddress

# Test connectivity
docker exec earnapp-node-1 ping -c 3 8.8.8.8
```

## Best Practices

1. **Security:**
   - Use strong proxy passwords
   - Regularly update Docker images
   - Monitor container logs for suspicious activity

2. **Reliability:**
   - Use `restart: unless-stopped` policy
   - Monitor container health
   - Set up automated backups of configuration files

3. **Performance:**
   - Distribute containers across multiple hosts if deploying many instances
   - Monitor resource usage with `docker stats`
   - Adjust restart schedules if needed

4. **Maintenance:**
   - Keep configuration files in version control
   - Document any customizations
   - Test updates in staging environment first

## Support

For issues and questions:
- Check container logs: `docker-compose logs`
- Review transform.md specifications
- Check GOST documentation: https://github.com/go-gost/gost
- Check EarnApp documentation: https://earnapp.com

---

**Last Updated:** 2025-10-21
