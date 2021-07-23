#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${WORKDIR}"

KUBE_BUILD_PLATFORMS=(
    linux/amd64
)

./build/run.sh make KUBE_BUILD_PLATFORMS="${KUBE_BUILD_PLATFORMS}" kubectl 2>&1 | grep -v -E '^I\w+ ' || echo "client build failed"

WANTS=(
    kubectl
)
TARGETS=$(ls _output/dockerized/bin/*/*/*)
FAILD=false
for want in ${WANTS}; do
    if ! [[ "${TARGETS}" =~ "${want}" ]]; then
        FAILD=true
        echo "Missing ${want}"
    fi
done

if [[ "${FAILD}" == true ]]; then
    exit 1
fi
