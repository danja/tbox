# About tbox

tbox is a repo designed to house a docker container with various services, including a Fuseki SPARQL store server. The configuration relevant to this can be found in fuseki-config-paths.

The currently defined datasets have the following intended purposes :

* ds - tbox system use
* test-mem - a volatile in-memory store for testing purposes, cleared between container sessions
* test-db - a persistent store for testing purposes, retained between container sessions
* semem - semen data for production

The system is currently under development, for now the necessary credentials are :

* admin user : admin
* admin password : admin123

Changes can made to this system but should be kept at a minimum, only made when a client encounters a clear bug or needs an additional feature to operate. Client issues should be addressed first. 
