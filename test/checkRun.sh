#!/bin/sh

set -e

for tag in $(ls modpacks)
do
	echo "running $tag"
	docker run -ti --rm --name "$tag" -e TEST_ONLY=true -e JAVA_PARAMETERS="-Xms1G -Xmx1G" -e motd="test" "jusito/docker-ftb-alpine:$tag"
done