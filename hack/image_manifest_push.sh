#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${WORKDIR}"

REGISTRY=${REGISTRY:-}
TAG=$(git describe --tags | head -n 1)

DOCKER_CLI_EXPERIMENTAL=enabled

IMAGES=$(docker images | awk '{print $1":"$2}' | grep -E "^${REGISTRY}/" | grep -E ":${TAG}$")

declare -A IMAGE_ARCH=()

for image in ${IMAGES}; do
    name_arch_tag="${image##*/}"
    tag="${name_arch_tag##*:}"
    name_arch="${name_arch_tag%:*}"
    name="${name_arch%-*}"
    arch="${name_arch##*-}"

    if [[ -v "IMAGE_ARCH[${name}]" ]]; then
        IMAGE_ARCH["${name}"]+=" ${arch}"
    else
        IMAGE_ARCH["${name}"]="${arch}"
    fi
done

for name in ${!IMAGE_ARCH[@]}; do
    echo "+++ Creating manifest image ${REGISTRY}/${name}:${TAG}"
    manifests=""
    for arch in ${IMAGE_ARCH[${name}]}; do
        manifests+=" ${REGISTRY}/${name}-${arch}:${TAG}"
    done
    docker manifest create --amend "${REGISTRY}/${name}:${TAG}" ${manifests}

    for arch in ${IMAGE_ARCH[${name}]}; do
        echo "+++ Annotating ${REGISTRY}/${name}-${arch}:${TAG} with --arch ${arch}"
        docker manifest annotate "${REGISTRY}/${name}:${TAG}" "${REGISTRY}/${name}-${arch}:${TAG}" --arch "${arch}"
    done

    echo "+++ Pushing manifest image ${REGISTRY}/${name}:${TAG}"
    docker manifest push "${REGISTRY}/${name}:${TAG}" --purge
done
