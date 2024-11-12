#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

KUBE_ROOT=$(dirname "${BASH_SOURCE[0]}")/..

source "kit/helper.sh"
cd "${WORKDIR}"

# Kubeadm was added for testing in 1.19 and later
for n in {1..5}; do
    echo "+++ Test retry ${n}"
    ./build/shell.sh -c '

make all -C "${KUBE_ROOT}" WHAT=cmd/kubeadm
mkdir -p _output/local/go/bin/ && cp _output/dockerized/bin/linux/amd64/kubeadm _output/local/go/bin/
./hack/install-etcd.sh
PATH=$(pwd)/third_party/etcd:${PATH} make test-cmd
' 2>&1 | grep -v -E '^I\w+ ' && exit 0
done
