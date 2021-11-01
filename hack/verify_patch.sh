#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "kit/helper.sh"
cd "${ROOT}"

RELEASES=$(helper::config::list_releases)

make ${RELEASES}
