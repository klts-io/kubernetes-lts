#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${ROOT}"

./hack/pkg_rpm.sh cri-tools amd64,arm64,arm,ppc64le,s390x 1.13.0
./hack/pkg_rpm.sh kubernetes-cni amd64,arm64,arm,ppc64le,s390x 0.8.7
