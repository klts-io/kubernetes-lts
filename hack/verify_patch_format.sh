#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "kit/helper.sh"
cd "${ROOT}"

cp -r patches patches.bak

function cleanup() {
    rm -rf patches.bak
}
trap cleanup EXIT

${KITDIR}/format_all_patch.sh

diff -a patches patches.bak
