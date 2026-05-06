#!/usr/bin/env bash
# Switch Ugglan to "local umbrella" mode: HedvigShared.framework is built fresh from
# the sibling android repo by a pre-build phase on every Xcode build, instead of being
# consumed as a published Swift Package. After running this once, every Xcode rebuild
# picks up your latest Kotlin changes — no extra commands needed between iterations.
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

touch "$UGGLAN_ROOT/.local-umbrella-path"
echo "==> Marker created at $UGGLAN_ROOT/.local-umbrella-path"

( cd "$UGGLAN_ROOT" && scripts/post-checkout.sh )
echo "==> Done. Open Ugglan.xcworkspace and build — gradle runs as a pre-build phase."
echo "    Run scripts/use-released-umbrella.sh to revert to the published package."
