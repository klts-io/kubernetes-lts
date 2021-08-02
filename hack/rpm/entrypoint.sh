#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

NAME="${1:-kubelet}"
VERSION="${2:-v1.18.20}"
RELEASE="${3:-00}"
ARCH="${4:-amd64}"

declare -A ARCH_MAP
ARCH_MAP["amd64"]="x86_64"
ARCH_MAP["arm"]="armhfp"
ARCH_MAP["arm64"]="aarch64"
ARCH_MAP["ppc64le"]="ppc64le"
ARCH_MAP["s390x"]="s390x"

RPMBUILD="/root/rpmbuild"
SRC_PATH="${RPMBUILD}/SOURCES"
SPEC_PATH="${RPMBUILD}/SPECS"
RPM_PATH="${RPMBUILD}/RPMS"

RPMARCH="${ARCH_MAP[$ARCH]}"

# Download sources if not already available
cd "${SPEC_PATH}" && spectool -gf "${NAME}.spec"
rpmbuild --target "${RPMARCH}" --define "_sourcedir ${SRC_PATH}" --define "_version ${VERSION}" --define "_release ${RELEASE}" -bb "${SPEC_PATH}/${NAME}.spec"
mkdir -p "${RPM_PATH}/${RPMARCH}"
# createrepo -o "${RPM_PATH}/${RPMARCH}/" "/root/rpmbuild/RPMS/${RPMARCH}"
