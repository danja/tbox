#!/bin/bash
set -e

# Function to clean up lock files safely
cleanup_locks() {
    echo "Checking for stale lock files..."
    find /fuseki/databases -name "*.lock" -type f -delete 2>/dev/null || true
    echo "Lock files cleaned up"
}

# Function to handle graceful shutdown
graceful_shutdown() {
    echo "Shutting down Fuseki gracefully..."
    if [ -n "$PID" ] && kill -0 $PID 2>/dev/null; then
        kill -TERM $PID
        wait $PID
    fi
    cleanup_locks
    exit 0
}

# Set up trap for graceful shutdown
trap graceful_shutdown SIGTERM SIGINT

# Initial cleanup of lock files
cleanup_locks

# Ensure proper permissions on directories
mkdir -p /fuseki/configuration /fuseki/databases
chown -R fuseki:fuseki /fuseki/databases /fuseki/configuration 2>/dev/null || true

# Copy configuration if needed
if [ -d "/fuseki/config-source" ] && [ ! -f "/fuseki/configuration/config.ttl" ]; then
    echo "Copying configuration files..."
    cp -f /fuseki/config-source/* /fuseki/configuration/ 2>/dev/null || true
fi

echo "Starting Fuseki with arguments: $@"
if [ "$(id -u)" = "0" ]; then
    # If running as root, switch to fuseki user
    echo "Running as fuseki user..."
    exec su-exec fuseki:fuseki /fuseki/entrypoint.sh "$@" &
else
    # Otherwise run directly
    exec /fuseki/entrypoint.sh "$@" &
fi

PID=$!
wait $PID
