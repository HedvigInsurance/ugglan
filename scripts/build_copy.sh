#!/bin/sh
set -e
set -u
set -o pipefail

mainDir=${CONFIGURATION_BUILD_DIR}/../

frameworks=$(find "${mainDir}" -name '*.framework')

for file in $frameworks
do
  rsync --progress -a -u -v "${file}" "${CONFIGURATION_BUILD_DIR}"
done
