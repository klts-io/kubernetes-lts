#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${ROOT}"

PATCHES=$(ls ${PATCHESDIR}/*.patch)

for patch in ${PATCHES}; do
    ./hack/format_patch.sh "$patch"
done
