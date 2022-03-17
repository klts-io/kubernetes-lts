#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "kit/helper.sh"
cd "${WORKDIR}"

TMPFILE="${TMPDIR}/test-integration.log"

# Etcd was added for testing in 1.21 and later
function test-integration() {
    ./build/shell.sh -c './hack/install-etcd.sh && PATH=$(pwd)/third_party/etcd:${PATH} make test-integration'
}

test-integration 2>&1 | tee "${TMPFILE}" | grep -v -E '^I\w+ ' && exit 0

RETRY_CASES=$(cat "${TMPFILE}" | grep -E '^FAIL\s+k8s.io/kubernetes' | awk '{print $2}' || echo "")

TAG=$(helper::workdir::version)

FAILURES_TOLERATED=$(helper::config::get_test_integration_failures_tolerated ${TAG})
if [[ "${FAILURES_TOLERATED}" != "" ]]; then
    echo "+++ Test failed, the case is as follows:"
    echo "${RETRY_CASES}"
    echo "+++ Failures tolerated, the case is as follows:"
    echo "${FAILURES_TOLERATED}"

    for tolerate in ${FAILURES_TOLERATED}; do
        RETRY_CASES=$(echo "${RETRY_CASES}" | grep -v -E "^${tolerate}$" || echo "")
    done
    if [[ "${RETRY_CASES}" == "" ]]; then
        exit 0
    fi
fi

echo "+++ Test failed, will retry 5 times"
for n in {1..5}; do
    echo "+++ Test retry ${n}, the case is as follows:"
    echo "${RETRY_CASES}"
    want=$(echo ${RETRY_CASES})
    test-integration WHAT="${want}" 2>&1 | tee "${TMPFILE}" | grep -v -E '^I\w+ ' && exit 0
    RETRY_CASES=$(cat "${TMPFILE}" | grep -E '^FAIL\s+k8s.io/kubernetes' | awk '{print $2}' || echo "")
done

echo "!!! Test failed, the case is as follows:"
echo "${RETRY_CASES}"

exit 1
