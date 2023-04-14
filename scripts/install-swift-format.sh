#!/usr/bin/env bash
set -e
set -x

mkdir -p build
cd build

if [ -d "swift-format" ] 
then
    echo "Skipping installing"
    cd ../
else
    git clone -b release/5.9 https://github.com/apple/swift-format.git

    cd swift-format

    swift build -c release --disable-sandbox

    cd ../..
fi
