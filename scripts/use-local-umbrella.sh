#!/usr/bin/env bash
# Build HedvigShared.xcframework from the sibling android repo and point Tuist at it,
# bypassing the published umbrella package. Run this after every Kotlin change you
# want to test on iOS — Xcode rebuilds in between are normal.
#
# Requires android and ugglan to be checked out as siblings:
#   <parent>/android
#   <parent>/ugglan   <-- you are here

set -euo pipefail

UGGLAN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_REPO="$UGGLAN_ROOT/../android"

if [[ ! -d "$ANDROID_REPO" ]]; then
    echo "error: expected android repo at $ANDROID_REPO" >&2
    exit 1
fi

XCFRAMEWORK="$ANDROID_REPO/app/umbrella/build/XCFrameworks/release/HedvigShared.xcframework"
if [[ ! -d "$XCFRAMEWORK" ]]; then
    echo "error: gradle build did not produce $XCFRAMEWORK" >&2
    exit 1
fi

echo "$XCFRAMEWORK" > "$UGGLAN_ROOT/.local-umbrella-path"
echo "==> Marker written: $UGGLAN_ROOT/.local-umbrella-path"

echo "==> Building HedvigShared.xcframework from $ANDROID_REPO"
( cd "$ANDROID_REPO" && ./gradlew :umbrella:assembleHedvigSharedReleaseXCFramework )

( cd "$UGGLAN_ROOT" && tuist generate )
echo "==> Done. Open Ugglan.xcworkspace and rebuild."
echo "    Run scripts/use-released-umbrella.sh to revert to the published package."
