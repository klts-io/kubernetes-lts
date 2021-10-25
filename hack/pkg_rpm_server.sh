#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${ROOT}"

VERSION=$(helper::workdir::version)
RELEASE="${VERSION##*-}"
VERSION="${VERSION%-*}"

if [[ "${VERSION}" == "${RELEASE}" ]]; then
  RELEASE="00"
fi

./hack/pkg_rpm.sh kubeadm,kubelet amd64,arm64,arm,ppc64le,s390x "${VERSION}" "${RELEASE}"
