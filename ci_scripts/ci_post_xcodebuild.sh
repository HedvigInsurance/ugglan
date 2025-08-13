#!/usr/bin/env bash
set -e
set -x

if [ "${DATADOG_API_KEY+x}" ]; then
echo "===== upload to datadog phase ====="
npx @datadog/datadog-ci dsyms upload "${CI_ARCHIVE_PATH}/dSYMs/"
fi
