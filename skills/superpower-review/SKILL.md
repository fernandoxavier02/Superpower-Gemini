---
name: superpower-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements. Dispatches a structured code review, classifies findings by severity, and forces re-review when Critical or Important issues remain.
---

<!-- Adapted from Claude Code superpowers v5.0.7 for Gemini CLI -->

# SuperPower Review — Requesting Code Review

Dispatch a structured code review to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process, and preserves your own context for continued work.

**Core principle:** Review early, review often.

---

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing a major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing a complex bug

---

## How to Request

### Step 1 — Get git SHAs

```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

Use `run_shell_command` to obtain these values.

### Step 2 — Prepare review context

Gather the diff and file stats:

```bash
git diff --stat {BASE_SHA}..{HEAD_SHA}
git diff {BASE_SHA}..{HEAD_SHA}
```

Then read the plan or requirements file with `read_file` so the reviewer can compare intent versus implementation.

### Step 3 — Execute the Code Review Agent inline

Follow the **Code Review Agent Protocol** below, filling in the placeholders:

| Placeholder | Value |
|---|---|
| `{WHAT_WAS_IMPLEMENTED}` | What you just built |
| `{PLAN_OR_REQUIREMENTS}` | What it should do (spec, plan, or user story) |
| `{BASE_SHA}` | Starting commit |
| `{HEAD_SHA}` | Ending commit |
| `{DESCRIPTION}` | Brief summary of changes |

### Step 4 — Act on feedback

| Severity | Action |
|---|---|
| Critical | Fix immediately — **hard gate**, do not proceed |
| Important | Fix before proceeding to next task |
| Minor | Note for later, do not block progress |
| Reviewer wrong | Push back with technical reasoning, show code/tests that prove correctness |

### Step 5 — Re-review after fixes

After fixing Critical or Important issues, re-run the review cycle. Only proceed when the assessment is "Ready to merge" or "Ready to merge: with minor notes."

---

## Code Review Agent Protocol

> This section replaces the external `code-reviewer.md` subagent template. Execute it inline within the current session.

### Mission

You are reviewing code changes for production readiness.

**Your task:**
1. Review {WHAT_WAS_IMPLEMENTED}
2. Compare against {PLAN_OR_REQUIREMENTS}
3. Check code quality, architecture, testing
4. Categorize issues by severity
5. Assess production readiness

### What Was Implemented

{DESCRIPTION}

### Requirements / Plan

Use `read_file` to load the plan or requirements referenced by {PLAN_OR_REQUIREMENTS}.

### Git Range to Review

**Base:** {BASE_SHA}
**Head:** {HEAD_SHA}

```bash
# Run via run_shell_command
git diff --stat {BASE_SHA}..{HEAD_SHA}
git diff {BASE_SHA}..{HEAD_SHA}
```

Use `run_shell_command` with `grep` or `find` to locate specific files or patterns when the diff is large.

### Review Checklist

**Code Quality:**
- Clean separation of concerns?
- Proper error handling?
- Type safety (if applicable)?
- DRY principle followed?
- Edge cases handled?

**Architecture:**
- Sound design decisions?
- Scalability considerations?
- Performance implications?
- Security concerns?

**Testing:**
- Tests actually test logic (not mocks)?
- Edge cases covered?
- Integration tests where needed?
- All tests passing?

**Requirements:**
- All plan requirements met?
- Implementation matches spec?
- No scope creep?
- Breaking changes documented?

**Production Readiness:**
- Migration strategy (if schema changes)?
- Backward compatibility considered?
- Documentation complete?
- No obvious bugs?

### Output Format

Produce the review in the following structure:

```
### Strengths
[What's well done? Be specific with file:line references.]

### Issues

#### Critical (Must Fix)
[Bugs, security issues, data loss risks, broken functionality]

#### Important (Should Fix)
[Architecture problems, missing features, poor error handling, test gaps]

#### Minor (Nice to Have)
[Code style, optimization opportunities, documentation improvements]

**For each issue:**
- File:line reference
- What's wrong
- Why it matters
- How to fix (if not obvious)

### Recommendations
[Improvements for code quality, architecture, or process]

### Assessment
**Ready to merge?** [Yes / No / With fixes]
**Reasoning:** [Technical assessment in 1-2 sentences]

### Decisões tomadas
- [list]

### Riscos remanescentes
- [list]

### Pendências para o usuário
- [list]

### Próximo passo recomendado
- [list]
```

### Critical Rules for the Reviewer

**DO:**
- Categorize by actual severity (not everything is Critical)
- Be specific (file:line, not vague)
- Explain WHY issues matter
- Acknowledge strengths
- Give a clear verdict

**DON'T:**
- Say "looks good" without checking
- Mark nitpicks as Critical
- Give feedback on code you didn't review
- Be vague ("improve error handling")
- Avoid giving a clear verdict

---

## Example Flow

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

# Step 1 — Get SHAs via run_shell_command
BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

# Step 2 — Get diff
git diff --stat $BASE_SHA..$HEAD_SHA
git diff $BASE_SHA..$HEAD_SHA

# Step 3 — Read requirements
read_file("docs/superpowers/plans/deployment-plan.md")

# Step 4 — Execute Code Review Agent Protocol inline
  WHAT_WAS_IMPLEMENTED: Verification and repair functions for conversation index
  PLAN_OR_REQUIREMENTS: Task 2 from docs/superpowers/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types

# Review result:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

# Step 5 — Fix Important issues, re-review
[Fix progress indicators]
[Re-run review → clean]
[Continue to Task 3]
```

---

## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**Executing Plans (via `$superpower-executing-plans`):**
- Review after each batch (3 tasks)
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

---

## Hard Gates and Red Flags

### Never:
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

### If reviewer is wrong:
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

### Re-review gate:
After fixing Critical or Important issues, you MUST re-run the review. Do not self-certify fixes as sufficient.

---

## Anti-Patterns

| Anti-Pattern | Why It's Bad | Correct Approach |
|---|---|---|
| Skipping review for "trivial" changes | Trivial changes cause production outages | Always review |
| Marking everything as Minor | Hides real risk | Use severity honestly |
| Self-reviewing your own code | Confirmation bias | Use fresh review context |
| Reviewing without reading the diff | Theatre, not review | Run `git diff` first |
| Proceeding after "With fixes" verdict | Fixes may introduce new issues | Re-review after fixes |

---

## Tracking Block

When managing multiple review cycles, use an inline YAML tracking block:

```yaml
REVIEW_TRACKER:
  cycle: 1
  scope: "Task 2 — verification functions"
  base_sha: "a7981ec"
  head_sha: "3df7661"
  findings:
    critical: 0
    important: 1
    minor: 1
  status: "fixes_in_progress"
  next_action: "re-review after progress indicator fix"
```

Update this block after each review cycle to maintain traceability.

---

## Gemini CLI Tool Mapping

| Operation | Tool |
|---|---|
| Run git commands, grep, find | `run_shell_command` |
| Read files (plans, specs, source) | `read_file` |
| Write or create files | `write_file` |
| Edit existing files | `edit_file` |
| Ask the user a question | `ask_user` |
| Invoke another skill | `activate_skill` |

---

## Output Contract

Return:

- `Scope:` what was reviewed (files, SHAs, task reference)
- `Findings:` ordered by severity (Critical > Important > Minor)
- `Disposition:` fixed, deferred, or rejected with reason per finding
- `Review cycles:` number of review/fix iterations performed
- `Next skill:` `$superpower-verification` once the review is clean enough to support a completion claim

### High-Volume Decision Gate (reviewing large or conflicting findings)

If findings create a meaningful fork in risk, sequencing, or scope (for example, multiple high-severity categories, or one fix could block another), pause implementation and ask exactly one structured question before continuing.

Use this exact format:

```text
Pergunta de clareza:
- [1] Opção recomendada (menor risco)
- [2] Opção alternativa
- [3] Opção alternativa
- [4] Outra (descreva)

Se a interface suportar, emita isso como 4 opções clicáveis.
Se a UI clicável não estiver disponível, liste as mesmas 4 opções e peça a resposta pelo identificador 1-4.
```

No questions -> no execution.

## Decision Block (required in each review response)

Return the following sections, always in this order:

- Decisões tomadas
- Riscos remanescentes
- Pendências para o usuário
- Próximo passo recomendado

---

## Cross-References

- `$superpower-verification` — run after review passes to validate completion claims
- `$superpower-executing-plans` — integrates review after each task batch
- `$superpower-subagents` — subagent-driven development triggers mandatory review
- `$superpower-finish` — closeout requires passing review
