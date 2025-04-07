#!/bin/bash
set -e

# Ensure configuration directory exists and has proper permissions
mkdir -p /fuseki/configuration
mkdir -p /fuseki/databases

# Clean up any stale lock files
echo "Checking for stale lock files..."
find /fuseki/databases -name "*.lock" -type f -delete 2>/dev/null || true
echo "Ensuring proper permissions..."
chmod -R 777 /fuseki/configuration /fuseki/databases

# Copy configuration files if needed
if [ -d "/fuseki/config-source" ] && [ ! -f "/fuseki/configuration/config.ttl" ]; then
  echo "Copying configuration files..."
  cp -f /fuseki/config-source/* /fuseki/configuration/ 2>/dev/null || true
fi

echo "Starting Fuseki..."
# Run the original entrypoint with all arguments passed to this script
exec /fuseki/entrypoint.sh "$@"
