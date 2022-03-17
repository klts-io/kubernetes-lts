#!/usr/bin/env bash

LIST=$(cat releases.yml | yq -r '.releases | .[] | .name, .base_release' | xargs -n 2 )


IFS=$'\n'
for item in ${LIST} ; do
    name=$(echo ${item} | cut -d ' ' -f 1)
    base_release=$(echo ${item} | cut -d ' ' -f 2)
    if [[ "${name%%-*}" != "${base_release%%-*}" ]]; then
        echo "ERROR: ${name} is not a release of ${base_release}"
        exit 1
    fi
done
