#!/bin/bash

set -e

echo "build FTBBase"
docker build -t "jusito/docker-ftb-alpine:FTBBase" .

for tag in $(ls modpacks)
do
	echo "[testBuild][INFO]build modpacks/$tag"
	docker rmi "jusito/docker-ftb-alpine:$tag"
	docker build -t "jusito/docker-ftb-alpine:$tag" "modpacks/$tag"
done
