#!/bin/bash
# deploy.sh

MODE=${1:-dev}
ACTION=${2:-up}

# Environment setup
setup_env() {
    if [ "$MODE" = "prod" ]; then
        cp .env.prod .env
    else
        cp .env.dev .env
    fi
}

# Certificate check for production
check_certs() {
    if [ "$MODE" = "prod" ]; then
        if [ ! -d "./ssl_certs" ]; then
            mkdir -p ./ssl_certs
            echo "Please add SSL certificates to ./ssl_certs"
            exit 1
        fi
    fi
}

# Deployment
deploy() {
    case $ACTION in
        up)
            docker-compose --profile $MODE up -d
            ;;
        down)
            docker-compose --profile $MODE down
            ;;
        restart)
            docker-compose --profile $MODE restart
            ;;
        rebuild)
            docker-compose --profile $MODE up -d --build
            ;;
        logs)
            docker-compose --profile $MODE logs -f
            ;;
    esac
}

# Main
setup_env
check_certs
deploy

# Usage: 
# ./deploy.sh dev|prod up|down|restart|rebuild|logs
