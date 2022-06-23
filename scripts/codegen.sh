#!/usr/bin/env bash
set -e
set -x

defaults write com.apple.dt.Xcode IDEPackageOnlyUseVersionsFromResolvedFile -bool NO
defaults write com.apple.dt.Xcode IDEDisableAutomaticPackageResolution -bool NO

tuist generate --path Projects/Codegen --no-open

x=$( xcodebuild -showBuildSettings -project Projects/Codegen/Codegen.project | grep ' BUILD_DIR =' | sed -e 's/.*= *//' )

DYLD_FRAMEWORK_PATH=$x/Debug DYLD_LIBRARY_PATH=$x/Debug $x/Debug/Codegen.app/Contents/MacOS/Codegen
