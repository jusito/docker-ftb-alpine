#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testCaseAll] starting..."

bash test/testCaseStyle.sh
bash test/Cleanup.sh

echo "[testCaseAll] process standard tests"
# build base images
bash test/standard/testBuild.bases.sh

# test modpacks
bash test/standard/testBuild.modpacks.sh
bash test/standard/testRun.modpacks.sh

# test features
echo "[testCaseAll] process feature tests"
bash test/features/testHealth.sh "$DEFAULT_TAG"
bash test/features/testAddOp.sh "$DEFAULT_TAG"

echo "[testCaseAll] successful!"