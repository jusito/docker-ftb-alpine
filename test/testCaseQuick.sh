#!/bin/bash

set -euxo pipefail

(
	cd "$(dirname "$0")/.."

	# shellcheck disable=SC1091
	. test/shared/shared.sh
	
	IMAGE="$DEFAULT_TAG"
	STYLE="true"
	HEALTH="false"
	ADD_OP="false"
	BUILD_BASE="true"
	while [ $# -ge 1 ]; do
		key="$1"
		shift

		case "$key" in
			-h|--help)
				echo "[help][multiple] testing every feature of specified server"
				echo "[help][multiple] full.sh [option] [server]"
				echo "[help][multiple] "
				echo "[help][multiple] options:"
				echo "[help][multiple] -a --all        enable all checks"
				echo "[help][multiple] -h --health     enable health check testing"
				echo "[help][multiple] -ns --no-style  disable style check"
				echo "[help][multiple] -op --add-op    enable add op feature testing"
				exit 0;;
			-a|--all)
				HEALTH="true"
				ADD_OP="true";;
			-ns|--no-style)
				STYLE="true";;
			*)
				if [ "$IMAGE" = "$DEFAULT_TAG" ]; then
					IMAGE="$key"
					echo "[info][multiple] using image $IMAGE"
					
				else
					echo "[error][multiple] image=\"$IMAGE\" but got additional image name I can't handle \"$key\""
					exit 1
				fi
				;;
		esac
	done

	if "$STYLE"; then
		bash test/testCaseStyle.sh
	fi

	if "$BUILD_BASE"; then
		bash test/standard/testBuild.bases.sh
	fi

	echo "[testCaseQuick][INFO] build modpacks/${IMAGE}"
	docker rmi "${REPO}:${IMAGE}" || true
	bash test/standard/testBuild.sh "${IMAGE}" "$(echo "${IMAGE}/." | sed 's/-/\//')" "modpacks"
	echo "[testCaseQuick][INFO] running ${IMAGE}"
	if bash test/standard/testRun.sh "${IMAGE}"; then
		docker stop "${TEST_CONTAINER}"
		echo "[testCaseQuick][INFO] run is fine, try to rerun"
		if bash test/standard/testRun.sh "${IMAGE}"; then
			echo "[testCaseQuick][INFO] could restart server"
		else
			echo "[testCaseQuick][ERROR] failed to rerun"
			docker logs -n 100 "${TEST_CONTAINER}"
		fi
	fi
	docker stop "${TEST_CONTAINER}" > /dev/null 2>&1 || true
	docker rm "${TEST_CONTAINER}" > /dev/null 2>&1  || true

	if "$HEALTH"; then
		bash test/features/testHealth.sh "${IMAGE}"
	fi

	if "$ADD_OP"; then
		bash test/features/testAddOp.sh "${IMAGE}"
	fi

	echo "[testCaseQuick] tag=${IMAGE} successful!"
)
