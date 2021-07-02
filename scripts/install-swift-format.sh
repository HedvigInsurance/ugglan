#!/usr/bin/env bash
set -e
set -x

mkdir -p build
cd build

if [ -d "swift-format" ] 
then
    echo "Skipping cloning" 
else
    git clone -b swift-5.4-branch https://github.com/apple/swift-format.git
fi

cd swift-format

swift build -c release --disable-sandbox