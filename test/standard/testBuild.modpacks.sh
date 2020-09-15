#!/bin/bash

imageSuffix="$1"
if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testBuild.modpacks][INFO] starting... with suffix $imageSuffix"

for modpack in "${MODPACKS[@]}"; do
	bash test/standard/testBuild.sh "$(getImageTag "$modpack")$imageSuffix" modpacks/"$(getImagePath "$modpack")" "." "--build-arg imageSuffix=$imageSuffix"
done

echo "[testBuild.modpacks][INFO] successful!"