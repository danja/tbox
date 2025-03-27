# Fuseki in Docker

[Fuseki](https://jena.apache.org/documentation/fuseki2/) is my go-to SPARQL store. There are several other perfectly good systems available, but [Apache Jena](https://jena.apache.org) was the first semweb kit I spent any real time with. I've not had any contact for ages, but in a past life I got to know the original team behind it a bit. All lovely folks, and bloody good at what they do. A big plus for their kit is that everything sticks very close to the specs, you know exactly what you're dealing with. (Hardly surprising, their paw prints are all over the specs).

So I've got plenty of historical bias towards Fuseki. But the main reason I keep coming back to it, is that it *Just Works*. Well, usually. I've used [Stain](https://github.com/stain)'s Docker image a few times in the past. But somewhere along the line a little snag has crept in. [A locking issue](https://github.com/stain/jena-docker/issues/34) with the TBD, which for me meant it wasn't starting up properly (I've got `systemctl` -> `docker-compose` set up on my office machine). On a skim, it's a little convoluted, so I went back to the source... Heh, silly me. I believe Fuseki was (is?) [Andy Seaborne](https://www.linkedin.com/in/andyseaborne/)'s baby, of course he's covered Docker.

[Fuseki: Docker Tools](https://jena.apache.org/documentation/fuseki2/fuseki-docker.html) is on planet Java. Hmm. I must have a Galactic Ordnance Survey map around somewhere...

Ok, good-oh, there's a `Dockerfile` and a `docker-compose.yaml` in here. Extra pleasing, Fuseki sits on Alpine, which I'm already using in #:tbox. I guess I should first try this as-is, in isolation, before looking at integration.
I do need to have a long session with the Docker-related bits. More pressing loose ends today.
To be continued...   
