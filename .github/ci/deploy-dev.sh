#!/bin/bash
# deploy-dev.sh - Deploy TBox to dev environment

set -e

# Configuration 
DEPLOY_HOST=${DEPLOY_HOST:-"dev-server.example.com"}
DEPLOY_USER=${DEPLOY_USER:-"deploy"}
DEPLOY_DIR=${DEPLOY_DIR:-"/opt/tbox"}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-"ghcr.io"}
DOCKER_REPO=${DOCKER_REPO:-"your-username/tbox"}
VERSION=${VERSION:-$(./scripts/ci/version.sh)}

# Check required environment variables
if [ -z "$DEPLOY_KEY" ]; then
  echo "Error: DEPLOY_KEY environment variable not set" >&2
  exit 1
fi

if [ -z "$VERSION" ]; then
  echo "Error: Could not determine version" >&2
  exit 1
fi

echo "Deploying version $VERSION to dev environment..."

# Create temporary SSH key file
SSH_KEY_FILE=$(mktemp)
echo "$DEPLOY_KEY" > $SSH_KEY_FILE
chmod 600 $SSH_KEY_FILE

# Deploy function
deploy() {
  # Upload docker-compose.dev.yml
  scp -i $SSH_KEY_FILE -o StrictHostKeyChecking=no \
    docker-compose.dev.yml \
    $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_DIR/docker-compose.yml

  # Generate .env file with version and other environment variables
  cat > .env.dev << EOF
VERSION=$VERSION
DOCKER_REGISTRY=$DOCKER_REGISTRY
DOCKER_REPO=$DOCKER_REPO
ENVIRONMENT=dev
FUSEKI_ADMIN_PASSWORD=$FUSEKI_ADMIN_PASSWORD
EOF

  # Upload .env file
  scp -i $SSH_KEY_FILE -o StrictHostKeyChecking=no \
    .env.dev \
    $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_DIR/.env

  # Execute deployment commands on remote server
  ssh -i $SSH_KEY_FILE -o StrictHostKeyChecking=no $DEPLOY_USER@$DEPLOY_HOST << EOF
    cd $DEPLOY_DIR

    # Pull latest images
    docker compose pull

    # Check if services are running
    if docker compose ps --services --filter "status=running" | grep -q "."; then
      # Perform zero-downtime deployment by updating one service at a time
      for service in \$(docker compose config --services); do
        echo "Updating service: \$service"
        docker compose up -d --no-deps --build \$service
        
        # Wait for service to be healthy
        echo "Waiting for \$service to be healthy..."
        timeout 300s bash -c "until docker compose ps \$service | grep -q '(healthy)'; do sleep 5; done" || {
          echo "Service \$service failed to become healthy within timeout"
          exit 1
        }
      done
    else
      # First deployment, start all services
      docker compose up -d
    fi

    # Clean up old images
    docker image prune -af --filter "until=24h"
EOF

  echo "Deployment to dev completed successfully."
}

# Run deployment
deploy

# Clean up
rm -f $SSH_KEY_FILE