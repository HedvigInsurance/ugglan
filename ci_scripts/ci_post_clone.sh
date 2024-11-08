#!/usr/bin/env bash
set -e
set -x

touch ~/.netrc

echo "machine maven.pkg.github.com" > ~/.netrc
echo "login ${MAVEN_LOGIN}" >> ~/.netrc
echo "password ${MAVEN_PASSWORD}" >> ~/.netrc

brew tap tuist/tuist
brew install --formula tuist@4.31.0
if [[ $CI_WORKFLOW == "Tests" ]]; then
    echo "tests" > ~/buildForTests
fi

if test -f ~/buildForTests; then
    echo "BUILDFORTESTS"
fi

cd $CI_PRIMARY_REPOSITORY_PATH;

scripts/post-checkout.sh
