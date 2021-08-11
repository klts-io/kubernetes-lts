#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"

NAMES="${1:-}"
ARCHS="${2:-}"
VERSION="${3:-}"
RELEASE="${4:-}"

SRC="${ROOT}/hack/rpm"
RPMBUILD="${ROOT}/rpmbuild"
RPMREPO="${REPOSDIR}/rpm"
BIN_PATH="${WORKDIR}/_output/dockerized/bin"

docker build -t rpm-builder "${SRC}"

docker run --rm -v "${SRC}:/root/src" -v "${BIN_PATH}:/root/output/bin" -v "${RPMBUILD}:/root/rpmbuild/" -v "${RPMREPO}:/root/rpmrepo/" rpm-builder "${NAMES}" "${ARCHS}" "${VERSION}" "${RELEASE}"
