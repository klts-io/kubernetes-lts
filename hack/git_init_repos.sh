#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"

SOURCE="${SOURCE:-$(helper::repos::get_base_repository)}"
BRANCH="${BRANCH:-$(helper::repos::branch)}"
ORIGIN="origin"
mkdir -p "${REPOSDIR}"
cd "${REPOSDIR}"

if ! [[ -d .git ]]; then
    git init
fi

if [[ "$(git config user.name)" == "" ]]; then
    git config --global user.name "bot"
fi

if [[ "$(git remote | grep ${ORIGIN})" == "${ORIGIN}" ]]; then
    git remote remove "${ORIGIN}"
fi

if [[ "${GH_TOKEN:-}" != "" ]]; then
    SOURCE=$(echo ${SOURCE} | sed "s#https://github.com#https://bot:${GH_TOKEN}@github.com#g")
fi

git remote add "${ORIGIN}" "${SOURCE}"

git fetch "${ORIGIN}" "${BRANCH}" --depth=1 || true

git checkout -f -B "${BRANCH}" --track "${ORIGIN}/${BRANCH}" || git checkout -B "${BRANCH}"
