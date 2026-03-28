#!/bin/bash
set -euo pipefail

required_vars=(
  APPLE_TEAM_ID
  APP_BUNDLE_IDENTIFIER
  PROFILE_NAME
)

for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "Missing required environment variable: $var_name" >&2
    exit 1
  fi
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/TianlaiVotePad.xcodeproj"
SCHEME="TianlaiVotePad"
BUILD_DIR="$ROOT_DIR/build"
LOG_DIR="$BUILD_DIR/logs"
ARCHIVE_PATH="$BUILD_DIR/TianlaiVotePad.xcarchive"
EXPORT_PATH="$BUILD_DIR/export"
EXPORT_OPTIONS_PLIST="$BUILD_DIR/ExportOptions.plist"
TEMPLATE_EXPORT_OPTIONS_PLIST="$ROOT_DIR/ci/ExportOptions.plist"

mkdir -p "$LOG_DIR" "$EXPORT_PATH"

if [[ -n "${EXPORT_OPTIONS_PLIST_BASE64:-}" ]]; then
  if ! printf '%s' "$EXPORT_OPTIONS_PLIST_BASE64" | base64 --decode > "$EXPORT_OPTIONS_PLIST" 2>/dev/null; then
    printf '%s' "$EXPORT_OPTIONS_PLIST_BASE64" | base64 -D > "$EXPORT_OPTIONS_PLIST"
  fi
elif [[ -f "$TEMPLATE_EXPORT_OPTIONS_PLIST" ]]; then
  : "${EXPORT_METHOD:?Missing required environment variable: EXPORT_METHOD}"

  cp "$TEMPLATE_EXPORT_OPTIONS_PLIST" "$EXPORT_OPTIONS_PLIST"
  sed -i.bak \
    -e "s/__EXPORT_METHOD__/${EXPORT_METHOD}/g" \
    -e "s/__APPLE_TEAM_ID__/${APPLE_TEAM_ID}/g" \
    -e "s/__APP_BUNDLE_IDENTIFIER__/${APP_BUNDLE_IDENTIFIER}/g" \
    -e "s/__PROFILE_NAME__/${PROFILE_NAME}/g" \
    "$EXPORT_OPTIONS_PLIST"
  rm -f "${EXPORT_OPTIONS_PLIST}.bak"
else
  : "${EXPORT_METHOD:?Missing required environment variable: EXPORT_METHOD}"

  cat > "$EXPORT_OPTIONS_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>${EXPORT_METHOD}</string>
  <key>signingStyle</key>
  <string>manual</string>
  <key>teamID</key>
  <string>${APPLE_TEAM_ID}</string>
  <key>provisioningProfiles</key>
  <dict>
    <key>${APP_BUNDLE_IDENTIFIER}</key>
    <string>${PROFILE_NAME}</string>
  </dict>
  <key>stripSwiftSymbols</key>
  <true/>
  <key>compileBitcode</key>
  <false/>
</dict>
</plist>
EOF
fi

echo "Archiving $SCHEME for generic iOS device..."

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  DEVELOPMENT_TEAM="$APPLE_TEAM_ID" \
  PRODUCT_BUNDLE_IDENTIFIER="$APP_BUNDLE_IDENTIFIER" \
  CODE_SIGN_STYLE=Manual \
  PROVISIONING_PROFILE_SPECIFIER="$PROFILE_NAME" \
  clean archive \
  | tee "$LOG_DIR/archive.log"

echo "Exporting IPA..."

xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
  | tee "$LOG_DIR/export.log"
