#!/usr/bin/env bash
set -e
set -x

touch ~/.netrc

echo "machine maven.pkg.github.com" > ~/.netrc
echo "login ${MAVEN_LOGIN}" >> ~/.netrc
echo "password ${MAVEN_PASSWORD}" >> ~/.netrc

if [ -z "$CI" ]; then
    TMPDIR=/tmp/datadog-2.30.0
else
    mkdir build
    TMPDIR=build/datadog-2.30.0
fi

mkdir $TMPDIR

curl -o $TMPDIR/datadog.zip -L https://github.com/DataDog/datadog-ci/releases/download/v2.30.0/datadog-ci_darwin-x64

unzip $TMPDIR/datadog.zip -d $TMPDIR

$TMPDIR/bin/datadog



export PATH=$PATH":$CI_PRIMARY_REPOSITORY_PATH/.tuist-bin"

cd $CI_PRIMARY_REPOSITORY_PATH;

scripts/post-checkout.sh
