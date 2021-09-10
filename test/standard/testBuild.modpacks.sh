#!/bin/bash

imageSuffix="$1"
if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testBuild.modpacks][INFO] starting... with suffix $imageSuffix"

for modpack in "${MODPACKS[@]}"; do
  # build default
  bash test/standard/testBuild.sh "$(getImageTag "$modpack")$imageSuffix" modpacks/"$(getImagePath "$modpack")" "." "--build-arg imageSuffix=$imageSuffix"

  # shellcheck disable=SC2044
  for baseImage in $(find "$(getImagePath "$modpack")" -type f -iname "*.base" -exec grep -Po '^.*(?=.base)' \;); do
    bash test/standard/testBuild.sh "$(getImageTag "$modpack")-$baseImage$imageSuffix" modpacks/"$(getImagePath "$modpack")" "." "--build-arg imageSuffix=$imageSuffix --build-arg imageBase=$baseImage"
	done
done

echo "[testBuild.modpacks][INFO] successful!"
