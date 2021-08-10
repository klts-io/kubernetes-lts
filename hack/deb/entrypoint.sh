#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

NAMES="${1:-kubelet}"
ARCHS="${2:-amd64}"
VERSION="${3:-v1.18.20}"
RELEASE="${4:-00}"

declare -A ARCH_MAP
ARCH_MAP["amd64"]="amd64"
ARCH_MAP["arm"]="armhf"
ARCH_MAP["arm64"]="arm64"
ARCH_MAP["ppc64le"]="ppc64el"
ARCH_MAP["s390x"]="s390x"

ROOT="/root"
SRC="${ROOT}/src"
BIN_PATH="${ROOT}/output/bin"
DEBBUILD="${ROOT}/debbuild"
DEBREPO="${ROOT}/debrepo"
PUBLIC="${ROOT}/.aptly/public"
SRC_PATH="${DEBBUILD}/debs"

IFS=, NAMES_SLICE=(${NAMES})
IFS=, ARCHS_SLICE=(${ARCHS})

for arch in ${ARCHS_SLICE[@]}; do
    for name in ${NAMES_SLICE[@]}; do
        echo "Building ${name} DEB's for ${arch}"
        bin="${BIN_PATH}/linux/${arch}/${name}"
        src="${SRC_PATH}/${name}-${VERSION}"

        mkdir -p "${src}"
        cp -r "${SRC}/${name}"/* "${src}/"
        cp "${bin}" "${src}/${name}"

        debarch="${ARCH_MAP[$arch]}"
        cd "${SRC_PATH}/${name}-${VERSION}"
        sed -i "s/%{version}/${VERSION#v}-${RELEASE}/g" ./debian/changelog
        sed -i "s/%{arch}/${debarch}/g" ./debian/control
        dpkg-buildpackage --unsigned-source --unsigned-changes --build=binary --host-arch "${debarch}"
    done
done

COMPONENT=main

mv "${DEBREPO}/pool/${COMPONENT}"/*/*/*.deb "${SRC_PATH}/" || true
aptly repo create -comment="KubePatch" -component="${COMPONENT}" -distribution="stable" kubepatch
aptly repo add kubepatch "${SRC_PATH}"/*.deb

aptly publish repo -distribution="stable" -skip-signing kubepatch
rm -rf "${DEBREPO}"/*
mv "${PUBLIC}"/* "${DEBREPO}"
