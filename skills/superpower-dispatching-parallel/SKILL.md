---
name: superpower-dispatching-parallel
description: Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies. Restructured for sequential multi-pass execution with explicit checkpoints.
---

> **Adapted from Claude Code superpowers v5.0.7 for Gemini CLI**
>
> **Key difference:** Gemini CLI executes in a single sequential session — it does NOT support parallel subagents. This skill restructures the original parallel dispatch pattern into a **sequential multi-pass workflow with explicit checkpoints**, preserving the same quality guarantees, isolation principles, and coordination patterns.

# Dispatching Parallel Tasks (Sequential Multi-Pass)

## Overview

When you face multiple independent problems (different test files, different subsystems, different bugs), investigating them all in one tangled pass leads to context pollution and missed root causes. This skill structures your work into **isolated sequential passes** — one pass per independent problem domain — with explicit context boundaries and checkpoints between them.

**Core principle:** Execute one focused pass per independent problem domain. Isolate context between passes. Checkpoint after each. Integrate at the end.

## When to Use

```
Multiple failures? ─── no ──→ Single investigation
       │ yes
       ▼
Are they independent? ─── no (related) ──→ Single investigation
       │ yes
       ▼
Sequential multi-pass with checkpoints
```

**Use when:**
- 3+ test files failing with different root causes
- Multiple subsystems broken independently
- Each problem can be understood without context from others
- No shared state between investigations

**Don't use when:**
- Failures are related (fix one might fix others)
- Need to understand full system state first
- Investigations would interfere with each other (editing same files)
- Exploratory debugging — you don't know what's broken yet

## Hard Gates

| Gate | Condition | Action if FAIL |
|------|-----------|----------------|
| G1 — Independence | Each task domain touches different files/subsystems | STOP: merge related tasks into one pass |
| G2 — No shared state | No two passes edit the same file | STOP: redefine pass boundaries |
| G3 — Clear scope | Each pass has explicit goal + constraints | STOP: refine pass definitions before starting |
| G4 — Tracking initialized | YAML tracking block written before first pass | STOP: create tracking block first |

## The Pattern: Sequential Multi-Pass Execution

### Phase 1 — Identify Independent Domains

Group failures by what's broken:

```
Domain A: Tool approval flow (file_a.test.ts)
Domain B: Batch completion behavior (file_b.test.ts)
Domain C: Abort functionality (file_c.test.ts)
```

Each domain is independent — fixing tool approval doesn't affect abort tests.

**Verification:** For each pair of domains, ask: "Could fixing domain X change the outcome of domain Y?" If yes, they are NOT independent — merge them.

### Phase 2 — Initialize Tracking Block

Before starting any pass, create an inline YAML tracking block in your response:

```yaml
MULTI_PASS_TRACKER:
  total_passes: 3
  status: "IN_PROGRESS"
  passes:
    - id: "PASS-1"
      domain: "Tool approval flow"
      scope: "src/agents/agent-tool-abort.test.ts"
      goal: "Fix 3 timing-related test failures"
      constraints: "Do NOT modify batch or race-condition code"
      status: "PENDING"
      findings: ""
      files_changed: []

    - id: "PASS-2"
      domain: "Batch completion behavior"
      scope: "src/agents/batch-completion-behavior.test.ts"
      goal: "Fix 2 test failures — tools not executing"
      constraints: "Do NOT modify abort or race-condition code"
      status: "PENDING"
      findings: ""
      files_changed: []

    - id: "PASS-3"
      domain: "Race conditions"
      scope: "src/agents/tool-approval-race-conditions.test.ts"
      goal: "Fix 1 failure — execution count = 0"
      constraints: "Do NOT modify abort or batch code"
      status: "PENDING"
      findings: ""
      files_changed: []

  integration:
    conflicts_detected: false
    full_suite_result: ""
    final_status: ""
```

### Phase 3 — Execute Passes Sequentially

For **each pass**, follow this exact protocol:

#### 3a. Context Isolation Boundary

Start each pass with a clear mental boundary:

```
═══════════════════════════════════════
  PASS N of M: [Domain Name]
  Scope: [files/subsystem]
  Goal: [specific outcome]
  Constraint: [what NOT to touch]
═══════════════════════════════════════
```

#### 3b. Investigate and Fix

Within the pass:

1. **Read** the relevant files using `read_file`
2. **Search** for patterns using `run_shell_command` with `grep` or `find`
3. **Understand** the root cause within this domain only
4. **Fix** using `edit_file` or `write_file`
5. **Verify** the specific tests pass using `run_shell_command`

```bash
# Example: run only the tests for this domain
run_shell_command("npm test -- src/agents/agent-tool-abort.test.ts")
```

#### 3c. Checkpoint

After completing each pass, update the tracking block:

```yaml
# Update PASS-N
status: "DONE"
findings: "Replaced arbitrary timeouts with event-based waiting"
files_changed: ["src/agents/agent-tool-abort.ts"]
```

**Checkpoint validation:**
- [ ] Tests for this domain pass
- [ ] No files outside declared scope were modified
- [ ] Findings documented in tracking block
- [ ] Ready to proceed to next pass

#### 3d. Context Reset

Before starting the next pass, explicitly acknowledge:
- "Pass N complete. Resetting context for Pass N+1."
- Do NOT carry assumptions from the previous pass into the next one.

### Phase 4 — Integration

After ALL passes complete:

1. **Review all findings** — read each pass summary from the tracking block
2. **Check for conflicts** — did any two passes touch the same file?

