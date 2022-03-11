#!/usr/bin/env bash
set -e
set -x

buildDir=$(xcodebuild \
    -project Codegen/Codegen.xcodeproj \
    -scheme "Apollo Codegen" \
    build | grep 'TARGET_BUILD_DIR')

eval $buildDir

$TARGET_BUILD_DIR/Codegen.app/Contents/MacOS/Codegen
