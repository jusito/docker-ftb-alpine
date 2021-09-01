#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh

set +o nounset
readonly IMAGE_TAG="$([ -n "$1" ] && echo "$1" || echo "$DEFAULT_TAG")"
readonly CHECK_STYLE="$(grep -q 'skipStyle' <<< "$@" && echo "false" || echo "true")"
readonly BUILD_BASES="$(grep -q 'skipBase' <<< "$@" && echo "false" || echo "true")"
readonly TEST_FEATURES="$(grep -q 'skipFeatures' <<< "$@" && echo "false" || echo "true")"
set -o nounset
echo "[testCaseQuick] tag=${IMAGE_TAG}"
echo "[testCaseQuick] shellcheck_enabled=${CHECK_STYLE}"
echo "[testCaseQuick] build_base_images=${BUILD_BASES}"
echo "[testCaseQuick] test_features=${TEST_FEATURES}"
echo "[testCaseQuick] starting..."

if "$CHECK_STYLE"; then
	bash test/testCaseStyle.sh
fi
if "$BUILD_BASES"; then
	echo "[testCaseQuick] build bases"
	bash test/standard/testBuild.bases.sh
fi


echo "[testCaseQuick][INFO] build modpacks/${IMAGE_TAG}"
docker rmi "${REPO}:${IMAGE_TAG}" || true
bash test/standard/testBuild.sh "${IMAGE_TAG}" "$(echo "${IMAGE_TAG}/." | sed 's/-/\//')" "modpacks"
echo "[testCaseQuick][INFO] running ${IMAGE_TAG}"
bash test/standard/testRun.sh "${IMAGE_TAG}"
docker stop "${TEST_CONTAINER}" || true
docker rm "${TEST_CONTAINER}" || true

if "$TEST_FEATURES"; then
	bash test/features/testHealth.sh "$IMAGE_TAG"
	bash test/features/testAddOp.sh "$IMAGE_TAG"
fi

echo "[testCaseQuick] tag=${IMAGE_TAG} successful!"