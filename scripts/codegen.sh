#!/usr/bin/env bash
set -e
set -x

tuist generate --path Projects/Codegen

buildDir=$(xcodebuild \
-project Projects/Codegen/Codegen.xcodeproj \
-scheme "Apollo Codegen" \
build | grep 'TARGET_BUILD_DIR')

eval $buildDir

$TARGET_BUILD_DIR/Codegen.app/Contents/MacOS/Codegen
