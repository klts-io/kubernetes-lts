#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "kit/helper.sh"
KUBE_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
cd "${WORKDIR}"

# Kubeadm was added for testing in 1.19 and later
for n in {1..5}; do
    echo "+++ Test retry ${n}"
    ./build/shell.sh -c '

# before v1.25
make generated_files kubeadm
# after v1.26
make all -C "${KUBE_ROOT}" WHAT=cmd/kubeadm

mkdir -p _output/local/go/bin/ && cp _output/dockerized/bin/linux/amd64/kubeadm _output/local/go/bin/
./hack/install-etcd.sh
PATH=$(pwd)/third_party/etcd:${PATH} make test-cmd
' 2>&1 | grep -v -E '^I\w+ ' && exit 0
done
