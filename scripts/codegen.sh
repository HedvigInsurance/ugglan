#!/usr/bin/env bash
set -e
set -x

Set default com.apple.dt.Xcode IDEPackageOnlyUseVersionsFromResolvedFile to false
Set default com.apple.dt.Xcode IDEDisableAutomaticPackageResolution to false

tuist generate --path Projects/Codegen --no-open

x=$(xcodebuild -showBuildSettings -workspace Projects/Codegen/Codegen.workspace | grep ' BUILD_DIR =' | sed -e 's/.*= *//' )

DYLD_FRAMEWORK_PATH=$x/Debug DYLD_LIBRARY_PATH=$x/Debug $x/Debug/Codegen.app/Contents/MacOS/Codegen
