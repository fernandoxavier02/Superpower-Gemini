#!/usr/bin/env bash
# Superpowers — Gemini CLI Extension Uninstaller

set -euo pipefail

EXTENSION_DIR="${HOME}/.gemini/extensions/superpowers"

echo ""
echo "Superpowers — Uninstaller"
echo ""

if [ -d "${EXTENSION_DIR}" ]; then
  read -p "Remove extension from ${EXTENSION_DIR}? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "${EXTENSION_DIR}"
    echo "  Extension removed."
  fi
else
  echo "  Extension not found at ${EXTENSION_DIR}"
fi

echo ""
echo "Done. You can also use: gemini extensions disable superpowers"
