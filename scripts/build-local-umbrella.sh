#!/usr/bin/env bash
# Pre-build phase attached to the CoreDependencies target. Builds HedvigShared.framework
# directly into ${BUILT_PRODUCTS_DIR} via the KMP `embedAndSignAppleFrameworkForXcode`
# task, but only when `.local-umbrella-path` is present (set by use-local-umbrella.sh).
# When absent, this is a no-op and Ugglan consumes the released SPM package as usual.
#
# Mirrors the pattern used by android/micro-apps/umbrella-consumer.

set -euo pipefail

UGGLAN_ROOT="$SRCROOT/../.."
if [ ! -f "$UGGLAN_ROOT/.local-umbrella-path" ]; then
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
