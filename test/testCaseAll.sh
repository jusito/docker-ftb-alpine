#!/bin/bash

set -e

bash test/testBuild.sh
bash test/testRun.sh
bash test/testHealth.sh