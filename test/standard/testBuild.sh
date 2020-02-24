#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testBuild][INFO] starting..."

readonly TAG="$1"
readonly DOCKERFILE_PATH="$2/Dockerfile"
readonly WORKDIR="$3"
readonly INITIAL="$PWD"

echo "[testBuild][INFO] building tag=${TAG} from file=${DOCKERFILE_PATH}"
if cd "$WORKDIR"; then
	docker build -t "${REPO}:${TAG}" -f "${DOCKERFILE_PATH}" "."
	cd "$INITIAL"
fi

echo "[testBuild][INFO] successful!"