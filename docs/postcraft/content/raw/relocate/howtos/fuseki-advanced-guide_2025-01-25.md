# Advanced Fuseki Dataset Management Guide

## Storage Persistence Verification

Test dataset persistence using this verification sequence:

```bash
# 1. Insert test data
curl -X POST http://localhost:4030/yourdataset/update \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
  -H "Content-Type: application/sparql-update" \
  --data "INSERT DATA { <http://example/test> <http://example/prop> 'test' }"

# 2. Restart Fuseki container
docker-compose restart fuseki

# 3. Verify data persistence
curl -X GET http://localhost:4030/yourdataset/query \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
  --data-urlencode "query=SELECT * WHERE { ?s ?p ?o }"
```

## Configuration Changes

### Requires Container Restart
- Adding new datasets
- Modifying storage type (TDB2/Memory)
- Changing endpoint configurations
- Authentication changes

### No Restart Required
- Data operations (query/update)
- Graph modifications
- Runtime statistics collection

## Storage Types Comparison

### Memory Datasets
```turtle
:memoryds rdf:type f:Service ;
    f:name "memoryds" ;
    f:dataset [
        rdf:type ja:MemoryDataset
    ] .
```
- Fastest access times
- Data cleared on restart
- Suitable for testing/development
- No disk space requirements

### TDB2 Datasets
```turtle
:persistentds rdf:type f:Service ;
    f:name "persistentds" ;
    f:dataset [
        rdf:type tdb2:DatasetTDB2 ;
        tdb2:location "/fuseki/databases/persistentds"
    ] .
```
- ACID compliant
- Persistent storage
- Optimized for large RDF datasets
- Better memory management

## Data Migration

### Small Datasets
```sparql
# Source dataset query
CONSTRUCT { ?s ?p ?o }
WHERE { ?s ?p ?o }
```

### Large Datasets
Use Fuseki's backup/restore functionality:
```bash
# Backup source dataset
curl -X POST http://localhost:4030/$/backup/sourceds \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)"

# Restore to target dataset
curl -X POST http://localhost:4030/$/restore/targetds \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
  -F "file=@backup.nq.gz"
```

## Production Configuration

### TDB2 Optimization
```turtle
:productionds rdf:type f:Service ;
    f:name "productionds" ;
    f:dataset [
        rdf:type tdb2:DatasetTDB2 ;
        tdb2:location "/fuseki/databases/productionds" ;
        tdb2:unionDefaultGraph true ;
        ja:context [
            ja:cxtName "arq:queryTimeout" ;
            ja:cxtValue "30000"
        ]
    ] .
```

### Dataset-Specific Authentication
Edit `shiro.ini`:
```ini
[urls]
/dataset1/** = authcBasic,roles[admin]
/dataset2/** = authcBasic,roles[reader]
```

## Monitoring

### Size Monitoring
```bash
# Get dataset size
curl -X GET http://localhost:4030/$/stats/productionds \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)"
```

### Performance Monitoring
```bash
# Enable statistics
curl -X POST http://localhost:4030/$/stats/enable \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)"

# Get performance metrics
curl -X GET http://localhost:4030/$/stats \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)"
```

## Replication Setup

1. Configure primary dataset:
```turtle
:primaryds rdf:type f:Service ;
    f:name "primaryds" ;
    f:dataset [
        rdf:type tdb2:DatasetTDB2 ;
        tdb2:location "/fuseki/databases/primaryds" ;
        ja:replication [
            ja:type "primary" ;
            ja:syncPeriod "5m"
        ]
    ] .
```

2. Configure replica dataset:
```turtle
:replicads rdf:type f:Service ;
    f:name "replicads" ;
    f:dataset [
        rdf:type tdb2:DatasetTDB2 ;
        tdb2:location "/fuseki/databases/replicads" ;
        ja:replication [
            ja:type "replica" ;
            ja:primaryServer "http://primary:3030/primaryds"
        ]
    ] .
```

## Best Practices

1. Always use TDB2 for production
2. Implement proper backup strategies
3. Monitor dataset sizes regularly
4. Set appropriate query timeouts
5. Use dataset-specific authentication
6. Enable statistics for performance monitoring
7. Configure replication for critical data
