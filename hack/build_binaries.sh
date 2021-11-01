#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "kit/helper.sh"
cd "${WORKDIR}"

KUBE_BUILD_PLATFORMS=(
    linux/amd64
    linux/arm64
)
for platform in ${KUBE_BUILD_PLATFORMS[*]}; do
    ./build/run.sh make KUBE_BUILD_PLATFORMS="${platform}" kubectl kubelet kubeadm  2>&1 | grep -v -E '^I\w+ ' || echo "fail ${platform}"
done
TARGETS=$(ls _output/dockerized/bin/*/*/{kubectl,kubelet,kubeadm})

rm -rf "${OUTPUT}"
mkdir -p "${OUTPUT}"
for target in $TARGETS; do
    dist=${target#_output/dockerized/bin/}
    mkdir -p "${OUTPUT}/${dist}"
    cp "${target}" "${OUTPUT}/${dist}/"
done
