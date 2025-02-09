```sh
sudo systemctl stop tbox
cd ~/hyperdata/tbox # my local dir
docker-compose down
```

```sh
docker-compose build --no-cache
sudo systemctl start tbox.service
```

docs/howtos/tbox-autostart_2025-01-26.md

```sh
curl -X POST http://localhost:4030/hyperdata/query   -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)"   -H "Content-Type: application/sparql-query"   -H "Accept: application/sparql-results+json"   --data "SELECT * WHERE { ?s ?p ?o } LIMIT 1"
```

```sh
cd ~/hyperdata/tbox # my local dir
docker-compose up -d
```

```sh
ssh semem@localhost -p 2222
...
exit
```

```sh
cd ~/hyperdata/tbox # my local dir
docker-compose down
docker-compose build --no-cache
rm logs/startup.log
docker-compose up -d
docker-compose logs -f > logs/startup.log
```

```sh
ssh root@localhost -p 2222
```

check syntax :

```sh
cd ~/hyperdata/tbox/config/fuseki
rapper -c -i turtle config.ttl
```

docker run -d -p 2222:22 your-image-name

---

`docs/artifacts_2025-01-19`

docker-compose build --no-cache
docker-compose up -d

# Make setup script executable

chmod +x projects/setup-repos.sh

# Build and start containers

docker-compose up --build -d

# Check logs

docker-compose logs -f

docker-compose down

---

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
