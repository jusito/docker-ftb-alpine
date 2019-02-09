#!/bin/sh

set -e

echo "build FTBBase"
docker build -t "jusito/docker-ftb-alpine:FTBBase" .

for tag in $(ls modpacks)
do
	echo "build modpacks/$tag"
	docker build -t "jusito/docker-ftb-alpine:$tag" "modpacks/$tag"
done