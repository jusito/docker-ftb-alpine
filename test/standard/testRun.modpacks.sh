#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testRun.modpacks][INFO] starting ..."

for modpack in "${MODPACKS[@]}"; do
	bash testRun.sh "$(getImageTag "$modpack")"
done

echo "[testRun.modpacks][INFO] successful!"