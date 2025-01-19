# Service Testing Checklist

## 1. Nginx Service

```bash
# Basic connectivity
curl -I http://localhost:4080

# Static file serving
curl http://localhost:4080/index.html

# CORS headers
curl -I -X OPTIONS http://localhost:4080/api/ \
  -H "Origin: http://localhost"

# Proxy to app
curl http://localhost:4080/health

# Proxy to Fuseki
curl http://localhost:4080/fuseki/$/ping
```

## 2. Fuseki Service

```bash
# Basic health
curl -I http://localhost:4030/$/ping

# Authentication
curl -X GET http://localhost:4030/$/datasets \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)"

############## OK TO HERE ######################################

# Dataset presence
curl -X GET http://localhost:4030/ds/query \
  -H "Accept: application/sparql-results+json" \
  --data-urlencode "query=ASK { ?s ?p ?o }"

# Write test
curl -X POST http://localhost:4030/ds/update \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
  -H "Content-Type: application/sparql-update" \
  --data "INSERT DATA { <http://test/s> <http://test/p> 'migration-test' }"

# Read test
curl -X GET http://localhost:4030/ds/query \
  -H "Accept: application/sparql-results+json" \
  --data-urlencode "query=SELECT * WHERE { <http://test/s> ?p ?o }"
```

## 3. XMPP (Prosody) Service

```bash
# Basic connectivity
nc -zv localhost 5222

# Server-to-server
nc -zv localhost 5269

# HTTP endpoints
curl -I http://localhost:5280
curl -I http://localhost:5282

# Certificate verification
echo | openssl s_client -connect localhost:5222 -verify 8 2>/dev/null

# Upload functionality
curl -I http://localhost:5280/upload
```

## 4. Monitor Service

```bash
# Basic health
curl http://localhost:4040/health

# Fuseki monitoring
curl http://localhost:4040/health/fuseki

# Prosody monitoring
curl http://localhost:4040/health/prosody

# HTML interface
curl -H "Accept: text/html" http://localhost:4040/
```

## 5. Main App Service

```bash
# Health endpoint
curl http://localhost:4000/health

# Request headers test
curl -H "X-Test-Header: migration-test" http://localhost:4000/

# Error handling
curl -I http://localhost:4000/nonexistent
```

## Integration Tests

```bash
# Full stack test (adjust query as needed)
curl -X GET http://localhost:4080/fuseki/ds/query \
  -H "Accept: application/sparql-results+json" \
  --data-urlencode "query=SELECT * WHERE { ?s ?p ?o } LIMIT 1"

# Monitor dashboard data accuracy
curl http://localhost:4040/ | grep "healthy"

# Sequential service dependency test
docker-compose restart fuseki
sleep 10
curl http://localhost:4040/health/fuseki
```

## Data Verification

```bash
# Compare dataset sizes
echo "SELECT (COUNT(*) as ?count) WHERE { ?s ?p ?o }" | \
curl -X POST http://localhost:4030/ds/query \
  -H "Accept: application/sparql-results+json" \
  -H "Content-Type: application/sparql-query" \
  --data-binary @-

# Verify file permissions
ls -la data/prosody/
ls -la data/fuseki/

# Check logs for errors
docker-compose logs --tail=100 | grep -i error
```

Save this as `migration-test.sh` in the `scripts` directory and make executable:

```bash
chmod +x scripts/migration-test.sh
```
