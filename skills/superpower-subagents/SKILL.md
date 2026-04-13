---
name: superpower-subagents
description: >
  Inline sequential execution of implementation plans with two-stage review
  (spec compliance + code quality) per task. Adapted from Claude Code superpowers
  v5.0.7 for Gemini CLI — restructured from subagent dispatch to single-session
  inline execution phases.
---

> **Adapted from Claude Code superpowers v5.0.7 for Gemini CLI.**
> The original skill uses subagent dispatch (Task tool). This version restructures
> the workflow into inline sequential execution phases within a single session,
> preserving all quality guarantees.

# Subagent-Driven Development (Inline Execution Model)

Execute a plan by cycling through three distinct cognitive phases per task:
**Implementer Phase** -> **Spec Review Phase** -> **Quality Review Phase**.

Each phase operates with a clear role, instructions, and output contract.
You mentally "reset" between phases to simulate the fresh-context benefit of subagents.

**Core principle:** One task at a time + two-stage review (spec then quality) = high quality, fast iteration

## When to Use

```
Have implementation plan?
  NO  -> Manual execution or brainstorm first
  YES -> Tasks mostly independent?
    NO  -> Manual execution (tightly coupled)
    YES -> Use this skill (superpower-subagents)
```

**vs. $superpower-executing-plans:**
- Same session (no context switch or handoff)
- Fresh mental context per task (explicit phase boundaries)
- Two-stage review after each task: spec compliance first, then code quality
- Faster iteration (no human-in-loop between tasks)

## The Process (Overview)

```
1. READ plan, extract ALL tasks with full text
2. CREATE inline tracking block (YAML)
3. FOR EACH TASK:
   a. IMPLEMENTER PHASE  -> implement, test, commit, self-review
   b. SPEC REVIEW PHASE  -> verify spec compliance (nothing more, nothing less)
   c. QUALITY REVIEW PHASE -> verify code quality
   d. IF issues found -> loop back to fix + re-review
   e. MARK task complete in tracking block
4. FINAL REVIEW PHASE -> review entire implementation holistically
5. HAND OFF to $superpower-finish
```

---

## Phase 0: Setup

1. **Read** the plan file once using `read_file`.
2. **Extract** every task with its full text, acceptance criteria, and context.
3. **Create** an inline YAML tracking block:

```yaml
# TASK TRACKING
tasks:
  - id: 1
    name: "Task name from plan"
    status: pending  # pending | in_progress | spec_review | quality_review | done | blocked
    implementer_status: null  # DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED
    spec_review: null  # pass | fail
    quality_review: null  # pass | fail
    concerns: []
    files_changed: []
  - id: 2
    name: "Next task"
    status: pending
    # ...
```

4. **Never** make the implementer phase re-read the plan file. Provide full task text inline.

---

## Phase 1: Implementer Phase

> **Mental model:** You are a focused implementer. You care ONLY about this one task.
> Forget the coordination role temporarily. Focus on building exactly what the spec says.

### Instructions to Follow

You are implementing **Task N: [task name]**.

#### Task Description

[FULL TEXT of task from plan - paste it inline, never re-read the file]

#### Context

[Scene-setting: where this fits, dependencies, architectural context]

#### Before You Begin

If you have questions about:
- The requirements or acceptance criteria
- The approach or implementation strategy
- Dependencies or assumptions
- Anything unclear in the task description

**Ask them now using `ask_user`.** Raise any concerns before starting work.

#### Your Job

Once you are clear on requirements:
1. Implement exactly what the task specifies
2. Write tests (following TDD if task says to -- see `$superpower-tdd`)
3. Verify implementation works (run tests via `run_shell_command`)
4. Commit your work (via `run_shell_command` with git)
5. Self-review (see below)
6. Report back (output the Implementer Report)

#### Code Organization

- Follow the file structure defined in the plan
- Each file should have one clear responsibility with a well-defined interface
- If a file you are creating grows beyond the plan's intent, STOP and report as DONE_WITH_CONCERNS -- do not split files on your own without plan guidance
- If an existing file you are modifying is already large or tangled, work carefully and note it as a concern
- In existing codebases, follow established patterns. Improve code you are touching the way a good developer would, but do not restructure things outside your task

#### When You Are Stuck

It is always OK to stop and escalate. Bad work is worse than no work.

