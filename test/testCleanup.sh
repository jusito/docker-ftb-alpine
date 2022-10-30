#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testCaseCleaning] starting..."

docker rmi "$(docker images -q "${REPO}")"

echo "[testCaseCleaning] images not cleaned:"
docker images "${REPO}"