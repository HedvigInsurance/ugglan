#!/bin/sh

export PATH=$PATH":$CI_WORKSPACE/.tuist-bin"

cd $CI_WORKSPACE;


scripts/post-checkout.sh
