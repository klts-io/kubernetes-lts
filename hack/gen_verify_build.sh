#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT="$(dirname "${BASH_SOURCE}")/.."
CONFIG="${FILE:-${ROOT}/releases.yml}"
RELEASES=$(cat "${CONFIG}" | yq ".releases | .[] | .name" | tr -d '"' | tr '\n' ' ')


cat << EOF
name: Verify

on:
  push:
    branches: [master]
  pull_request:
    branches: [master]

  workflow_dispatch:

jobs:
  Patch:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Verify patch
        run: |
          git config --global user.name "bot"
          make dependent verify-patch verify-patch-format

EOF

for release in ${RELEASES}; do
  name=${release//\./\-}
  cat << EOF
  Build-Client-${name}:
    needs: Patch
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Verify build client ${release}
        run: |
          git config --global user.name "bot"
          make dependent ${release} verify-build-client

  Build-Server-${name}:
    needs: Patch
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Verify build server ${release}
        run: |
          git config --global user.name "bot"
          make dependent ${release} verify-build-server

  Build-Image-${name}:
    needs: Patch
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Verify build image ${release}
        run: |
          git config --global user.name "bot"
          make dependent ${release} verify-build-image

EOF

done

 