#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${ROOT}"

RELEASES=$(helper::config::list_releases)

for release in ${RELEASES}; do
    echo "Tagging and push release ${release}"
    git tag "${release}" && git push origin "${release}"
done
