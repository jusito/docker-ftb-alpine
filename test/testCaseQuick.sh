#!/bin/bash

set -euo pipefail

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
				echo "[help][quick] testing every feature of specified server"
				echo "[help][quick] full.sh [option] [server]"
				echo "[help][quick] "
				echo "[help][quick] options:"
				echo "[help][quick] -a --all        enable all checks"
				echo "[help][quick] -h --health     enable health check testing"
				echo "[help][quick] -ns --no-style  disable style check"
				echo "[help][quick] -op --add-op    enable add op feature testing"
				exit 0;;
			-a|--all)
				HEALTH="true"
				ADD_OP="true";;
			-ns|--no-style)
				STYLE="true";;
			*)
				if [ "$IMAGE" = "$DEFAULT_TAG" ]; then
					IMAGE="$key"
					echo "[info][quick] using image $IMAGE"
					
				else
					echo "[error][quick] image=\"$IMAGE\" but got additional image name I can't handle \"$key\""
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

	echo "[info][quick] build modpacks/${IMAGE}"
	docker rmi "${REPO}:${IMAGE}" || true
	bash test/standard/testBuild.sh "${IMAGE}" "$(echo "${IMAGE}/." | sed 's/-/\//')" "modpacks"
	rm test/quick.run1.log test/quick.run2.log > /dev/null 2>&1 || true
	echo "[info][quick] running ${IMAGE} log: \"test/quick.run1.log\""
	successful="false"
	if bash test/standard/testRun.sh "${IMAGE}" > test/quick.run1.log 2>&1; then
		docker stop "${TEST_CONTAINER}"
		echo "[info][quick] run is fine, try to rerun log: \"test/quick.run2.log\""
		if docker start -ai "${TEST_CONTAINER}" > test/quick.run2.log 2>&1; then
			echo "[info][quick] could restart server"
			docker stop "${TEST_CONTAINER}" > /dev/null 2>&1 || true
			docker rm "${TEST_CONTAINER}" > /dev/null 2>&1  || true

			if "$HEALTH"; then
				bash test/features/testHealth.sh "${IMAGE}"
			fi

			if "$ADD_OP"; then
				bash test/features/testAddOp.sh "${IMAGE}"
			fi
			successful="true"
		else
			docker logs -n 100 "${TEST_CONTAINER}"
			echo "[error][quick] failed to rerun"
		fi
	else 
		docker logs -n 100 "${TEST_CONTAINER}"
		echo "[error][quick] run failed"
	fi
	docker stop "${TEST_CONTAINER}" > /dev/null 2>&1 || true
	docker rm "${TEST_CONTAINER}" > /dev/null 2>&1  || true

	if "$successful"; then
		echo "[info][quick] tag=${IMAGE} successful!"
	else
		exit 1
	fi
)
