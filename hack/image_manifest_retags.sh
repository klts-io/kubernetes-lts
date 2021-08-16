#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DOCKER_CLI_EXPERIMENTAL=enabled

REGISTRY=${REGISTRY:-}
IMAGES="$@"

for image in ${IMAGES[*]}; do

    tag=${image#*:}
    old_registry=${image%/*}
    name=${image%:*}
    name=${name##*/}

    echo "+++ Creating manifest image ${REGISTRY}/${name}:${tag}"

    # raw=$(docker manifest inspect "${image}")
    # Bypass permission authorized by docker manifest inspect
    raw=$(curl -H "User-Agent:Go-http-client/1.1" -H "Accept:application/vnd.docker.distribution.manifest.list.v2+json" "https://${old_registry}/v2/${name}/manifests/${tag}")

    echo "+++ Pulling source images by SHA"
    echo "${raw}" |
        jq -j ".manifests[] | \"${old_registry}/${name}@\", .digest, \"\n\" " |
        while read X; do docker pull $X; done

    echo "+++ Tagging images with ARCH and OS"
    echo "${raw}" |
        jq -j ".manifests[] | \"docker tag ${old_registry}/${name}@\", .digest, \" ${REGISTRY}/${name}:${tag}__\", .platform.architecture, \"_\", .platform.os, \"\n\"" |
        while read X; do $X; done

    echo "+++ Pushing images"
    echo "${raw}" |
        jq -j ".manifests[] | \"docker push ${REGISTRY}/${name}:${tag}__\", .platform.architecture, \"_\", .platform.os, \"\n\"" |
        while read X; do $X; done

    echo "+++ Creating manifest"
    docker manifest create --amend "${REGISTRY}/${name}:${tag}" \
        $(
            echo "${raw}" |
                jq -j ".manifests[] | \"${REGISTRY}/${name}:${tag}__\", .platform.architecture, \"_\", .platform.os, \" \""
        )

    echo "+++ Annotating manifest with ARCH and OS"
    echo "${raw}" |
        jq -j ".manifests[] | \"docker manifest annotate ${REGISTRY}/${name}:${tag} ${REGISTRY}/${name}:${tag}__\", .platform.architecture, \"_\", .platform.os, \" --arch \", .platform.architecture, \" --os \", .platform.os, \"\n\"" |
        while read X; do $X; done

    echo "+++ Pushing manifest ${REGISTRY}/${name}:${tag}"
    docker manifest push "${REGISTRY}/${name}:${tag}" --purge
done
