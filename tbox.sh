#!/bin/bash
# TBox Management Script

set -e

# Configuration
WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCKER_COMPOSE="docker compose"
LOG_DIR="$WORKDIR/logs"
mkdir -p "$LOG_DIR"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Functions
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

check_fuseki_health() {
    log "Checking Fuseki health..."
    if curl -s http://localhost:4030/$/ping > /dev/null; then
        log "Fuseki is healthy!"
        return 0
    else
        warn "Fuseki is not responding"
        return 1
    fi
}

start_services() {
    log "Starting all services..."
    $DOCKER_COMPOSE up -d
    log "Services started"
}

stop_services() {
    log "Stopping all services..."
    $DOCKER_COMPOSE down
    log "Services stopped"
}

restart_services() {
    log "Restarting all services..."
    $DOCKER_COMPOSE restart
    log "Services restarted"
}

restart_service() {
    SERVICE=$1
    log "Restarting $SERVICE service..."
    $DOCKER_COMPOSE restart "$SERVICE"
    log "$SERVICE restarted"
}

rebuild_services() {
    log "Rebuilding all services..."
    $DOCKER_COMPOSE down
    $DOCKER_COMPOSE build --no-cache
    $DOCKER_COMPOSE up -d
    log "Services rebuilt and started"
}

clean_environment() {
    log "Cleaning environment (including volumes)..."
    $DOCKER_COMPOSE down --volumes
    $DOCKER_COMPOSE build --no-cache
    $DOCKER_COMPOSE up -d
    log "Environment cleaned and restarted"
}

show_status() {
    log "Current service status:"
    $DOCKER_COMPOSE ps
    
    # Check individual service health
    log "\nService health checks:"
    if check_fuseki_health; then
        echo -e "Fuseki: ${GREEN}HEALTHY${NC}"
    else
        echo -e "Fuseki: ${RED}UNHEALTHY${NC}"
    fi
    
    # Add more health checks for other services
}

show_logs() {
    SERVICE=$1
    if [ -z "$SERVICE" ]; then
        log "Showing logs for all services..."
        $DOCKER_COMPOSE logs
    else
        log "Showing logs for $SERVICE..."
        $DOCKER_COMPOSE logs "$SERVICE"
    fi
}

fix_fuseki_locks() {
    log "Fixing Fuseki lock files..."
    $DOCKER_COMPOSE exec -u root fuseki find /fuseki/databases -name "*.lock" -delete 2>/dev/null || true
    log "Restarting Fuseki service..."
    restart_service fuseki
    log "Fuseki locks cleaned"
}

# Main execution
cd "$WORKDIR"

case "$1" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        if [ "$2" ]; then
            restart_service "$2"
        else
            restart_services
        fi
        ;;
    rebuild)
        rebuild_services
        ;;
    clean)
        clean_environment
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs "$2"
        ;;
    fix-fuseki)
        fix_fuseki_locks
        ;;
    *)
        echo "TBox Management Script"
        echo "Usage: $0 {start|stop|restart [service]|rebuild|clean|status|logs [service]|fix-fuseki}"
        exit 1
esac

exit 0
