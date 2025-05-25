#!/bin/bash
# Script to safely restart Fuseki

set -e

echo "Stopping tbox service..."
sudo systemctl stop tbox.service

echo "Checking for any running containers..."
FUSEKI_CONTAINER=$(docker ps -q -f name=tbox_fuseki)

if [ ! -z "$FUSEKI_CONTAINER" ]; then
    echo "Stopping Fuseki container..."
    docker stop $FUSEKI_CONTAINER
    
    echo "Removing Fuseki container..."
    docker rm $FUSEKI_CONTAINER
fi

echo "Rebuilding Fuseki container..."
cd /home/danny/hyperdata/tbox
docker compose build fuseki

echo "Starting tbox service..."
sudo systemctl start tbox.service

echo "Checking Fuseki status..."
sleep 5
docker logs $(docker ps -q -f name=tbox_fuseki)

echo "Fuseki restart completed successfully!"