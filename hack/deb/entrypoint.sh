#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

NAME="${1:-kubelet}"
VERSION="${2:-v1.18.20}"
RELEASE="${3:-00}"
ARCH="${4:-amd64}"

declare -A ARCH_MAP
ARCH_MAP["amd64"]="amd64"
ARCH_MAP["arm"]="armhf"
ARCH_MAP["arm64"]="arm64"
ARCH_MAP["ppc64le"]="ppc64el"
ARCH_MAP["s390x"]="s390x"

DEBBUILD="/root/debbuild"
SRC_PATH="${DEBBUILD}/debs"

DEBARCH="${ARCH_MAP[$ARCH]}"

cd "${SRC_PATH}/${NAME}-${VERSION}"
sed -i "s/%{version}/${VERSION#v}-${RELEASE}/g" ./debian/changelog
sed -i "s/%{arch}/${DEBARCH}/g" ./debian/control
dpkg-buildpackage --unsigned-source --unsigned-changes --build=binary --host-arch "${DEBARCH}"

# cd "${SRC_PATH}"
# dpkg-scanpackages . /dev/null | gzip >Packages
