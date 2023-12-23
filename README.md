# EarnApp Docker
### UNOFFICIAL Containerized Docker Image for BrightData's [EarnApp](https://earnapp.com/)

## Available Tags
+ `latest`
+ `1.xxx.xxx`

## Run
via `docker-compose.yaml`:
```yaml
version: '3'
services:
  earnapp:
    image: cwlu2001/earnapp
    container_name: earnapp
    environment:
      - EARNAPP_UUID=sdk-node-0123456789abcdeffedcba9876543210
    restart: unless-stopped
```
 
## How to Get UUID
1.  The UUID is 32 characters long with lowercase alphabet and numbers. You can either create this by yourself or via this command:
    ```bash
    echo -n sdk-node- && head -c 1024 /dev/urandom | md5sum | tr -d ' -'
    ```

    *Example output* </br>
    *sdk-node-0123456789abcdeffedcba9876543210*

2.  Before registering your device, ensure that you pass the UUID into the container and start it first. Then proceed to register your device using the url:
    ```
    https://earnapp.com/r/UUID
    ```
    *Example url* </br>
    *h<span>ttps://earnapp.</span>com/r/sdk-node-0123456789abcdeffedcba9876543210*

## Credit
[@fazalfarhan01](https://github.com/fazalfarhan01/EarnApp-Docker)
