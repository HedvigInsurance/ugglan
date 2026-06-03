#!/usr/bin/env bash
set -e
set -x

# `xcodebuild build-for-testing` builds the union of valid sim archs (arm64
# + x86_64) so the .xctestproducts bundle is portable across runner archs,
# ignoring ONLY_ACTIVE_ARCH. HedvigShared (KMP umbrella) only ships an arm64
# simulator slice, so the x86_64 link step drops every .o and fails.
# Exporting EXCLUDED_ARCHS here promotes it to a build setting at the
# highest precedence, overriding every xcconfig/target-level value.
export EXCLUDED_ARCHS="x86_64"
