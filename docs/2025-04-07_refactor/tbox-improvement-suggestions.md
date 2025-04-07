# TBox Docker Environment Improvement Suggestions

Here are specific solutions for each of the identified pain points in the current docker-compose setup:

## 1. Fuseki Stability Issues

**Solutions:**
- Replace the custom lock file cleanup scripts with a proper init system in the container
- Use Docker's `init: true` flag (already present but ensure it's working)
- Implement a proper entrypoint script that handles graceful shutdown:

```dockerfile
# In Dockerfile or docker-compose.yml
STOPSIGNAL SIGINT
```

```bash
# In entrypoint.sh
trap 'echo "Shutting down gracefully..."; kill -TERM $PID; wait $PID' SIGTERM SIGINT
/path/to/fuseki/command "$@" &
PID=$!
wait $PID
```

- Update to the latest Fuseki version (5.3.0+) with improved locking mechanisms

## 2. Permission Problems

**Solutions:**
- Use Docker named volumes instead of host bind mounts for database files:

```yaml
volumes:
  fuseki_data:
    driver: local

services:
  fuseki:
    volumes:
      - fuseki_data:/fuseki/databases
      - ./config/fuseki:/fuseki/configuration:ro
```

- If bind mounts are necessary, use a non-root user with explicit UID/GID:

```yaml
services:
  fuseki:
    user: "1000:1000"  # Match host user/group IDs
    volumes:
      - ./data/fuseki:/fuseki/databases
```

- Fix the container's entrypoint to properly set permissions once at startup rather than with chmod 777

## 3. Complex Restart Process

**Solutions:**
- Implement proper health checks for all services (some already exist)
- Use Docker Compose's `restart: unless-stopped` policy (already implemented for some services)
- Create a single management script with clear commands:

```bash
#!/bin/bash
case "$1" in
  start)
    docker-compose up -d
    ;;
  stop)
    docker-compose down
    ;;
  restart)
    docker-compose restart
    ;;
  rebuild)
    docker-compose down
    docker-compose build --no-cache
    docker-compose up -d
    ;;
  clean)
    docker-compose down --volumes
    docker-compose build --no-cache
    docker-compose up -d
    ;;
  status)
    docker-compose ps
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|rebuild|clean|status}"
    exit 1
esac
```

## 4. Configuration Duplication

**Solutions:**
- Use a single configuration source:

```yaml
services:
  fuseki:
    volumes:
      - ./config/fuseki:/fuseki/configuration:ro
    environment:
      - FUSEKI_CONFIG_FILE=/fuseki/configuration/config.ttl
```

- Separate static configuration from runtime-generated files:

```yaml
volumes:
  fuseki_runtime:

services:
  fuseki:
    volumes:
      - ./config/fuseki:/fuseki/configuration:ro  # Static config
      - fuseki_runtime:/fuseki/run                # Runtime files
```

## 5. Manual Intervention Required

**Solutions:**
- Create Docker Compose profiles for different scenarios:

```yaml
services:
  fuseki:
    profiles: ["default", "minimal", "full"]
  
  xmpp:
    profiles: ["full"]
```

- Use environment files for configuration:

```yaml
services:
  fuseki:
    env_file: ./config/fuseki.env
```

- Implement proper logging with log rotation:

```yaml
services:
  fuseki:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## 6. No Automated Recovery

**Solutions:**
- Implement comprehensive health checks for all services:

```yaml
services:
  fuseki:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3030/$/ping"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

- Use Docker Compose dependency management with condition:

```yaml
services:
  app:
    depends_on:
      fuseki:
        condition: service_healthy
```

- Implement a proper monitor service with auto-recovery capabilities:

```yaml
services:
  monitor:
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    command: ["node", "src/index.js", "--auto-restart"]
```

These improvements should significantly reduce maintenance overhead and increase the stability of your TBox environment.
