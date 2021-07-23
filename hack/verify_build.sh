#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${ROOT}"

RELEASES=$(helper::config::list_releases)

for release in ${RELEASES}; do
  echo "Verifying build release: ${release}"
  make "${release}" verify-build-client verify-build-server verify-build-image
done
