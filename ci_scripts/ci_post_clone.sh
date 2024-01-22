#!/usr/bin/env bash
set -e
set -x

touch ~/.netrc

echo "machine maven.pkg.github.com" > ~/.netrc
echo "login ${MAVEN_LOGIN}" >> ~/.netrc
echo "password ${MAVEN_PASSWORD}" >> ~/.netrc

export PATH=$PATH":$CI_PRIMARY_REPOSITORY_PATH/.tuist-bin"

cd $CI_PRIMARY_REPOSITORY_PATH;

scripts/post-checkout.sh
