#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


OLD_REGISTRY=${OLD_REGISTRY:-}
REGISTRY=${REGISTRY:-}

if [[ -z "${REGISTRY}" ]]; then
    echo "REGISTRY is required"
    exit 1
fi

if [[ "${REGISTRY}" != ghcr.io/* ]]; then
    echo "REGISTRY must target ghcr.io, got: ${REGISTRY}"
    exit 1
fi

declare -a CANDIDATE_OLD_REGISTRIES=()
add_candidate_registry() {
    local candidate="${1}"
    [[ -z "${candidate}" ]] && return 0

    for existing in "${CANDIDATE_OLD_REGISTRIES[@]}"; do
        if [[ "${existing}" == "${candidate}" ]]; then
            return 0
        fi
    done

    CANDIDATE_OLD_REGISTRIES+=("${candidate}")
}

add_candidate_registry "${OLD_REGISTRY}"
add_candidate_registry "registry.k8s.io"
add_candidate_registry "k8s.gcr.io"

declare -a OLD_IMAGES=()
for candidate in "${CANDIDATE_OLD_REGISTRIES[@]}"; do
    OLD_IMAGES=()
    while IFS= read -r image; do
        [[ -n "${image}" ]] && OLD_IMAGES+=("${image}")
    done < <(
        docker images --format '{{.Repository}}:{{.Tag}}' \
            | awk -v prefix="${candidate}/kube-" 'index($0, prefix) == 1 && $0 !~ /cross/ { print $0 }'
    )

    if [[ ${#OLD_IMAGES[@]} -gt 0 ]]; then
        OLD_REGISTRY="${candidate}"
        break
    fi
done

if [[ ${#OLD_IMAGES[@]} -eq 0 ]]; then
    echo "No kube images found under registries: ${CANDIDATE_OLD_REGISTRIES[*]}"
    exit 0
fi

echo "Retagging ${#OLD_IMAGES[@]} images from ${OLD_REGISTRY} to ${REGISTRY}"
for old_image in "${OLD_IMAGES[@]}"; do
    new_image=$(echo "${old_image}" | sed "s#^${OLD_REGISTRY}#${REGISTRY}#")
    docker tag "${old_image}" "${new_image}"
    docker rmi "${old_image}"
done
