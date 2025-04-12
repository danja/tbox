#!/bin/sh
## Licensed under the terms of http://www.apache.org/licenses/LICENSE-2.0

# Clean up lock files if they exist
cleanup_locks() {
    echo "Checking for stale lock files..."
    LOCKS=$(find "${FUSEKI_DIR}/databases" -name "*.lock" 2>/dev/null || true)
    if [ -n "$LOCKS" ]; then
        echo "Found stale lock files, removing them:"
        echo "$LOCKS"
        find "${FUSEKI_DIR}/databases" -name "*.lock" -delete 2>/dev/null || true
    else
        echo "No stale lock files found"
    fi
}

# Function to clean up properly on exit/termination
cleanup() {
    echo "Shutting down Fuseki gracefully..."
    # Send SIGTERM to the Java process if it's running
    if [ -n "$PID" ] && kill -0 $PID 2>/dev/null; then
        kill -TERM $PID
        # Wait for the process to terminate
        wait $PID
    fi
    
    # Clean up lock files on exit
    cleanup_locks
    
    exit 0
}

# Trap signals
trap cleanup SIGINT SIGTERM

# Clean up any stale lock files before starting
cleanup_locks

# Start Fuseki
#echo "Starting Fuseki with Java options: $JAVA_OPTIONS"
#"$JAVA_HOME/bin/java" $JAVA_OPTIONS -jar "${FUSEKI_DIR}/${FUSEKI_JAR}" "$@" &
#PID=$!

# Wait for the Java process
#wait $PID
