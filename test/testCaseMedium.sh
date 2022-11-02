#!/bin/bash

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh
echo "[testCaseMedium] starting..."

# check style first
bash test/testCaseStyle.sh

# build base images
bash test/standard/testBuild.bases.sh

bash test/testCaseQuick.sh "$DEFAULT_TAG" "skipStyle" "skipBase"
bash test/testCaseQuick.sh "FTBPresentsSkyfactory3-3.0.15-1.10.2" "skipStyle" "skipBase"
bash test/testCaseQuick.sh "FTBRevelation-3.0.1-1.12.2" "skipStyle" "skipBase"
bash test/testCaseQuick.sh "FTBInferno-1.1.1-1.18.2" "skipStyle" "skipBase"

echo "[testCaseMedium] successful!"