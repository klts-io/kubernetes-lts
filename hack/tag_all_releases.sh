#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


ROOT="$(dirname "${BASH_SOURCE}")/.."
CONFIG="${FILE:-${ROOT}/releases.yml}"


RELEASES=$(cat "${CONFIG}" | yq '.releases | .[] | .name' | tr -d '"' | tr '\n' ' ')

for release in ${RELEASES} ; do
    echo "Tagging and push release ${release}"
    git tag "${release}" && git push origin "${release}"
done
