#!/usr/bin/env bash
set -e
set -x

defaults write com.apple.dt.Xcode IDEPackageOnlyUseVersionsFromResolvedFile -bool NO
defaults write com.apple.dt.Xcode IDEDisableAutomaticPackageResolution -bool NO

tuist generate --path Projects/Codegen --no-open

if [[ -z "${CI_DERIVED_DATA_PATH}" ]]; then
  xcodebuild build -destination 'platform=macOS,arch=x86_64' -configuration Release -scheme Codegen -project Projects/Codegen/Codegen.xcodeproj

  x=$(xcodebuild -showBuildSettings -configuration Release -scheme Codegen -project Projects/Codegen/Codegen.xcodeproj | grep ' BUILD_DIR =' | sed -e 's/.*= *//' )

  DYLD_FRAMEWORK_PATH=$x/Release DYLD_LIBRARY_PATH=$x/Release $x/Release/Codegen.app/Contents/MacOS/Codegen
else
  xcodebuild build -destination 'platform=macOS,arch=x86_64' -derivedDataPath $CI_DERIVED_DATA_PATH -configuration Release -scheme Codegen -project Projects/Codegen/Codegen.xcodeproj

  x=$(xcodebuild -showBuildSettings -configuration Release -scheme Codegen -derivedDataPath $CI_DERIVED_DATA_PATH  -project Projects/Codegen/Codegen.xcodeproj | grep ' BUILD_DIR =' | sed -e 's/.*= *//' )

  DYLD_FRAMEWORK_PATH=$x/Release DYLD_LIBRARY_PATH=$x/Release $x/Release/Codegen.app/Contents/MacOS/Codegen
fi
