This repository contains server for:
https://www.feed-the-beast.com/

tag = branch

## Overview
- persistend files:
	- server.properties
	- banned-ips.json
	- banned-players.json
	- ops.json
	- usercache.json
	- usernamecache.json
	- whitelist.json
	- config.sh
- need persistend config?
	- edit the config.sh (default its empty or non-existing)
		- only /bin/sh
		
## example
docker -d -v "minecraft_modded:/home/docker/volume:rw" "jusito/docker-ftb-alpine:FTBInfinity-3.0.2-1.7.10"

## FTB Infinity Evolved:
https://www.feed-the-beast.com/projects/ftb-infinity-evolved
jusito/docker-ftb-alpine:FTBInfinity-3.0.2-1.7.10

## FTB Presents SkyFactory 3:
https://www.feed-the-beast.com/projects/ftb-presents-skyfactory-3
jusito/docker-ftb-alpine:FTBPresentsSkyfactory3-3.0.15-1.10.2

## FTB Presents Direwolf20 1.12:
https://www.feed-the-beast.com/projects/ftb-presents-direwolf20-1-12
jusito/docker-ftb-alpine:FTBPresentsDirewolf20-2.1.0-1.12.2

## FTB Continuum 1.4.1:
https://www.feed-the-beast.com/projects/ftb-continuum
jusito/docker-ftb-alpine:FTBContinuum-1.4.1-1.12.2

## FTB Revelation 2.2.0:
https://www.feed-the-beast.com/projects/ftb-revelation
jusito/docker-ftb-alpine:FTBRevelation-2.2.0-1.12.2