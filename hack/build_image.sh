#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT="$(dirname "${BASH_SOURCE}")/.."
WORKDIR="${ROOT}/workdir"
cd "${WORKDIR}"

KUBE_BUILD_PLATFORMS=(
    linux/amd64
    linux/arm
    linux/arm64
    linux/s390x
    linux/ppc64le
)
for platform in ${KUBE_BUILD_PLATFORMS[*]} ; do
    make KUBE_BUILD_HYPERKUBE=n KUBE_BUILD_CONFORMANCE=n KUBE_BUILD_PULL_LATEST_IMAGES=n KUBE_RELEASE_RUN_TESTS=n KUBE_BUILD_PLATFORMS="${platform}" KUBE_DOCKER_REGISTRY="${KUBE_DOCKER_REGISTRY}" release-images || echo "fail ${platform}"
done
