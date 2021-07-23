#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "$#" -lt 1 ]]; then
    echo "${0} release: patch of release"
    exit 2
fi

ROOT="$(dirname "${BASH_SOURCE}")/.."
CONFIG="${FILE:-${ROOT}/releases.yml}"
PATCHES=$@

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


PATCH_LIST=""
for patch in ${PATCHES} ; do
    patches=$(cat "${CONFIG}" | yq  ".patches | .[] | select( .name == \"${patch}\" ) | .patch | .[]" | tr -d '"' || "")
    for item in ${patches}; do
      PATCH_LIST+=" $(download ${item})"
    done
done

echo ${PATCH_LIST}