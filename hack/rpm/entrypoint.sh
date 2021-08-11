#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

NAMES="${1:-kubelet}"
ARCHS="${2:-amd64}"
VERSION="${3:-v1.18.20}"
RELEASE="${4:-00}"

declare -A ARCH_MAP
ARCH_MAP["amd64"]="x86_64"
ARCH_MAP["arm"]="armhfp"
ARCH_MAP["arm64"]="aarch64"
ARCH_MAP["ppc64le"]="ppc64le"
ARCH_MAP["s390x"]="s390x"

ROOT="/root"
SRC="${ROOT}/src"
BIN_PATH="${ROOT}/output/bin"
RPMBUILD="${ROOT}/rpmbuild"
RPMREPO="${ROOT}/rpmrepo"
SRC_PATH="${RPMBUILD}/SOURCES"
SPEC_PATH="${RPMBUILD}/SPECS"
RPM_PATH="${RPMBUILD}/RPMS"

IFS=, NAMES_SLICE=(${NAMES})
IFS=, ARCHS_SLICE=(${ARCHS})

for arch in ${ARCHS_SLICE[@]}; do
    RPMARCH="${ARCH_MAP[$arch]}"
    for name in ${NAMES_SLICE[@]}; do
        echo "Building ${name} RPM's for ${arch}"

        bin="${BIN_PATH}/linux/${arch}/${name}"
        src="${SRC_PATH}/${name}-${VERSION}"
        tar="${SRC_PATH}/${name}-${VERSION}.tar.gz"

        mkdir -p "${src}" "${SPEC_PATH}"

        cp -r "${SRC}/${name}"/* "${src}/"
        mv "${src}/${name}.spec" "${SPEC_PATH}/${name}.spec"

        if [[ "${name}" != "kubernetes-cni" ]] && [[ "${name}" != "cri-tools" ]]; then
            cp "${bin}" "${src}/${name}"

            tar -czvf "${tar}" -C "${SRC_PATH}" "${name}-${VERSION}"
        fi

        declare -A define
        define["_sourcedir"]="${SRC_PATH}"
        define["_version"]="${VERSION}"
        define["_release"]="${RELEASE}"
        define["_goarch"]="${arch}"

        for key in ${!define[@]}; do
            sed -i "s#%{${key}}#${define[${key}]}#g" "${SPEC_PATH}/${name}.spec"
        done

        cd "${SPEC_PATH}" && spectool -gf -C "${SRC_PATH}" "${name}.spec"
        rpmbuild --target "${RPMARCH}" -bb "${SPEC_PATH}/${name}.spec"
    done
    mkdir -p "${RPMREPO}/${RPMARCH}"
    mv "${RPM_PATH}/${RPMARCH}"/*.rpm "${RPMREPO}/${RPMARCH}"
    createrepo --update "${RPMREPO}/${RPMARCH}"
done
