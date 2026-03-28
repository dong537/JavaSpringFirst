#!/bin/bash
set -euo pipefail

required_vars=(
  APPLE_TEAM_ID
  APP_BUNDLE_IDENTIFIER
  BUILD_CERTIFICATE_BASE64
  P12_PASSWORD
  BUILD_PROVISION_PROFILE_BASE64
  KEYCHAIN_PASSWORD
)

for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "Missing required environment variable: $var_name" >&2
    exit 1
  fi
done

decode_base64_to_file() {
  local encoded_value="$1"
  local output_path="$2"

  if printf '%s' "$encoded_value" | base64 --decode > "$output_path" 2>/dev/null; then
    return 0
  fi

  printf '%s' "$encoded_value" | base64 -D > "$output_path"
}

RUNNER_TEMP_DIR="${RUNNER_TEMP:-/tmp}"
KEYCHAIN_PATH="$RUNNER_TEMP_DIR/ci-signing.keychain-db"
CERT_PATH="$RUNNER_TEMP_DIR/build_certificate.p12"
PROFILE_PATH="$RUNNER_TEMP_DIR/build_profile.mobileprovision"
PROFILE_PLIST="$RUNNER_TEMP_DIR/build_profile.plist"
PROFILE_INSTALL_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"

mkdir -p "$PROFILE_INSTALL_DIR"

decode_base64_to_file "$BUILD_CERTIFICATE_BASE64" "$CERT_PATH"
decode_base64_to_file "$BUILD_PROVISION_PROFILE_BASE64" "$PROFILE_PATH"

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security list-keychains -d user -s "$KEYCHAIN_PATH" login.keychain-db
security default-keychain -d user -s "$KEYCHAIN_PATH"
security import "$CERT_PATH" -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

security cms -D -i "$PROFILE_PATH" > "$PROFILE_PLIST"

PROFILE_UUID="$(/usr/libexec/PlistBuddy -c 'Print UUID' "$PROFILE_PLIST")"
PROFILE_NAME="$(/usr/libexec/PlistBuddy -c 'Print Name' "$PROFILE_PLIST")"

cp "$PROFILE_PATH" "$PROFILE_INSTALL_DIR/$PROFILE_UUID.mobileprovision"

if [[ -z "${GITHUB_ENV:-}" ]]; then
  echo "GITHUB_ENV is not available in this environment." >&2
  exit 1
fi

{
  echo "KEYCHAIN_PATH=$KEYCHAIN_PATH"
  echo "PROFILE_UUID=$PROFILE_UUID"
  echo "PROFILE_NAME=$PROFILE_NAME"
  echo "PROFILE_INSTALL_PATH=$PROFILE_INSTALL_DIR/$PROFILE_UUID.mobileprovision"
} >> "$GITHUB_ENV"

echo "Installed provisioning profile: $PROFILE_NAME ($PROFILE_UUID)"
