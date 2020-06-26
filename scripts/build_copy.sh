#!/bin/sh
set -e
set -u
set -o pipefail

mainDir=${CONFIGURATION_BUILD_DIR}/../

frameworks=$(find "${mainDir}" -name '*.framework')

for file in $frameworks
do
    if [ ! -d "${SRCROOT}/../../Carthage/Build/iOS/$(basename -- $file)" ] && [[ $file != *".app"* ]] && [[ $file != *"XCTest.framework"* ]] && [[ $file != *"XCTAutomationSupport.framework"* ]]; then
        rsync --progress -a -u -v "${file}" "${CONFIGURATION_BUILD_DIR}"
    else
        echo "Skipping $file as it seems to be a Carthage dependency, nested inside an app bundle or being XC*!"
    fi
done

swiftModules=$(find "${mainDir}" -name '*.swiftmodule')

for file in $swiftModules
do
    rsync --progress -a -u -v "${file}" "${CONFIGURATION_BUILD_DIR}"
done

swiftO=$(find "${mainDir}" -name '*.o')

for file in $swiftO
do
    rsync --progress -a -u -v "${file}" "${CONFIGURATION_BUILD_DIR}"
done
