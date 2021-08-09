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

IFS=, NAMES=(${NAMES})
IFS=, ARCHS=(${ARCHS})

SRC="${ROOT}/hack/deb"
DEBBUILD="${ROOT}/debbuild"
BIN_PATH="${WORKDIR}/_output/dockerized/bin"
SRC_PATH="${DEBBUILD}/debs"

docker build -t deb-builder "${SRC}"

for arch in ${ARCHS[@]}; do
    for name in ${NAMES[@]}; do
        echo "Building DEB's for ${arch}"
        bin="${BIN_PATH}/linux/${arch}/${name}"
        src="${SRC_PATH}/${name}-${VERSION}"
        tar="${SRC_PATH}/${name}-${VERSION}.tar.gz"

        mkdir -p "${src}"
        cp -r "${SRC}/${name}"/* "${src}/"
        cp "${bin}" "${src}/${name}"

        docker run --rm -v "${DEBBUILD}:/root/debbuild/" deb-builder "${name}" "${VERSION}" "${RELEASE}" "${arch}"
    done
done

cp "${SRC_PATH}"/*.deb "${OUTPUT}"
