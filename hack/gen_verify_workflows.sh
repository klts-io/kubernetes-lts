#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "kit/helper.sh"

RELEASES=$(helper::config::list_releases)

cat <<EOF
name: Verify

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

  workflow_dispatch:

jobs:
  Patch:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Cache
        uses: actions/cache@v2
        env:
          cache-name: src
        with:
          path: |
            src
          key: \${{ runner.os }}-build-\${{ env.cache-name }}
      - name: Config Github
        run: |
          git config --global user.email "noreply@github.com"
          git config --global user.name "GitHub"
      - name: Install dependent
        run: |
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
  Test-${name}:
    needs: Patch
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Cache
        uses: actions/cache@v2
        env:
          cache-name: src
        with:
          path: |
            src
          key: \${{ runner.os }}-build-\${{ env.cache-name }}-${name}
          restore-keys: |
            \${{ runner.os }}-build-\${{ env.cache-name }}
      - name: Config Github
        run: |
          git config --global user.email "noreply@github.com"
          git config --global user.name "GitHub"
      - name: Install dependent
        run: |
          make dependent
      - name: Checkout to ${release}
        run: |
          make ${release}
      - name: Install etcd
        run: |
          make install-etcd
      - name: Test
        run: |
          make test

  Test-Cmd-${name}:
    needs: Patch
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Cache
        uses: actions/cache@v2
        env:
          cache-name: src
        with:
          path: |
            src
          key: \${{ runner.os }}-build-\${{ env.cache-name }}-${name}
          restore-keys: |
            \${{ runner.os }}-build-\${{ env.cache-name }}
      - name: Config Github
        run: |
          git config --global user.email "noreply@github.com"
          git config --global user.name "GitHub"
      - name: Install dependent
        run: |
          make dependent
      - name: Checkout to ${release}
        run: |
          make ${release}
      - name: Install etcd
        run: |
          make install-etcd
      - name: Test cmd
        run: |
          make test-cmd

  Test-Integration-${name}:
    needs: Patch
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Cache
        uses: actions/cache@v2
        env:
          cache-name: src
        with:
          path: |
            src
            /tmp/kubernetes-lts/
          key: \${{ runner.os }}-build-\${{ env.cache-name }}-${name}
          restore-keys: |
            \${{ runner.os }}-build-\${{ env.cache-name }}
      - name: Config Github
        run: |
          git config --global user.email "noreply@github.com"
          git config --global user.name "GitHub"
      - name: Install dependent
        run: |
          make dependent
      - name: Checkout to ${release}
        run: |
          make ${release}
      - name: Install etcd
        run: |
          make install-etcd
      - name: Test integration
        run: |
          make test-integration

EOF

done
