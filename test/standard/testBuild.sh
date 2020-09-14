#!/bin/bash

readonly ADDIDIONAL_DOCKER_ARGS="$4"

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testBuild][INFO] starting..."

readonly TAG="$1"
readonly DOCKERFILE_PATH="$2/Dockerfile"
readonly WORKDIR="$3"


echo "[testBuild][INFO] building tag=${TAG} from file=${DOCKERFILE_PATH}"
(
	if cd "$WORKDIR"; then
		docker rmi "${REPO}:${TAG}" || true
		#shellcheck disable=SC2086
		docker build $ADDIDIONAL_DOCKER_ARGS -t "${REPO}:${TAG}" -f "${DOCKERFILE_PATH}" "."
	fi
)
echo "[testBuild][INFO] successful!"