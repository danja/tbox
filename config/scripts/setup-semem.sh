#!/bin/bash

# Setup script for semem service
# This script is designed to be run after setup-repos.sh
# It ensures the semem service has the correct permissions and dependencies

echo "[INFO] Starting semem service setup..."

# Define paths
SEMEM_DIR="/home/projects/semem"

# Check if semem directory exists
if [ ! -d "$SEMEM_DIR" ]; then
    echo "[ERROR] Semem directory not found at $SEMEM_DIR"
    echo "[ERROR] Please ensure the semem repository is cloned in the projects directory"
    exit 1
fi

# Ensure proper permissions
chown -R semem:semem "$SEMEM_DIR"
chmod -R 755 "$SEMEM_DIR"

# Install dependencies if needed
if [ -f "$SEMEM_DIR/package.json" ]; then
    echo "[INFO] Installing semem dependencies..."
    cd "$SEMEM_DIR" || exit 1
    npm install
    cd - > /dev/null || exit 1
fi

echo "[SUCCESS] semem service setup complete"
echo "[INFO] The semem service will be started automatically by Docker Compose"
echo "[INFO] Services will be available on:"
echo "  - API: http://localhost:4100"
echo "  - UI: http://localhost:4120"
echo "  - Redirect: http://localhost:4110"
