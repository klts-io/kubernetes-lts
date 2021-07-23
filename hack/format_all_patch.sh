#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


PATCHES=$(ls patches/*.patch)

for patch in ${PATCHES} ; do
    ./hack/format_patch.sh "$patch"
done