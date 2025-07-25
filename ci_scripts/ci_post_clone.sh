#!/usr/bin/env bash
set -e
set -x

brew tap tuist/tuist
brew install --formula tuist@4.50.2

cd $CI_PRIMARY_REPOSITORY_PATH;

scripts/post-checkout.sh
