#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"

NAMES="${1:-}"
ARCHS="${2:-}"
VERSION="${3:-}"
RELEASE="${4:-}"

SRC="${ROOT}/hack/deb"
DEBBUILD="${ROOT}/debbuild"
DEBREPO="${REPOSDIR}/deb"
BIN_PATH="${WORKDIR}/_output/dockerized/bin"

docker build -t deb-builder "${SRC}"

docker run --rm -v "${SRC}:/root/src" -v "${BIN_PATH}:/root/output/bin" -v "${DEBBUILD}:/root/debbuild/" -v "${DEBREPO}:/root/debrepo" deb-builder "${NAMES}" "${ARCHS}" "${VERSION}" "${RELEASE}"
