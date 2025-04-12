#!/bin/sh
set -e

# Additional logging for debugging
set -x

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
echo "Setting up directories..."
mkdir -p /fuseki/configuration /fuseki/databases
chmod -R 777 /fuseki/databases /fuseki/configuration 2>/dev/null || true

# Check if configuration file exists
if [ ! -f "/fuseki/configuration/config.ttl" ]; then
    echo "Error: Configuration file /fuseki/configuration/config.ttl not found. Exiting."
    exit 1
fi

# Check if dataset directory exists
if [ ! -d "/fuseki/databases" ]; then
    echo "Error: Dataset directory /fuseki/databases not found. Exiting."
    exit 1
fi

# Copy configuration if needed
if [ -d "/fuseki/config-source" ] && [ ! -f "/fuseki/configuration/config.ttl" ]; then
    echo "Copying configuration files..."
    cp -f /fuseki/config-source/* /fuseki/configuration/ 2>/dev/null || true
fi

# Log JVM arguments and dataset details
echo "JVM Arguments: $JVM_ARGS"
echo "Dataset directory contents:"
ls -l /fuseki/databases

echo "Starting Fuseki with arguments: $@"
# Run the original Fuseki entrypoint script
if [ -f "/fuseki/entrypoint.sh" ]; then
    echo "Using Fuseki's entrypoint script..."
    /fuseki/entrypoint.sh "$@" &
else
    echo "Fuseki entrypoint script not found, using java directly..."
    java $JVM_ARGS -jar /fuseki/fuseki-server.jar "$@" &
fi

PID=$!
wait $PID