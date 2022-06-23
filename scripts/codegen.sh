#!/usr/bin/env bash
set -e
set -x

defaults write com.apple.dt.Xcode IDEPackageOnlyUseVersionsFromResolvedFile -bool NO
defaults write com.apple.dt.Xcode IDEDisableAutomaticPackageResolution -bool NO

tuist generate --path Projects/Codegen --no-open

if [[ -z "${CI_DERIVED_DATA_PATH}" ]]; then
  x=$( xcodebuild -showBuildSettings -project Projects/Codegen/Codegen.xcodeproj | grep ' BUILD_DIR =' | sed -e 's/.*= *//' )

  DYLD_FRAMEWORK_PATH=$x/Debug DYLD_LIBRARY_PATH=$x/Debug $x/Debug/Codegen.app/Contents/MacOS/Codegen
else
  x=$( xcodebuild -showBuildSettings -derivedDataPath $CI_DERIVED_DATA_PATH -scheme Codegen -project Projects/Codegen/Codegen.xcodeproj | grep ' BUILD_DIR =' | sed -e 's/.*= *//' )

  DYLD_FRAMEWORK_PATH=$x/Debug DYLD_LIBRARY_PATH=$x/Debug $x/Debug/Codegen.app/Contents/MacOS/Codegen
fi