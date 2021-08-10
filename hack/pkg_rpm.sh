#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"

NAMES="${1:-kubelet}"
ARCHS="${2:-amd64}"
VERSION=$(helper::workdir::version)
RELEASE="${VERSION##*-}"
VERSION="${VERSION%-*}"

SRC="${ROOT}/hack/rpm"
RPMBUILD="${ROOT}/rpmbuild"
RPMREPO="${REPOSDIR}/rpm"
BIN_PATH="${WORKDIR}/_output/dockerized/bin"

docker build -t rpm-builder "${SRC}"

docker run --rm -v "${SRC}:/root/src" -v "${BIN_PATH}:/root/output/bin" -v "${RPMBUILD}:/root/rpmbuild/" -v "${RPMREPO}:/root/rpmrepo/" rpm-builder "${NAMES}" "${ARCHS}" "${VERSION}" "${RELEASE}"
