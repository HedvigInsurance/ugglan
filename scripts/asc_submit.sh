#!/usr/bin/env bash
#
# Automates App Store submission via the App Store Connect API:
# 1. Extracts app version from the archive
# 2. Creates a new App Store version if one doesn't exist
# 3. Waits for build processing to complete
# 4. Selects the build for the version
# 5. Submits the version for App Store review
#
# Required environment variables (set in Xcode Cloud workflow):
#   ASC_KEY_ID        - App Store Connect API Key ID
#   ASC_ISSUER_ID     - App Store Connect API Issuer ID
#   ASC_PRIVATE_KEY   - App Store Connect API Private Key (base64-encoded .p8 contents)
#   APP_APPLE_ID      - Your app's Apple ID (numeric, from App Store Connect)
#
# Optional:
#   ASC_PLATFORM      - Platform string (default: IOS)
#   CI_ARCHIVE_PATH   - Set automatically by Xcode Cloud
#   CI_BUILD_NUMBER   - Set automatically by Xcode Cloud

set -euo pipefail

# --- Configuration ---
PLATFORM="${ASC_PLATFORM:-IOS}"
ASC_API="https://api.appstoreconnect.apple.com/v1"
MAX_BUILD_WAIT_SECONDS=3600  # 1 hour
BUILD_POLL_INTERVAL=30       # seconds

