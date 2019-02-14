#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

docker run -ti --rm \
 --name "JusitoTesting" \
 -e TEST_MODE=true -e JAVA_PARAMETERS="-Xms1G -Xmx1G" \
 -e ADMIN_NAME=terzut \
 "jusito/docker-ftb-alpine:Vanilla"
