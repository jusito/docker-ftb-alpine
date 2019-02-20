#!/bin/bash

if [ "${DEBUGGING}" = "true" ]; then
	set -o xtrace
fi

set -o errexit
set -o nounset
set -o pipefail

docker run -d \
 --name "JusitoTesting" \
 -e DEBUGGING=${DEBUGGING} \
 -e TEST_MODE=true -e JAVA_PARAMETERS="-Xms1G -Xmx1G" \
 -e ADMIN_NAME=terzut \
 "jusito/docker-ftb-alpine:$DEFAULT_IMAGE"

docker exec JusitoTesting /home/addOp.sh "" Hey_Schnitte "" ""

docker restart JusitoTesting
docker attach JusitoTesting
