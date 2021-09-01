#!/bin/bash

export DEFAULT_TAG="Vanilla-1.17.1"
if [ -z "$DOCKER_REPO" ]; then
	export REPO="docker.io/jusito/docker-ftb-alpine"
else
	export REPO="$DOCKER_REPO"
fi

export TEST_CONTAINER="JusitoTesting"
if [ "${DEBUGGING}" = "true" ]; then
	set -o xtrace
else
	export DEBUGGING=false
fi

set -o errexit
set -o nounset
set -o pipefail

function loadBaseImages() {
	if cd "base"; then
		for javaVersion in *; do
		if [ -d "$javaVersion" ] && cd "$javaVersion"; then
			for distro in * ; do
			if [ -d "$distro" ] && cd "$distro"; then
				for jvm in * ; do
				if [ -d "$jvm" ] && [ -f "${jvm}/Dockerfile" ]; then
					BASE_IMAGES+=("${javaVersion}!${distro}!${jvm}")
				fi; done; cd ".."
			fi; done; cd ".."
		fi; done; cd ".."
	fi
}
declare -a BASE_IMAGES
loadBaseImages
#echo "${BASE_IMAGES[*]}"

function loadModpackImages() {
	if cd "modpacks"; then
		for modpack in *; do
		if [ -d "$modpack" ] && cd "$modpack"; then
			for version in * ; do
			if [ -d "$version" ] && [ -f "${version}/Dockerfile" ]; then
				MODPACKS+=("${modpack}!${version}")
			fi; done; cd ".."
		fi; done; cd ".."
	fi
}
declare -a MODPACKS
loadModpackImages
#echo "${MODPACKS[*]}"

function getImageTag() {
	# shellcheck disable=SC2001
	echo "$1" | sed 's/!/-/g'
}

function getImagePath() {
	# shellcheck disable=SC2001
	echo "$1" | sed 's/!/\//g'
}

function await() {
	container=$1
	file=$2
	waitFor=$3
	#minTime=$((30))
		
	isRunning=true
	counter=0
	timeout=300
	step=1
	while [ $isRunning = true ]; do
		counter=$((counter+1))
		
		if [ "$step" = "1" ]; then
			echo -en "\r[shared.await][INFO] waiting[-]..."
		elif [ "$step" = "2" ]; then
			echo -en "\r[shared.await][INFO] waiting[\\]..."
		else
			echo -en "\r[shared.await][INFO] waiting[/]..."
			step=0
		fi
		step=$((step+1))
		
		if docker exec "$container" grep -Fq -e "$waitFor" "$file" 2>/dev/null; then
			isRunning=false
			timeout=$((timeout+1))
		elif [ $counter -ge $timeout ]; then
			isRunning=false			
		fi
		
		sleep 1s
	done
	
	if [ $counter -ge $timeout ]; then
		echo -en "\r[shared.await][ERROR] TIMEOUT! \n"
		return 1
	else
		echo -en "\r[shared.await][INFO] await done\n"
		#if [ $counter -lt $minTime ]; then
		#	sleep $((minTime-counter))s
		#fi
		return 0
	fi
}