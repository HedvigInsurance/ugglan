#!/bin/sh

INSTALL_DIR=$PWD/tuist curl -Ls https://install.tuist.io | bash

$INSTALL_DIR  generate
