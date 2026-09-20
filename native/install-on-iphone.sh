#!/bin/bash
set -euo pipefail
NATIVE_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -z "${DEVELOPER_DIR:-}" && -d /Applications/Xcode.app/Contents/Developer ]]; then
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi
if ! xcrun --find xcodebuild >/dev/null 2>&1; then
  echo 'Full Xcode is required. Install and launch Xcode, then rerun.' >&2
  exit 1
fi
if [[ $# -lt 2 ]]; then
  echo 'Usage: ./install-on-iphone.sh DEVICE_UDID TEAM_ID [BASE_BUNDLE_ID]'
  xcrun devicectl list devices
  exit 1
fi
DEVICE_UDID="$1"
TEAM_ID="$2"
BUNDLE_ID="${3:-com.liuzhe.xuanxu.demo}"
xcrun xcodebuild -project "$NATIVE_DIR/XuanXu.xcodeproj" -scheme XuanXu \
  -configuration Debug -destination "id=$DEVICE_UDID" \
  -derivedDataPath "$NATIVE_DIR/build" -allowProvisioningUpdates \
  -allowProvisioningDeviceRegistration "DEVELOPMENT_TEAM=$TEAM_ID" \
  "BASE_BUNDLE_ID=$BUNDLE_ID" build
APP_PATH="$NATIVE_DIR/build/Build/Products/Debug-iphoneos/XuanXu.app"
test -d "$APP_PATH/PlugIns/XuanXuWidget.appex"
/usr/bin/codesign --verify --deep --strict "$APP_PATH"
xcrun devicectl device install app --device "$DEVICE_UDID" "$APP_PATH"
xcrun devicectl device process launch --device "$DEVICE_UDID" "$BUNDLE_ID"
echo 'Installed. Add the XuanXu widget using the iPhone lock-screen or home-screen widget gallery.'
