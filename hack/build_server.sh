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
    linux/arm
    linux/arm64
    linux/s390x
    linux/ppc64le
)
for platform in ${KUBE_BUILD_PLATFORMS[*]} ; do
    ./build/run.sh make KUBE_BUILD_PLATFORMS="${platform}" kubelet kubeadm 2>&1 | grep -v -E '^I\w+ ' || echo "fail ${platform}"
done
targets=$(ls _output/dockerized/bin/*/*/{kubelet,kubeadm})
echo cp "${targets}" "${OUTPUT}"
mkdir -p "${OUTPUT}"
for target in $targets; do
    dist=$(echo ${target} | sed 's#_output/dockerized/bin/##' | tr '/' '-' )
    cp "${target}" "${OUTPUT}/${dist}"
done
