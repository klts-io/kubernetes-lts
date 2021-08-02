#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${WORKDIR}"

for n in {1..5}; do
    echo "+++ Test retry ${n}"
    ./build/run.sh make test-cmd 2>&1 | grep -v -E '^I\w+ ' && exit 0
done
