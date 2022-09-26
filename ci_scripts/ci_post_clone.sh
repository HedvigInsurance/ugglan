#!/usr/bin/env bash
set -e
set -x

export PATH=$PATH":$CI_WORKSPACE/.tuist-bin"

cd $CI_WORKSPACE;

scripts/post-checkout.sh
