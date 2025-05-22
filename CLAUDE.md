# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TBox is a Docker-based development environment for hyperdata.it projects providing a complete semantic web and XMPP messaging stack. It orchestrates multiple services through Docker Compose to create an integrated development platform.

## Architecture

**Core Services:**
- **ssh-server** (port 2222): Alpine Linux environment with SSH access and project volume mounts
- **app** (port 4010): Express.js service for request debugging and API endpoints
- **fuseki** (port 4030): Apache Jena SPARQL triple store with 10 pre-configured RDF datasets
- **nginx** (port 4000): Reverse proxy serving web content and routing to services
- **xmpp** (port 5222/5269/5280): Prosody XMPP server with conference and file upload support
- **monitor** (port 4040): Health monitoring dashboard for all services

**Key Configuration:**
- 10 RDF datasets: ds, test-mem, test-db, semem, squirt, tia, claudiob, danja, danbri, hyperdata
- Persistent volumes for database storage and SSH configuration
- Custom entrypoint scripts for XMPP user provisioning and certificate management
- Workspace structure with services in `services/` subdirectories

## Development Commands

**Primary Management (use `./tbox.sh`):**
```bash
./tbox.sh start           # Start all services
./tbox.sh stop            # Stop all services  
./tbox.sh restart [svc]   # Restart all services or specific service
./tbox.sh rebuild         # Full rebuild with --no-cache
./tbox.sh clean           # Complete rebuild including volumes (DESTRUCTIVE)
./tbox.sh status          # Show service status and health checks
./tbox.sh logs [svc]      # View logs for all or specific service
./tbox.sh fix-fuseki      # Clean Fuseki lock files and restart
```

**NPM Scripts:**
```bash
npm start                 # Start via docker-compose up
npm run build            # Build all Docker images
npm test                 # Run tests across all workspaces
npm run test:xmpp        # Test XMPP connectivity specifically
npm run clean            # Stop and remove volumes
npm run lint             # Run linting across workspaces
npm run rp               # Generate repository summary with repomix
```

**First Time Setup:**
```bash
./tbox.sh clean          # Complete rebuild (wait ~10 minutes)
./tbox.sh status         # Verify all services are healthy
ssh root@localhost -p 2222  # Access container (password: semem)
```

## Service Access

**Web Interfaces:**
- Main: http://localhost:4000/
- SPARQL: http://localhost:4030/ (admin/admin123)
- Health Monitor: http://localhost:4040/
- App Service: http://localhost:4010/

**SSH Access:**
- `ssh root@localhost -p 2222` (password: semem)
- Projects mounted at `/home/projects`

**XMPP Access:**
- Domain: `xmpp`
- Admin: admin@xmpp/admin123
- Additional users provisioned via `prosody-init-users.sh`

## Testing

**XMPP Testing:**
- Use `npm run test:xmpp` for connectivity tests
- Test files in `tests/xmpp/` directory
- Set `NODE_TLS_REJECT_UNAUTHORIZED=0` for development

**Service Health:**
- Monitor at http://localhost:4040/
- Individual health checks via `./tbox.sh status`
- Fuseki ping at http://localhost:4030/$/ping

## File Structure

**Configuration:**
- `config/fuseki/config.ttl`: RDF dataset definitions
- `config/prosody/`: XMPP server configuration and scripts
- `config/nginx/nginx.conf`: Reverse proxy routing
- `docker-compose.yml`: Main service orchestration

**Services:**
- `services/app/`: Express.js application service
- `services/monitor/`: Health monitoring service
- `services/web/public/`: Static web content

**Development:**
- `projects/`: Mounted into containers for development
- `tests/xmpp/`: XMPP connectivity and functionality tests

## Common Issues

**Fuseki Lock Files:**
Run `./tbox.sh fix-fuseki` if Fuseki fails to start due to lock files.

**XMPP Connection Issues:**
Check user provisioning in `config/prosody/prosody-init-users.sh` and verify certificate generation.

**Service Startup:**
Initial startup takes ~10 minutes due to DH key generation and GitHub repository cloning. Use `./tbox.sh status` to monitor progress.