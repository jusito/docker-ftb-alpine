#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh

readonly tag="$1"

echo "[testRun][INFO] starting tag=$tag"
docker stop "$TEST_CONTAINER" || true
docker rm "$TEST_CONTAINER" || true
if ! docker run -ti --name "$TEST_CONTAINER" --rm -e TEST_MODE=true -e DEBUGGING="${DEBUGGING}" "${REPO}:$tag"; then
	echo "[testRun][ERROR] run test failed for $tag"
	exit 1
fi
docker stop "$TEST_CONTAINER" || true
docker rm "$TEST_CONTAINER" || true

echo "[testRun][INFO] successful! tag=$tag"