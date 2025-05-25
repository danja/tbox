#!/bin/bash

# Setup script for semem service
# This script is designed to be run after setup-repos.sh

echo "[INFO] Starting semem service setup..."

# Define paths
SEMEM_DIR="$HOME/hyperdata/tbox/projects/semem"
START_SCRIPT="$SEMEM_DIR/start.sh"

# Check if semem directory exists
if [ ! -d "$SEMEM_DIR" ]; then
    echo "[ERROR] Semem directory not found at $SEMEM_DIR"
    echo "[ERROR] Please ensure the semem repository is cloned in the projects directory"
    exit 1
fi

# Check if start script exists and is executable
if [ ! -f "$START_SCRIPT" ]; then
    echo "[ERROR] start.sh not found in $SEMEM_DIR"
    exit 1
fi

if [ ! -x "$START_SCRIPT" ]; then
    echo "[INFO] Making start.sh executable..."
    chmod +x "$START_SCRIPT" || {
        echo "[ERROR] Failed to make start.sh executable"
        exit 1
    }
fi

echo "[INFO] Starting semem service..."
# Run the start script in the background
nohup "$START_SCRIPT" > "$SEMEM_DIR/semem-service.log" 2>&1 &
SEMEM_PID=$!

echo "[SUCCESS] semem service started with PID: $SEMEM_PID"
echo "[INFO] Logs are being written to: $SEMEM_DIR/semem-service.log"

# Make the script executable
chmod +x "$0"
echo "[INFO] setup-semem.sh is now executable"
