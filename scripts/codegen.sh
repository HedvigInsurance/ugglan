#!/usr/bin/env bash
set -e
set -x

tuist generate --path Projects/Codegen --no-open

x=$(xcodebuild -resolvePackageDependencies -showBuildSettings -project Projects/Codegen/Codegen.xcodeproj | grep ' BUILD_DIR =' | sed -e 's/.*= *//' )

DYLD_FRAMEWORK_PATH=$x/Debug DYLD_LIBRARY_PATH=$x/Debug $x/Debug/Codegen.app/Contents/MacOS/Codegen
