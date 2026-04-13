---
name: superpower-finish
description: >
  Use when implementation is complete, all tests pass, and you need to decide
  how to integrate the work. Guides completion of development work by presenting
  structured options for merge, PR, or cleanup.
---

<!-- Adapted from Claude Code superpowers v5.0.7 for Gemini CLI -->

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling the chosen workflow.

**Core principle:** Verify tests → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the `$superpower-finish` skill to complete this work."

---

## The Process

### Step 1: Verify Tests

**Before presenting options, verify tests pass.**

Use `run_shell_command` to run the project's test suite:

```bash
# Run project's test suite (detect the right command)
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**

```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

**HARD GATE:** Stop. Do NOT proceed to Step 2. Fix tests first.

**If tests pass:** Continue to Step 2.

---

### Step 2: Determine Base Branch

Use `run_shell_command`:

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Or use `ask_user`: "This branch split from main - is that correct?"

---

### Step 3: Present Options

Present exactly these 4 options using `ask_user`:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Don't add explanation** — keep options concise.

---

### Step 4: Execute Choice

#### Option 1: Merge Locally

Execute via `run_shell_command`:

```bash
# Switch to base branch
git checkout <base-branch>

# Pull latest
git pull

# Merge feature branch
git merge <feature-branch>

# Verify tests on merged result
<test command>

# If tests pass, delete feature branch
git branch -d <feature-branch>
```

Then: Cleanup worktree (Step 5).

#### Option 2: Push and Create PR

Execute via `run_shell_command`:

```bash
# Push branch
git push -u origin <feature-branch>

# Create PR
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Test Plan
- [ ] <verification steps>
EOF
)"
```

Then: Cleanup worktree (Step 5).

#### Option 3: Keep As-Is

Report: "Keeping branch `<name>`. Worktree preserved at `<path>`."

**Don't cleanup worktree.**

#### Option 4: Discard

**Confirm first** using `ask_user`:

```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

**HARD GATE:** Wait for exact confirmation. Do NOT proceed without it.

If confirmed, execute via `run_shell_command`:

```bash
git checkout <base-branch>
git branch -D <feature-branch>
```

Then: Cleanup worktree (Step 5).

---

### Step 5: Cleanup Worktree

**For Options 1, 2, 4:**

Check if in worktree via `run_shell_command`:

```bash
git worktree list | grep $(git branch --show-current)
```

If yes:

```bash
git worktree remove <worktree-path>
```

**For Option 3:** Keep worktree.

---

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Branch |
|--------|-------|------|---------------|----------------|
| 1. Merge locally | Yes | - | - | Yes |
| 2. Create PR | - | Yes | Yes | - |
| 3. Keep as-is | - | - | Yes | - |
| 4. Discard | - | - | - | Yes (force) |

---

## Output Contract

At each phase, emit the corresponding block:

```
Verified state: <test results evidence>
Available closeout paths: <only what the current runtime supports>
Selected action: <only after the user chooses>
Remaining manual steps: <if any>
```

---

## Hard Gates

| Gate | Condition | Action if violated |
|------|-----------|-------------------|
| Tests must pass | Step 1 fails | STOP — do not present options |
| User must choose | Step 3 not answered | STOP — do not assume a choice |
| Discard confirmation | Option 4 without typed "discard" | STOP — do not delete anything |
| No force-push | User did not explicitly request | NEVER force-push |

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Skipping test verification | Merge broken code, create failing PR | Always verify tests before offering options |
| Open-ended questions | "What should I do next?" is ambiguous | Present exactly 4 structured options |
| Automatic worktree cleanup | Remove worktree when might need it (Option 2, 3) | Only cleanup for Options 1 and 4 |
| No confirmation for discard | Accidentally delete work | Require typed "discard" confirmation |

---

## Anti-Patterns

**Never:**
- Proceed with failing tests
- Merge without verifying tests on merged result
- Delete work without confirmation
- Force-push without explicit request
- Assume worktrees, hooks, or hosting integrations exist
- Present finish options before verification is fresh

**Always:**
- Verify tests before offering options
- Present exactly 4 options
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 and 4 only
- If git or hosting tooling is unavailable, provide a closeout summary plus exact manual steps

---

## Gemini CLI Tool Mapping

| CC Tool | Gemini Equivalent | Usage |
|---------|-------------------|-------|
| Bash | `run_shell_command` | All git, test, and shell commands |
| AskUserQuestion | `ask_user` | Presenting options, confirmations |
| Read / Write / Edit | `read_file` / `write_file` / `edit_file` | File operations (if needed) |
| Grep / Glob | `run_shell_command` with `grep` / `find` | Search operations |
| Task tool / Agent tool | Inline execution | No subagent delegation needed |
| Skill tool | `activate_skill` | Cross-skill references |
| TodoWrite | Inline YAML tracking blocks | Progress tracking |

---

## Integration

**Called by:**
- `$superpower-subagents` (Step 7) — After all tasks complete
- `$superpower-executing-plans` (Step 5) — After all batches complete

**Pairs with:**
- `$superpower-verification` — Tests must be freshly verified before this skill runs
- `$superpower-git-worktrees` — Cleans up worktree created by that skill