**STOP and escalate when:**
- The task requires architectural decisions with multiple valid approaches
- You need to understand code beyond what was provided and cannot find clarity
- You feel uncertain about whether your approach is correct
- The task involves restructuring existing code in ways the plan did not anticipate
- You have been reading file after file trying to understand the system without progress

**How to escalate:** Report back with status BLOCKED or NEEDS_CONTEXT. Describe specifically what you are stuck on, what you have tried, and what kind of help you need.

#### Before Reporting Back: Self-Review

Review your work with fresh eyes. Ask yourself:

**Completeness:**
- Did I fully implement everything in the spec?
- Did I miss any requirements?
- Are there edge cases I did not handle?

**Quality:**
- Is this my best work?
- Are names clear and accurate (match what things do, not how they work)?
- Is the code clean and maintainable?

**Discipline:**
- Did I avoid overbuilding (YAGNI)?
- Did I only build what was requested?
- Did I follow existing patterns in the codebase?

**Testing:**
- Do tests actually verify behavior (not just mock behavior)?
- Did I follow TDD if required?
- Are tests comprehensive?

If you find issues during self-review, fix them now before reporting.

#### Implementer Report Format

```
## Implementer Report: Task N

**Status:** DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT

**What was implemented:**
- [bullet points]

**Tests:**
- [what was tested, results]

**Files changed:**
- [list]

**Self-review findings:**
- [any issues found and fixed, or "None"]

**Concerns (if DONE_WITH_CONCERNS):**
- [specific doubts]

**Blocker (if BLOCKED/NEEDS_CONTEXT):**
- [what is needed]
```

### Handling Implementer Status

After producing the Implementer Report, switch back to coordinator mindset:

- **DONE:** Proceed to Phase 2 (Spec Review).
- **DONE_WITH_CONCERNS:** Read the concerns. If about correctness or scope, address before review. If observational (e.g., "file is getting large"), note and proceed to review.
- **NEEDS_CONTEXT:** Use `ask_user` to get the missing information, then re-execute Phase 1 with the additional context.
- **BLOCKED:** Assess the blocker:
  1. If it is a context problem, gather more context and re-execute Phase 1
  2. If the task is too large, break it into smaller pieces
  3. If the plan itself is wrong, use `ask_user` to escalate to the human

**HARD GATE:** Never ignore a BLOCKED or NEEDS_CONTEXT status. Something must change before proceeding.

---

## Phase 2: Spec Compliance Review Phase

> **Mental model:** You are now a skeptical spec reviewer. Forget that you just wrote the code.
> Assume the implementer finished suspiciously quickly. Verify everything independently.

### Instructions to Follow

You are reviewing whether the implementation matches its specification.

#### What Was Requested

[FULL TEXT of task requirements -- same text provided to the implementer]

#### What Implementer Claims They Built

[From the Implementer Report produced in Phase 1]

#### CRITICAL: Do Not Trust the Report

The implementer finished suspiciously quickly. The report may be incomplete, inaccurate, or optimistic. You MUST verify everything independently.

**DO NOT:**
- Take the report's word for what was implemented
- Trust claims about completeness
- Accept the implementer's interpretation of requirements

**DO:**
- Read the actual code using `read_file`
- Compare actual implementation to requirements line by line
- Check for missing pieces claimed to be implemented
- Look for extra features not mentioned

#### Verification Checklist

**Missing requirements:**
- Did the implementer implement everything that was requested?
- Are there requirements that were skipped or missed?
- Did they claim something works but did not actually implement it?

**Extra/unneeded work:**
- Did they build things that were not requested?
- Did they over-engineer or add unnecessary features?
- Did they add "nice to haves" that were not in spec?

**Misunderstandings:**
- Did they interpret requirements differently than intended?
- Did they solve the wrong problem?
- Did they implement the right feature but the wrong way?

**Verify by reading code, not by trusting the report.**

#### Spec Review Report Format

```
## Spec Review: Task N

**Verdict:** PASS | FAIL

**Requirements checked:**
- [requirement] -> [verified/missing/extra]

**Issues (if FAIL):**
- MISSING: [what is missing, with file:line references]
- EXTRA: [what was added but not requested]
- MISUNDERSTOOD: [what was interpreted incorrectly]
```

### If Spec Review Fails

