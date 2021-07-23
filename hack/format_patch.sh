#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "$#" -lt 1 ]]; then
    echo "${0} patch_path: patch path"
    exit 2
fi

ROOT="$(dirname "${BASH_SOURCE}")/.."
CONFIG="${FILE:-${ROOT}/releases.yml}"
WORKDIR="${ROOT}/workdir"

PATCH_PATH=$1
NAME=${PATCH_PATH##*/}
BASENAME=${NAME%%.*}
RELEASE=${NAME#*.}
RELEASE=${RELEASE%.*}

PATCH_RELEASE=$(cat "${CONFIG}" | yq ".releases | .[] | .name" | grep v${RELEASE} | tr -d '"' | head -1)

PATCH_LIST=$(cat "${CONFIG}" | yq ".releases | .[] | select( .name == \"${PATCH_RELEASE}\" ) | .patches | .[]" | tr -d '"' | tr '\n' ' ')

BASE_RELEASE=$(cat "${CONFIG}" | yq ".releases | .[] | select( .name == \"${PATCH_RELEASE}\" ) | .base_release" | tr -d '"')

BASE=$(cat "${CONFIG}" | yq ".base" | tr -d '"')

COMMIT_COUNT=$(cat ${PATCH_PATH} | grep 'Subject: \[PATCH' | wc -l | tr -d ' ')

WORKDIR="${WORKDIR}" REPO="${BASE}" ./hack/git_fetch_tag.sh ${BASE_RELEASE}

PATCHES_LIST=$(./hack/get_patches.sh "${PATCH_LIST}")

for patch in ${PATCHES_LIST} ; do
    if [[ "${patch}" =~ "${PATCH_PATH}" ]]; then
        break
    fi
    WORKDIR="${WORKDIR}" ./hack/git_patch.sh "${patch}"
done

WORKDIR="${WORKDIR}" ./hack/git_patch.sh "../${PATCH_PATH}"

cd "${WORKDIR}" && git format-patch "-$COMMIT_COUNT" --zero-commit --no-signature --stdout > "../${PATCH_PATH}"
