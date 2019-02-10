#!/bin/bash

set -e

# Travis debugging
#for tag in $(ls modpacks)
#do
#	echo "running $tag"
#	docker run -ti --rm --name "$tag" -e TEST_MODE=true -e JAVA_PARAMETERS="-Xms1G -Xmx1G" -e motd="test" "jusito/docker-ftb-alpine:$tag"
#done
docker run -ti --rm --name "Vanilla" -e TEST_MODE=true -e JAVA_PARAMETERS="-Xms1G -Xmx1G" -e motd="test" "jusito/docker-ftb-alpine:Vanilla"
