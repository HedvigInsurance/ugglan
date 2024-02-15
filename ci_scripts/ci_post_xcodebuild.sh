#!/usr/bin/env bash

if [ "$CI_WORKFLOW" = "Release" ];
then
    mkdir build
    TMPDIR=build/datadog

    mkdir $TMPDIR

    curl -L --fail https://github.com/DataDog/datadog-ci/releases/latest/download/datadog-ci_darwin-x64 --output $TMPDIR/datadog-ci && chmod +x $TMPDIR/datadog-ci

    echo "Uploading Symbol"
    export DATADOG_SITE="datadoghq.eu"
    export DATADOG_API_KEY="${DATADOG_API_KEY}"
    build/datadog/datadog-ci dsyms upload $CI_ARCHIVE_PATH/dSYMs/
fi
