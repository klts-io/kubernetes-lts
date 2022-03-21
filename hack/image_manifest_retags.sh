#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

REGISTRY=${REGISTRY:-}
IMAGES="$@"

for image in ${IMAGES[*]}; do
    tag=${image#*:}
    name=${image%:*}
    name=${name##*/}

    skopeo copy --all "docker://${image}" "docker://${REGISTRY}/${name}:${tag}"
done
