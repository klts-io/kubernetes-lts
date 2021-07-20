#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


ROOT="$(dirname "${BASH_SOURCE}")/.."
CONFIG="${FILE:-${ROOT}/releases.yml}"


cd "${ROOT}"
make $(cat "${CONFIG}" | yq '.releases | .[] | .name' | tr -d '"' | tr '\n' ' ')
