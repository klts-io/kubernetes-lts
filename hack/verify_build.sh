#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


ROOT="$(dirname "${BASH_SOURCE}")/.."
CONFIG="${FILE:-${ROOT}/releases.yml}"

cd "${ROOT}"
RELEASES=$(cat "${CONFIG}" | yq '.releases | .[] | .name' | tr -d '"' | tr '\n' ' ')

for release in ${RELEASES}; do
  echo "Verifying build release: ${release}"
  make "${release}" verify-build-client verify-build-server verify-build-image
done