1. Switch back to Implementer mindset
2. Fix ONLY the issues identified by the spec reviewer
3. Commit the fixes
4. Switch back to Spec Reviewer mindset and re-review
5. Repeat until PASS

**HARD GATE:** Do NOT proceed to Phase 3 until spec review is PASS.

---

## Phase 3: Code Quality Review Phase

> **Mental model:** You are now a senior code reviewer. The spec is confirmed correct.
> Focus purely on code quality, maintainability, and engineering best practices.

**Only execute this phase after Phase 2 (Spec Review) returns PASS.**

### Instructions to Follow

Review the implementation for code quality. Check:

**Structure and Responsibility:**
- Does each file have one clear responsibility with a well-defined interface?
- Are units decomposed so they can be understood and tested independently?
- Is the implementation following the file structure from the plan?
- Did this implementation create new files that are already large, or significantly grow existing files? (Do not flag pre-existing file sizes -- focus on what this change contributed.)

**Standard Code Quality:**
- Naming: clear, accurate, consistent with codebase conventions
- Error handling: edge cases covered, errors propagated correctly
- Testing: tests verify behavior (not just mock behavior), adequate coverage
- Performance: no obvious inefficiencies introduced
- Security: no secrets, injections, or unsafe patterns
- Duplication: no copy-paste code that should be extracted
- Magic values: constants named and documented

**Gather context for review:**
- Use `run_shell_command` with `git diff` to see the changes for this task
- Use `read_file` to inspect the changed files in full context

#### Quality Review Report Format

```
## Quality Review: Task N

**Assessment:** APPROVED | NEEDS_CHANGES

**Strengths:**
- [what was done well]

**Issues:**
- [CRITICAL] [description] (file:line) -- must fix
- [IMPORTANT] [description] (file:line) -- should fix
- [MINOR] [description] (file:line) -- nice to fix

**Verdict:** [APPROVED / NEEDS_CHANGES with required fixes listed]
```

### If Quality Review Fails

1. Switch back to Implementer mindset
2. Fix the issues (CRITICAL and IMPORTANT are required; MINOR is optional)
3. Commit the fixes
4. Switch back to Quality Reviewer mindset and re-review
5. Repeat until APPROVED

**HARD GATE:** Do NOT mark the task complete until quality review is APPROVED.

---

## Phase 4: Task Completion

After both reviews pass:

1. Update the inline YAML tracking block:
```yaml
  - id: N
    status: done
    implementer_status: DONE
    spec_review: pass
    quality_review: pass
    files_changed: [list of files]
```

2. Move to the next pending task and repeat Phases 1-3.

---

## Phase 5: Final Review

After ALL tasks are complete:

1. Review the entire implementation holistically using `run_shell_command` with `git diff` against the base branch
2. Check for:
   - Cross-task integration issues
   - Inconsistencies between tasks
   - Missing connections or broken imports
   - Overall architecture coherence
3. Fix any integration issues found
4. Hand off to `$superpower-finish`

---

## Anti-Patterns Table

| Anti-Pattern | Why It Is Bad | What To Do Instead |
|---|---|---|
| Skip spec review | Over/under-building goes undetected | ALWAYS run Phase 2 |
| Skip quality review | Technical debt accumulates | ALWAYS run Phase 3 |
| Quality review before spec review | Polishing wrong implementation | Phase 2 MUST pass before Phase 3 |
| Trust implementer report blindly | Reports can be optimistic/incomplete | Read actual code in Phase 2 |
| Proceed with unfixed issues | Issues compound across tasks | Fix + re-review until approved |
| Fix issues without re-review | Fixes can introduce new problems | Always re-review after fixes |
| Multiple tasks simultaneously | Context pollution, merge conflicts | One task at a time, sequentially |
| Re-read plan file per task | Wastes tokens, context pollution | Extract all tasks once in Phase 0 |
| Start on main/master without consent | Dangerous for shared branches | Use `ask_user` to confirm branch strategy |
| Skip self-review in Phase 1 | Issues caught later cost more | Self-review before reporting |
| Ignore BLOCKED/NEEDS_CONTEXT | Produces bad work | Always address before proceeding |
| Guess when unclear | Assumptions cause rework | Use `ask_user` to clarify |
| Let self-review replace Phase 2/3 | Different perspectives catch different issues | Both self-review AND external reviews required |

---

