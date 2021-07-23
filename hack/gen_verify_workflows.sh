#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"

RELEASES=$(helper::config::list_releases)

cat <<EOF
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
      - name: Cache workdir
        uses: actions/cache@v2
        env:
          cache-name: workdir
        with:
          path: workdir
          key: \${{ runner.os }}-build-\${{ env.cache-name }}
      - name: Install dependent
        run: |
          git config --global user.name "bot"
          make dependent
      - name: Verify patch
        run: |
          make verify-patch
      - name: Verify patch format
        run: |
          make verify-patch-format

EOF

for release in ${RELEASES}; do
  name=${release//\./\-}
  cat <<EOF
  Build-Client-${name}:
    needs: Patch
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Cache workdir
        uses: actions/cache@v2
        env:
          cache-name: workdir
        with:
          path: workdir
          key: \${{ runner.os }}-build-\${{ env.cache-name }}-${name}
          restore-keys: |
            \${{ runner.os }}-build-\${{ env.cache-name }}
      - name: Install dependent
        run: |
          git config --global user.name "bot"
          make dependent
      - name: Checkout to ${release}
        run: |
          make ${release}
      - name: Verify build client
        run: |
          make verify-build-client

  Build-Server-${name}:
    needs: Patch
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Cache workdir
        uses: actions/cache@v2
        env:
          cache-name: workdir
        with:
          path: workdir
          key: \${{ runner.os }}-build-\${{ env.cache-name }}-${name}
          restore-keys: |
            \${{ runner.os }}-build-\${{ env.cache-name }}
      - name: Install dependent
        run: |
          git config --global user.name "bot"
          make dependent
      - name: Checkout to ${release}
        run: |
          make ${release}
      - name: Verify build server
        run: |
          make verify-build-server

  Build-Image-${name}:
    needs: Patch
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Cache workdir
        uses: actions/cache@v2
        env:
          cache-name: workdir
        with:
          path: workdir
          key: \${{ runner.os }}-build-\${{ env.cache-name }}-${name}
          restore-keys: |
            \${{ runner.os }}-build-\${{ env.cache-name }}
      - name: Install dependent
        run: |
          git config --global user.name "bot"
          make dependent
      - name: Checkout to ${release}
        run: |
          make ${release}
      - name: Verify build image
        run: |
          make verify-build-image
EOF

done
