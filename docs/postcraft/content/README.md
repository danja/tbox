# tbox

A Docker container for **hyperdata.it** projects. This is very experimental.

## Exposed Services

## HTTP

- http://localhost:4000/ - nginx
- http://localhost:4010/ - echo request header
- http://localhost:4030/ - Fuseki
- http://localhost:4040/ - health check


## Contains

**3rd party**

- Alpine Linux
- nginx HTTP server
- Fuseki SPARQL server
- Prosody XMPP
- node
- ssh

**hyperdata.it**

-

## Install

First time, run

```sh
cd ~/hyperdata/tbox # whatever your local dir
./rebuild-start.sh
```

```sh
sudo systemctl stop tbox
cd ~/hyperdata/tbox # my local dir
docker-compose down
docker-compose up -d
```

Wait a bit...

```sh
ssh root@localhost -p 2222
```

It may grumble about certs. Do the keygen command it suggests and login again.

Then password is `semem`

## Troubleshooting

* [Docker Cheatsheet](https://docs.docker.com/get-started/docker_cheatsheet.pdf)
* [Docker Compose Cheatsheet](https://devopscycle.com/pdfs/the-ultimate-docker-compose-cheat-sheet.pdf)
* [nginx Cheatsheet](https://www.docdroid.net/ooD0qnV/nginx-cheat-sheet-pdf)
