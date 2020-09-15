#!/bin/bash

imageSuffix="$1"
if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testBuild.bases][INFO] starting... with suffix $imageSuffix"

for baseImage in "${BASE_IMAGES[@]}"; do
	bash test/standard/testBuild.sh "$(getImageTag "$baseImage")$imageSuffix" "base/$(getImagePath "$baseImage")" "." "--pull --build-arg imageSuffix=$imageSuffix"
done

echo "[testBuild.bases][INFO] successful!"