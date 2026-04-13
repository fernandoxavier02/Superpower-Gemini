#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]}"
if [[ "$SCRIPT_PATH" == */* ]]; then
  SCRIPT_DIR="${SCRIPT_PATH%/*}"
else
  SCRIPT_DIR="."
fi
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

EXPECTED_CANONICAL_SKILLS=14
EXPECTED_COMPAT_SKILLS=14
EXPECTED_COMMANDS=12

echo "Superpowers parity validation (operational layer)"
echo "Root: ${ROOT_DIR}"
echo

canonic_skills=(
  brainstorming
  dispatching-parallel-agents
  executing-plans
  finishing-a-development-branch
  receiving-code-review
  requesting-code-review
  subagent-driven-development
  systematic-debugging
  test-driven-development
  using-git-worktrees
  using-superpowers
  verification-before-completion
  writing-plans
  writing-skills
)

compat_skills=(
  superpower-bootstrap
  superpower-brainstorming
  superpower-debugging
  superpower-dispatching-parallel
  superpower-executing-plans
  superpower-finish
  superpower-git-worktrees
  superpower-receiving-code-review
  superpower-review
  superpower-subagents
  superpower-tdd
  superpower-verification
  superpower-writing-plans
  superpower-writing-skills
)

expected_commands=(
  brainstorm.toml
  write-plan.toml
  execute-plan.toml
  plan.toml
  superpower-bootstrap.toml
  superpower-brainstorming.toml
  superpower-debug.toml
  superpower-finish.toml
  superpower-plan.toml
  superpower-review.toml
  superpower-tdd.toml
  superpower-verify.toml
)

command_count=0
for candidate in "${ROOT_DIR}/commands"/*.toml; do
  if [ -f "$candidate" ]; then
    command_count=$((command_count + 1))
  fi
done
canonic_skill_count=0
compat_skill_count=0
errors=0
for skill in "${canonic_skills[@]}"; do
  if [ -f "${ROOT_DIR}/skills/${skill}/SKILL.md" ]; then
    canonic_skill_count=$((canonic_skill_count+1))
  else
    echo "[ERROR] Missing canonical skill directory: ${skill}"
    errors=$((errors+1))
  fi
done
for skill in "${compat_skills[@]}"; do
  if [ -f "${ROOT_DIR}/skills/${skill}/SKILL.md" ]; then
    compat_skill_count=$((compat_skill_count+1))
  else
    echo "[ERROR] Missing compatibility skill directory: ${skill}"
    errors=$((errors+1))
  fi
done
for command in "${expected_commands[@]}"; do
  if [ ! -f "${ROOT_DIR}/commands/${command}" ]; then
    echo "[ERROR] Missing command file: ${command}"
    errors=$((errors+1))
  fi
done

echo "[I] Core artifact checks"
for path in \
  "${ROOT_DIR}/gemini-extension.json" \
  "${ROOT_DIR}/GEMINI.md" \
  "${ROOT_DIR}/BRIDGE_SPEC.md" \
  "${ROOT_DIR}/README.md" \
  "${ROOT_DIR}/install.sh" \
  "${ROOT_DIR}/uninstall.sh" \
  "${ROOT_DIR}/agents/code-reviewer.md" \
  "${ROOT_DIR}/hooks/hooks.json" \
  "${ROOT_DIR}/hooks/hooks-cursor.json" \
  "${ROOT_DIR}/hooks/session-start" \
  "${ROOT_DIR}/hooks/run-hook.cmd" \
  "${ROOT_DIR}/tests/README.md" \
  "${ROOT_DIR}/tests/validate-parity.sh" \
  "${ROOT_DIR}/tests/validate-parity.ps1" \
  "${ROOT_DIR}/docs/testing.md" \
  "${ROOT_DIR}/docs/README.codex.md" \
  "${ROOT_DIR}/docs/README.opencode.md" \
  "${ROOT_DIR}/tests/brainstorm-server" \
  "${ROOT_DIR}/tests/claude-code" \
  "${ROOT_DIR}/tests/explicit-skill-requests" \
  "${ROOT_DIR}/tests/opencode" \
  "${ROOT_DIR}/tests/skill-triggering" \
  "${ROOT_DIR}/tests/subagent-driven-dev"
do
  if [ -e "${path}" ]; then
    echo "  OK  ${path}"
  else
    echo "  FAIL ${path}"
    errors=$((errors+1))
  fi
done

echo
echo "[I] Expected counts"
echo "  Canonical skills:   ${canonic_skill_count}/${EXPECTED_CANONICAL_SKILLS}"
echo "  Compatibility skills: ${compat_skill_count}/${EXPECTED_COMPAT_SKILLS}"
echo "  Commands: ${command_count}/${EXPECTED_COMMANDS}"

if [ "${canonic_skill_count}" -ne "${EXPECTED_CANONICAL_SKILLS}" ]; then
  echo "[ERROR] Canonical skill count mismatch"
  errors=$((errors+1))
fi

if [ "${command_count}" -ne "${EXPECTED_COMMANDS}" ]; then
  echo "[ERROR] Command count mismatch"
  errors=$((errors+1))
fi

if [ "${compat_skill_count}" -ne "${EXPECTED_COMPAT_SKILLS}" ]; then
  echo "[ERROR] Compatibility skill count mismatch"
  errors=$((errors+1))
fi

if [ ! -x "${ROOT_DIR}/hooks/session-start" ]; then
  echo "[WARN] hooks/session-start is not executable. Set chmod +x if running on Unix."
fi

if [ "${errors}" -ne 0 ]; then
  echo
  echo "[ERROR] Parity check FAILED: ${errors} issue(s)"
  exit 1
fi

echo
echo "[OK] Parity check PASSED"
