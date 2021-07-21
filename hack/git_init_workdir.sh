#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT="$(dirname "${BASH_SOURCE}")/.."
WORKDIR="${ROOT}/workdir"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

REPO="${REPO:-https://github.com/kubernetes/kubernetes}"
BRANCH="master"
ORIGIN="upstream"

if ! [[ -d .git ]]; then
    git init
fi

if [[ "$(git remote | grep ${ORIGIN})" == "${ORIGIN}" ]]; then
    git remote remove "${ORIGIN}"
fi
git remote add "${ORIGIN}" "${REPO}"

git remote update
