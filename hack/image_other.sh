#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${WORKDIR}"

VERSION=$(helper::workdir::version)

./build/run.sh make kubeadm 2>&1 | grep -v -E '^I\w+ '

IMAGE=$(KUBE_RUN_COPY_OUTPUT=n ./build/run.sh ./_output/bin/kubeadm config --kubernetes-version "${VERSION}" images list | grep -v '+++' | grep -v "/kube-" | sed -E 's/\s+/ /g' | sed 's/-amd64:/:/g')

cd "${ROOT}"
./hack/image_manifest_retags.sh ${IMAGE}
