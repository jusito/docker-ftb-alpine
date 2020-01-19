#!/bin/bash

export DEBUGGING=false

if [ -n "$1" ]; then
	export DEFAULT_IMAGE="$1"
else
	export DEFAULT_IMAGE="Vanilla-1.14.4"
fi

if [ "${DEBUGGING}" = "true" ]; then
	set -o xtrace
fi

set -o errexit
set -o nounset
set -o pipefail

bash test/testStyle.sh

tag="$DEFAULT_IMAGE"
echo "build FTBBase"
docker build -t "jusito/docker-ftb-alpine:FTBBase" "base/"

echo "[testBuild][INFO]build modpacks/$tag"
docker rmi "jusito/docker-ftb-alpine:$tag" || true
docker build -t "jusito/docker-ftb-alpine:$tag" "modpacks/"$(echo "$tag/." | sed 's/-/\//')
echo "[testRun][INFO]running $tag"
if ! docker run -ti --name "JusitoTesting" --rm -e TEST_MODE=true -e DEBUGGING=${DEBUGGING} -e JAVA_PARAMETERS="-Xms1G -Xmx2G" "jusito/docker-ftb-alpine:$tag"; then
	echo "[testRun][ERROR]run test failed for $tag"
	exit 1
fi
docker stop "JusitoTesting" || true
docker rm "JusitoTesting" || true

bash test/testHealth.sh
bash test/testAddOp.sh