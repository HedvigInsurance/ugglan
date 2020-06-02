#!/bin/bash
#
# This script verifies that the commitish values in the Cartfile.resolved are in
# sync with the commitish values in the Carthage/Build/*.version files.
#
# Usage:
#   cd ProjectFolder && /path/to/carthage-verify [-m no_skip_missing] [-s no_strict]

no_skip_missing=0
no_strict=0

while [ "$1" != "" ]; do
    case $1 in
        -m | --no_skip_missing )
            no_skip_missing=1
            ;;
        -s | --no_strict )
            no_strict=1
            ;;
    esac
    shift
done


sed -E 's/(github|git|binary) \"([^\"]+)\" \"([^\"]+)\"/\2 \3/g' Cartfile.resolved | while read line
do
    read -a array <<< "$line"

    # Handles:
    # - ReactiveCocoa/ReactiveSwift > ReactiveSwift
    # - Auth0/JWTDecode.swift > JWTDecode.swift
    # - https://github.com/Carthage/Carthage.git > Carthage
    # - https://www.mapbox.com/ios-sdk/Mapbox-iOS-SDK.json > Mapbox-iOS-SDK
    dependency=`basename ${array[0]} | awk -F '.(git|json)' '{print $1}'`

    resolved_commitish=${array[1]}

    echo -e "Cartfile.resolved[$dependency] at $resolved_commitish"

    version_file="Carthage/Build/.$dependency.version"

    if [ ! -f "$version_file" ]
    then
        echo -e -n "No version file found for $dependency at $version_file, " >&2

        if [ $no_skip_missing -eq 1 ]
        then
            echo "aborting." >&2
            exit 2
        else
            echo "skipping." >&2
            echo
            continue
        fi
    fi

    version_file_commitish=`grep -o '"commitish".*"' "$version_file" | awk -F'"' '{ print $4 }'`

    echo -e "$version_file at $version_file_commitish"

    if [ "$resolved_commitish" != "$version_file_commitish" ]
    then
        if [ $no_strict -eq 1 ]
        then
            echo -e "warning: $dependency commitish ($version_file_commitish) does not match resolved commitish ($resolved_commitish)" >&2
        else
            echo -e "error: $dependency commitish ($version_file_commitish) does not match resolved commitish ($resolved_commitish)" >&2
            exit 1
        fi
    fi

    echo
done
