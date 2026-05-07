#!/usr/bin/env bash
# Pre-build phase on CoreDependencies. Runs gradle to rebuild HedvigShared.framework
# into ${BUILT_PRODUCTS_DIR} when .local-umbrella is present; no-op otherwise.

set -euo pipefail

UGGLAN_ROOT="$SRCROOT/../.."
if [ ! -f "$UGGLAN_ROOT/.local-umbrella" ]; then
    exit 0
fi

if [ "YES" = "${OVERRIDE_KOTLIN_BUILD_IDE_SUPPORTED:-}" ]; then
    echo "Skipping Gradle (OVERRIDE_KOTLIN_BUILD_IDE_SUPPORTED=YES)"
    exit 0
fi

ANDROID_REPO="$UGGLAN_ROOT/../android"
if [ ! -d "$ANDROID_REPO" ]; then
    echo "error: expected android repo at $ANDROID_REPO" >&2
    exit 1
fi

cd "$ANDROID_REPO"
./gradlew :umbrella:embedAndSignAppleFrameworkForXcode
