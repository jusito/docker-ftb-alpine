#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testBuild.bases][INFO] starting..."

for baseImage in "${BASE_IMAGES[@]}"; do
	bash test/standard/testBuild.sh "$(getImageTag "$baseImage")" "$(getImagePath "$baseImage")" "base"
done

echo "[testBuild.bases][INFO] successful!"