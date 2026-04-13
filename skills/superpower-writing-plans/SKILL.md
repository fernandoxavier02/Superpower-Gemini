---
name: superpower-writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code. Creates comprehensive implementation plans with TDD, bite-sized tasks, and full code examples.
---

<!-- Adapted from Claude Code superpowers v5.0.7 for Gemini CLI -->

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Tool Mapping (Gemini CLI)

| Operation | Tool |
|-----------|------|
| Run commands, grep, find | `run_shell_command` |
| Read files | `read_file` |
| Write files | `write_file` |
| Edit files | `edit_file` |
| Ask user questions | `ask_user` |
| Activate another skill | `activate_skill` with `$superpower-{name}` |
| Track task progress | Inline YAML tracking blocks (see below) |
| Plan mode (read-only analysis) | Sequential read-only analysis — read files and reason about structure without making changes |

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure — but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

### Discovery Phase

Before writing the plan, use sequential read-only analysis to understand the codebase:

1. **Find relevant files:**
   ```
   run_shell_command: find src/ -name "*.ts" -path "*feature*"
   run_shell_command: grep -rn "pattern" src/ --include="*.ts"
   ```

2. **Read key files:**
   ```
   read_file: path/to/relevant/file.ts
   ```

3. **Map dependencies:**
   ```
   run_shell_command: grep -rn "import.*from" src/path/to/file.ts
   ```

Do NOT modify any files during this phase. Only read and reason.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" — step
- "Run it to make sure it fails" — step
- "Implement the minimal code to make the test pass" — step
- "Run the tests and make sure they pass" — step
- "Commit" — step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** RECOMMENDED SKILL: Use $superpower-executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## No Placeholders — HARD GATE

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:

| Anti-Pattern | Why It Fails |
|-------------|-------------|
| "TBD", "TODO", "implement later", "fill in details" | Engineer has no actionable content |
| "Add appropriate error handling" / "add validation" / "handle edge cases" | Vague — what errors? what validation? |
| "Write tests for the above" (without actual test code) | No test code = no test |
| "Similar to Task N" (repeat the code) | Engineer may read tasks out of order |
| Steps that describe what to do without showing how | Code steps require code blocks |
| References to types, functions, or methods not defined in any task | Undefined references = build failure |

## Remember
- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

## Self-Review — HARD GATE

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a sequential read-only analysis you run yourself — not a separate dispatch.

### Self-Review Checklist

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Plan Document Review (Inlined)

After completing the self-review, perform a final verification pass using this review protocol.

### What to Check

| Category | What to Look For |
|----------|------------------|
| Completeness | TODOs, placeholders, incomplete tasks, missing steps |
| Spec Alignment | Plan covers spec requirements, no major scope creep |
| Task Decomposition | Tasks have clear boundaries, steps are actionable |
| Buildability | Could an engineer follow this plan without getting stuck? |

### Calibration

**Only flag issues that would cause real problems during implementation.**
An implementer building the wrong thing or getting stuck is an issue.
Minor wording, stylistic preferences, and "nice to have" suggestions are not.

Approve unless there are serious gaps — missing requirements from the spec, contradictory steps, placeholder content, or tasks so vague they can't be acted on.

### Review Output Format

After the review, append to the plan:

```markdown
## Plan Review

**Status:** Approved | Issues Found

**Issues (if any):**
- [Task X, Step Y]: [specific issue] — [why it matters for implementation]

**Recommendations (advisory, do not block approval):**
- [suggestions for improvement]
```

## Task Progress Tracking

Use inline YAML blocks to track task completion state:

```yaml
# Plan Progress
plan: "feature-name"
status: in-progress
tasks:
  - id: 1
    name: "Component Name"
    status: complete  # pending | in-progress | complete | blocked
  - id: 2
    name: "Next Component"
    status: in-progress
  - id: 3
    name: "Final Component"
    status: pending
```

Update this block as tasks are completed during execution.

## Execution Handoff

After saving the plan, offer execution:

**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`.**

**To execute, activate:** `$superpower-executing-plans`

**This will:** Execute tasks sequentially with checkpoints for review between major sections."

## Process Flow

```
1. Announce skill activation
2. Read spec/requirements (read_file)
3. Discovery phase — map codebase (run_shell_command with grep/find, read_file)
4. Scope check — single plan or split?
5. Define file structure
6. Write tasks with TDD steps and full code
7. Self-review (spec coverage, placeholder scan, type consistency)
8. Plan document review (completeness, alignment, decomposition, buildability)
9. Save plan (write_file to docs/superpowers/plans/)
10. Offer execution handoff
```
