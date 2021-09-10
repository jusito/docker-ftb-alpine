#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testRun.modpacks][INFO] starting ..."

for modpack in "${MODPACKS[@]}"; do
	bash test/standard/testRun.sh "$(getImageTag "$modpack")"

	# shellcheck disable=SC2044
  for baseImage in $(find "$(getImagePath "$modpack")" -type f -iname "*.base" -exec grep -Po '^.*(?=.base)' \;); do
    bash test/standard/testRun.sh "$(getImageTag "$modpack")-$baseImage$imageSuffix"
  done
done

echo "[testRun.modpacks][INFO] successful!"
