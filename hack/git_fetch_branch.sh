#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "$#" -lt 1 ]]; then
    echo "${0} branch: branch name"
    exit 2
fi

WORKDIR="${WORKDIR:-.}"
cd "${WORKDIR}"

REPO="${REPO:-https://github.com/kubernetes/kubernetes}"
BRANCH="$1"
ORIGIN="origin-pull-branch-${BRANCH}"

if ! [[ -d .git ]]; then
    git init
fi

if [[ "$(git remote | grep ${ORIGIN})" == "${ORIGIN}" ]]; then
    git remote remove "${ORIGIN}"
fi
git remote add "${ORIGIN}" "${REPO}"

git fetch "${ORIGIN}" "${BRANCH}" --depth=1
git checkout -B "${BRANCH}" --track "${ORIGIN}/${BRANCH}"