# --- Generate JWT ---
generate_jwt() {
  local header payload unsigned_token signature

  local now
  now=$(date +%s)
  local exp=$((now + 1200))  # 20 minute expiry

  header=$(printf '{"alg":"ES256","kid":"%s","typ":"JWT"}' "$ASC_KEY_ID" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')
  payload=$(printf '{"iss":"%s","iat":%d,"exp":%d,"aud":"appstoreconnect-v1"}' "$ASC_ISSUER_ID" "$now" "$exp" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

  unsigned_token="${header}.${payload}"

  local key_file
  key_file=$(mktemp)
  echo "$ASC_PRIVATE_KEY" | base64 --decode > "$key_file"

  # OpenSSL produces DER-encoded ECDSA signatures, but JWT ES256 requires raw R||S (64 bytes).
  # Temporarily disable pipefail — the pipeline is fragile under set -eo pipefail in subshells.
  set +o pipefail 2>/dev/null || true
  signature=$(printf '%s' "$unsigned_token" \
    | openssl dgst -sha256 -sign "$key_file" -binary \
    | python3 -c "
import sys
der = sys.stdin.buffer.read()
idx = 2
r_len = der[idx + 1]
r = der[idx + 2 : idx + 2 + r_len]
idx = idx + 2 + r_len
s_len = der[idx + 1]
s = der[idx + 2 : idx + 2 + s_len]
r = r[-32:].rjust(32, b'\x00')
s = s[-32:].rjust(32, b'\x00')
sys.stdout.buffer.write(r + s)
" \
    | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')
  set -o pipefail 2>/dev/null || true
  rm -f "$key_file"

  echo "${unsigned_token}.${signature}"
}

# --- API helper ---
asc_curl() {
  local method="$1"
  local url="$2"
  local data="${3:-}"

  local token
  token=$(generate_jwt)

  local body_file
  body_file=$(mktemp)

  local args=(
    -s
    -g
    -o "$body_file"
    -w '%{http_code}'
    -H "Authorization: Bearer ${token}"
    -H "Content-Type: application/json"
    -X "$method"
  )

  if [ -n "$data" ]; then
    args+=(-d "$data")
  fi

  local http_code body
  http_code=$(curl "${args[@]}" "$url" 2>&1) || true
  body=$(cat "$body_file")
  rm -f "$body_file"

  echo "DEBUG: ${method} ${url} → HTTP ${http_code}" >&2

  if [ -z "$http_code" ] || [ "$http_code" -lt 200 ] 2>/dev/null || [ "$http_code" -ge 300 ] 2>/dev/null; then
    echo "ERROR: ASC API ${method} ${url} returned HTTP ${http_code}" >&2
    echo "$body" >&2
    return 1
  fi

  echo "$body"
}

# --- Extract app version and build number ---
# Prefers APP_VERSION/BUILD_NUMBER env vars (set by GitHub Actions).
# Falls back to reading from the Xcode Cloud archive.
get_app_version() {
  if [ -n "${APP_VERSION:-}" ]; then
    echo "$APP_VERSION"
  elif [ -n "${CI_ARCHIVE_PATH:-}" ]; then
    /usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${CI_ARCHIVE_PATH}/Products/Applications/Hedvig.app/Info.plist"
  else
    echo "ERROR: APP_VERSION or CI_ARCHIVE_PATH must be set" >&2
    return 1
  fi
}

get_build_number() {
  if [ -n "${BUILD_NUMBER:-}" ]; then
    echo "$BUILD_NUMBER"
  elif [ -n "${CI_ARCHIVE_PATH:-}" ]; then
    /usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${CI_ARCHIVE_PATH}/Products/Applications/Hedvig.app/Info.plist"
  else
    echo "ERROR: BUILD_NUMBER or CI_ARCHIVE_PATH must be set" >&2
    return 1
  fi
}

# --- Find existing App Store version ---
find_app_store_version() {
  local app_version="$1"
  local response

  response=$(asc_curl GET "${ASC_API}/apps/${APP_APPLE_ID}/appStoreVersions?filter[versionString]=${app_version}&filter[platform]=${PLATFORM}") || {
    echo "ERROR: Failed to fetch App Store versions for ${app_version}" >&2
    return 1
  }

  local version_id
  version_id=$(echo "$response" | python3 -c "
import sys, json
data = json.load(sys.stdin)
versions = data.get('data', [])
if versions:
    print(versions[0]['id'])
" 2>&1) || {
    echo "WARNING: Failed to parse appStoreVersions response: ${version_id}" >&2
    echo ""
    return 0
  }

  echo "$version_id"
}

# --- Create new App Store version ---
create_app_store_version() {
  local app_version="$1"

  local payload
  payload=$(python3 -c "
import json, sys
print(json.dumps({
    'data': {
        'type': 'appStoreVersions',
        'attributes': {
            'versionString': sys.argv[1],
            'platform': sys.argv[2],
            'releaseType': 'MANUAL'
        },
        'relationships': {
            'app': {
                'data': {
                    'type': 'apps',
                    'id': sys.argv[3]
                }
            }
        }
    }
}))
" "$app_version" "$PLATFORM" "$APP_APPLE_ID")

  local response
  response=$(asc_curl POST "${ASC_API}/appStoreVersions" "$payload") || {
    echo "ERROR: Failed to create App Store version ${app_version}" >&2
    return 1
  }

  local version_id
  version_id=$(echo "$response" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data['data']['id'])
" 2>&1) || {
    echo "ERROR: Failed to parse create version response: ${version_id}" >&2
    echo "Response was: ${response}" >&2
    return 1
  }

  echo "$version_id"
}

# --- Wait for build to appear and finish processing ---
wait_for_build() {
  local app_version="$1"
  local build_number="$2"
  local elapsed=0

  echo "Waiting for build ${build_number} (version ${app_version}) to finish processing..." >&2

  while [ $elapsed -lt $MAX_BUILD_WAIT_SECONDS ]; do
    local response
    response=$(asc_curl GET "${ASC_API}/builds?filter[app]=${APP_APPLE_ID}&filter[version]=${build_number}&filter[preReleaseVersion.version]=${app_version}") || {
      echo "  API error, retrying..." >&2
      sleep $BUILD_POLL_INTERVAL
      elapsed=$((elapsed + BUILD_POLL_INTERVAL))
      continue
    }

    if [ -n "$response" ]; then
      local build_info
      build_info=$(echo "$response" | python3 -c "
import sys, json
data = json.load(sys.stdin)
builds = data.get('data', [])
if builds:
    b = builds[0]
    print(b['id'] + '|' + b['attributes'].get('processingState', 'UNKNOWN'))
" 2>&1 || true)

      # Skip if python3 produced a traceback instead of build info
      if [ -n "$build_info" ] && [[ "$build_info" != *"Traceback"* ]]; then
        local build_id="${build_info%%|*}"
        local state="${build_info##*|}"

        echo "  Build state: ${state}" >&2

        if [ "$state" = "VALID" ]; then
          echo "Build ${build_number} is ready." >&2
          echo "$build_id"
          return 0
        elif [ "$state" = "INVALID" ]; then
          echo "ERROR: Build ${build_number} is INVALID. Check App Store Connect for details." >&2
          return 1
        fi
      else
        echo "  Build not found yet or parse error: ${build_info}" >&2
      fi
    else
      echo "  No response from builds API (build may not be uploaded yet)." >&2
    fi

    sleep $BUILD_POLL_INTERVAL
    elapsed=$((elapsed + BUILD_POLL_INTERVAL))
  done

  echo "ERROR: Timed out waiting for build to process after ${MAX_BUILD_WAIT_SECONDS}s" >&2
  return 1
}

# --- Select build for the version ---
select_build_for_version() {
  local version_id="$1"
  local build_id="$2"

  local payload
  payload=$(python3 -c "
import json, sys
print(json.dumps({
    'data': {
        'type': 'builds',
        'id': sys.argv[1]
    }
}))
" "$build_id")

  asc_curl PATCH "${ASC_API}/appStoreVersions/${version_id}/relationships/build" "$payload" > /dev/null || {
    echo "ERROR: Failed to select build ${build_id} for version ${version_id}" >&2
    return 1
  }
}

# --- Set "What's New" release notes on all localizations ---
set_whats_new() {
  local version_id="$1"
  local response
  response=$(asc_curl GET "${ASC_API}/appStoreVersions/${version_id}/appStoreVersionLocalizations") || {
    echo "ERROR: Failed to fetch localizations for version ${version_id}" >&2
    return 1
  }

  local localizations
  localizations=$(echo "$response" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for loc in data.get('data', []):
    whats_new = loc['attributes'].get('whatsNew') or ''
    print(loc['id'] + '|' + loc['attributes'].get('locale', '') + '|' + whats_new)
" 2>&1) || {
    echo "ERROR: Failed to parse localizations response: ${localizations}" >&2
    return 1
  }

  for entry in $localizations; do
    local loc_id="${entry%%|*}"
    local rest="${entry#*|}"
    local locale="${rest%%|*}"
    local existing_whats_new="${rest#*|}"

    if [ -n "$existing_whats_new" ]; then
      echo "  Skipping localization ${loc_id} (${locale}) — already has release notes."
      continue
    fi

    local whats_new
    case "$locale" in
      sv*) whats_new='Hedvig-appen har uppdaterats för att göra det ännu enklare att hantera din försäkring.' ;;
      *)   whats_new='The latest version contains bug fixes and performance improvements.' ;;
    esac

    local payload
    payload=$(python3 -c "
import json, sys
print(json.dumps({
    'data': {
        'type': 'appStoreVersionLocalizations',
        'id': sys.argv[1],
        'attributes': {
            'whatsNew': sys.argv[2]
        }
    }
}))
" "$loc_id" "$whats_new")
    asc_curl PATCH "${ASC_API}/appStoreVersionLocalizations/${loc_id}" "$payload" > /dev/null || {
      echo "  ERROR: Failed to update localization ${loc_id} (${locale})" >&2
      continue
    }
    echo "  Updated localization ${loc_id} (${locale})"
  done
}

# --- Submit for App Store review ---
# Uses the newer 3-step reviewSubmissions flow (appStoreReviewSubmissions is deprecated).
submit_for_review() {
  local version_id="$1"

  # Step 1: Create a review submission
  local payload response submission_id
  payload=$(python3 -c "
import json, sys
print(json.dumps({
    'data': {
        'type': 'reviewSubmissions',
        'attributes': {
            'platform': sys.argv[1]
        },
        'relationships': {
            'app': {
                'data': {
                    'type': 'apps',
                    'id': sys.argv[2]
                }
            }
        }
    }
}))
" "$PLATFORM" "$APP_APPLE_ID")

  response=$(asc_curl POST "${ASC_API}/reviewSubmissions" "$payload") || {
    echo "ERROR: Failed to create review submission" >&2
    return 1
  }

  submission_id=$(echo "$response" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data['data']['id'])
") || {
    echo "ERROR: Failed to parse review submission response" >&2
    return 1
  }
  echo "Created review submission (ID: ${submission_id})"

  # Step 2: Add the app store version as a submission item
  payload=$(python3 -c "
import json, sys
print(json.dumps({
    'data': {
        'type': 'reviewSubmissionItems',
        'relationships': {
            'reviewSubmission': {
                'data': {
                    'type': 'reviewSubmissions',
                    'id': sys.argv[1]
                }
            },
            'appStoreVersion': {
                'data': {
                    'type': 'appStoreVersions',
                    'id': sys.argv[2]
                }
            }
        }
    }
}))
" "$submission_id" "$version_id")

  asc_curl POST "${ASC_API}/reviewSubmissionItems" "$payload" > /dev/null || {
    echo "ERROR: Failed to add version to review submission" >&2
    return 1
  }
  echo "Added version to review submission."

  # Step 3: Submit for review
  payload=$(python3 -c "
import json, sys
print(json.dumps({
    'data': {
        'type': 'reviewSubmissions',
        'id': sys.argv[1],
        'attributes': {
            'submitted': True
        }
    }
}))
" "$submission_id")

  asc_curl PATCH "${ASC_API}/reviewSubmissions/${submission_id}" "$payload" > /dev/null || {
    echo "ERROR: Failed to submit for review" >&2
    return 1
  }
}

# --- Main ---
main() {
  echo "===== App Store Connect Submission ====="

  # Validate required env vars
  for var in ASC_KEY_ID ASC_ISSUER_ID ASC_PRIVATE_KEY APP_APPLE_ID; do
    if [ -z "${!var:-}" ]; then
      echo "ERROR: Required environment variable ${var} is not set."
      exit 1
    fi
  done

  local app_version build_number
  app_version=$(get_app_version)
  build_number=$(get_build_number)
  echo "App version: ${app_version}"
  echo "Build number: ${build_number}"

  # Step 1: Find or create App Store version
  local version_id
  echo "Looking for existing App Store version ${app_version}..."
  version_id=$(find_app_store_version "$app_version" || true)

  if [ -n "$version_id" ]; then
    echo "App Store version ${app_version} already exists (ID: ${version_id}). Skipping creation."
  else
    echo "Creating new App Store version ${app_version}..."
    version_id=$(create_app_store_version "$app_version" || true)
    if [ -n "$version_id" ]; then
      echo "Created App Store version ${app_version} (ID: ${version_id})."
    else
      echo "Create failed, searching again (version may already exist)..."
      version_id=$(find_app_store_version "$app_version" || true)
    fi
    if [ -z "$version_id" ]; then
      echo "ERROR: Could not find or create App Store version ${app_version}." >&2
      exit 1
    fi
  fi

  # Step 2: Wait for build processing
  local build_id
  build_id=$(wait_for_build "$app_version" "$build_number")

  # Step 3: Select build for the version
  echo "Selecting build ${build_number} for version ${app_version}..."
  select_build_for_version "$version_id" "$build_id"
  echo "Build selected."

  # Step 4: Set "What's New" release notes
  echo "Setting release notes..."
  set_whats_new "$version_id"

  # Step 5: Submit for review
  echo "Submitting version ${app_version} for App Store review..."
  submit_for_review "$version_id"
  echo "===== Submitted for App Store review! ====="
}

main "$@"
