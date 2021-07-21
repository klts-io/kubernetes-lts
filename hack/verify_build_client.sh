#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT="$(dirname "${BASH_SOURCE}")/.."
OUTPUT="../release"
WORKDIR="${ROOT}/workdir"
cd "${WORKDIR}"

KUBE_BUILD_PLATFORMS=(
    linux/amd64
)

./build/run.sh make KUBE_BUILD_PLATFORMS="${KUBE_BUILD_PLATFORMS}" kubectl | grep -v -E '^I\w+ '
