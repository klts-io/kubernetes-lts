#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"

NAMES="${1:-kubelet}"
ARCHS=${2:-amd64}
VERSION="$(cd ${WORKDIR} && git describe --tags | head -n 1)"
RELEASE="${VERSION##*-}"
VERSION="${VERSION%-*}"

IFS=, NAMES=(${NAMES})
IFS=, ARCHS=(${ARCHS})

SRC="${ROOT}/hack/rpm"
RPMBUILD="${ROOT}/rpmbuild"
BIN_PATH="${WORKDIR}/_output/dockerized/bin"
SPEC_PATH="${RPMBUILD}/SPECS"
SRC_PATH="${RPMBUILD}/SOURCES"
RPM_PATH="${RPMBUILD}/RPMS"

docker build -t rpm-builder "${SRC}"

for arch in ${ARCHS[@]}; do
    for name in ${NAMES[@]}; do
        echo "Building RPM's for ${arch}"
        bin="${BIN_PATH}/linux/${arch}/${name}"
        src="${SRC_PATH}/${name}-${VERSION}"
        tar="${SRC_PATH}/${name}-${VERSION}.tar.gz"

        mkdir -p "${src}" "${SPEC_PATH}"

        cp -r "${SRC}/${name}"/* "${src}/"
        mv "${src}/${name}.spec" "${SPEC_PATH}/${name}.spec"
        cp "${bin}" "${src}/${name}"

        tar -czvf "${tar}" -C "${SRC_PATH}" "${name}-${VERSION}"

        docker run --rm -v "${RPMBUILD}:/root/rpmbuild/" rpm-builder "${name}" "${VERSION}" "${RELEASE}" "${arch}"
    done
done

cp "${RPM_PATH}"/*/*.rpm "${OUTPUT}"
