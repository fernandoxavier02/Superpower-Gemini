#!/usr/bin/env bash
# ============================================================================
# Superpowers — Gemini CLI Extension Installer
# ============================================================================
#
# PREFERRED METHOD:
#   gemini extensions install https://github.com/fernandoxavier02/Superpower-Gemini
#
# ALTERNATIVE (this script):
#   git clone https://github.com/fernandoxavier02/Superpower-Gemini.git
#   cd Superpower-Gemini
#   chmod +x install.sh
#   ./install.sh
#
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GEMINI_DIR="${HOME}/.gemini"
EXTENSION_DIR="${GEMINI_DIR}/extensions/superpowers"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Superpowers — Gemini CLI Extension Installer               ║"
echo "║  Version 2.0.0                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ ! -f "${SCRIPT_DIR}/gemini-extension.json" ]; then
  echo "[ERROR] gemini-extension.json not found. Run from repo root."
  exit 1
fi

if [ ! -d "${GEMINI_DIR}" ]; then
  echo "[ERROR] ~/.gemini not found. Install Gemini CLI first."
  echo "        https://github.com/google-gemini/gemini-cli"
  exit 1
fi

echo "[1/2] Installing extension -> ${EXTENSION_DIR}"
mkdir -p "${EXTENSION_DIR}"

for dir in agents skills commands; do
  if [ -d "${SCRIPT_DIR}/${dir}" ]; then
    cp -r "${SCRIPT_DIR}/${dir}" "${EXTENSION_DIR}/"
    echo "      + ${dir}/"
  fi
done

for file in gemini-extension.json GEMINI.md BRIDGE_SPEC.md; do
  if [ -f "${SCRIPT_DIR}/${file}" ]; then
    cp "${SCRIPT_DIR}/${file}" "${EXTENSION_DIR}/${file}"
    echo "      + ${file}"
  fi
done

echo "[2/2] Verifying..."
SKILL_COUNT=$(find "${EXTENSION_DIR}/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
CMD_COUNT=$(find "${EXTENSION_DIR}/commands" -name "*.toml" 2>/dev/null | wc -l | tr -d ' ')

echo "      Skills:   ${SKILL_COUNT}/14"
echo "      Commands: ${CMD_COUNT}/12"
echo "      Agent:    $([ -f "${EXTENSION_DIR}/agents/code-reviewer.md" ] && echo 'OK' || echo 'MISSING')"
echo "      GEMINI.md: $([ -f "${EXTENSION_DIR}/GEMINI.md" ] && echo 'OK' || echo 'MISSING')"

echo ""
echo "Installation complete!"
echo ""
echo "  /superpower-bootstrap   Start the workflow"
echo "  /superpower-tdd         TDD implementation"
echo "  /superpower-debug       Systematic debugging"
echo "  /superpower-review      Code review"
echo "  /superpower-verify      Verification"
echo "  /superpower-finish      Finalize branch"
echo ""
