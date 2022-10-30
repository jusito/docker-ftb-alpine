#!/bin/bash
### check style

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh

echo "[testCaseStyle] check style"
for baseImage in "${BASE_IMAGES[@]}"; do
	bash test/standard/testStyle.docker.sh "$(getImagePath "$baseImage")"
done
bash test/standard/testStyle.shell.sh

echo "[testCaseStyle] successful!"