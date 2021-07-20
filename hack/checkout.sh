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

function query() {
    cat "${CONFIG}" | yq "$1" | tr -d '"'
}

function query_field() {
    query ".$1 | .[] | select( .name == \"$2\" ) | .$3"
}

function query_field_line() {
    query_field "$1" "$2" "$3 | .[]"
}

function download() {
    PATCH="$1"
    if ! [[ "${PATCH}" =~ ^https?:// ]]; then
        echo "../${PATCH}"
        return
    fi
    TMP_PATCH="${TMPDIR:-/tmp/}/patches/$(basename ${PATCH})"
    if ! [[ -f "${TMP_PATCH}" ]]; then
        mkdir -p "$(dirname ${TMP_PATCH})"
        echo "+++ Downloading patch to ${TMP_PATCH} from ${PATCH}" 1>&2
        curl -o "${TMP_PATCH}" -sSL "${PATCH}"
    fi
    echo ${TMP_PATCH}
}

BASE=$(query ".base")
BASE_RELEASE=$(query_field "releases" "${RELEASE}" "base_release")
PATCHES=$(query_field_line "releases" "${RELEASE}" "patches")

echo "Release ${BASE_RELEASE} patches ($(echo ${PATCHES} | tr ' ' ',')) as release ${RELEASE}"

PATCH_LIST=""
for patch in ${PATCHES}; do
    patches=$(query_field_line "patches" "${patch}" "patch" || echo "")
    echo "Patch ($(echo ${patches} | tr ' ' ',')) to ${BASE_RELEASE} from ${patch}"
    for item in ${patches}; do
      PATCH_LIST+=" $(download ${item})"
    done
done

mkdir -p "${WORKDIR}"
WORKDIR="${WORKDIR}" REPO="${BASE}" ./hack/git_fetch_tag.sh ${BASE_RELEASE}
if [[ "${PATCH_LIST}" != "" ]]; then
    WORKDIR="${WORKDIR}" ./hack/git_patch.sh ${PATCH_LIST}
fi
WORKDIR="${WORKDIR}" ./hack/git_tag.sh ${RELEASE}
