#!/bin/bash
# Builds the release binary and assembles dist/Busy Tabs.app (ad-hoc signed).
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${VERSION:-0.1.0}"
APP="dist/Busy Tabs.app"

swift build -c release

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"

cp .build/release/BusyTabs "$APP/Contents/MacOS/BusyTabs"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>BusyTabs</string>
    <key>CFBundleIdentifier</key>
    <string>ai.cyberdogs.busytabs</string>
    <key>CFBundleName</key>
    <string>Busy Tabs</string>
    <key>CFBundleDisplayName</key>
    <string>Busy Tabs</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>© Cyber Dogs AI</string>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP"
echo "Built $APP (v${VERSION})"
