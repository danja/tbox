# Adding Datasets to Fuseki Container

This guide explains how to add new datasets to the Fuseki container.

## Method 1: Using Environment Variables

**THIS ISN'T LIKE THE CURRENT .yml**

1. Edit `docker-compose.yml` and add a new `FUSEKI_DATASET_X` environment variable:

```yaml
fuseki:
  environment:
    - FUSEKI_DATASET_1=ds
    - FUSEKI_DATASET_2=semem
    - FUSEKI_DATASET_3=test-db
    - FUSEKI_DATASET_4=test-mem
    - FUSEKI_DATASET_5=newdataset # Add your new dataset here
```

## Method 2: Using Configuration File

1. Edit `config/fuseki/config.ttl` and add a new service definition:

```turtle
:newdataset rdf:type f:Service ;
    f:name "newdataset" ;
    f:endpoint [ f:operation f:query ; ] ;
    f:endpoint [ f:operation f:update ; ] ;
    f:dataset [
        rdf:type tdb2:DatasetTDB2 ;
        tdb2:location "/fuseki/databases/newdataset"
    ] .
```

2. Add the service to the services list in the server configuration:

```turtle
[] rdf:type f:Server ;
   f:services (
     :ds
     :semem
     :test-db
     :test-mem
     :newdataset              # Add your new dataset here
   ) .
```

## Applying Changes

1. Stop the containers:

```bash
docker-compose down
```

2. Rebuild and restart:

```bash
docker-compose up -d --build
```

## Verifying the Dataset

1. Check if the dataset is available:

```bash
curl -X GET http://localhost:4030/$/datasets \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)"
```

2. Test the dataset with a basic query:

```bash
curl -X POST http://localhost:4030/newdataset/query \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data "SELECT * WHERE { ?s ?p ?o } LIMIT 1"
```

## Notes

- Dataset names must be unique
- The dataset directory will be created automatically
- Use TDB2 for persistent storage
- Memory datasets are cleared on restart
