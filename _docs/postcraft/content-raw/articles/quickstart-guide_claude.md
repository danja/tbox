## Quick Start

This guide will help you set up a sandboxed Linux environment using Docker, which includes Node.js, Nginx, Git, persistent storage and whatever else might be useful for [transmissions](https://github.com/danja/transmissions)...

This is for an Ubuntu-like OS, but it's all common kit, should be straightforward on other systems.

## Prerequisites

Ensure you have the following installed on your Ubuntu system:

1. Docker
2. Docker Compose
3. Git

If not already installed, you can install them using the following commands:

```bash
sudo apt update
sudo apt install docker.io docker-compose git
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

Note: After adding yourself to the docker group, you may need to log out and back in for the changes to take effect.

## Setup Steps

1. Create a new directory for your project:
   ```
   mkdir tbox && cd tbox
   ```

2. Create a file named `Dockerfile` with the following content:
   [Content of the Dockerfile artifact]

3. Create a file named `docker-compose.yml` with the following content:
   [Content of the docker-compose.yml artifact]

4. Create a directory for your application:
   ```
   mkdir app
   ```

5. Create a simple Node.js application in the `app` directory. For example, create `app/app.js`:
   ```javascript
   const http = require('http');
   const server = http.createServer((req, res) => {
     res.writeHead(200, { 'Content-Type': 'text/plain' });
     res.end('Hello, Sandboxed World!');
   });
   server.listen(8080, () => console.log('Server running on port 8080'));
   ```

6. Create a basic Nginx configuration. Create `nginx.conf` in your project root:
   ```nginx
   events {
     worker_connections 1024;
   }
   http {
     server {
       listen 80;
       location / {
         proxy_pass http://localhost:8080;
       }
     }
   }
   ```

## Running the System

Use the provided bash script (described in the next section) to prepare and run the system. The script will:

1. Build the Docker image
2. Start the containers
3. Display the logs

## Accessing the System

- The Node.js application will be accessible at `http://localhost:8080`
- Nginx will proxy requests from `http://localhost:80` to the Node.js application
- To access the container's shell for Git operations or other tasks:
  ```
  docker-compose exec app /bin/sh
  ```

## Persistent Storage

- Application code: `./app` on your host is mounted to `/home/myuser/app` in the container
- Persistent data: Use `/home/myuser/data` in the container to store data that should persist
- Logs: Written to `/var/log/myapp` in the container, accessible in `./logs` on your host

## Using Git

Git is installed in the container. To use it:

1. Access the container shell:
   ```
   docker-compose exec app /bin/sh
   ```
2. Configure Git (first time only):
   ```
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```
3. Use Git commands as usual within the `/home/myuser/app` directory

Remember to commit your changes and push to remote repositories as needed.
