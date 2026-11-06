#!/bin/bash
# Runs `tuist generate`, then rewrites the generated schemes into the form Xcode saves them in, so selecting a
# scheme in Xcode doesn't leave a diff. Arguments are passed on to `tuist generate`.
set -e

cd "$(dirname "$0")/.."

tuist generate "$@"
python3 -I scripts/normalize-schemes.py
