#!/usr/bin/env bash
# ============================================================================
# Superpowers — Multi-runtime installer helper
# ============================================================================
#
# Gemini (primary):
#   gemini extensions install https://github.com/fernandoxavier02/Superpower-Gemini
#
# Other runtimes:
#   ./install.sh --host=codex    # prints Codex native install flow
#   ./install.sh --host=opencode # prints OpenCode native install flow
#   ./install.sh --host=cursor   # prints Cursor install recommendation
#
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUPERPOWER_VERSION="5.0.7"

usage() {
  cat <<'EOF'
Usage: ./install.sh [--host=<auto|gemini|codex|cursor|opencode>]

The default is host auto-detection.

-r, --host <host>  Choose target runtime explicitly
  auto               Detect best host from environment (default)
  gemini             Run Gemini extension install copy
  codex              Show Codex native install instructions
  cursor             Show Cursor install recommendation
  opencode           Show OpenCode install instructions
EOF
}

validate_host() {
  case "$1" in
    auto|gemini|codex|cursor|opencode)
      ;;
    *)
      echo "[ERROR] Unsupported host: $1" >&2
      usage
      exit 1
      ;;
  esac
}

HOST="auto"
if [ "$#" -gt 0 ]; then
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -r|--host)
      if [ "$#" -lt 2 ]; then
        echo "[ERROR] --host requires a value." >&2
        usage
        exit 1
      fi
      HOST="$2"
      shift 2
      ;;
    --host=*)
      HOST="${1#*=}"
      shift
      ;;
    *)
      echo "[ERROR] Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
fi

if [ "$#" -gt 0 ]; then
  echo "[ERROR] Unexpected extra argument(s): $*" >&2
  usage
  exit 1
fi

validate_host "$HOST"

if [ "$HOST" = "auto" ]; then
  if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] || [ -d "${HOME}/.codex" ]; then
    HOST="codex"
  elif [ -n "${CURSOR_PLUGIN_ROOT:-}" ] || [ -d "${HOME}/.cursor" ]; then
    HOST="cursor"
  elif [ -n "${OPENCODE_CONFIG_DIR:-}" ] || [ -d "${HOME}/.config/opencode" ]; then
    HOST="opencode"
  elif [ -n "${GEMINI_PLUGIN_ROOT:-}" ] || [ -d "${HOME}/.gemini/extensions" ]; then
    HOST="gemini"
  else
    HOST="gemini"
  fi
fi
validate_host "$HOST"

show_host_instructions() {
  local host="$1"
  case "$host" in
    codex)
      echo ""
      echo "╔══════════════════════════════════════════════════════════════╗"
      echo "║  Superpowers — Codex runtime selected                      ║"
      echo "╚══════════════════════════════════════════════════════════════╝"
      echo ""
      echo "This repository is packaged for multiple runtimes."
      echo "For Codex, install using the native flow in .codex/INSTALL.md:"
      echo ""
      cat "${SCRIPT_DIR}/.codex/INSTALL.md"
      ;;
    cursor)
      echo ""
      echo "╔══════════════════════════════════════════════════════════════╗"
      echo "║  Superpowers — Cursor runtime selected                     ║"
      echo "╚══════════════════════════════════════════════════════════════╝"
      echo ""
      echo "This repository contains Cursor compatibility metadata at .cursor-plugin/plugin.json."
      echo "Add this file via your Cursor plugin installation flow."
      echo ""
      echo "Recommended steps:"
      echo "1) Import or register .cursor-plugin/plugin.json"
      echo "2) Restart Cursor"
      ;;
    opencode)
      echo ""
      echo "╔══════════════════════════════════════════════════════════════╗"
      echo "║  Superpowers — OpenCode runtime selected                    ║"
      echo "╚══════════════════════════════════════════════════════════════╝"
      echo ""
      echo "For OpenCode, use .opencode/INSTALL.md instructions:"
      echo ""
      cat "${SCRIPT_DIR}/.opencode/INSTALL.md"
      ;;
  esac
}

if [ "$HOST" != "gemini" ]; then
  show_host_instructions "$HOST"
  case "$HOST" in
    codex|cursor|opencode)
      exit 0
      ;;
  esac
  echo "[ERROR] Unsupported host: ${HOST}" >&2
  usage
  exit 1
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Superpowers — Gemini CLI Extension Installer               ║"
echo "║  Version ${SUPERPOWER_VERSION}                                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ ! -f "${SCRIPT_DIR}/gemini-extension.json" ]; then
  echo "[ERROR] gemini-extension.json not found. Run from repo root."
  exit 1
fi

GEMINI_DIR="${HOME}/.gemini"
EXTENSION_DIR="${GEMINI_DIR}/extensions/superpowers"

if [ ! -d "${GEMINI_DIR}" ]; then
  echo "[ERROR] ~/.gemini not found. Install Gemini CLI first."
  echo "        https://github.com/google-gemini/gemini-cli"
  exit 1
fi

echo "[1/2] Installing extension -> ${EXTENSION_DIR}"
mkdir -p "${EXTENSION_DIR}"

for dir in agents skills commands hooks tests docs; do
  if [ -d "${SCRIPT_DIR}/${dir}" ]; then
    cp -r "${SCRIPT_DIR}/${dir}" "${EXTENSION_DIR}/"
    echo "      + ${dir}/"
  fi
done

for file in gemini-extension.json GEMINI.md BRIDGE_SPEC.md README.md docs/testing.md; do
  if [ -f "${SCRIPT_DIR}/${file}" ]; then
    cp "${SCRIPT_DIR}/${file}" "${EXTENSION_DIR}/${file}"
    echo "      + ${file}"
  fi
done

echo "[2/2] Verifying..."
SKILL_COUNT=$(find "${EXTENSION_DIR}/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
CMD_COUNT=$(find "${EXTENSION_DIR}/commands" -name "*.toml" 2>/dev/null | wc -l | tr -d ' ')
HOOK_COUNT=$(find "${EXTENSION_DIR}/hooks" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')
TEST_COUNT=$(find "${EXTENSION_DIR}/tests" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')

echo "      Skills:   ${SKILL_COUNT}/14"
echo "      Commands: ${CMD_COUNT}/12"
echo "      Agent:    $([ -f "${EXTENSION_DIR}/agents/code-reviewer.md" ] && echo 'OK' || echo 'MISSING')"
echo "      GEMINI.md: $([ -f "${EXTENSION_DIR}/GEMINI.md" ] && echo 'OK' || echo 'MISSING')"
echo "      Hooks:    ${HOOK_COUNT}"
echo "      Tests:    ${TEST_COUNT}"

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
