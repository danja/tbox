# TBox and Object Store Overview

## System Organization
The repository contains definitions for two independent containerized services:

1. TBox System
   - Main Fuseki SPARQL store service
   - Existing configuration and data management
   - Current deployment patterns maintained

2. Object Store System
   - Independent object storage service
   - Separate configuration and deployment
   - Can be deployed on different servers

## Deployment Model
- Services are independently deployable
- Each service has its own docker-compose configuration
- Common configuration patterns but separate instances
- Deployment process:
  1. Clone repository
  2. Navigate to desired service directory
  3. Configure local settings
  4. Deploy using docker-compose

## Development Organization
- Shared development practices
- Independent versioning possible
- Common tooling and scripts
- Separate testing suites