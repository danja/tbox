#!/bin/bash

# cd ~/hyperdata/tbox # my local dir
docker-compose down
chmod -R 777 ./data/fuseki
docker-compose build --no-cache
rm logs/startup.log
docker-compose up -d
# docker-compose logs -f > logs/startup.log