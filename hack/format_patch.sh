#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "$#" -lt 1 ]]; then
    echo "${0} patchfile: format the patch file"
    exit 2
fi

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${ROOT}"

PATCH_PATH=$1
PATCH_PATH=$(realpath ${PATCH_PATH})
NAME=${PATCH_PATH##*/}
BASENAME=${NAME%%.*}
RELEASE=${NAME#*.}
RELEASE=${RELEASE%.*}

PATCH_RELEASE=$(helper::config::list_releases | grep v${RELEASE} | head -1)
PATCH_LIST=$(helper::config::get_patches_all ${PATCH_RELEASE})
BASE_RELEASE=$(helper::config::base_chain ${PATCH_RELEASE} | tail -1)
COMMIT_COUNT=$(cat ${PATCH_PATH} | grep 'Subject: \[PATCH' | wc -l | tr -d ' ')

./hack/git_fetch_tag.sh ${BASE_RELEASE}

PATCHES_LIST=$(helper::config::get_patch "${PATCH_LIST}")

for patch in ${PATCHES_LIST}; do
    if [[ "${patch}" =~ "${PATCH_PATH}" ]]; then
        break
    fi
    ./hack/git_patch.sh "${patch}"
done

./hack/git_patch.sh "${PATCH_PATH}"

cd "${WORKDIR}" && git format-patch "-$COMMIT_COUNT" --zero-commit --no-signature --stdout >"${PATCH_PATH}"
