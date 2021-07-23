#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${WORKDIR}"

QUIET="${QUIET:-y}"
STARTING_BRANCH="$(git symbolic-ref --short HEAD)"
REPO_ROOT="$(git rev-parse --show-toplevel)"
REBASE_APPLY="${REPO_ROOT}/.git/rebase-apply"

if [[ "$#" -lt 1 ]]; then
    echo "${0} patchfile...: patch one or more patch onto branch"
    exit 2
fi

if git_status=$(git status --porcelain --untracked=no 2>/dev/null) && [[ -n "${git_status}" ]]; then
    echo "!!! Dirty tree. Clean up and try again."
    exit 1
fi

if [[ -e "${REBASE_APPLY}" ]]; then
    echo "!!! 'git rebase' or 'git am' in progress. Clean up and try again."
    exit 1
fi

cd "${REPO_ROOT}"

GIT_AM_CLEANUP=false
function cleanup() {
    if [[ "${GIT_AM_CLEANUP}" == "true" ]]; then
        echo
        echo "+++ Aborting in-progress git am."
        git am --abort >/dev/null 2>&1 || true
    fi

    echo
    echo "+++ Returning you to the ${STARTING_BRANCH} branch and cleaning up."
    git checkout -f "${STARTING_BRANCH}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

GIT_AM_CLEANUP=true

PATCHES=("$@")
for PATCH in "${PATCHES[@]}"; do
    echo
    echo "+++ About to attempt patch. To reattempt:"
    echo "  $ git am -3 ${PATCH}"
    echo
    git am -3 "${PATCH}" || {
        conflicts=false
        while unmerged=$(git status --porcelain | grep ^U) && [[ -n ${unmerged} ]] || [[ -e "${REBASE_APPLY}" ]]; do
            conflicts=true
            echo
            echo "+++ Conflicts detected:"
            echo
            (git status --porcelain | grep ^U) || echo "!!! None. Did you git am --continue?"
            if [[ "${QUIET}" =~ ^[yY]$ ]]; then
                echo "Aborting." >&2
                exit 1
            fi
            echo
            echo "+++ Please resolve the conflicts in another window (and remember to 'git add / git am --continue')"
            read -p "+++ Proceed (anything but 'y' aborts the patch)? [y/n] " -r
            echo
            if ! [[ "${REPLY}" =~ ^[yY]$ ]]; then
                echo "Aborting." >&2
                exit 1
            fi
        done

        if [[ "${conflicts}" != "true" ]]; then
            echo "!!! git am failed, likely because of an in-progress 'git am' or 'git rebase'"
            exit 1
        fi
    }
done
GIT_AM_CLEANUP=false
