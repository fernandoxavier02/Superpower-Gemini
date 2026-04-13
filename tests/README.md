# Superpowers Parity Check

This directory contains a lightweight operational parity checklist so the Gemini port
can be audited against the canonical Claude Code plugin behavior expected in this repo.

## What is validated

- manifest and discovery consistency (manifest + context files);
- expected asset counts (skills, commands, and code reviewer agent);
- existence of hook compatibility assets (`hooks/*.json`, `hooks/session-start`, `hooks/run-hook.cmd`);
- existence of parity docs (`docs/*`);
- executable status hints for hook scripts (best effort on Unix-like platforms).

## Run checks

```bash
# Cross-platform script (Linux/macOS/WSL)
bash tests/validate-parity.sh

# Windows
powershell -ExecutionPolicy Bypass -File tests/validate-parity.ps1
```

The check is intentionally strict about what exists and lenient about runtime
integration since Gemini CLI currently does not trigger `SessionStart` automatically.
