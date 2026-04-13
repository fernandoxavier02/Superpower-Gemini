---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

> **Adapted from Claude Code superpowers v5.0.7 for Gemini CLI**
>
> Tool mapping: `run_shell_command` (shell), `read_file`/`write_file`/`edit_file` (files),
> `ask_user` (user input), `activate_skill` (skill invocation).
> Tracking via inline YAML blocks (no external task tool).

# Verification Before Completion

## Overview

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command via run_shell_command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

### Execution Notes (Gemini CLI)

- Use `run_shell_command` for ALL verification commands (build, test, lint).
- If a verification requires reading file contents, use `read_file` — never assume file state from memory.
- If delegating to another skill via `activate_skill`, you MUST still independently verify the result with `run_shell_command` before claiming success.
- Track verification status inline using YAML blocks:

```yaml
VERIFICATION_STATUS:
  claim: "All tests pass"
  command: "npm test"
  executed: true
  exit_code: 0
  evidence: "34/34 tests passed, 0 failures"
  verified: true
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Skill completed | VCS diff shows changes | Skill reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting skill or sub-task success reports without independent verification
- Relying on partial verification
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification via `run_shell_command` |
| "I'm confident" | Confidence is not evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter is not compiler |
| "Skill said success" | Verify independently with `run_shell_command` |
| "I'm tired" | Exhaustion is not excuse |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
CORRECT:  run_shell_command("npm test") → See: 34/34 pass → "All tests pass"
WRONG:    "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
CORRECT:  Write test → run_shell_command (pass) → Revert fix → run_shell_command (MUST FAIL) → Restore → run_shell_command (pass)
WRONG:    "I've written a regression test" (without red-green verification)
```

**Build:**
```
CORRECT:  run_shell_command("npm run build") → See: exit 0 → "Build passes"
WRONG:    "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
CORRECT:  Re-read plan via read_file → Create checklist → Verify each → Report gaps or completion
WRONG:    "Tests pass, phase complete"
```

**Skill delegation:**
```
CORRECT:  activate_skill reports success → run_shell_command to check VCS diff → Verify changes → Report actual state
WRONG:    Trust skill report
```

## Verification Checklist (Hard Gate)

Before ANY completion claim, confirm ALL apply:

- [ ] Verification command identified
- [ ] Command executed via `run_shell_command` in THIS message (not a previous one)
- [ ] Full output reviewed (not truncated, not skimmed)
- [ ] Exit code checked (0 = success, non-zero = failure)
- [ ] Failure count confirmed as zero
- [ ] Evidence quoted in the completion claim
- [ ] No weasel words ("should", "probably", "seems")

**If ANY checkbox fails: DO NOT claim completion.**

## Anti-Patterns Table

| Anti-Pattern | Why It Fails | Correct Approach |
|--------------|-------------|------------------|
| Claim before run | Zero evidence | Run first, claim after |
| Stale evidence | Previous run may not reflect current state | Fresh run every time |
| Partial verification | Linter pass does not mean build pass | Run the exact command for the exact claim |
| Trusting delegation | Skills/sub-tasks can silently fail | Independent `run_shell_command` verification |
| Weasel language | Hides uncertainty | Binary: verified or not verified |
| Skipping on "simple" changes | Simple changes break things too | No exceptions |

## Output Contract

Every verification MUST produce this structured output:

```
Claim: [exact statement being verified]
Verification run: [command executed via run_shell_command]
Exit code: [0 or non-zero]
Evidence: [key output lines proving or disproving the claim]
Actual status: [VERIFIED | FAILED | PARTIAL — with explanation]
Next skill: $superpower-finish when the work is truly complete
```

## Cross-References

- Complete work and finalize: $superpower-finish
- Test-driven development: $superpower-tdd
- Code review workflow: $superpower-review

## Why This Matters

From documented failure patterns:
- "I don't believe you" — trust broken with human partner
- Undefined functions shipped — would crash in production
- Missing requirements shipped — incomplete features
- Time wasted on false completion leading to redirect and rework
- Violates: "Honesty is a core value. If you lie, you'll be replaced."

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to skills via `activate_skill`

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

## The Bottom Line

**No shortcuts for verification.**

Run the command via `run_shell_command`. Read the output. THEN claim the result.

This is non-negotiable.
