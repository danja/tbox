# tbox

[![CI/CD](https://github.com/danja/tbox/actions/workflows/main.yml/badge.svg)](https://github.com/danja/tbox/actions/workflows/main.yml) [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/danja/tbox)


A Docker container for **hyperdata.it** projects. This is all very experimental.

## Contains

**3rd party**

- Alpine Linux
- nginx HTTP server
- Fuseki SPARQL server
- Prosody XMPP
- node
- ssh

**hyperdata.it** stuff (under `projects`)

## Install

**Prequisites**

* Docker Compose (installing with Docker Desktop is probably the easiest)
* ssh client
* node

Recommended is creating a dir `hyperdata` in your home directory, installing things there (there are other bits as well as tbox that may be useful). 

```sh
mkdir ~/hyperdata
cd ~/hyperdata
git clone https://github.com/danja/tbox.git
```

**tbox.sh** is a utility for managing the containers 

`Usage: ./tbox.sh start|stop|restart [service]|rebuild|clean|status|logs [service]`

### First Run

```sh
cd ~/hyperdata/tbox # whatever your local dir
./tbox.sh clean # complete rebuild, start - **danger** wipes volumes
./tbox.sh status
```
Wait a bit...

## Exposed Services

* http://localhost:4000/ - nginx 
  * http://localhost:4000/squirt/
* http://localhost:4010/ - echo request header
* http://localhost:4030/ - SPARQL server endpoints
* http://localhost:4040/ - health check

```sh
ssh root@localhost -p 2222
```
Password is `semem`

It may grumble about certs. If so, do the keygen command it suggests and try again.

## XMPP

*In-progress...*

When I start docker-compose and ssh in, and then do :
```sh
cd /home/projects/tia/dogbot
 ./start-dogbot.sh
``` 
This client sees the Prosody XMPP server on port 5222 and tries to connect, but fails authorization. What needs to be added?

### Adding default XMPP users

To allow clients to connect, you need to create user accounts in Prosody. You can automate this by adding user creation commands to your container setup. For example, to add a user `danja` with password `Claudiopup`:

```sh
docker-compose exec xmpp prosodyctl adduser danja@localhost
docker-compose exec xmpp prosodyctl passwd danja@localhost  # then enter 'Claudiopup' when prompted
```

To automate this for multiple users, add these commands to your Prosody/XMPP container entrypoint or a setup script.

**Example users:**
- user: danja, password: Claudiopup
- user: alice, password: wonderland
- user: bob, password: builder

You can add more users as needed. Make sure the client uses the correct username, domain (e.g., `@localhost`), and password.

## Troubleshooting

```sh
sudo systemctl stop tbox
cd ~/hyperdata/tbox # my local dir
docker compose down
docker compose up -d
```

- [Docker Cheatsheet](https://docs.docker.com/get-started/docker_cheatsheet.pdf)
- [Docker Compose Cheatsheet](https://devopscycle.com/pdfs/the-ultimate-docker-compose-cheat-sheet.pdf)
- [nginx Cheatsheet](https://www.docdroid.net/ooD0qnV/nginx-cheat-sheet-pdf)
