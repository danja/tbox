#!/bin/bash
set -e

echo "==> docker-entrypoint.sh: Script started."
echo "==> docker-entrypoint.sh: Running as user: $(id)"
echo "==> docker-entrypoint.sh: PROSODY_DOMAIN as seen by entrypoint: '${PROSODY_DOMAIN}'"
echo "==> docker-entrypoint.sh: PROSODY_ADMIN_JID as seen by entrypoint: '${PROSODY_ADMIN_JID}'"
echo "==> docker-entrypoint.sh: PROSODY_ADMIN_PASSWORD as seen by entrypoint: '${PROSODY_ADMIN_PASSWORD:-not set}'"

#apt-get update && apt-get install -y --no-install-recommends gosu 
# rm -rf /var/lib/apt/lists/*

# Ensure certificates and DH parameters are in place using the dedicated script.
echo "==> docker-entrypoint.sh: Attempting to execute /usr/local/bin/ensure-prosody-certs.sh..."
/usr/local/bin/ensure-prosody-certs.sh
echo "==> docker-entrypoint.sh: Finished executing /usr/local/bin/ensure-prosody-certs.sh."

echo "==> docker-entrypoint.sh: Starting Prosody in foreground as prosody user..."
# Run Prosody directly as prosody user in foreground
exec runuser -u prosody -- prosody --config /etc/prosody/prosody.cfg.lua
