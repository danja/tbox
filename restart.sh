#!/bin/bash

# chmod -R 777 ./data/fuseki

sudo systemctl stop tbox
cd ~/hyperdata/tbox # my local dir

docker-compose down

# docker-compose build --no-cache  # Rebuild without cache
# --volumes  # Remove volumes - destructive

docker-compose up -d

# docker-compose logs
