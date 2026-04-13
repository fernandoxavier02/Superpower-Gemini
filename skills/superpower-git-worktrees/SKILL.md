---
name: superpower-git-worktrees
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans - creates isolated git worktrees with smart directory selection and safety verification. Adapted from Claude Code superpowers v5.0.7 for Gemini CLI.
---

# Using Git Worktrees

> **Gemini CLI Adaptation:** This skill was adapted from Claude Code superpowers v5.0.7 for Gemini CLI. All tool references use Gemini-native equivalents (`run_shell_command`, `read_file`, `write_file`, `edit_file`, `ask_user`).

## Overview

Git worktrees create isolated workspaces sharing the same repository, allowing work on multiple branches simultaneously without switching.

**Core principle:** Systematic directory selection + safety verification = reliable isolation.

**Announce at start:** "I'm using the superpower-git-worktrees skill to set up an isolated workspace."

## Directory Selection Process

Follow this priority order:

### 1. Check Existing Directories

Use `run_shell_command` to check in priority order:

```bash
ls -d .worktrees 2>/dev/null     # Preferred (hidden)
ls -d worktrees 2>/dev/null      # Alternative
```

**If found:** Use that directory. If both exist, `.worktrees` wins.

### 2. Check GEMINI.md / CLAUDE.md

Use `run_shell_command` to search for worktree configuration:

```bash
grep -i "worktree.*director" GEMINI.md 2>/dev/null || grep -i "worktree.*director" CLAUDE.md 2>/dev/null
```

**If preference specified:** Use it without asking.

### 3. Ask User

If no directory exists and no config preference, use `ask_user`:

```
No worktree directory found. Where should I create worktrees?

1. .worktrees/ (project-local, hidden)
2. ~/.config/superpowers/worktrees/<project-name>/ (global location)

Which would you prefer?
```

## Safety Verification

### HARD GATE: Project-Local Directories MUST Be Ignored

**For project-local directories (.worktrees or worktrees):**

**MUST verify directory is ignored before creating worktree.** Use `run_shell_command`:

