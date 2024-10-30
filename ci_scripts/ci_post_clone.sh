#!/usr/bin/env bash
set -e
set -x

touch ~/.netrc

echo "machine maven.pkg.github.com" > ~/.netrc
echo "login ${MAVEN_LOGIN}" >> ~/.netrc
echo "password ${MAVEN_PASSWORD}" >> ~/.netrc

brew tap tuist/tuist
brew install --formula tuist
brew install --formula tuist@4.31.0
if [[ $CI_WORKFLOW == "Tests" ]]; then
    export BUILD_FOR_TESTS="1"
fi
echo "BUILD FOR TESTS = ${BUILD_FOR_TESTS}"

cd $CI_PRIMARY_REPOSITORY_PATH;

scripts/post-checkout.sh
