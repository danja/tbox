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

NB. It appears the latest version of Docker Compose (as found in Docker Desktop) replaces the `docker-compose` command with `docker compose`.

Allowing Docker things to run as a non-root user might help, but I've lost the full instructions, something like :
```sh
sudo groupadd docker
sudo usermod -aG docker "$USER"
```

Definitely recommended is creating a dir `hyperdata` in your home directory, installing things there (there are other bits as well as tbox that may be useful). 

```sh
mkdir ~/hyperdata
cd ~/hyperdata
git clone https://github.com/danja/tbox.git
```

**tbox.sh** is a utility for managing the containers. If you get Docker things running as a regular user, great. Otherwise prefix with **sudo** : 

`Usage: ./tbox.sh start|stop|restart [service]|rebuild|clean|status|logs [service]`

### First Run


```sh
cd ~/hyperdata/tbox # whatever your local dir
./tbox.sh clean # complete rebuild, start - **danger** wipes volumes
./tbox.sh status
```
Wait 10 minutes...

It needs to pull images, takes a while for that. Then longer. 

Wait a bit longer...

Open http://localhost:4000/ in a browser.

Fuseki has password `admin` user `admin123`

Other things probably won't work.

Then if you are feeling adventurous/daft : [TIA](https://github.com/danja/tia)

To get inside,

*The following command won't work until after quite a while, the startup is time-consuming & a little resource-hungry. It generates a DH key, also pulls and builds material from GitHub. Expect `Connection reset by peer` a few times before ssh is ready to let you in.*

```sh
ssh root@localhost -p 2222
```
Password is `semem`

It may grumble about certs. If so, do the keygen command it suggests *"remove with:"* and try again.

## XMPP

```sh
./tbox.sh logs xmpp

# rebuild just this bit
docker compose up -d --force-recreate xmpp
```

*In-progress...*

### Adding default XMPP users

To allow clients to connect, you need to create user accounts in Prosody. You can automate this by adding user creation commands to your container setup. For example, to add a user `danja` with password `Claudiopup`:

```sh
docker-compose exec xmpp prosodyctl adduser danja@localhost
docker-compose exec xmpp prosodyctl passwd danja@localhost  # then enter 'Claudiopup' when prompted
```

**Default users:**
- user: alice, password: wonderland
- user: bob, password: builder
- user: chaals, password: bigguy

You can add more users as needed. Make sure the client uses the correct username, domain (e.g., `@localhost`), and password.

The is a systemd startup file in `scripts`

## Troubleshooting

```sh
sudo systemctl stop tbox
cd ~/hyperdata/tbox # my local dir
docker compose down
docker compose up -d
# things like this
docker-compose up -d --force-recreate xmpp
```

- [Docker Cheatsheet](https://docs.docker.com/get-started/docker_cheatsheet.pdf)
- [Docker Compose Cheatsheet](https://devopscycle.com/pdfs/the-ultimate-docker-compose-cheat-sheet.pdf)
- [nginx Cheatsheet](https://www.docdroid.net/ooD0qnV/nginx-cheat-sheet-pdf)
