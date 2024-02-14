#!/usr/bin/env bash
set -e
set -x

touch ~/.netrc

echo "machine maven.pkg.github.com" > ~/.netrc
echo "login ${MAVEN_LOGIN}" >> ~/.netrc
echo "password ${MAVEN_PASSWORD}" >> ~/.netrc

mkdir build
TMPDIR=build


curl -L --fail "https://github.com/DataDog/datadog-ci/releases/latest/download/datadog-ci_darwin-x64" --output "$TMPDIR/datadog-ci" && chmod +x $TMPDIR/datadog-ci

datadog-ci dsyms upload $TMPDIR

export PATH=$PATH":$CI_PRIMARY_REPOSITORY_PATH/.tuist-bin"

cd $CI_PRIMARY_REPOSITORY_PATH;

scripts/post-checkout.sh
