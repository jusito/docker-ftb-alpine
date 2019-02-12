#!/bin/bash

set -e

# Travis debugging
for tag in $(ls modpacks)
do
	echo "[testRun][INFO]running $tag"
	docker run -ti --rm -e TEST_MODE=true -e JAVA_PARAMETERS="-Xms1G -Xmx2G" "jusito/docker-ftb-alpine:$tag"
	ec=$?
	if [ $ec != 0 ]; then
		exit $ec
	fi
done