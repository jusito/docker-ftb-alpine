#!/bin/bash

set -e

NAME_HEALTHY="VanillaHealthy"
NAME_UNHEALTHY="VanillaUnhealthy"
NAME_UNHEALTHY2="VanillaUnhealthy2"

docker run -d --rm --name "$NAME_HEALTHY" -e JAVA_PARAMETERS="-Xms1G -Xmx1G" "jusito/docker-ftb-alpine:Vanilla"
docker run -d --rm --name "$NAME_UNHEALTHY" -e JAVA_PARAMETERS="-Xms1G -Xmx1G" "jusito/docker-ftb-alpine:Vanilla"
docker run -d --rm --name "$NAME_UNHEALTHY2" -e JAVA_PARAMETERS="-Xms1G -Xmx1G" -e HEALTH_PORT="20" "jusito/docker-ftb-alpine:Vanilla"

# make unhealth
docker cp $NAME_UNHEALTHY2:/home/checkHealth.sh temp
if [ ! -e temp ]; then
	echo "failed to copy checkHealth.sh"
	exit 1
fi
echo "newLine" >> temp
docker cp temp $NAME_UNHEALTHY2:/home/checkHealth.sh

sleep 40s
info=$(docker ps | grep -F -e "$NAME_HEALTHY")
if [ -z "$info" ]; then
	echo "[FATAL] couldn't run $NAME_HEALTHY"
	docker ps
	exit 2
elif [ $( echo "$info" | grep -F -e "(healthy)" | wc -c) == "0" ]; then
	echo "[ERROR] health check failed"
	docker ps
	echo "$info"
	exit 3
fi

info=$(docker ps | grep -F -e "$NAME_UNHEALTHY")
if [ -z "$info" ]; then
	echo "[FATAL] couldn't run $NAME_UNHEALTHY"
	docker ps
	exit 4
elif [ $( echo "$info" | grep -F -e unhealthy | wc -c) == "0" ]; then
	echo "[ERROR] unhealth check failed"
	docker ps
	echo "$info"
	exit 5
fi

info=$(docker ps | grep -F -e "$NAME_UNHEALTHY2")
if [ -z "$info" ]; then
	echo "[FATAL] couldn't run $NAME_UNHEALTHY2"
	docker ps
	exit 6
elif [ $( echo "$info" | grep -F -e unhealthy | wc -c) == "0" ]; then
	echo "[ERROR] unhealth check failed"
	docker ps
	echo "$info"
	exit 7
fi

docker stop "$NAME_HEALTHY" && docker rm "$NAME_HEALTHY"
docker stop "$NAME_UNHEALTHY" && docker rm "$NAME_UNHEALTHY"
docker stop "$NAME_UNHEALTHY2" && docker rm "$NAME_UNHEALTHY2"
