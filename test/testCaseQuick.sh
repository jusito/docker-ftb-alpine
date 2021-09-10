#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh

set +o nounset
readonly IMAGE_TAG="$([ -n "$1" ] && echo "$1" || echo "$DEFAULT_TAG")"
readonly CHECK_STYLE="$(grep -q 'test-style' <<< "$@" && echo "true" || echo "false")"
readonly BUILD_BASES="$(grep -q 'skip-base' <<< "$@" && echo "false" || echo "true")"
readonly TEST_FEATURES="$(grep -q 'test-features' <<< "$@" && echo "true" || echo "false")"
readonly TEST_BASES="$(grep -q 'test-bases' <<< "$@" && echo "true" || echo "false")"
set -o nounset
echo "[testCaseQuick] tag_filter=${IMAGE_TAG}"
echo "[testCaseQuick] shellcheck_enabled=${CHECK_STYLE}"
echo "[testCaseQuick] build_base_images=${BUILD_BASES}"
echo "[testCaseQuick] test_features=${TEST_FEATURES}"
echo "[testCaseQuick] test_base_support=${TEST_BASES}"
echo "[testCaseQuick] starting..."

if "$CHECK_STYLE"; then
	bash test/testCaseStyle.sh
fi
if "$BUILD_BASES"; then
	echo "[testCaseQuick] build bases"
	bash test/standard/testBuild.bases.sh
fi


for modpack in "${MODPACKS[@]}"; do
  name="$(getImageTag "$modpack")"
  directory="modpacks/${name//-*/}/${name//${name//-*/}-/}"

  if grep -qF "$IMAGE_TAG" <<< "$name" || grep -qF "$IMAGE_TAG" <<< "$directory"; then
    loop=("default")
    if "$TEST_BASES"; then
      loop=("${BASE_IMAGES[@]}")
    fi
    for baseImage in "${loop[@]}"; do
      baseImage="${baseImage//!/-}"
      echo -e '\n\n\n'; echo "[testCaseBaseImageSupport][INFO] testing compatibility for $baseImage for $name"

      # build it
      if [ "$baseImage" == "default" ]; then
        bash test/standard/testBuild.sh "${name}" "$directory" "."
      else
        bash test/standard/testBuild.sh "${name}" "$directory" "." "--build-arg imageBase=$baseImage"
      fi

      # run it once
      if bash test/standard/testRun.sh "${name}"; then
        touch "$directory/$baseImage.base"
      else
        rm "$directory/$baseImage.base" || true
      fi

      if "$TEST_FEATURES"; then
        bash test/features/testHealth.sh "$IMAGE_TAG"
        bash test/features/testAddOp.sh "$IMAGE_TAG"
      fi
    done
  fi
done
