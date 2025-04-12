#!/bin/bash
# Script to properly build and run Fuseki

set -e

# Step 1: Clean up any existing containers and volumes
echo "Stopping any existing containers..."
docker compose down

# Step 2: Clean up lock files
echo "Cleaning up lock files..."
find ./data/fuseki -name "*.lock" -type f -delete 2>/dev/null || true

# Step 3: Set up the directory structure
echo "Setting up directory structure..."
mkdir -p ./data/fuseki
for ds in ds test-mem test-db semem squirt tia claudiob danja danbri hyperdata; do
    mkdir -p "./data/fuseki/$ds"
done

# Step 4: Set correct permissions
echo "Setting permissions on directories..."
chmod -R 777 ./data/fuseki

# Step 5: Build the Fuseki image
echo "Building Fuseki image..."
docker compose build --no-cache fuseki

# Step 6: Start the services
echo "Starting services..."
docker compose up -d

# Step 7: Watch logs for Fuseki
echo "Watching Fuseki logs... (press Ctrl+C to stop)"
docker compose logs -f fuseki