```bash
# Check if directory is ignored (respects local, global, and system gitignore)
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**If NOT ignored — fix immediately:**

1. Use `edit_file` to add appropriate line to `.gitignore`
2. Commit the change via `run_shell_command`:
   ```bash
   git add .gitignore && git commit -m "chore: add worktrees dir to .gitignore"
   ```
3. Proceed with worktree creation

**Why critical:** Prevents accidentally committing worktree contents to repository.

### For Global Directory (~/.config/superpowers/worktrees)

No .gitignore verification needed — outside project entirely.

## Creation Steps

### 1. Detect Project Name

Use `run_shell_command`:

```bash
project=$(basename "$(git rev-parse --show-toplevel)")
```

### 2. Create Worktree

Use `run_shell_command`:

```bash
# Determine full path
case $LOCATION in
  .worktrees|worktrees)
    path="$LOCATION/$BRANCH_NAME"
    ;;
  ~/.config/superpowers/worktrees/*)
    path="~/.config/superpowers/worktrees/$project/$BRANCH_NAME"
    ;;
esac

# Create worktree with new branch
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

### 3. Run Project Setup

Auto-detect and run appropriate setup via `run_shell_command`:

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

### 4. Verify Clean Baseline

Run tests to ensure worktree starts clean via `run_shell_command`:

```bash
# Examples - use project-appropriate command
npm test
cargo test
pytest
go test ./...
```

**If tests fail:** Report failures, use `ask_user` to confirm whether to proceed or investigate.

**If tests pass:** Report ready.

### 5. Report Location

Output directly:

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## Progress Tracking

Use inline YAML tracking blocks to record worktree state:

```yaml
WORKTREE_STATUS:
  branch: "feature/auth"
  path: "/Users/dev/project/.worktrees/auth"
  location_type: "project-local"  # or "global"
  gitignore_verified: true
  setup_completed: true
  baseline_tests: "47 passing, 0 failures"
  status: "ready"
```

## Quick Reference

| Situation | Action |
|-----------|--------|
| `.worktrees/` exists | Use it (verify ignored) |
| `worktrees/` exists | Use it (verify ignored) |
| Both exist | Use `.worktrees/` |
| Neither exists | Check GEMINI.md/CLAUDE.md -> ask_user |
| Directory not ignored | Add to .gitignore + commit |
| Tests fail during baseline | Report failures + ask_user |
| No package.json/Cargo.toml | Skip dependency install |

## Common Mistakes (Anti-Patterns)

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Skipping ignore verification | Worktree contents get tracked, pollute git status | Always use `git check-ignore` before creating project-local worktree |
| Assuming directory location | Creates inconsistency, violates project conventions | Follow priority: existing > GEMINI.md/CLAUDE.md > ask_user |
| Proceeding with failing tests | Can't distinguish new bugs from pre-existing issues | Report failures, get explicit permission to proceed |
| Hardcoding setup commands | Breaks on projects using different tools | Auto-detect from project files (package.json, etc.) |
| Running `git worktree add` without checking existing worktrees | May create duplicates or conflict | Run `git worktree list` first to check current state |

## Example Workflow

```
You: I'm using the superpower-git-worktrees skill to set up an isolated workspace.

[run_shell_command: ls -d .worktrees 2>/dev/null → exists]
[run_shell_command: git check-ignore -q .worktrees → ignored, OK]
[run_shell_command: git worktree add .worktrees/auth -b feature/auth]
[run_shell_command: cd .worktrees/auth && npm install]
[run_shell_command: npm test → 47 passing]

Worktree ready at /Users/dev/myproject/.worktrees/auth
Tests passing (47 tests, 0 failures)
Ready to implement auth feature
```

## Checklist (Pre-Flight)

Before creating any worktree, verify ALL items:

- [ ] Directory selection priority followed (existing > config > ask)
- [ ] `.gitignore` verified for project-local directories
- [ ] `.gitignore` fixed and committed if missing entry
- [ ] Worktree created with correct branch name
- [ ] Project dependencies installed (auto-detected)
- [ ] Baseline tests executed
- [ ] Test failures reported to user (if any)
- [ ] Final location reported

## Red Flags

**Never:**
- Create worktree without verifying it's ignored (project-local)
- Skip baseline test verification
- Proceed with failing tests without asking
- Assume directory location when ambiguous
- Skip GEMINI.md/CLAUDE.md check

**Always:**
- Follow directory priority: existing > GEMINI.md/CLAUDE.md > ask_user
- Verify directory is ignored for project-local
- Auto-detect and run project setup
- Verify clean test baseline
- Use `run_shell_command` for all git operations

## Cleanup Commands

When done with a worktree, use `run_shell_command`:

```bash
# List all worktrees
git worktree list

# Remove a specific worktree
git worktree remove <path>

# Prune stale worktree references
git worktree prune
```

## Integration

**Called by:**
- **$superpower-brainstorming** (Phase 4) — REQUIRED when design is approved and implementation follows
- **$superpower-subagents** — REQUIRED before executing any tasks
- **$superpower-executing-plans** — REQUIRED before executing any tasks
- Any skill needing isolated workspace

**Pairs with:**
- **$superpower-finish** — REQUIRED for cleanup after work complete

## Tool Mapping Reference

| Claude Code Tool | Gemini CLI Equivalent |
|------------------|----------------------|
| Task tool / Agent tool | Inline execution or `activate_skill` |
| Skill tool | `activate_skill` |
| Bash | `run_shell_command` |
| AskUserQuestion | `ask_user` |
| Read / Write / Edit | `read_file` / `write_file` / `edit_file` |
| Grep / Glob | `run_shell_command` with `grep` / `find` |
| TodoWrite | Inline YAML tracking blocks |
