# TBox Implementation Guide

## 1. Profile Configuration

```yaml
version: "3"

x-common-config: &common-config
  networks:
    - tbox_net
  depends_on:
    nginx:
      condition: service_healthy
      
services:
  nginx:
    image: nginx:alpine
    profiles: ["dev", "prod"]
    ports:
      - "80:80"
      - "443:443"
    networks:
      - tbox_net
    volumes:
      - ssl_certs:/etc/nginx/certs
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 10s
      retries: 3

  app:
    <<: *common-config
    profiles: ["dev", "prod"]
    build: 
      context: .
      args:
        ENV: ${ENV:-dev}

  fuseki:
    <<: *common-config
    profiles: ["dev", "prod"]
    volumes:
      - fuseki_data:/fuseki/databases

  xmpp:
    <<: *common-config
    profiles: ["dev", "prod"]
    volumes:
      - prosody_data:/var/lib/prosody

  monitor:
    <<: *common-config
    profiles: ["dev", "prod"]
    build: ./monitor

networks:
  tbox_net:
    driver: bridge

volumes:
  fuseki_data:
    driver: local
  prosody_data:
    driver: local
  ssl_certs:
    driver: local
```

## 2. Running Profiles

Development:
```bash
ENV=dev docker-compose --profile dev up -d
```

Production:
```bash
ENV=prod docker-compose --profile prod up -d
```

## 3. Service Dependencies 

Dependencies are managed through:
1. `depends_on` with health checks
2. Common network configuration
3. Shared environment variables
4. Health check on nginx as primary entrypoint

All services wait for nginx to be healthy before starting, preventing connection issues.

The monitor service checks other services' health continuously after startup.