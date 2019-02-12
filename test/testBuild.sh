#!/bin/bash

set -e

echo "build FTBBase"
docker build -t "jusito/docker-ftb-alpine:FTBBase" .

for tag in $(ls modpacks)
do
	echo "[testBuild][INFO]build modpacks/$tag"
	docker build -t "jusito/docker-ftb-alpine:$tag" "modpacks/$tag"
done
