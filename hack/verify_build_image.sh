#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "kit/helper.sh"
cd "${WORKDIR}"

KUBE_BUILD_PLATFORMS=(
    linux/amd64
)

make KUBE_GIT_TREE_STATE=clean KUBE_BUILD_HYPERKUBE=n KUBE_BUILD_CONFORMANCE=n KUBE_BUILD_PULL_LATEST_IMAGES=n KUBE_RELEASE_RUN_TESTS=n KUBE_BUILD_PLATFORMS="${KUBE_BUILD_PLATFORMS}" release-images || echo "image build failed"

WANTS=(
    kube-controller-manager
    kube-scheduler
    kube-apiserver
    kube-proxy
)
TARGETS=$(ls _output/release-images/*/*.tar)
FAILD=false
for want in ${WANTS}; do
    if ! [[ "${TARGETS}" =~ "${want}.tar" ]]; then
        FAILD=true
        echo "Missing ${want}.tar"
    fi
done

if [[ "${FAILD}" == true ]]; then
    exit 1
fi
