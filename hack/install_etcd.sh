#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "kit/helper.sh"
cd "${WORKDIR}"

hack/install-etcd.sh
export PATH="${WORKDIR}/third_party/etcd:${PATH}"

etcd --version
