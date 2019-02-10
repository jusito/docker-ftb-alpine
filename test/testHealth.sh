#!/bin/bash

set -e

MODE="$1"

NAME_HEALTHY="VanillaHealthy"
NAME_UNHEALTHY="VanillaUnhealthy"
NAME_UNHEALTHY2="VanillaFromHealthyToUnhealthy"
IMAGE="jusito/docker-ftb-alpine:Vanilla"

if [ -n "$MODE" ]; then
	set +e
	IMAGE="jusito:develop"
	docker stop "$NAME_HEALTHY" "$NAME_UNHEALTHY" "$NAME_UNHEALTHY2"
	set -e
fi

echo "starting container Healthy, Healthy->Unhealthy, Unhealthy"
docker run -d --rm --name "$NAME_HEALTHY" -e JAVA_PARAMETERS="-Xms1G -Xmx1G" -e server_port=30000 "$IMAGE"
docker run -d --rm --name "$NAME_UNHEALTHY" -e JAVA_PARAMETERS="-Xms1G -Xmx1G" -e server_port=30001 -e HEALTH_PORT="20" "$IMAGE"
docker run -d --rm --name "$NAME_UNHEALTHY2" -e JAVA_PARAMETERS="-Xms1G -Xmx1G" -e server_port=30002 "$IMAGE"

if [ "$MODE" == 1 ]; then
	exit 100
fi

# make unhealth
docker cp $NAME_UNHEALTHY2:/home/checkHealth.sh MyFile
if [ ! -e MyFile ]; then
	echo "failed to copy checkHealth.sh"
	exit 1
fi
echo "newLine" >> MyFile
chmod a=rwx MyFile
docker cp MyFile $NAME_UNHEALTHY2:/home/checkHealth.sh

sleep 100s
if [ "$MODE" == 2 ]; then
	docker ps --filter "name=Vanilla"
	exit 100
fi

info=$(docker ps | grep -F -e "$NAME_HEALTHY")
if [ $(echo "$info" | wc -c) == "0" ]; then
	echo "[FATAL] couldn't run $NAME_HEALTHY"
	docker ps
	exit 2
elif [ $(echo "$info" | grep -F -e "(healthy)" | wc -c) == "0" ]; then
	echo "[ERROR] health check failed"
	docker ps
	docker exec $NAME_HEALTHY /home/checkHealth.sh debugMode || true
	docker exec $NAME_HEALTHY ifconfig
	echo "$info"
	docker exec $NAME_HEALTHY cat "/home/docker/logs/latest.log"
	exit 3
else
	echo "[INFO] Healthy container looks healthy"
fi

info=$(docker ps | grep -F -e "$NAME_UNHEALTHY")
if [ $(echo "$info" | wc -c) == "0" ]; then
	echo "[FATAL] couldn't run $NAME_UNHEALTHY"
	docker ps
	exit 4
elif [ $(echo "$info" | grep -F -e unhealthy | wc -c) == "0" ]; then
	echo "[ERROR] unhealth check failed"
	docker ps
	docker exec $NAME_UNHEALTHY /home/checkHealth.sh debugMode || true
	echo "$info"
	exit 5
else
	echo "[INFO] Unhealthy container looks Unhealthy"
fi

info=$(docker ps | grep -F -e "$NAME_UNHEALTHY2" )
if [ $(echo "$info" | wc -c) == "0" ]; then
	echo "[FATAL] couldn't run $NAME_UNHEALTHY2"
	docker ps
	exit 6
elif [ $(echo "$info" | grep -F -e unhealthy | wc -c) == "0" ]; then
	echo "[ERROR] unhealth check failed"
	docker ps
	docker exec $NAME_UNHEALTHY2 /home/checkHealth.sh debugMode || true
	echo "$info"
	exit 7
else
	echo "[INFO] Healthy Container successfully unhealthy."
fi

docker stop "$NAME_HEALTHY"
docker stop "$NAME_UNHEALTHY"
docker stop "$NAME_UNHEALTHY2"
exit 0