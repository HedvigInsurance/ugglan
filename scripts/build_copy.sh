#!/bin/sh
set -e
set -u
set -o pipefail

mainDir=${CONFIGURATION_BUILD_DIR}/../

frameworks=$(find "${mainDir}" -name '*.framework')

for file in $frameworks
do
    if [ ! -d "${SRCROOT}/../../Carthage/Build/iOS/$(basename -- $file)" ] && [ $file != *".app"* ] && [ $file != *"XC"* ]; then
        rsync --progress -a -u -v "${file}" "${CONFIGURATION_BUILD_DIR}"
    else
        echo "Skipping $file as it seems to be a Carthage dependency, nested inside an app bundle or being XC*!"
    fi
done
