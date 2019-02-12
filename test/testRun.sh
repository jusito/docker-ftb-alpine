#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Travis debugging
for tag in $(ls modpacks)
do
	echo "[testRun][INFO]running $tag"
	if ! docker run -ti --rm -e TEST_MODE=true -e JAVA_PARAMETERS="-Xms1G -Xmx2G" "jusito/docker-ftb-alpine:$tag"; then
		exit $ec
	fi
done