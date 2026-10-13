#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testRun.modpacks][INFO] starting ..."

error="false"
for modpack in "${MODPACKS[@]}"; do
	if bash test/standard/testRun.sh "$(getImageTag "$modpack")"; then
		error="true"
	fi
done


if [ "$error" = "false" ]; then
	echo "[testRun.modpacks][INFO] successful!"
else
	echo "[testRun.modpacks][ERROR] failed see above!"
fi
