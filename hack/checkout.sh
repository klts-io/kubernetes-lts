#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "$#" -lt 1 ]]; then
    echo "${0} release: checkout to expected patch release"
    exit 2
fi

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${ROOT}"

ORIGIN_RELEASE="$1"

if [[ "${ORIGIN_RELEASE}" =~ ^v1(.[0-9]+){2}$ ]]; then
    ./hack/git_fetch_tag.sh "${ORIGIN_RELEASE}"
    exit
fi

RELEASE="${ORIGIN_RELEASE%.*}.0"

BASE_RELEASE=$(helper::config::get_base_release ${ORIGIN_RELEASE})
if [[ "${BASE_RELEASE}" != "" ]]; then
    RELEASE="${ORIGIN_RELEASE}"
else
    BASE_RELEASE=$(helper::config::get_base_release ${RELEASE})
fi

./hack/checkout.sh ${BASE_RELEASE}

PATCHES=$(helper::config::get_patches ${RELEASE})

echo "Release ${BASE_RELEASE} patches ($(echo ${PATCHES} | tr ' ' ',')) as release ${RELEASE}"

PATCH_LIST=$(helper::config::get_patch ${PATCHES})

if [[ "${PATCH_LIST}" != "" ]]; then
    ./hack/git_patch.sh ${PATCH_LIST}
fi

cd "${WORKDIR}" && git tag -f "${ORIGIN_RELEASE}"
