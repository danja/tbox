### Main Services:
4000: Main TBox dashboard (nginx)
2222: SSH server
3030: Fuseki SPARQL endpoint (mapped to host port 4030)
4010: Application Service - Echo headers and request information service
4040: Health Monitor - System health checks and monitoring endpoints
8311: Application server
9090: Prometheus monitoring

### RDF & Semantic Web Tools:
4030: Apache Jena Fuseki - SPARQL server with multiple datasets and query endpoints
4200: Squirt - RDF data manipulation tool

### Data Management Tools:
4210: Atuin - Turtle RDF Editor
4240: Semem - Semantic memory and knowledge graph tools
4280: Wstore - HTTP file storage and retrieval server

### Semem Service:
4100: Semem API Server
4110: Semem UI
4120: Semem MCP Server

### Documentation & Examples:
4290: Hyperdata - Main hyperdata.it project documentation

### Monitoring & Debugging:
16686: Jaeger UI for distributed tracing
14250: Jaeger collector

### Temporarily Disabled:
4100, 4110, 4120: Semem service (API, redirect, and UI ports)
4220: Transmissions - Communication protocols and data transmission (temporarily disabled)
You can check the status of these ports using: