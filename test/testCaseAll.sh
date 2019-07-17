#!/bin/bash

export DEBUGGING=false
export DEFAULT_IMAGE="Vanilla-1.14.3"
if [ "${DEBUGGING}" = "true" ]; then
	set -o xtrace
fi

set -o errexit
set -o nounset
set -o pipefail

bash test/testStyle.sh
bash test/testBuild.sh
bash test/testRun.sh
bash test/testHealth.sh
bash test/testAddOp.sh