# Superpowers — Extension Context

> This file is automatically loaded by Gemini CLI at session start.

## What This Extension Does

Superpowers transforms Gemini CLI into a disciplined, methodologically sound development partner. It provides 14 specialized skills that enforce best practices like TDD, systematic debugging, comprehensive planning, and rigorous code review.

## Available Skills

Skills are activated automatically when the task matches their description, or manually via slash commands.

| Skill | Command | When to Use |
|-------|---------|-------------|
| `superpower-bootstrap` | `/superpower-bootstrap` | Start of any conversation — classifies and routes tasks |
| `superpower-brainstorming` | `/superpower-brainstorming` | Before any creative work — explores intent and design |
| `superpower-writing-plans` | `/superpower-plan` | Before coding — creates decision-complete implementation plans |
| `superpower-executing-plans` | `/execute-plan` | Execute approved plans in controlled batches |
| `superpower-tdd` | `/superpower-tdd` | Implementation — Red-Green-Refactor cycle |
| `superpower-subagents` | — | Multi-phase implementation with inline review |
| `superpower-debugging` | `/superpower-debug` | Systematic root cause analysis |
| `superpower-review` | `/superpower-review` | Code review with severity classification |
| `superpower-receiving-code-review` | — | Responding to review feedback with rigor |
| `superpower-verification` | `/superpower-verify` | Evidence-based completion verification |
| `superpower-finish` | `/superpower-finish` | Branch finalization — merge/PR/discard |
| `superpower-git-worktrees` | — | Isolated feature work via git worktrees |
| `superpower-dispatching-parallel` | — | Sequential multi-pass for independent tasks |
| `superpower-writing-skills` | — | Creating and testing new Gemini CLI skills |

## Workflow

The typical superpowers workflow follows this sequence:

```
Bootstrap → Brainstorm → Plan → TDD/Implement → Review → Verify → Finish
```

Each skill enforces discipline at its phase. Skills can be used independently or as part of the full workflow.

## Key Principles

1. **Evidence before assertions** — Always run commands and verify output before claiming success
2. **TDD discipline** — Write tests first (RED), then implement (GREEN), then refactor
3. **Plan before code** — Create comprehensive plans before touching implementation
4. **Systematic debugging** — Reproduce, isolate root cause, then fix
5. **Adversarial review** — Review your own work critically before declaring done
