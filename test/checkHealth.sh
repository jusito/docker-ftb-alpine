#!/bin/bash

set -e
NAME_HEALTHY="VanillaHealthy"
NAME_UNHEALTHY="VanillaUnhealthy"

docker run -d --rm --name "$NAME_HEALTHY" -e JAVA_PARAMETERS="-Xms1G -Xmx1G" -e motd="test" "jusito/docker-ftb-alpine:Vanilla"
docker run -d --rm --name "$NAME_UNHEALTHY" -e JAVA_PARAMETERS="-Xms1G -Xmx1G" -e HEALTH_PORT="20" "jusito/docker-ftb-alpine:Vanilla"

sleep 100s
info=$(docker ps | grep -F -e "$NAME_HEALTHY")
if [ -z "$info" ]; then
	echo "[FATAL] couldn't run $NAME_HEALTHY"
	docker ps
	exit 1
elif [ $( echo "$info" | grep -F -e "(healthy)" | wc -c) == "0" ]; then
	echo "[ERROR] health check failed"
	docker ps
	echo "$info"
	exit 2
fi
docker stop "$NAME_HEALTHY" && docker rm "$NAME_HEALTHY"

info=$(docker ps | grep -F -e "$NAME_UNHEALTHY")
if [ -z "$info" ]; then
	echo "[FATAL] couldn't run $NAME_UNHEALTHY"
	docker ps
	exit 3
elif [ $( echo "$info" | grep -F -e unhealthy | wc -c) == "0" ]; then
	echo "[ERROR] unhealth check failed"
	docker ps
	echo "$info"
	exit 4
fi
docker stop "$NAME_UNHEALTHY" && docker rm "$NAME_UNHEALTHY"