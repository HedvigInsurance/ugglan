#!/usr/bin/env bash
set -e
set -x

touch ~/.netrc

echo "machine maven.pkg.github.com" > ~/.netrc
echo "login ${MAVEN_LOGIN}" >> ~/.netrc
echo "password ${MAVEN_PASSWORD}" >> ~/.netrc

brew tap tuist/tuist@4.31.0
brew install --formula tuist@4.31.0
brew install --formula tuist@4.31.0

cd $CI_PRIMARY_REPOSITORY_PATH;

scripts/post-checkout.sh
