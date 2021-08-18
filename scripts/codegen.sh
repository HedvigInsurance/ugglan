#!/usr/bin/env bash
set -e
set -x

tuist generate --path Projects/Codegen

if [ -z "$CI" ]; then
    buildDir=$(xcodebuild \
    -project Projects/Codegen/Codegen.xcodeproj \
    -scheme "Apollo Codegen" \
    build | grep 'TARGET_BUILD_DIR')
else
    buildDir=$(xcodebuild \
        -derivedDataPath ../../../DerivedData  \
        -project Projects/Codegen/Codegen.xcodeproj \
        -scheme "Apollo Codegen" \
        build | grep 'TARGET_BUILD_DIR')
fi

eval $buildDir

$TARGET_BUILD_DIR/Codegen.app/Contents/MacOS/Codegen
