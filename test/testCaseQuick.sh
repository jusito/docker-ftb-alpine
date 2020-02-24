#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh

echo "[testCaseQuick] starting..."
set +o nounset
if [ -n "$1" ]; then
	IMAGE_TAG="$1"
else
	IMAGE_TAG="$DEFAULT_TAG"
fi
set -o nounset
echo "[testCaseQuick] tag=${IMAGE_TAG}"

set +o nounset
if [ "$2" != "skipStyle" ]; then
	bash test/testCaseStyle.sh
fi
if [ "$3" != "skipBase" ]; then
	echo "[testCaseQuick] build bases"
	bash test/standard/testBuild.bases.sh
fi
set -o nounset


echo "[testCaseQuick][INFO] build modpacks/${IMAGE_TAG}"
docker rmi "${REPO}:${IMAGE_TAG}" || true
bash test/standard/testBuild.sh "${IMAGE_TAG}" "$(echo "${IMAGE_TAG}/." | sed 's/-/\//')" "modpacks"
echo "[testCaseQuick][INFO] running ${IMAGE_TAG}"
bash test/standard/testRun.sh "${IMAGE_TAG}"
docker stop "${TEST_CONTAINER}" || true
docker rm "${TEST_CONTAINER}" || true

set +o nounset
if [ "$4" != "skipFeatures" ]; then
	bash test/features/testHealth.sh "$IMAGE_TAG"
	bash test/features/testAddOp.sh "$IMAGE_TAG"
fi
set -o nounset

echo "[testCaseQuick] tag=${IMAGE_TAG} successful!"