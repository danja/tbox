#!/bin/bash
# Clean up any stale lock files
rm -f /fuseki/system/tdb.lock
rm -f /fuseki/databases/*/tdb.lock

# Start Fuseki server
exec "$@"