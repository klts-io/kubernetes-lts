#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "$#" -lt 1 ]]; then
    echo "${0} release: release name"
    exit 2
fi

WORKDIR="${WORKDIR:-.}"
cd "${WORKDIR}"

git tag -f "$1"
