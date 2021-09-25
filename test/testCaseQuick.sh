#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh

set +o nounset
readonly IMAGE_TAG="$([ -n "$1" ] && echo "$1" || echo "$DEFAULT_TAG")"
readonly CHECK_STYLE="$(grep -q 'test-style' <<< "$@" && echo "true" || echo "false")"
readonly BUILD_BASES="$(grep -q 'build-bases' <<< "$@" && echo "true" || echo "false")"
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

  if grep -qE "$IMAGE_TAG" <<< "$name" || grep -qE "$IMAGE_TAG" <<< "$directory"; then
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
        if [ "$baseImage" != "default" ]; then
          touch "$directory/$baseImage.base"
        fi
      else
        rm "$directory/$baseImage.base" || true
      fi

      if "$TEST_FEATURES"; then
        bash test/features/testHealth.sh "$IMAGE_TAG"
        bash test/features/testAddOp.sh "$IMAGE_TAG"
      fi
    done

    # set default base
    if "$TEST_BASES"; then
      successful_bases=()
      mapfile -t successful_bases < <(cd "$directory" > /dev/null && find . -type f -iname "*.base" | sed -E 's/^.\///g' | sed -E 's/.base$//g' | sort -g)
      new_default_base=""
      # check for hotspot
      for base_successful in "${successful_bases[@]}"; do
        if grep -qE -e '-hotspot$' <<< "$base_successful"; then
          new_default_base="$base_successful"
          break
        fi
      done
      # no hotspot found (weird) take first
      if [ -z "$new_default_base" ] && [ "${#successful_bases[@]}" -gt "0" ]; then
        new_default_base="${successful_bases[0]}"
      fi
      echo "[testCaseBaseImageSupport][INFO] $name new default base image is: ${new_default_base:-"none because no run successful"}"

      sed -Ei "s/jusito\/docker-ftb-alpine:[^#]*/jusito\/docker-ftb-alpine:$new_default_base/g" "$directory/docker-compose.yml" || true
      sed -Ei "s/imageBase=\"[^\"]*/imageBase=\"$new_default_base/g" "$directory/Dockerfile" || true
    fi
  fi
done
