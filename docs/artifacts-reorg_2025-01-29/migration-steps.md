# Implementation Instructions

## Initial Setup

1. Create new directory structure:
```bash
# Create object-store structure
mkdir -p object-store/{config,data}
```

2. Move existing TBox files to tbox directory:
```bash
# Create tbox directory
mkdir tbox

# Move current files to tbox directory
mv config data docker-compose.yml tbox/
mv *.md tbox/ 2>/dev/null || true
```

3. Create repository documentation:
```bash
# Create root README.md with repository overview
cat > README.md << 'EOF'
# TBox and Object Store Repository

This repository contains two independent containerized services:

## TBox
SPARQL store service for RDF data management.
- Directory: `/tbox`
- Deploy: `cd tbox && docker-compose up -d`

## Object Store
Object storage service.
- Directory: `/object-store`
- Deploy: `cd object-store && docker-compose up -d`
EOF
```

## Verify Current Functionality

1. Test TBox service still works:
```bash
cd tbox
docker-compose down
docker-compose up -d
curl -u admin:admin123 http://localhost:4030/$/ping
```

2. Add Object Store definition:
```bash
# Create object-store docker-compose.yml
cat > object-store/docker-compose.yml << 'EOF'
version: '3.8'
services:
  object-store:
    image: minio/minio
    ports:
      - "4040:9000"
    volumes:
      - ./data:/data
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: admin123
    command: server /data
EOF
```

3. Test Object Store deployment:
```bash
cd object-store
docker-compose up -d
curl http://localhost:4040/minio/health/ready
```

## Final Steps

1. Create service-specific documentation:
```bash
# Create object-store README
cat > object-store/README.md << 'EOF'
# Object Store Service

## Deployment
1. Configure in config/
2. Run: docker-compose up -d
3. Access at http://localhost:4040
EOF
```

2. Add deployment scripts (optional):
```bash
mkdir -p scripts/deploy
cat > scripts/deploy/deploy.sh << 'EOF'
#!/bin/bash
SERVICE=$1
if [ -z "$SERVICE" ]; then
  echo "Specify service: tbox or object-store"
  exit 1
fi
cd $SERVICE
docker-compose up -d
EOF
chmod +x scripts/deploy/deploy.sh
```

## Verification

1. Test independent deployment:
```bash
# Deploy TBox
cd tbox
docker-compose up -d

# In another terminal, deploy Object Store
cd object-store
docker-compose up -d

# Verify both services
curl -u admin:admin123 http://localhost:4030/$/ping
curl http://localhost:4040/minio/health/ready
```

## Rollback
If issues occur with either service:
```bash
cd affected-service
docker-compose down
git checkout previous-version
docker-compose up -d
```