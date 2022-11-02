#!/bin/bash
### check style

set -euo pipefail

(
	cd "$(dirname "$0")/.."
	# shellcheck disable=SC1091
	. test/shared/shared.sh

	echo "[testCaseStyle] check style"
	for baseImage in "${BASE_IMAGES[@]}"; do
		bash test/standard/testStyle.docker.sh "$(getImagePath "$baseImage")"
	done
	bash test/standard/testStyle.shell.sh

	echo "[testCaseStyle] successful!"
)
