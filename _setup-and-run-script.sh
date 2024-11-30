#!/bin/bash

# Exit on any error
set -e

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "Docker does not seem to be running, start it first and then re-run this script"
        exit 1
    fi
}

# Check if Docker is installed and running
check_docker

# Create necessary directories
mkdir -p app logs

# Check if app.js exists, if not, create a sample one
if [ ! -f app/app.js ]; then
    echo "Creating a sample app.js..."
    cat > app/app.js << EOL
const http = require('http');
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello, Sandboxed World!');
});
server.listen(8311, () => console.log('Server running on port 8311'));
EOL
fi

# Check if nginx.conf exists, if not, create it
if [ ! -f nginx.conf ]; then
    echo "Creating nginx.conf..."
    cat > nginx.conf << EOL
events {
  worker_connections 1024;
}
http {
  server {
    listen 3770;
    location / {
      proxy_pass http://localhost:8311;
    }
  }
}
EOL
fi

# Build and start the Docker containers
echo "Building and starting Docker containers..."
docker-compose up --build -d

# Display the logs
echo "Displaying logs (press Ctrl+C to exit)..."
docker-compose logs -f
