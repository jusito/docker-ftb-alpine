#!/bin/bash

if [ "${DEBUGGING}" = "true" ]; then
	set -o xtrace
fi

set -o errexit
set -o nounset
set -o pipefail

echo "build FTBBase"
docker build -t "jusito/docker-ftb-alpine:FTBBase" .

# shellcheck disable=SC2045
for tag in $(ls modpacks) #ls is fragile
do
	echo "[testBuild][INFO]build modpacks/$tag"
	docker rmi "jusito/docker-ftb-alpine:$tag" || true
	docker build -t "jusito/docker-ftb-alpine:$tag" "modpacks/$tag"
done
