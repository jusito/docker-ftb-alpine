#!/bin/bash

if [ "${DEBUGGING}" = "true" ]; then
	set -o xtrace
fi

set -o errexit
set -o nounset
set -o pipefail

(
cd "modpacks"
for modpack in *
do
	(
	cd "$modpack"
	for version in *
	do	
		tag="${modpack}-${version}"
		echo "[testRun][INFO]running $tag"
		if ! docker run -ti --name "JusitoTesting" --rm -e TEST_MODE=true -e DEBUGGING="${DEBUGGING}" -e JAVA_PARAMETERS="-Xms1G -Xmx2G" "jusito/docker-ftb-alpine:$tag"; then
			echo "[testRun][ERROR]run test failed for $tag"
			exit 1
		fi
		docker stop "JusitoTesting" || true
		docker rm "JusitoTesting" || true
	done
	)
done
)