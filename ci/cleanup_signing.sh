#!/bin/bash
set -euo pipefail

if [[ -n "${PROFILE_INSTALL_PATH:-}" && -f "${PROFILE_INSTALL_PATH}" ]]; then
  rm -f "${PROFILE_INSTALL_PATH}"
fi

if [[ -n "${KEYCHAIN_PATH:-}" && -f "${KEYCHAIN_PATH}" ]]; then
  security delete-keychain "${KEYCHAIN_PATH}" || true
fi
