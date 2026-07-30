#!/bin/bash
# Builds the distributable installer: dist/BusyTabs.pkg (installs to /Applications).
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${VERSION:-0.1.0}"
export VERSION

./scripts/build-app.sh

pkgbuild \
    --component "dist/Busy Tabs.app" \
    --install-location /Applications \
    --identifier ai.cyberdogs.busytabs \
    --version "$VERSION" \
    "dist/BusyTabs.pkg"

echo "Built dist/BusyTabs.pkg (v${VERSION})"
