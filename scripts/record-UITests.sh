#!/bin/bash

xcodebuild \
  -project test.xcodeproj \
  -scheme Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone Xs,OS=13.0' \
  SWIFT_ACTIVE_COMPILATION_CONDITIONS="DEBUG RECORD_MODE APP_VARIANT_DEV" \
  test
