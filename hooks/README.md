# Superpowers Hook Compatibility Layer

This plugin is ported to Gemini CLI and therefore does not have native hook support
equivalent to Claude Code's `SessionStart` hook event.

The local `hooks/` directory is included to keep operational parity artifacts in one
place for environments that still support hook execution. It provides:

- `hooks.json` — hook declaration format inspired by hook-capable runtimes.
- `session-start` — optional bootstrap script that injects Superpowers context.
- `run-hook.cmd` — Windows launcher that calls the script through `bash`.

## Why this exists in Gemini

In this port, hook behavior is not automatically wired by Gemini today, so these files
are **not loaded automatically**. They are still kept here to:

1. preserve the architectural contract of the canonical plugin,
2. provide a clear migration path if Gemini adds hook support later,
3. support manual workflow automation outside the CLI.

## Manual usage

```bash
# If you want to run the session context bootstrap before a new task:
cd /path/to/superpower-gemini
bash hooks/session-start
```

```bash
# Windows equivalent (finds Git Bash if available):
hooks\\run-hook.cmd session-start
```

If you are using a shell without Bash, use the output from `session-start` as manual
context for your first prompt.

## Expected behavior in this port

- Always includes the Superpowers bootstrap guidance (`superpower-bootstrap`).
- Replaces unavailable Claude Code primitives with Gemini equivalents where possible.
- Adds compatibility notes instead of enforcing unavailable features.

For the canonical hook model and exact Claude Code behavior, see the upstream project.
