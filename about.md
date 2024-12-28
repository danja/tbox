next steps are in

/home/danny/github-danny/hyperdata/packages/tbox/docs/artifacts_2024-12-28

docker-compose restart monitor will restart just the monitor service with updated index.js.
For a complete rebuild: docker-compose up -d --build monitor

Here are the key commands to rebuild from scratch:

Stop and remove all containers/volumes:

bashCopydocker-compose down --volumes

Rebuild without using cache:

bashCopydocker-compose build --no-cache

Start everything up:

docker-compose up -d

Check logs for issues:

bashCopydocker-compose logs
These commands are actually stored in restart.sh in your project.
The monitor dashboard will be available at http://localhost:4040 once everything is up.

Restart:
http://localhost:4000/
http://localhost:4030/ - Fuseki
http://localhost:4080/

```sh
 docker-compose up --build

docker-compose down --volumes  # Remove containers and volumes
docker-compose build --no-cache  # Rebuild without cache
docker-compose up -d  # Start fresh

docker-compose logs

curl -X GET http://localhost:4030/ds/query \
  -H "Accept: application/sparql-results+json" \
  --data-urlencode "query=SELECT * WHERE { ?s ?p ?o }"

curl -X GET http://localhost:4030/test/query \
  -H "Accept: application/sparql-results+json" \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
  --data-urlencode "query=SELECT * WHERE { ?s ?p ?o }"
```

Access monitor dashboard at http://localhost:4040
