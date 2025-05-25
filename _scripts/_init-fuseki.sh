#!/bin/bash

# Ensure configuration directory exists and has proper permissions
mkdir -p /fuseki/configuration
chmod -R 777 /fuseki/configuration

# Clean up any stale lock files
find /fuseki/databases -name "*.lock" -type f -delete 2>/dev/null || true

# Copy configuration files if they don't exist
if [ -d "/fuseki/config-source" ] && [ "$(ls -A /fuseki/config-source)" ]; then
  cp -n /fuseki/config-source/* /fuseki/configuration/ 2>/dev/null || true
  chmod 644 /fuseki/configuration/* 2>/dev/null || true
fi

# Start Fuseki
exec "$@"
