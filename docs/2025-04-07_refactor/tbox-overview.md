# TBox Docker Environment

## Core Services

| Service | Port | Description |
|---------|------|-------------|
| ssh-server | 2222 | SSH access to development environment with user `semem:semem` |
| app | 4010 | Simple Express application exposing request headers and health endpoint |
| fuseki | 4030 | Apache Jena Fuseki RDF triple store with multiple datasets |
| nginx | 4000 | Web server reverse proxy integrating all services |
| xmpp | 5222, 5269, 5280 | Prosody XMPP messaging server |
| monitor | 4040 | Health monitoring service for all components |

## Datasets

The Fuseki service hosts several RDF datasets:
- `ds` - Default persistent dataset
- `semem` - Semantic memory dataset
- `test-mem` - In-memory test dataset
- `test-db` - Persistent test dataset
- `hyperdata` - Dataset for hyperdata project
- `trellis` - Additional dataset defined in configuration

## Volume Mounts

- `/home/projects` - Main project files directory
- `/scripts` - Administrative scripts (read-only)
- `/fuseki/databases` - Persistent RDF storage
- `/fuseki/configuration` - Fuseki configuration
- `/etc/prosody` - XMPP server configuration
- Node modules, npm cache and SSH config volumes

## Authentication

- SSH: User `semem` with password `semem`
- Fuseki Admin: Username `admin` with password `admin123`
- XMPP Admin: JID `admin@localhost` with password `admin123`

## Management Scripts

- `restart.sh`, `rebuild-restart.sh` - Service management 
- `clean-fuseki-locks.sh` - Fix stale lock files
- `check_fuseki.sh` - Verify Fuseki is running correctly
- `sparql-test.sh` - Test SPARQL endpoints
- Various other utility scripts for maintenance

## System Integration

- `tbox.service` - Systemd service for managing the Docker environment
- Health checks configured for services
- Automatic restart capabilities

## Access URLs

- App: http://localhost:4010/
- Fuseki: http://localhost:4030/
- Web/NGINX: http://localhost:4000/
- Monitor: http://localhost:4040/

## Container Dependencies

The environment uses Alpine-based containers with minimal footprints and has appropriate dependency chains (monitor → app/fuseki/xmpp, app → fuseki, nginx → app/fuseki).