## Hard Gates Summary

| Gate | Condition | Action if Failed |
|---|---|---|
| G1: Implementer Status | BLOCKED or NEEDS_CONTEXT | Do NOT proceed. Address blocker first. |
| G2: Spec Review | FAIL | Do NOT start quality review. Fix + re-review. |
| G3: Quality Review | NEEDS_CHANGES (CRITICAL/IMPORTANT) | Do NOT mark complete. Fix + re-review. |
| G4: Phase Order | Quality before Spec | INVALID. Always Spec first, then Quality. |
| G5: Task Sequencing | Next task while current has open issues | INVALID. Complete current task first. |

---

## Example Workflow

```
You: I am using $superpower-subagents to execute this plan.

[Read plan file once with read_file: docs/plans/feature-plan.md]
[Extract all 5 tasks with full text and context]
[Create inline YAML tracking block]

--- Task 1: Hook installation script ---

[IMPLEMENTER PHASE]
Phase 1 question: "Should the hook be installed at user or system level?"
[ask_user -> "User level (~/.config/superpowers/hooks/)"]
Phase 1 continues:
  - Implemented install-hook command
  - Added tests, 5/5 passing
  - Self-review: Found I missed --force flag, added it
  - Committed
  - Status: DONE

[SPEC REVIEW PHASE]
Phase 2: Read actual code with read_file, compare to requirements
  -> PASS: All requirements met, nothing extra

[QUALITY REVIEW PHASE]
Phase 3: Review code quality via git diff + read_file
  -> APPROVED: Good test coverage, clean code

[Mark Task 1: done]

--- Task 2: Recovery modes ---

[IMPLEMENTER PHASE]
Phase 1 (no questions):
  - Added verify/repair modes
  - 8/8 tests passing
  - Self-review: All good
  - Committed
  - Status: DONE

[SPEC REVIEW PHASE]
Phase 2: FAIL
  - MISSING: Progress reporting (spec says "report every 100 items")
  - EXTRA: Added --json flag (not requested)

[Back to IMPLEMENTER to fix]
  - Removed --json flag, added progress reporting
  - Committed fix

[SPEC REVIEW PHASE again]
Phase 2: PASS

[QUALITY REVIEW PHASE]
Phase 3: NEEDS_CHANGES
  - [IMPORTANT] Magic number 100 should be a named constant

[Back to IMPLEMENTER to fix]
  - Extracted PROGRESS_INTERVAL constant
  - Committed fix

[QUALITY REVIEW PHASE again]
Phase 3: APPROVED

[Mark Task 2: done]

... (Tasks 3-5) ...

--- Final Review ---
[Review entire implementation holistically]
[All cross-task integration checks pass]

Hand off to $superpower-finish
```

---

## Tool Mapping Reference

| Original (Claude Code) | Gemini CLI Equivalent |
|---|---|
| Task tool / Agent tool | Inline sequential execution phases (this skill) |
| Skill tool | activate_skill |
| Bash | run_shell_command |
| AskUserQuestion | ask_user |
| Read | read_file |
| Write | write_file |
| Edit | edit_file |
| Grep | run_shell_command with grep |
| Glob | run_shell_command with find |
| TodoWrite | Inline YAML tracking blocks |

---

## Integration

**Required workflow skills:**
- **$superpower-writing-plans** - Creates the plan this skill executes
- **$superpower-review** - Code review patterns for review phases
- **$superpower-finish** - Complete development after all tasks
- **$superpower-tdd** - Follow TDD for each implementation phase
- **$superpower-verification** - Final verification before merge

**Alternative workflow:**
- **$superpower-executing-plans** - Use for parallel/multi-session execution instead of single-session inline execution

---

## Output Contract

When this skill completes, produce:

```yaml
# SUBAGENT EXECUTION SUMMARY
skill: $superpower-subagents
plan_source: "[path to plan file]"
tasks_total: N
tasks_completed: N
tasks_blocked: 0

task_results:
  - id: 1
    name: "Task name"
    status: done
    spec_review_passes: 1  # number of review rounds
    quality_review_passes: 1
    files_changed: [list]
  - id: 2
    name: "Task name"
    status: done
    spec_review_passes: 2  # needed a fix round
    quality_review_passes: 2
    files_changed: [list]

final_review: pass
next_skill: $superpower-finish
```
