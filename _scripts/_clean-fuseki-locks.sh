#!/bin/bash
# Script to clean up Fuseki lock files and restart the service

set -e

echo "Stopping tbox service..."
sudo systemctl stop tbox.service || true

echo "Making sure all Docker containers are stopped..."
docker compose down || true

echo "Removing all Fuseki lock files..."
sudo find ./data/fuseki -name "*.lock" -type f -delete || true

echo "Setting proper permissions on data directory..."
sudo chown -R $(id -u):$(id -g) ./data/fuseki

echo "Rebuilding the Fuseki container..."
docker compose build fuseki

echo "Starting tbox service..."
sudo systemctl start tbox.service

echo "Waiting for Fuseki to start..."
sleep 10

echo "Checking Fuseki container status..."
docker ps | grep fuseki