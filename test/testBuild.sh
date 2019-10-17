#!/bin/bash

if [ "${DEBUGGING}" = "true" ]; then
	set -o xtrace
fi

set -o errexit
set -o nounset
set -o pipefail

echo "build FTBBase"
docker build -t "jusito/docker-ftb-alpine:FTBBase" "base/"

(
cd "modpacks"
for modpack in *
do
	(
	cd "$modpack"
	for version in *
	do
		echo "[testBuild][INFO]build ${modpack}-${version}"
		docker rmi "jusito/docker-ftb-alpine:${modpack}-${version}" || true
		docker build -t "jusito/docker-ftb-alpine:${modpack}-${version}" "${version}/."
	done
	)
done
)
