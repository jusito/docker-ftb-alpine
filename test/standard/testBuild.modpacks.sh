#!/bin/bash

imageSuffix="$1"
if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testBuild.modpacks][INFO] starting... with suffix $imageSuffix"

error="false"
for modpack in "${MODPACKS[@]}"; do
	if bash test/standard/testBuild.sh "$(getImageTag "$modpack")$imageSuffix" modpacks/"$(getImagePath "$modpack")" "." "--build-arg imageSuffix=$imageSuffix"; then
		error="true"
	fi
done

if [ "$error" = "false" ]; then
	echo "[testBuild.modpacks][INFO] successful!"
else
	echo "[testBuild.modpacks][ERROR] failed, see above!"
fi
