#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

export DEBUG_MODE=true

bash test/testStyle.sh
bash test/testBuild.sh
#bash test/testRun.sh
bash test/testHealth.sh