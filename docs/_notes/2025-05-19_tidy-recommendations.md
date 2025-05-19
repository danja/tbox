# Tbox Project Cleanup Recommendations

## 1. Consolidate Redundant Files

- **Redundant Fuseki Configuration**: Remove duplicate configurations found in:
  - `/fuseki/config.ttl`
  - `/config/fuseki/config.ttl`
  - `/config/fuseki/config.ttl.bak`
  
- **Redundant Docker Definitions**:
  - Merge `/jena-fuseki-docker-5.3.0/Dockerfile` with main `Dockerfile` using multi-stage builds
  - Remove `Dockerfile copy` which is unused

- **Script Consolidation**:
  - Merge overlapping restart scripts in `/scripts/` directory
  - Standardize on `tbox-manage.sh` as the primary control script

## 2. Standardize Directory Structure

```
tbox/
├── config/                 # All configuration files
│   ├── fuseki/            # Fuseki SPARQL server configuration 
│   ├── nginx/             # Nginx configuration
│   ├── prosody/           # XMPP server configuration
│   └── certs/             # SSL certificates
├── scripts/               # Utility scripts
├── services/              # Service source code
│   ├── app/               # Node.js application 
│   ├── monitor/           # Health monitoring service
│   └── web/               # Web frontend
├── docker-compose.yml     # Main service definitions
├── Dockerfile             # Main builder
└── .env                   # Environment variables (new file)
```

## 3. Improve Docker Configuration

- **Docker Compose Improvements**:
  - Add service dependency checks with `depends_on.condition: service_healthy`
  - Implement proper volume naming conventions
  - Externalize environment variables to `.env` file

- **Dockerfile Improvements**:
  - Use multi-stage builds to reduce image size
  - Standardize on Alpine-based images for consistency
  - Add proper labels for maintainability (org.label-schema conventions)

## 4. Implement Testing

- **Service Health Testing**:
  - Implement Docker health checks for all services
  - Create integration test script that verifies all service endpoints
  - Add CI pipeline configuration (GitHub Actions or similar)

- **Automated Tests**:
  - Create a `tests/` directory with service-specific tests
  - Implement smoke tests that verify basic functionality
  - Add validation tests for configuration files

## 5. Improve Configuration Management

- **Configuration Standardization**:
  - Move all credentials to a unified `.env` file (gitignored)
  - Provide a `.env.example` file as a template
  - Implement consistent naming conventions across services

- **Documentation Improvements**:
  - Add a proper README.md with setup, usage and maintenance instructions
  - Document each service's purpose and configuration options
  - Add architectural diagram showing service relationships

## 6. Enhance Security

- **Security Improvements**:
  - Change default passwords in configuration files
  - Implement proper secret management
  - Configure services to run as non-root users where possible
  - Add network segmentation between services

## Implementation Approach

To implement these changes without breaking functionality:

1. Create a complete backup of the current system
2. Implement changes incrementally, testing after each change
3. Use the existing `tbox-manage.sh` script to add test commands
4. Keep backward compatibility with existing volume mounts
5. Document all changes for future maintainers
