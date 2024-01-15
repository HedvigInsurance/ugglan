#!/usr/bin/env bash
set -e
set -x

export PATH=$PATH":$CI_PRIMARY_REPOSITORY_PATH/.tuist-bin"

cd $CI_PRIMARY_REPOSITORY_PATH;

scripts/post-checkout.sh
