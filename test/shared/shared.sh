#!/bin/bash

export DEFAULT_TAG="Vanilla-1.15.2"
export REPO="jusito/docker-ftb-alpine"
export TEST_CONTAINER="JusitoTesting"
if [ "${DEBUGGING}" = "true" ]; then
	set -o xtrace
else
	export DEBUGGING=false
fi

set -o errexit
set -o nounset
set -o pipefail

loadBaseImages() {
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

loadModpackImages() {
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

getImageTag() {
	# shellcheck disable=SC2001
	echo "$1" | sed 's/!/-/g'
}

getImagePath() {
	# shellcheck disable=SC2001
	echo "$1" | sed 's/!/\//g'
}
