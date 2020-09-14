#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh

readonly admin1="terzut"
readonly admin2="drunkenmonkey"
readonly tag=$1
echo "[testAddOp][INFO] starting tag=$tag"

docker stop "$TEST_CONTAINER" || true
docker rm "$TEST_CONTAINER" || true
docker run -d \
 --name "$TEST_CONTAINER" \
 -e DEBUGGING="${DEBUGGING}" \
 -e JAVA_PARAMETERS="-Xms2G -Xmx2G" \
 -e ADMIN_NAME="$admin1" \
 "${REPO}:$tag"

await "$TEST_CONTAINER" "/home/docker/logs/latest.log" "]: Done ("
if docker exec "$TEST_CONTAINER" grep -q "$admin1" "/home/docker/ops.json"; then
	echo "[testAddOp][INFO] found first op"
else
	echo "[testAddOp][ERROR] found no op"
	exit 31
fi

docker exec "$TEST_CONTAINER" /home/addOp.sh "" "$admin2" "" ""

docker restart "$TEST_CONTAINER"
docker exec "$TEST_CONTAINER" rm /home/docker/logs/latest.log
await "$TEST_CONTAINER" "/home/docker/logs/latest.log" "]: Done ("
#docker exec "$TEST_CONTAINER" ls -lA /home #debug OUT
#docker exec "$TEST_CONTAINER" ls -lA /home/docker #debug OUT
if docker exec "$TEST_CONTAINER" grep -q "$admin1" "/home/docker/ops.json"; then
	if docker exec "$TEST_CONTAINER" grep -q "$admin2" "/home/docker/ops.json"; then
		echo "[testAddOp][INFO] found both ops"
	else
		echo "[testAddOp][ERROR] found only first op"
		exit 10
	fi
else
	if docker exec "$TEST_CONTAINER" grep -q "$admin2" "/home/docker/ops.json"; then
		echo "[testAddOp][ERROR] found only second"
		exit 20
	else
		echo "[testAddOp][ERROR] found no op"
		exit 30
	fi
fi

docker stop "$TEST_CONTAINER" || true
docker rm "$TEST_CONTAINER" || true
echo "[testAddOp][INFO] successful!"