#!/usr/bin/env bash
set -e
set -x

patch Projects/Payment/Payment.xcodeproj/project.pbxproj scripts/macOS-platform-filter-patch-2.patch
patch Projects/App/Ugglan.xcodeproj/project.pbxproj scripts/macOS-platform-filter-patch-1.patch