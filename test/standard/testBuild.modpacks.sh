#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testBuild.modpacks][INFO] starting..."

for modpack in "${MODPACKS[@]}"; do
	bash test/standard/testBuild.sh "$(getImageTag "$modpack")" "$(getImagePath "$modpack")" "modpacks"
done

echo "[testBuild.modpacks][INFO] successful!"