#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

REGISTRY=${REGISTRY:-}
IMAGES="$@"

if [[ -z "${REGISTRY}" ]]; then
    echo "REGISTRY is required"
    exit 1
fi

if [[ "${REGISTRY}" != ghcr.io/* ]]; then
    echo "REGISTRY must target ghcr.io, got: ${REGISTRY}"
    exit 1
fi

for image in ${IMAGES[*]}; do
    tag=${image#*:}
    name=${image%:*}
    name=${name##*/}

    skopeo copy --all "docker://${image}" "docker://${REGISTRY}/${name}:${tag}"
done
