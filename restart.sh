#!/bin/bash
chmod -R 777 ./data/fuseki
docker-compose down
# --volumes  # Remove volumes - destructive
docker-compose build --no-cache  # Rebuild without cache
docker-compose up -d  # Start fresh

docker-compose logs
