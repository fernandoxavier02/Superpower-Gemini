---
name: superpower-executing-plans
description: Use when there is an approved written plan to execute in controlled batches with review checkpoints, blocker handling, and progress tracking. Adapted from Claude Code superpowers v5.0.7 for Gemini CLI.
---

# SuperPower Executing Plans

> Adapted from Claude Code superpowers v5.0.7 for Gemini CLI.

## Overview

Load plan, review critically, execute all tasks in controlled batches, report when complete.

**Announce at start:** "I'm using the `$superpower-executing-plans` skill to implement this plan."

**Note:** For best results, tell your human partner that superpowers work better with subagent support. If subagents are available, prefer `$superpower-subagents` instead of this skill.

---

## The Process

### Step 1: Load and Review Plan

1. Read plan file using `read_file`
2. Review critically — identify any questions or concerns about the plan
3. If concerns exist: raise them with your human partner using `ask_user` before starting
4. If no concerns: create an inline YAML tracking block and proceed

**Tracking block format** (maintain in your responses as tasks progress):

```yaml
PLAN_TRACKER:
  plan_file: "path/to/plan.md"
  total_tasks: N
  tasks:
    - id: "1"
      title: "Task description"
      status: "pending"  # pending | in_progress | completed | blocked
      notes: ""
    - id: "2"
      title: "Task description"
      status: "pending"
      notes: ""
```

### Step 2: Execute Tasks in Batches

Choose a safe batch size:
- **1 task** for high-risk, tightly coupled, or ambiguous work
- **Up to 3 tasks** for low-risk, independent work

For each task in the batch:

1. Update status to `in_progress` in the tracking block
2. Follow each step exactly (the plan has bite-sized steps)
3. Apply `$superpower-tdd` during implementation
4. Run verifications as specified in the plan using `run_shell_command`
5. Update status to `completed` (or `blocked` if stuck)

After each batch, emit the **Batch Report** (see Output Contract below).

### Step 3: Complete Development

After all tasks are complete and verified:

- Announce: "I'm using the `$superpower-finish` skill to complete this work."
- **REQUIRED:** Hand off to `$superpower-review`, then `$superpower-verification`, then `$superpower-finish`
- Follow that skill to verify tests, present options, execute choice

---

## Stop Conditions (HARD GATE)

**STOP executing immediately when:**

| Condition | Action |
|-----------|--------|
| Plan has critical gaps preventing start | Ask user via `ask_user` |
| Hit a blocker (missing dependency, file not found) | Report blocker, stop batch |
| Instruction is unclear or ambiguous | Ask for clarification via `ask_user` |
| Verification fails repeatedly (2x same check) | Stop and analyze root cause |
| User input needed for a real decision | Ask via `ask_user`, do not guess |

**Ask for clarification rather than guessing.**

---

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** — stop and ask.

---

## Guardrails and Anti-Patterns

### Guardrails

- Do not silently expand scope beyond what the plan specifies
- Do not continue past a failed verification
- Do not report success for a batch without fresh evidence
- Never start implementation on main/master branch without explicit user consent
- Do not skip verifications even if "obvious"

### Anti-Patterns Table

| Anti-Pattern | Why It's Bad | Do Instead |
|--------------|-------------|------------|
| Skipping plan review | Missed gaps surface mid-implementation | Always review critically in Step 1 |
| Executing all tasks at once | No checkpoint visibility, hard to debug | Use controlled batch sizes |
| Guessing when blocked | Compounds errors, wastes time | Stop and ask via `ask_user` |
| Marking task done without verification | Silent failures accumulate | Run every specified verification |
| Expanding scope silently | Plan drift, unexpected side effects | Raise scope changes with user first |
| Continuing after repeated test failure | Deeper issue being masked | Stop after 2 failures, analyze root cause |

---

## Output Contract

### Batch Report (after each batch)

```
## Batch Report — Tasks [X-Y]

- **Completed:** [list of tasks finished in this batch]
- **Evidence:** [commands run or checks observed, with results]
- **Open issues:** [blockers or concerns, if any]
- **Ready:** [yes/no — whether the next batch can begin]
```

### Final Report (after all tasks)

```
## Plan Execution Complete

- **Plan:** [path to plan file]
- **Tasks completed:** [N/N]
- **Verification summary:** [build status, test results]
- **Blockers resolved:** [list, or "none"]
- **Next step:** Handing off to $superpower-finish
```

---

## Checklist — Before Declaring Plan Complete

- [ ] All tasks in tracking block show status `completed`
- [ ] Every verification specified in the plan has been executed
- [ ] Build passes (`run_shell_command` with build command)
- [ ] Tests pass (`run_shell_command` with test command)
- [ ] No silent scope expansions occurred
- [ ] Batch reports emitted for every batch
- [ ] Final report emitted

---

## Tool Mapping (Gemini CLI)

| Operation | Tool |
|-----------|------|
| Read plan/files | `read_file` |
| Write/create files | `write_file` |
| Edit existing files | `edit_file` |
| Run builds, tests, git | `run_shell_command` |
| Search file contents | `run_shell_command` with `grep` or `rg` |
| Find files by pattern | `run_shell_command` with `find` |
| Ask user for input | `ask_user` |
| Track progress | Inline YAML tracking blocks (see Step 1) |
| Invoke sub-skills | `activate_skill` |

---

## Integration

**Required workflow skills:**

- **$superpower-writing-plans** — Creates the plan this skill executes
- **$superpower-tdd** — Applied during implementation of each task
- **$superpower-review** — Code review after all tasks complete
- **$superpower-verification** — Final verification pass
- **$superpower-finish** — Complete development branch after all tasks verified

---

## Remember

- Review plan critically first — do not start blindly
- Follow plan steps exactly — the plan is the contract
- Don't skip verifications — they catch silent failures
- Reference sub-skills when the plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent
- Emit batch reports after every batch — visibility is non-negotiable
