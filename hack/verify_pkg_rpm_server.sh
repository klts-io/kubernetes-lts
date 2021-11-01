#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "kit/helper.sh"
cd "${ROOT}"

./hack/pkg_rpm.sh kubeadm,kubelet amd64
