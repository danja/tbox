```sh
cd ~/hyperdata/tbox # my local dir
docker-compose down
docker rmi tbox_fuseki:5.3.0
cd /home/danny/hyperdata/tbox/jena-fuseki-docker-5.3.0
docker-compose build --build-arg JENA_VERSION=5.3.0
docker-compose up -d fuseki
```
