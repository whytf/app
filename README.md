# EarnApp Docker
### UNOFFICIAL Containerized Docker Image for BrightData's [EarnApp](https://earnapp.com/)

## 📦 Available Versions

This repository contains two versions:

### 1. **Lite Version** (Original)
Simple, lightweight EarnApp container without proxy integration.
- Image: `madereddy/earnapp`
- Location: `build/lite/`
- Best for: Simple deployments without proxy requirements

### 2. **GOST Proxy Version** (New) ⭐
EarnApp with integrated GOST transparent proxy, automated restarts, and multi-container deployment support.
- Image: `killermantv/gostprod:latest`
- Location: `build/gost/`
- Best for: Advanced deployments requiring proxy routing and automated management

---

## 🚀 Quick Start

### Lite Version

via `docker-compose.yaml`:
```yaml
version: '3'
services:
  earnapp:
    image: madereddy/earnapp
    container_name: earnapp
    environment:
      - EARNAPP_UUID=sdk-node-0123456789abcdeffedcba9876543210
    restart: unless-stopped
```

### GOST Proxy Version

See detailed instructions in:
- **[GOST Build README](build/gost/README.md)** - Complete documentation
- **[GOST Deployment Guide](GOST_DEPLOYMENT.md)** - Step-by-step deployment

Quick deployment:
```bash
# 1. Prepare configuration
cp containers.txt.example containers.txt
# Edit containers.txt with your hostnames, IPs, and UUIDs

# 2. Generate docker-compose.yml
./generate-compose.sh containers.txt [PROXY_ADDR] [USERNAME] [PASSWORD] [TIMEZONE] > docker-compose.yml

# 3. Deploy
docker-compose up -d
```

---

## 🔑 How to Get UUID

1.  The UUID is 32 characters long with lowercase alphabet and numbers. You can either create this by yourself or via this command:
    ```bash
    echo -n sdk-node- && head -c 1024 /dev/urandom | md5sum | tr -d ' -'
    ```

    *Example output:*  
    `sdk-node-0123456789abcdeffedcba9876543210`

2.  Before registering your device, ensure that you pass the UUID into the container and start it first. Then proceed to register your device using the url:
    ```
    https://earnapp.com/r/UUID
    ```
    *Example URL:*  
    `https://earnapp.com/r/sdk-node-0123456789abcdeffedcba9876543210`

---

## 📚 Documentation

### Lite Version
- [Lite Dockerfile](build/lite/Dockerfile)
- Standard Docker deployment
- Simple setup

### GOST Proxy Version
- [GOST Build README](build/gost/README.md) - Architecture & features
- [GOST Deployment Guide](GOST_DEPLOYMENT.md) - Deployment instructions
- [Transform Specifications](transform.md) - Technical specifications

---

## 🌟 GOST Proxy Features

- ✅ **Transparent Proxy Routing** - All traffic routed through GOST SOCKS5 proxy
- ✅ **Automated Restarts** - EarnApp and GOST restart every 2 hours
- ✅ **Multi-Container Support** - Deploy multiple instances with unique IPs
- ✅ **Static IP Assignment** - Each container gets dedicated IP address
- ✅ **Automated Configuration** - Generate docker-compose.yml from simple text file
- ✅ **iptables Integration** - Transparent traffic redirection
- ✅ **Secure User Isolation** - GOST runs as non-root user (UID 42069)

---

## 📋 Available Tags

### Lite Version
+ `latest`
+ `1.xxx.xxx`

### GOST Proxy Version
+ `killermantv/gostprod:latest`

---

## 🏗️ Project Structure

```
.
├── build/
│   ├── lite/                  # Original lite version
│   │   ├── Dockerfile
│   │   └── src/
│   └── gost/                  # GOST proxy version
│       ├── Dockerfile
│       ├── README.md
│       └── scripts/
│           ├── entrypoint.sh
│           ├── restart-earnapp.sh
│           ├── restart-gost.sh
│           └── setup-iptables.sh
├── generate-compose.sh        # Docker Compose generator
├── containers.txt.example     # Example configuration
├── docker-compose.yml.example # Example generated compose
├── GOST_DEPLOYMENT.md        # Deployment guide
└── transform.md              # Technical specifications
```

---

## 🔧 Building Images

### Lite Version
```bash
cd build/lite
docker build -t madereddy/earnapp:latest .
```

### GOST Proxy Version
```bash
cd build/gost
docker build -t killermantv/gostprod:latest .
```

---

## 💡 Use Cases

### Use Lite Version When:
- Simple single-container deployment
- No proxy requirements
- Minimal setup needed

### Use GOST Proxy Version When:
- Need to route traffic through SOCKS5 proxy
- Deploying multiple containers with unique IPs
- Want automated service restarts
- Need transparent proxy integration
- Require advanced container management

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📝 Credit

- [@fazalfarhan01](https://github.com/fazalfarhan01/EarnApp-Docker)
- [@cwlu2001](https://github.com/cwlu2001/EarnApp-Docker-lite)
- [@madereddy](https://github.com/madereddy/EarnApp-Docker)

---

## ⚠️ Disclaimer

This is an unofficial containerized implementation of EarnApp. Use at your own risk.

---

## 📄 License

See individual project files for licensing information.

---

**Last Updated:** 2025-10-21
