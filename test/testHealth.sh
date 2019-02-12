#!/bin/bash

set -e

MODE="$1"
HEALTH=" --health-start-period 20s --health-retries 3 --health-timeout 3s --health-interval 2s "

function await() {
	container=$1
	file=$2
	waitFor=$3
	minTime=$((20+9+3))
		
	isRunning=true
	counter=0
	timeout=120
	while [ $isRunning == true ]; do
		counter=$((counter+1))
		
		set -e
		current=$( (docker exec $container grep -F -e "$waitFor" "$file" || true) | wc -w )
		set +e
		if [ "$current" != "0" ]; then
			isRunning=false
			timeout=$((timeout+1))
		elif [ $counter -ge $timeout ]; then
			isRunning=false			
		fi
		
		sleep 1s
	done
	
	if [ $counter -ge $timeout ]; then
		echo "[testHealth][ERROR]TIMEOUT!"
		return 1
	else
		echo "[testHealth][INFO]await done"
		if [ $counter -lt $minTime ]; then
			sleep $((minTime-counter))s
		fi
		return 0
	fi
}

function isHealthy() {
	container=$1
	healthy=$2
	info=$(docker ps | grep -F -e "$container")
	
	if [ $healthy == true ]; then
		state="(healthy)"
	else
		state="(unhealthy)"
	fi
	
	if [ $(echo "$info" | wc -c) == "0" ]; then
		echo "[testHealth][FATAL]$container isn't running"
		docker ps
		return 2
	elif [ $(echo "$info" | grep -F -e "$state" | wc -c) == "0" ]; then
		echo "[testHealth[ERROR]$state check failed"
		echo "$info" || true
		set +o errexit
		ps -o comm,pid,etime,vsz,stat,args
		docker exec $container "/home/checkHealth.sh" "debug"
		docker exec $container ls "/home/docker/"
		docker exec $container ls "/home/docker/logs/"
		# shellcheck disable=SC2002
		if docker exec $container grep -Eq -e ':\s*Done\s*\([0-9.]+\w?\)!' "/home/docker/logs/latest.log"; then
			echo "[testHealth][INFO]server log contains done"
		else
			echo "[testHealth][ERROR]server log DOESN'T contains done"
		fi
		set -o errexit
		return 3
	else
		echo "[testHealth][INFO]$container container looks: $state"
		return 0
	fi
}

function printDebug() {
	container=$1
	docker ps --filter "name=Vanilla"
	if [ -z "$container" ]; then
		docker exec $container /home/checkHealth.sh debugMode || true
	fi
}

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

echo "[testHealth][INFO]starting container Healthy"
docker run -d --rm --name "$NAME_HEALTHY" -e JAVA_PARAMETERS="-Xms1G -Xmx1G" $HEALTH "$IMAGE"
await "$NAME_HEALTHY" "/home/docker/logs/latest.log" "[Server thread/INFO]: Done"
ret=$?
if [ $ret == 0 ]; then
	echo "[testHealth][INFO]$NAME_HEALTHY starting done"
	isHealthy "$NAME_HEALTHY" true
	ret=$?
	if [ "$ret" == "0" ]; then
		echo "[testHealth][INFO]$NAME_HEALTHY looks healthy"	
	else
		echo "[testHealth][ERROR]$NAME_HEALTHY looks unhealthy"
		printDebug "$NAME_HEALTHY"
		exit 2
	fi
else
	echo "[testHealth][ERROR]$NAME_HEALTHY starting failed"
	printDebug "$NAME_HEALTHY"
	exit 1
fi
docker stop $NAME_HEALTHY || true
docker rm $NAME_HEALTHY || true






echo "[testHealth][INFO]starting Unhealthy"
docker run -d --rm --name "$NAME_UNHEALTHY" -e JAVA_PARAMETERS="-Xms1G -Xmx1G" -e HEALTH_PORT="20" $HEALTH "$IMAGE"
await "$NAME_UNHEALTHY" "/home/docker/logs/latest.log" "[Server thread/INFO]: Done"
ret=$?
if [ "$ret" == "0" ]; then
	isHealthy "$NAME_UNHEALTHY" false
	ret=$?
	if [ "$ret" == "0" ]; then
		echo "[testHealth][INFO]$NAME_UNHEALTHY looks unhealthy"	
	else
		echo "[testHealth][ERROR]$NAME_UNHEALTHY looks healthy"
		printDebug "$NAME_UNHEALTHY"
		exit 4
	fi
else
	echo "[testHealth][ERROR]$NAME_UNHEALTHY starting failed"
	printDebug "$NAME_UNHEALTHY"
	exit 3
fi
docker stop "$NAME_UNHEALTHY" || true





echo "[testHealth][INFO]starting Healthy->Unhealthy"
docker run -d --rm --name "$NAME_UNHEALTHY2" -e JAVA_PARAMETERS="-Xms1G -Xmx1G" $HEALTH "$IMAGE"

# make unhealth
echo "[testHealth][INFO]lets make it unhealthy"
docker cp $NAME_UNHEALTHY2:/home/checkHealth.sh MyFile
if [ ! -e MyFile ]; then
	echo "[testHealth][FATAL]failed to copy checkHealth.sh"
	exit 1
fi
echo "newLine" >> MyFile
chmod a=rwx MyFile
docker cp MyFile $NAME_UNHEALTHY2:/home/checkHealth.sh
echo "[testHealth][INFO]should be unhealthy"
await "$NAME_UNHEALTHY2" "/home/docker/logs/latest.log" "[Server thread/INFO]: Done"
ret=$?
if [ "$ret" == "0" ]; then
	isHealthy "$NAME_UNHEALTHY2" false
	ret=$?
	if [ "$ret" == "0" ]; then
		echo "[testHealth][INFO]$NAME_UNHEALTHY2 looks unhealthy"	
	else
		echo "[testHealth][ERROR]$NAME_UNHEALTHY2 looks healthy"
		printDebug "$NAME_UNHEALTHY2"
		exit 6
	fi
else
	echo "[testHealth][ERROR]$NAME_UNHEALTHY2 starting failed"
	printDebug "$NAME_UNHEALTHY2"
	exit 5
fi
docker stop "$NAME_UNHEALTHY2" || true
docker rm "$NAME_UNHEALTHY2" || true

exit 0