# Quick Start Guide - PM2 in Docker

## Prerequisites
- Docker and Docker Compose installed
- Git installed
- Node.js project repositories ready

## Setup Steps

1. **Create Project Structure**
```bash
mkdir tbox-pm2
cd tbox-pm2
```

2. **Copy Configuration Files**
Copy these files to your project directory:
- `projects/Dockerfile`
- `projects/docker-compose.yml`
- `projects/setup-repos.sh`
- `ecosystem.config.js`

3. **Configure Repository Sources**
Edit `setup-repos.sh` and update the REPOS array with your repository URLs:
```bash
REPOS=(
  "your-username/repo1"
  "your-username/repo2"
)
```

4. **Set Environment Variables**
```bash
# Optional: For PM2 monitoring
export PM2_PUBLIC_KEY="your-key"
export PM2_SECRET_KEY="your-secret"
```

5. **Build and Run**
```bash
# Make setup script executable
chmod +x projects/setup-repos.sh

# Build and start containers
docker-compose up --build -d

# Check logs
docker-compose logs -f
```

6. **Verify Services**
```bash
# Connect to container
docker-compose exec node-ssh sh

# Check PM2 status
pm2 list
pm2 logs
```

## Common Operations

### Restart Services
```bash
docker-compose exec node-ssh pm2 restart all
```

### View Logs
```bash
docker-compose exec node-ssh pm2 logs
```

### Monitor Resources
```bash
docker-compose exec node-ssh pm2 monit
```

### Stop Everything
```bash
docker-compose down
```

## Troubleshooting

1. If services fail to start:
   ```bash
   docker-compose logs node-ssh
   ```

2. If PM2 shows no processes:
   ```bash
   docker-compose exec node-ssh pm2 start /app/ecosystem.config.js
   ```

3. For permission issues:
   ```bash
   docker-compose exec node-ssh chown -R node:node /app
   ```