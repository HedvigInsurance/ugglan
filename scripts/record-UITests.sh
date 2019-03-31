#!/bin/bash

xcodebuild \
  -project project.xcodeproj \
  -scheme Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone X,OS=12.0' \
  SWIFT_ACTIVE_COMPILATION_CONDITIONS="DEBUG RECORD_MODE" \
  test
