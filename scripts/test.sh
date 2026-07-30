#!/bin/bash
# Runs the test suite. Wrapper needed because Command Line Tools (no full Xcode)
# don't put Swift Testing on the default search paths.
set -euo pipefail
cd "$(dirname "$0")/.."

FWK=/Library/Developer/CommandLineTools/Library/Developer/Frameworks
LIBDIR=/Library/Developer/CommandLineTools/Library/Developer/usr/lib

swift test \
    -Xswiftc -F"$FWK" \
    -Xlinker -F"$FWK" \
    -Xlinker -rpath -Xlinker "$FWK" \
    -Xlinker -rpath -Xlinker "$LIBDIR" \
    "$@"
