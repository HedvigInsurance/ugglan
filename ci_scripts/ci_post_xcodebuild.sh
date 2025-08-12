#!/usr/bin/env bash
set -e
set -x

if [ "${DATADOG_API_KEY+x}" ]; then
echo "===== upload to datadog phase ====="
npx @datadog/datadog-ci dsyms upload "${DWARF_DSYM_FOLDER_PATH}"
fi
