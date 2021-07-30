#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${WORKDIR}"

./build/run.sh make test-e2e-node 2>&1 | grep -v -E '^I\w+ '
