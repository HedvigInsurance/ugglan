#!/bin/bash
set -e

rm -rf **/Derived/*

scripts/githooks.sh
arch -x86_64 scripts/translations.sh
scripts/swiftgen.sh

set -e
set -x

defaults write com.apple.dt.Xcode IDEPackageOnlyUseVersionsFromResolvedFile -bool NO
defaults write com.apple.dt.Xcode IDEDisableAutomaticPackageResolution -bool NO

