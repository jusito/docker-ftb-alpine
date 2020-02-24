#!/bin/sh

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testStyle.docker][INFO] starting..."

readonly PATH_DOCKERFILE="$1/Dockerfile"
readonly PATH_CHECK_HEALTH="$(grep -Eo 'COPY.+checkHealth.sh' "base/${PATH_DOCKERFILE}" | grep -Eo '[^"]+$')"

if ! printf '%s  %s' "$(grep -Eo "grep -Eq '\^[^\\]+" "base/${PATH_DOCKERFILE}" | sed 's/...........//')" "base/${PATH_CHECK_HEALTH}" | sha3sum -c ; then
	echo "[testStyle.Docker][ERROR] Sha3sum of ${PATH_CHECK_HEALTH} in base/${PATH_DOCKERFILE} invalid"
	exit 2
fi

# shellcheck disable=SC2181
if [ "$?" = "0" ]; then
	echo "[testStyle.docker][INFO] all elements passed style check"
	exit 0
else
	echo "[testStyle.docker][ERROR] style in at least one element looks bad"
	exit 1
fi
echo "[testStyle.docker][INFO] successful!"