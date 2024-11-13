#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "kit/helper.sh"
export KUBE_ROOT=$(dirname "$(readlink -f "$0")")/../src/github.com/kubernetes/kubernetes/
export TERM=linux
echo "KUBE_ROOT directory: $KUBE_ROOT"
cd "${WORKDIR}"

# Kubeadm was added for testing in 1.19 and later
for n in {1..5}; do
    echo "+++ Test retry ${n}"
    ./build/shell.sh -c '

# before v1.25
make generated_files kubeadm
# after v1.26
./build/run.sh make all WHAT=cmd/kubeadm

mkdir -p _output/local/go/bin/ && cp _output/dockerized/bin/linux/amd64/kubeadm _output/local/go/bin/
./hack/install-etcd.sh
TERM=linux PATH=$(pwd)/third_party/etcd:${PATH} make test-cmd
' 2>&1 | grep -v -E '^I\w+ ' && exit 0
done
