#!/bin/bash
# Script to initialize Fuseki without relying on host chmod

set -e

echo "=== Initializing Fuseki ==="

# Step 1: Create data directory if it doesn't exist
mkdir -p ./data/fuseki

# Step 2: Stop any existing containers
docker compose down

# Step 3: Create a temporary container to initialize the directories
echo "Creating dataset directories with correct permissions..."
docker run --rm -v "$(pwd)/data/fuseki:/data" alpine:latest sh -c '
    mkdir -p /data
    for ds in ds test-mem test-db semem squirt tia claudiob danja danbri hyperdata; do
        mkdir -p "/data/$ds"
        echo "Created dataset directory: /data/$ds"
    done
    # Remove any lock files
    find /data -name "*.lock" -type f -delete 2>/dev/null || true
    echo "All dataset directories created"
'

# Step 4: Update the config file for fuseki if needed
if [ ! -f ./config/fuseki/config.ttl ]; then
    echo "Warning: config.ttl not found, copying from example..."
    cp ./config/fuseki/examples/config-tdb1.ttl ./config/fuseki/config.ttl
fi

# Step 5: Start the container with a modified entrypoint
echo "Starting Fuseki with container-side permission handling..."
docker compose up -d fuseki

# Step 6: Wait for container to start
echo "Waiting for Fuseki to start..."
sleep 5

# Step 7: Fix permissions from inside the container
echo "Setting permissions from inside the container..."
docker compose exec -u root fuseki sh -c '
    chmod -R 777 /fuseki/databases
    chmod -R 777 /fuseki/configuration
    echo "Permissions set successfully"
'

echo "=== Initialization Complete ==="
echo "Fuseki should now be running. Check status with docker compose ps"
echo "Access the SPARQL endpoint at http://localhost:4030/"