```bash
# Verify no file conflicts
run_shell_command("git diff --name-only | sort | uniq -d")
```

3. **Run full test suite** — verify all fixes work together

```bash
run_shell_command("npm test")
```

4. **Update final tracking:**

```yaml
integration:
  conflicts_detected: false
  full_suite_result: "ALL PASS"
  final_status: "SUCCESS"
```

5. **Report to user** — summarize all passes and integration result using `ask_user` if confirmation is needed.

## Pass Prompt Structure

Good pass definitions are:
1. **Focused** — one clear problem domain
2. **Self-contained** — all context needed to understand the problem
3. **Specific about output** — what should this pass produce?

### Template

```
PASS [N]: Fix [file/subsystem]

Failing tests:
1. "[test name]" — expects X but gets Y
2. "[test name]" — behavior Z not observed

Root cause hypothesis: [timing / logic / config]

Steps:
1. Read the test file and understand assertions
2. Identify root cause within this domain
3. Fix implementation or test expectations
4. Run domain-specific tests to verify

Constraints:
- Do NOT modify files outside [scope]
- Do NOT change [other subsystem] code

Output: Summary of root cause and changes made
```

## Common Mistakes

| Mistake | Problem | Correct Approach |
|---------|---------|------------------|
| Too broad scope | "Fix all tests" — context gets polluted | One domain per pass |
| No context isolation | Carry assumptions between passes | Explicit boundary + reset |
| No constraints | Pass modifies files in other domains | Declare file scope upfront |
| Skipping checkpoints | Don't verify before moving on | Checkpoint after EVERY pass |
| No tracking block | Lose track of what was done | Initialize YAML tracker first |
| Vague output | "Fixed it" — no audit trail | Document findings per pass |
| Not checking conflicts | Passes silently edit same file | Run conflict check in integration |

## Anti-Patterns Table

| Anti-Pattern | Why It Fails | Alternative |
|--------------|-------------|-------------|
| Investigate all failures in one pass | Context pollution, miss root causes | One pass per domain |
| Skip independence check | "Independent" tasks actually share state | Verify G1+G2 gates |
| Fix and move on without testing | Broken fix cascades to integration | Test at each checkpoint |
| Assume no conflicts | Two passes edit same utility file | Always run conflict check |
| Reuse findings from pass N in pass N+1 | Introduces coupling between passes | Each pass is self-contained |

## Output Contract

After completing all passes and integration, produce this summary:

```markdown
## Multi-Pass Execution Summary

### Tracking
- Total passes: N
- Passes completed: N
- Integration: SUCCESS / FAILURE

### Pass Results
| Pass | Domain | Root Cause | Fix Applied | Files Changed |
|------|--------|-----------|-------------|---------------|
| 1 | [domain] | [cause] | [fix] | [files] |
| 2 | [domain] | [cause] | [fix] | [files] |
| 3 | [domain] | [cause] | [fix] | [files] |

### Integration
- Conflicts: None / [list]
- Full suite: PASS / FAIL
- Final status: SUCCESS / FAILURE

### Files Modified (all passes)
- file1.ts (Pass 1)
- file2.ts (Pass 2)
- file3.ts (Pass 3)
```

## Real Example

**Scenario:** 6 test failures across 3 files after major refactoring

**Failures:**
- agent-tool-abort.test.ts: 3 failures (timing issues)
- batch-completion-behavior.test.ts: 2 failures (tools not executing)
- tool-approval-race-conditions.test.ts: 1 failure (execution count = 0)

**Independence check:** Abort logic, batch completion, and race conditions are separate subsystems with no shared files.

**Execution:**

```
PASS 1 → Fix agent-tool-abort.test.ts
  Finding: Replaced timeouts with event-based waiting
  Checkpoint: 3/3 tests pass

PASS 2 → Fix batch-completion-behavior.test.ts
  Finding: Fixed event structure bug (threadId in wrong place)
  Checkpoint: 2/2 tests pass

PASS 3 → Fix tool-approval-race-conditions.test.ts
  Finding: Added wait for async tool execution to complete
  Checkpoint: 1/1 test passes

INTEGRATION → No conflicts, full suite green
```

**Quality preserved:** Same root causes found, same fixes applied, same zero-conflict result as the original parallel approach — achieved through disciplined sequential isolation.

## Verification Checklist

After completing the full workflow:

- [ ] Independence verified (G1) — no domain overlap
- [ ] No shared state (G2) — no file conflicts
- [ ] Clear scope per pass (G3) — constraints defined
- [ ] Tracking block initialized (G4) — before first pass
- [ ] Each pass has explicit boundary marker
- [ ] Each pass ends with checkpoint
- [ ] Context reset between passes
- [ ] Integration conflict check performed
- [ ] Full test suite run after integration
- [ ] Summary output contract produced

## Cross-References

- $superpower-debugging — for single-domain deep investigation within a pass
- $superpower-tdd — for test-driven fixes within each pass
- $superpower-verification — for integration verification after all passes
- $superpower-executing-plans — for structured execution of each pass

## Key Benefits (Sequential Adaptation)

1. **Isolation** — Each pass has clean context, no pollution from other domains
2. **Focus** — Narrow scope per pass reduces cognitive load
3. **Auditability** — YAML tracking + checkpoints create clear audit trail
4. **Conflict detection** — Integration phase catches any overlap
5. **Resumability** — If interrupted, tracking block shows exactly where to resume
6. **Same quality** — Finds same root causes as parallel execution, with guaranteed ordering
