#!/bin/bash
# Script to troubleshoot Fuseki issues

set -e

echo "=== Fuseki Troubleshooting ==="

# Check if Fuseki container is running
echo "Checking if Fuseki container is running..."
CONTAINER_ID=$(docker ps -q -f name=fuseki)

if [ -z "$CONTAINER_ID" ]; then
  echo "❌ Fuseki container is not running"
  echo "Checking if it existed but stopped:"
  
  STOPPED_ID=$(docker ps -a -q -f name=fuseki)
  if [ -n "$STOPPED_ID" ]; then
    echo "Found stopped container. Checking logs:"
    docker logs $STOPPED_ID
  else
    echo "No Fuseki container found at all. Try running docker-compose up -d"
  fi
  exit 1
fi

echo "✅ Fuseki container is running with ID: $CONTAINER_ID"

# Check container logs
echo -e "\n=== Container Logs ==="
docker logs $CONTAINER_ID | tail -n 50

# Check filesystem permissions inside container
echo -e "\n=== Filesystem Permissions ==="
echo "Checking database directory permissions inside container:"
docker exec -it $CONTAINER_ID sh -c "ls -la /fuseki/databases"

echo -e "\nChecking configuration directory permissions inside container:"
docker exec -it $CONTAINER_ID sh -c "ls -la /fuseki/configuration"

# Check if config.ttl exists and is readable
echo -e "\n=== Configuration File ==="
docker exec -it $CONTAINER_ID sh -c "if [ -f /fuseki/configuration/config.ttl ]; then echo '✅ config.ttl exists'; else echo '❌ config.ttl is missing'; fi"
docker exec -it $CONTAINER_ID sh -c "if [ -r /fuseki/configuration/config.ttl ]; then echo '✅ config.ttl is readable'; else echo '❌ config.ttl is not readable'; fi"

# Try to list datasets
echo -e "\n=== Dataset Check ==="
echo "Attempting to list datasets via API:"
curl -s -X GET http://localhost:4030/$/datasets -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" | grep -q "ds" && 
  echo "✅ Datasets API is functional" || echo "❌ Datasets API failed"

# Check for lock files
echo -e "\n=== Lock Files ==="
echo "Checking for lock files inside container:"
docker exec -it $CONTAINER_ID sh -c "find /fuseki/databases -name '*.lock' -type f | wc -l" | grep -q "^0$" &&
  echo "✅ No lock files found" || echo "❌ Lock files exist, may need cleanup"

# Check JVM and runtime
echo -e "\n=== JVM Check ==="
echo "Checking Java process in container:"
docker exec -it $CONTAINER_ID sh -c "ps aux | grep java"

echo -e "\n=== Memory Usage ==="
docker stats $CONTAINER_ID --no-stream

echo -e "\n=== Troubleshooting Complete ==="
