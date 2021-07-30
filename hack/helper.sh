#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT="${ROOT:-$(dirname "${BASH_SOURCE}")/..}"
OUTPUT="${OUTPUT:-${ROOT}/release}"
WORKDIR="${WORKDIR:-${ROOT}/workdir}"
PATCHESDIR="${PATCHESDIR:-${ROOT}/patches}"
TMPDIR="${TMPDIR:-/tmp}/kubepatch"
CONFIG="${CONFIG:-${ROOT}/releases.yml}"

function helper::fullpath() {
    local dir="$(dirname $1)"
    local base="$(basename $1)"
    if [[ "${base}" == "." || "${base}" == ".." ]]; then
        dir="$1"
        base=""
    fi
    if ! [[ -d ${dir} ]]; then
        return 1
    fi
    pushd ${dir} >/dev/null 2>&1
    echo ${PWD}/${base}
    popd >/dev/null 2>&1
}

ROOT=$(helper::fullpath ${ROOT})
OUTPUT=$(helper::fullpath ${OUTPUT})
WORKDIR=$(helper::fullpath ${WORKDIR})
PATCHESDIR=$(helper::fullpath ${PATCHESDIR})
TMPDIR=$(helper::fullpath ${TMPDIR})
CONFIG=$(helper::fullpath ${CONFIG})

mkdir -p "${TMPDIR}"

function helper::download() {
    local patch="$1"
    if ! [[ "${patch}" =~ ^https?:// ]]; then
        echo "$(helper::fullpath ${patch})"
        return
    fi
    local tmp_patch="${TMPDIR}/$(basename ${patch})"
    if ! [[ -f "${tmp_patch}" ]]; then
        echo "+++ Downloading patch to ${tmp_patch} from ${patch}" 1>&2
        curl -o "${tmp_patch}" -sSL "${patch}"
    fi
    echo ${tmp_patch}
}

function helper::config::get_base_repository() {
    cat "${CONFIG}" | yq ".base" | tr -d '"'
}

readonly REPO=$(helper::config::get_base_repository)

function helper::config::get_base_release() {
    cat "${CONFIG}" | yq ".releases | .[] | select( .name == \"$1\" ) | .base_release" | tr -d '"'
}

function helper::config::get_patches() {
    cat "${CONFIG}" | yq ".releases | .[] | select( .name == \"$1\" ) | .patches | .[]" | tr -d '"'
}

function helper::config::get_test_failures_tolerated() {
    cat "${CONFIG}" | yq ".releases | .[] | select( .name == \"$1\" ) | .test_failures_tolerated | .[]" | tr -d '"'
}

function helper::config::get_test_integration_failures_tolerated() {
    cat "${CONFIG}" | yq ".releases | .[] | select( .name == \"$1\" ) | .test_integration_failures_tolerated | .[]" | tr -d '"'
}

function helper::config::get_patch() {
    local list=""
    for patch in $@; do
        patches=$(cat "${CONFIG}" | yq ".patches | .[] | select( .name == \"${patch}\" ) | .patch | .[]" | tr -d '"' || "")
        for item in ${patches}; do
            list+=" $(helper::download ${item})"
        done
    done
    echo "${list}"
}

function helper::config::list_releases() {
    cat "${CONFIG}" | yq ".releases | .[] | .name" | tr -d '"'
}

# etcd
export PATH="${WORKDIR}/third_party/etcd:${PATH}"
