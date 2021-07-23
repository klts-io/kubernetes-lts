#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "$#" -lt 1 ]]; then
    echo "${0} release: patch of release"
    exit 2
fi

ROOT="$(dirname "${BASH_SOURCE}")/.."
WORKDIR="${ROOT}/workdir"
RELEASE="$1"
CONFIG="${FILE:-${ROOT}/releases.yml}"
CONFIG_DIR="$(dirname "${CONFIG}")"

BASE=$(cat "${CONFIG}" | yq ".base" | tr -d '"')
BASE_RELEASE=$(cat "${CONFIG}" | yq ".releases | .[] | select( .name == \"${RELEASE}\" ) | .base_release" | tr -d '"')
PATCHES=$(cat "${CONFIG}" | yq ".releases | .[] | select( .name == \"${RELEASE}\" ) | .patches | .[]" | tr -d '"')

echo "Release ${BASE_RELEASE} patches ($(echo ${PATCHES} | tr ' ' ',')) as release ${RELEASE}"

PATCH_LIST=$(./hack/get_patches.sh ${PATCHES})

WORKDIR="${WORKDIR}" REPO="${BASE}" ./hack/git_fetch_tag.sh ${BASE_RELEASE}
if [[ "${PATCH_LIST}" != "" ]]; then
    WORKDIR="${WORKDIR}" ./hack/git_patch.sh ${PATCH_LIST}
fi
WORKDIR="${WORKDIR}" ./hack/git_tag.sh ${RELEASE}
