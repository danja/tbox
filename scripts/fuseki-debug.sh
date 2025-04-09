#!/bin/bash
# fuseki-debug.sh - Diagnostic script for Fuseki container issues

# Get container ID for the Fuseki container
CONTAINER_ID=$(docker ps -qf "name=fuseki")

if [ -z "$CONTAINER_ID" ]; then
  echo "Fuseki container not found running. Checking stopped containers..."
  CONTAINER_ID=$(docker ps -aqf "name=fuseki")
  
  if [ -z "$CONTAINER_ID" ]; then
    echo "No Fuseki container found. Is it named differently?"
    exit 1
  else
    echo "Fuseki container exists but is not running."
    echo "Container ID: $CONTAINER_ID"
    echo "Container status:"
    docker inspect --format='{{.State.Status}}' $CONTAINER_ID
    echo "Exit code: $(docker inspect --format='{{.State.ExitCode}}' $CONTAINER_ID)"
    echo ""
    echo "Last 50 log lines:"
    docker logs --tail 50 $CONTAINER_ID
    exit 1
  fi
fi

echo "=============== FUSEKI DIAGNOSTIC INFORMATION ==============="
echo "Container ID: $CONTAINER_ID"
echo ""

echo "=============== CONTAINER ENVIRONMENT VARIABLES ==============="
docker exec $CONTAINER_ID env | sort
echo ""

echo "=============== FUSEKI PROCESS INFORMATION ==============="
docker exec $CONTAINER_ID ps aux | grep java
echo ""

echo "=============== FUSEKI CONFIGURATION FILES ==============="
echo "Config directory contents:"
docker exec $CONTAINER_ID ls -la /fuseki/configuration
echo ""

echo "Available databases:"
docker exec $CONTAINER_ID ls -la /fuseki/databases 2>/dev/null || echo "No databases directory found"
echo ""

echo "Shiro configuration:"
docker exec $CONTAINER_ID cat /fuseki/shiro.ini 2>/dev/null || echo "No shiro.ini found"
echo ""

echo "=============== CURRENT MEMORY USAGE ==============="
docker stats --no-stream $CONTAINER_ID
echo ""

echo "=============== LAST 50 LOG LINES ==============="
docker logs --tail 50 $CONTAINER_ID
echo ""

echo "=============== NETWORK PORTS ==============="
docker port $CONTAINER_ID
echo ""

echo "=============== VOLUME MOUNTS ==============="
docker inspect -f '{{range .Mounts}}{{.Source}} -> {{.Destination}}{{println}}{{end}}' $CONTAINER_ID
echo ""

echo "=============== DIAGNOSTICS COMPLETE ==============="
echo "For a full log dump, run: docker logs $CONTAINER_ID"
echo "To access the container shell: docker exec -it $CONTAINER_ID /bin/bash"
