#!/bin/bash

export DEBUGGING=false
if [ "${DEBUGGING}" = "true" ]; then
	set -o xtrace
fi

set -o errexit
set -o nounset
set -o pipefail

bash test/testStyle.sh

tag="Vanilla-1.13.2"
echo "build FTBBase"
docker build -t "jusito/docker-ftb-alpine:FTBBase" .
echo "[testBuild][INFO]build modpacks/$tag"
docker rmi "jusito/docker-ftb-alpine:$tag" || true
docker build -t "jusito/docker-ftb-alpine:$tag" "modpacks/$tag"
echo "[testRun][INFO]running $tag"
if ! docker run -ti --name "JusitoTesting" --rm -e TEST_MODE=true -e DEBUGGING=${DEBUGGING} -e JAVA_PARAMETERS="-Xms1G -Xmx2G" "jusito/docker-ftb-alpine:$tag"; then
	echo "[testRun][ERROR]run test failed for $tag"
	exit 1
fi
docker stop "jusito/docker-ftb-alpine:$tag" || true
docker rm "jusito/docker-ftb-alpine:$tag" || true

bash test/testHealth.sh
bash test/testAddOp.sh