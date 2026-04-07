#!/usr/bin/env bash
set -e
set -x

if [ "${DATADOG_API_KEY+x}" ]; then
echo "===== upload to datadog phase ====="
npx @datadog/datadog-ci dsyms upload "${CI_ARCHIVE_PATH}/dSYMs/"
fi

# Trigger ASC submission via GitHub Actions after the build is uploaded.
# The workflow polls until the build appears in App Store Connect.
if [[ "${GH_ASC_SUBMIT_TOKEN+x}" ]]; then
echo "===== Triggering App Store Connect submission workflow ====="
APP_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${CI_ARCHIVE_PATH}/Products/Applications/Hedvig.app/Info.plist")
BUILD_NUMBER="${CI_BUILD_NUMBER}"
curl -s -X POST \
  -H "Authorization: Bearer ${GH_ASC_SUBMIT_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/HedvigInsurance/ugglan/dispatches" \
  -d "{\"event_type\":\"xcode-cloud-build-complete\",\"client_payload\":{\"app_version\":\"${APP_VERSION}\",\"build_number\":\"${BUILD_NUMBER}\"}}"
fi
