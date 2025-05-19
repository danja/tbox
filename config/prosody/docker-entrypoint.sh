#!/bin/bash
set -e

CERT_DIR="/etc/prosody/certs"
KEY_FILE="$CERT_DIR/localhost.key"
CRT_FILE="$CERT_DIR/localhost.crt"

# Generate self-signed certs if missing
if [[ ! -f "$KEY_FILE" || ! -f "$CRT_FILE" ]]; then
    echo "Generating self-signed certificates for localhost..."
    prosodyctl cert generate localhost
fi

# Start Prosody in the background
prosody &
PROSODY_PID=$!

# Wait a bit for Prosody to be ready
sleep 3

# Run user initialization script
if [ -x "/usr/local/bin/prosody-init-users.sh" ]; then
    /usr/local/bin/prosody-init-users.sh
else
    echo "User init script not found or not executable."
fi

# Wait for Prosody process
wait $PROSODY_PID
