---
name: superpower-debugging
description: >
  Systematic debugging skill — use when encountering any bug, test failure,
  or unexpected behavior, BEFORE proposing fixes. Enforces root-cause-first
  methodology with hard gates, defense-in-depth, and condition-based waiting.
  Adapted from Claude Code superpowers v5.0.7 for Gemini CLI.
---

> **Gemini CLI adaptation note:** Adapted from Claude Code superpowers v5.0.7
> for Gemini CLI. All tool references use Gemini-native equivalents
> (`run_shell_command`, `read_file`, `write_file`, `edit_file`, `ask_user`,
> `activate_skill`).

# Systematic Debugging

## Overview

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## When to Use

Use for ANY technical issue:
- Test failures
- Bugs in production
- Unexpected behavior
- Performance problems
- Build failures
- Integration issues

**Use this ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- Previous fix didn't work
- You don't fully understand the issue

**Don't skip when:**
- Issue seems simple (simple bugs have root causes too)
- You're in a hurry (rushing guarantees rework)
- Manager wants it fixed NOW (systematic is faster than thrashing)

---

## The Four Phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read Error Messages Carefully**
   - Don't skip past errors or warnings
   - They often contain the exact solution
   - Read stack traces completely
   - Note line numbers, file paths, error codes

2. **Reproduce Consistently**
   - Can you trigger it reliably?
   - What are the exact steps?
   - Does it happen every time?
   - If not reproducible, gather more data — don't guess

3. **Check Recent Changes**
   - What changed that could cause this?
   - Use `run_shell_command` with `git diff`, `git log --oneline -20`
   - New dependencies, config changes
   - Environmental differences

4. **Gather Evidence in Multi-Component Systems**

   **WHEN system has multiple components (CI -> build -> signing, API -> service -> database):**

   **BEFORE proposing fixes, add diagnostic instrumentation:**
   ```
   For EACH component boundary:
     - Log what data enters component
     - Log what data exits component
     - Verify environment/config propagation
     - Check state at each layer

   Run once to gather evidence showing WHERE it breaks
   THEN analyze evidence to identify failing component
   THEN investigate that specific component
   ```

   **Example (multi-layer system):**
   ```bash
   # Layer 1: Workflow
   echo "=== Secrets available in workflow: ==="
   echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"

   # Layer 2: Build script
   echo "=== Env vars in build script: ==="
   env | grep IDENTITY || echo "IDENTITY not in environment"

   # Layer 3: Signing script
   echo "=== Keychain state: ==="
   security list-keychains
   security find-identity -v

   # Layer 4: Actual signing
   codesign --sign "$IDENTITY" --verbose=4 "$APP"
   ```

   **This reveals:** Which layer fails (secrets -> workflow OK, workflow -> build FAIL)

5. **Trace Data Flow**

   **WHEN error is deep in call stack:** Use the Root Cause Tracing technique (see section below).

   **Quick version:**
   - Where does bad value originate?
   - What called this with bad value?
   - Keep tracing up until you find the source
   - Fix at source, not at symptom

### Phase 2: Pattern Analysis

**Find the pattern before fixing:**

1. **Find Working Examples**
   - Locate similar working code in same codebase
   - Use `run_shell_command` with `grep -rn "pattern" src/` to find examples
   - What works that's similar to what's broken?

2. **Compare Against References**
   - If implementing pattern, read reference implementation COMPLETELY via `read_file`
   - Don't skim — read every line
   - Understand the pattern fully before applying

3. **Identify Differences**
   - What's different between working and broken?
   - List every difference, however small
   - Don't assume "that can't matter"

4. **Understand Dependencies**
   - What other components does this need?
   - What settings, config, environment?
   - What assumptions does it make?

### Phase 3: Hypothesis and Testing

**Scientific method:**

1. **Form Single Hypothesis**
   - State clearly: "I think X is the root cause because Y"
   - Write it down
   - Be specific, not vague

2. **Test Minimally**
   - Make the SMALLEST possible change to test hypothesis
   - One variable at a time
   - Don't fix multiple things at once

3. **Verify Before Continuing**
   - Did it work? Yes -> Phase 4
   - Didn't work? Form NEW hypothesis
   - DON'T add more fixes on top

4. **When You Don't Know**
   - Say "I don't understand X"
   - Don't pretend to know
   - Use `ask_user` when blocked
   - Research more

### Phase 4: Implementation

**Fix the root cause, not the symptom:**

1. **Create Failing Test Case**
   - Simplest possible reproduction
   - Automated test if possible
   - One-off test script if no framework
   - MUST have before fixing
   - Use `activate_skill` with `$superpower-tdd` for writing proper failing tests

2. **Implement Single Fix**
   - Address the root cause identified
   - ONE change at a time
   - No "while I'm here" improvements
   - No bundled refactoring

3. **Verify Fix**
   - Test passes now? Use `run_shell_command` to execute tests
   - No other tests broken?
   - Issue actually resolved?

4. **If Fix Doesn't Work**
   - STOP
   - Count: How many fixes have you tried?
   - If < 3: Return to Phase 1, re-analyze with new information
   - **If >= 3: STOP and question the architecture (step 5 below)**
   - DON'T attempt Fix #4 without architectural discussion

5. **If 3+ Fixes Failed: Question Architecture**

   **Pattern indicating architectural problem:**
   - Each fix reveals new shared state/coupling/problem in different place
   - Fixes require "massive refactoring" to implement
   - Each fix creates new symptoms elsewhere

   **STOP and question fundamentals:**
   - Is this pattern fundamentally sound?
   - Are we "sticking with it through sheer inertia"?
   - Should we refactor architecture vs. continue fixing symptoms?

   **Use `ask_user` to discuss with your human partner before attempting more fixes**

   This is NOT a failed hypothesis — this is a wrong architecture.

---

## Red Flags — STOP and Follow Process

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Pattern says X but I'll adapt it differently"
- "Here are the main problems: [lists fixes without investigation]"
- Proposing solutions before tracing data flow
- **"One more fix attempt" (when already tried 2+)**
- **Each fix reveals new problem in different place**

**ALL of these mean: STOP. Return to Phase 1.**

**If 3+ fixes failed:** Question the architecture (see Phase 4.5)

## Human Partner Signals You're Doing It Wrong

**Watch for these redirections:**
- "Is that not happening?" — You assumed without verifying
- "Will it show us...?" — You should have added evidence gathering
- "Stop guessing" — You're proposing fixes without understanding
- "Ultrathink this" — Question fundamentals, not just symptoms
- "We're stuck?" (frustrated) — Your approach isn't working

**When you see these:** STOP. Return to Phase 1.

---

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "I'll write test after confirming fix works" | Untested fixes don't stick. Test first proves it. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I see the problem, let me fix it" | Seeing symptoms != understanding root cause. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem. Question pattern, don't fix again. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence | Understand WHAT and WHY |
| **2. Pattern** | Find working examples, compare | Identify differences |
| **3. Hypothesis** | Form theory, test minimally | Confirmed or new hypothesis |
| **4. Implementation** | Create test, fix, verify | Bug resolved, tests pass |

## When Process Reveals "No Root Cause"

If systematic investigation reveals issue is truly environmental, timing-dependent, or external:

1. You've completed the process
2. Document what you investigated
3. Implement appropriate handling (retry, timeout, error message)
4. Add monitoring/logging for future investigation

**But:** 95% of "no root cause" cases are incomplete investigation.

---

## Output Contract

When completing a debugging session, return:

```
Symptom: what is failing
Evidence: what was observed during investigation
Root cause: the confirmed explanation (or best hypothesis if unconfirmed)
Fix applied: what was changed and why
Verification: test results confirming the fix
Next skill: $superpower-tdd or $superpower-writing-plans for larger remediation

### Decisões tomadas
- [list]

### Decision Gate (for multiple plausible root causes)

When competing hypotheses remain and each implies a different fix scope, do not continue with an implementation commit yet. Ask one structured clarification question with 4 options:

```text
Pergunta de clareza:
- [1] Opção recomendada (menos risco)
- [2] Opção alternativa
- [3] Opção alternativa
- [4] Outra (descreva)

Se a interface suportar, emita isso como 4 opções clicáveis.
Se a UI clicável não estiver disponível, liste as mesmas 4 opções e peça a resposta pelo identificador 1-4.
```

No questions -> no execution.

### Riscos remanescentes
- [list]

### Pendências para o usuário
- [list]

### Próximo passo recomendado
- [list]
```

---

## Debug Tracking Block

Use this inline YAML block to track debugging state across turns. Update it as you progress through phases:

```yaml
# DEBUG_TRACKER:
#   issue: "description of the bug"
#   phase: 1  # Current phase (1-4)
#   hypotheses_tested: 0
#   fixes_attempted: 0
#   root_cause: "unknown"
#   evidence:
#     - "error message from logs"
#     - "git diff shows X changed"
#   next_step: "reproduce the issue"
#   architectural_concern: false
```

**Hard gate:** If `fixes_attempted >= 3` and issue persists, set `architectural_concern: true` and use `ask_user` before continuing.

---

## Supporting Technique: Root Cause Tracing

### Overview

Bugs often manifest deep in the call stack (git init in wrong directory, file created in wrong location, database opened with wrong path). Your instinct is to fix where the error appears, but that's treating a symptom.

**Core principle:** Trace backward through the call chain until you find the original trigger, then fix at the source.

### When to Use

- Error happens deep in execution (not at entry point)
- Stack trace shows long call chain
- Unclear where invalid data originated
- Need to find which test/code triggers the problem

### The Tracing Process

#### 1. Observe the Symptom
```
Error: git init failed in /Users/dev/project/packages/core
```

#### 2. Find Immediate Cause
**What code directly causes this?**
```typescript
await execFileAsync('git', ['init'], { cwd: projectDir });
```

#### 3. Ask: What Called This?
```typescript
WorktreeManager.createSessionWorktree(projectDir, sessionId)
  -> called by Session.initializeWorkspace()
  -> called by Session.create()
  -> called by test at Project.create()
```

#### 4. Keep Tracing Up
**What value was passed?**
- `projectDir = ''` (empty string!)
- Empty string as `cwd` resolves to `process.cwd()`
- That's the source code directory!

#### 5. Find Original Trigger
**Where did empty string come from?**
```typescript
const context = setupCoreTest(); // Returns { tempDir: '' }
Project.create('name', context.tempDir); // Accessed before beforeEach!
```

### Adding Stack Traces

When you can't trace manually, add instrumentation:

```typescript
// Before the problematic operation
async function gitInit(directory: string) {
  const stack = new Error().stack;
  console.error('DEBUG git init:', {
    directory,
    cwd: process.cwd(),
    nodeEnv: process.env.NODE_ENV,
    stack,
  });

  await execFileAsync('git', ['init'], { cwd: directory });
}
```

**Critical:** Use `console.error()` in tests (not logger — may not show)

**Run and capture via `run_shell_command`:**
```bash
npm test 2>&1 | grep 'DEBUG git init'
```

**Analyze stack traces:**
- Look for test file names
- Find the line number triggering the call
- Identify the pattern (same test? same parameter?)

### Finding Which Test Causes Pollution

If something appears during tests but you don't know which test, use this bisection approach via `run_shell_command`:

```bash
#!/usr/bin/env bash
# Bisection script to find which test creates unwanted files/state
# Usage: ./find-polluter.sh <file_or_dir_to_check> <test_pattern>
# Example: ./find-polluter.sh '.git' 'src/**/*.test.ts'

set -e

if [ $# -ne 2 ]; then
  echo "Usage: $0 <file_to_check> <test_pattern>"
  echo "Example: $0 '.git' 'src/**/*.test.ts'"
  exit 1
fi

POLLUTION_CHECK="$1"
TEST_PATTERN="$2"

echo "Searching for test that creates: $POLLUTION_CHECK"
echo "Test pattern: $TEST_PATTERN"
echo ""

TEST_FILES=$(find . -path "$TEST_PATTERN" | sort)
TOTAL=$(echo "$TEST_FILES" | wc -l | tr -d ' ')

echo "Found $TOTAL test files"
echo ""

COUNT=0
for TEST_FILE in $TEST_FILES; do
  COUNT=$((COUNT + 1))

  if [ -e "$POLLUTION_CHECK" ]; then
    echo "WARNING: Pollution already exists before test $COUNT/$TOTAL"
    echo "   Skipping: $TEST_FILE"
    continue
  fi

  echo "[$COUNT/$TOTAL] Testing: $TEST_FILE"

  npm test "$TEST_FILE" > /dev/null 2>&1 || true

  if [ -e "$POLLUTION_CHECK" ]; then
    echo ""
    echo "FOUND POLLUTER!"
    echo "   Test: $TEST_FILE"
    echo "   Created: $POLLUTION_CHECK"
    echo ""
    echo "Pollution details:"
    ls -la "$POLLUTION_CHECK"
    echo ""
    echo "To investigate:"
    echo "  npm test $TEST_FILE"
    exit 1
  fi
done

echo ""
echo "No polluter found - all tests clean!"
exit 0
```

### Real Example: Empty projectDir

**Symptom:** `.git` created in `packages/core/` (source code)

**Trace chain:**
1. `git init` runs in `process.cwd()` — empty cwd parameter
2. WorktreeManager called with empty projectDir
3. Session.create() passed empty string
4. Test accessed `context.tempDir` before beforeEach
5. setupCoreTest() returns `{ tempDir: '' }` initially

**Root cause:** Top-level variable initialization accessing empty value

**Fix:** Made tempDir a getter that throws if accessed before beforeEach

**Also added defense-in-depth:**
- Layer 1: Project.create() validates directory
- Layer 2: WorkspaceManager validates not empty
- Layer 3: NODE_ENV guard refuses git init outside tmpdir
- Layer 4: Stack trace logging before git init

### Key Principle

**NEVER fix just where the error appears.** Trace back to find the original trigger.

### Stack Trace Tips

- **In tests:** Use `console.error()` not logger — logger may be suppressed
- **Before operation:** Log before the dangerous operation, not after it fails
- **Include context:** Directory, cwd, environment variables, timestamps
- **Capture stack:** `new Error().stack` shows complete call chain

---

## Supporting Technique: Defense-in-Depth Validation

### Overview

When you fix a bug caused by invalid data, adding validation at one place feels sufficient. But that single check can be bypassed by different code paths, refactoring, or mocks.

**Core principle:** Validate at EVERY layer data passes through. Make the bug structurally impossible.

### Why Multiple Layers

Single validation: "We fixed the bug"
Multiple layers: "We made the bug impossible"

Different layers catch different cases:
- Entry validation catches most bugs
- Business logic catches edge cases
- Environment guards prevent context-specific dangers
- Debug logging helps when other layers fail

### The Four Layers

#### Layer 1: Entry Point Validation
**Purpose:** Reject obviously invalid input at API boundary

```typescript
function createProject(name: string, workingDirectory: string) {
  if (!workingDirectory || workingDirectory.trim() === '') {
    throw new Error('workingDirectory cannot be empty');
  }
  if (!existsSync(workingDirectory)) {
    throw new Error(`workingDirectory does not exist: ${workingDirectory}`);
  }
  if (!statSync(workingDirectory).isDirectory()) {
    throw new Error(`workingDirectory is not a directory: ${workingDirectory}`);
  }
  // ... proceed
}
```

#### Layer 2: Business Logic Validation
**Purpose:** Ensure data makes sense for this operation

```typescript
function initializeWorkspace(projectDir: string, sessionId: string) {
  if (!projectDir) {
    throw new Error('projectDir required for workspace initialization');
  }
  // ... proceed
}
```

#### Layer 3: Environment Guards
**Purpose:** Prevent dangerous operations in specific contexts

```typescript
async function gitInit(directory: string) {
  if (process.env.NODE_ENV === 'test') {
    const normalized = normalize(resolve(directory));
    const tmpDir = normalize(resolve(tmpdir()));

    if (!normalized.startsWith(tmpDir)) {
      throw new Error(
        `Refusing git init outside temp dir during tests: ${directory}`
      );
    }
  }
  // ... proceed
}
```

#### Layer 4: Debug Instrumentation
**Purpose:** Capture context for forensics

```typescript
async function gitInit(directory: string) {
  const stack = new Error().stack;
  logger.debug('About to git init', {
    directory,
    cwd: process.cwd(),
    stack,
  });
  // ... proceed
}
```

### Applying the Pattern

When you find a bug:

1. **Trace the data flow** — Where does bad value originate? Where is it used?
2. **Map all checkpoints** — List every point data passes through
3. **Add validation at each layer** — Entry, business, environment, debug
4. **Test each layer** — Try to bypass layer 1, verify layer 2 catches it

### Example from Session

Bug: Empty `projectDir` caused `git init` in source code

**Data flow:**
1. Test setup -> empty string
2. `Project.create(name, '')`
3. `WorkspaceManager.createWorkspace('')`
4. `git init` runs in `process.cwd()`

**Four layers added:**
- Layer 1: `Project.create()` validates not empty/exists/writable
- Layer 2: `WorkspaceManager` validates projectDir not empty
- Layer 3: `WorktreeManager` refuses git init outside tmpdir in tests
- Layer 4: Stack trace logging before git init

**Result:** All 1847 tests passed, bug impossible to reproduce

### Key Insight

All four layers were necessary. During testing, each layer caught bugs the others missed:
- Different code paths bypassed entry validation
- Mocks bypassed business logic checks
- Edge cases on different platforms needed environment guards
- Debug logging identified structural misuse

**Don't stop at one validation point.** Add checks at every layer.

---

## Supporting Technique: Condition-Based Waiting

### Overview

Flaky tests often guess at timing with arbitrary delays. This creates race conditions where tests pass on fast machines but fail under load or in CI.

**Core principle:** Wait for the actual condition you care about, not a guess about how long it takes.

### When to Use

- Tests have arbitrary delays (`setTimeout`, `sleep`, `time.sleep()`)
- Tests are flaky (pass sometimes, fail under load)
- Tests timeout when run in parallel
- Waiting for async operations to complete

**Don't use when:**
- Testing actual timing behavior (debounce, throttle intervals)
- Always document WHY if using arbitrary timeout

### Core Pattern

```typescript
// BAD: Guessing at timing
await new Promise(r => setTimeout(r, 50));
const result = getResult();
expect(result).toBeDefined();

// GOOD: Waiting for condition
await waitFor(() => getResult() !== undefined);
const result = getResult();
expect(result).toBeDefined();
```

### Quick Patterns

| Scenario | Pattern |
|----------|---------|
| Wait for event | `waitFor(() => events.find(e => e.type === 'DONE'))` |
| Wait for state | `waitFor(() => machine.state === 'ready')` |
| Wait for count | `waitFor(() => items.length >= 5)` |
| Wait for file | `waitFor(() => fs.existsSync(path))` |
| Complex condition | `waitFor(() => obj.ready && obj.value > 10)` |

### Implementation

Generic polling function:
```typescript
async function waitFor<T>(
  condition: () => T | undefined | null | false,
  description: string,
  timeoutMs = 5000
): Promise<T> {
  const startTime = Date.now();

  while (true) {
    const result = condition();
    if (result) return result;

    if (Date.now() - startTime > timeoutMs) {
      throw new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`);
    }

    await new Promise(r => setTimeout(r, 10)); // Poll every 10ms
  }
}
```

### Domain-Specific Helpers

```typescript
/**
 * Wait for a specific event type to appear
 */
export function waitForEvent(
  threadManager: ThreadManager,
  threadId: string,
  eventType: string,
  timeoutMs = 5000
): Promise<Event> {
  return new Promise((resolve, reject) => {
    const startTime = Date.now();
    const check = () => {
      const events = threadManager.getEvents(threadId);
      const event = events.find((e) => e.type === eventType);
      if (event) {
        resolve(event);
      } else if (Date.now() - startTime > timeoutMs) {
        reject(new Error(`Timeout waiting for ${eventType} event after ${timeoutMs}ms`));
      } else {
        setTimeout(check, 10);
      }
    };
    check();
  });
}

/**
 * Wait for a specific number of events of a given type
 */
export function waitForEventCount(
  threadManager: ThreadManager,
  threadId: string,
  eventType: string,
  count: number,
  timeoutMs = 5000
): Promise<Event[]> {
  return new Promise((resolve, reject) => {
    const startTime = Date.now();
    const check = () => {
      const events = threadManager.getEvents(threadId);
      const matchingEvents = events.filter((e) => e.type === eventType);
      if (matchingEvents.length >= count) {
        resolve(matchingEvents);
      } else if (Date.now() - startTime > timeoutMs) {
        reject(
          new Error(
            `Timeout waiting for ${count} ${eventType} events after ${timeoutMs}ms (got ${matchingEvents.length})`
          )
        );
      } else {
        setTimeout(check, 10);
      }
    };
    check();
  });
}

/**
 * Wait for an event matching a custom predicate
 */
export function waitForEventMatch(
  threadManager: ThreadManager,
  threadId: string,
  predicate: (event: Event) => boolean,
  description: string,
  timeoutMs = 5000
): Promise<Event> {
  return new Promise((resolve, reject) => {
    const startTime = Date.now();
    const check = () => {
      const events = threadManager.getEvents(threadId);
      const event = events.find(predicate);
      if (event) {
        resolve(event);
      } else if (Date.now() - startTime > timeoutMs) {
        reject(new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`));
      } else {
        setTimeout(check, 10);
      }
    };
    check();
  });
}
```

### Usage Example (Before/After)

```typescript
// BEFORE (flaky):
const messagePromise = agent.sendMessage('Execute tools');
await new Promise(r => setTimeout(r, 300)); // Hope tools start in 300ms
agent.abort();
await messagePromise;
await new Promise(r => setTimeout(r, 50));  // Hope results arrive in 50ms
expect(toolResults.length).toBe(2);         // Fails randomly

// AFTER (reliable):
const messagePromise = agent.sendMessage('Execute tools');
await waitForEventCount(threadManager, threadId, 'TOOL_CALL', 2);
agent.abort();
await messagePromise;
await waitForEventCount(threadManager, threadId, 'TOOL_RESULT', 2);
expect(toolResults.length).toBe(2); // Always succeeds
// Result: 60% pass rate -> 100%, 40% faster execution
```

### Common Mistakes

| Mistake | Fix |
|---------|-----|
| Polling too fast (`setTimeout(check, 1)`) — wastes CPU | Poll every 10ms |
| No timeout — loop forever if condition never met | Always include timeout with clear error |
| Stale data — cache state before loop | Call getter inside loop for fresh data |

### When Arbitrary Timeout IS Correct

```typescript
// Tool ticks every 100ms - need 2 ticks to verify partial output
await waitForEvent(manager, 'TOOL_STARTED'); // First: wait for condition
await new Promise(r => setTimeout(r, 200));   // Then: wait for timed behavior
// 200ms = 2 ticks at 100ms intervals - documented and justified
```

**Requirements:**
1. First wait for triggering condition
2. Based on known timing (not guessing)
3. Comment explaining WHY

---

## Pressure Tests

These scenarios test whether you truly follow the systematic process under pressure. When faced with these situations, apply the skill rigorously.

### Pressure Test 1: Emergency Production Fix

**Scenario:** Production API is down. Error rate 100%. Revenue loss $15,000/minute. Already down 5 minutes.

Logs show: `PaymentError: Connection timeout to payments.api.com`

You remember a similar timeout last week was fixed with a retry in 2 minutes.

**Options:**
- **A) Follow systematic debugging process** — 35+ min investigation, $525k more lost
- **B) Quick fix now, investigate later** — Add retry (5 min), stop bleeding
- **C) Minimal investigation** — Quick 5-min check, then retry if nothing obvious

**Correct answer: A — Follow the process.**

Even under pressure. The retry "fix" masks the root cause. The timeout could be DNS, certificate expiry, network partition, or upstream outage — retry won't fix any of these. Systematic investigation (check DNS, check certs, check network, check upstream status) takes 10 minutes, not 35. The process IS the fast path.

### Pressure Test 2: Sunk Cost + Exhaustion

**Scenario:** 4 hours debugging a test failure. Tried `sleep(100)`, `sleep(500)`, `sleep(1000)`, `sleep(2000)` — all flaky. It's 8pm, dinner plans at 8:30.

**Options:**
- **A) Delete timeout code, start Phase 1** — Another 2-3 hours
- **B) Use `sleep(5000)`, file ticket** — "Good enough", make dinner
- **C) Quick 30-min investigation** — Then timeout if nothing found

**Correct answer: A — Delete and restart.**

The 4 hours of timeout attempts are sunk cost. The test is flaky because you're guessing at timing instead of understanding the condition. Use condition-based waiting (see technique above). The real fix likely takes 30 minutes once you understand the root cause.

### Pressure Test 3: Authority + Social Pressure

**Scenario:** Senior engineer (10 years exp) says "add token refresh after middleware" on a Zoom call. Tech lead wants to end the call. You think the middleware shouldn't be invalidating tokens in the first place.

**Options:**
- **A) Push back** — "We should investigate root cause first"
- **B) Go along** — Senior has experience, team wants to move on
- **C) Compromise** — "Can we check the middleware docs?"

**Correct answer: A — Push back.**

Experience doesn't override process. The senior is proposing a symptom fix without understanding why middleware invalidates tokens. That's exactly the pattern that creates tech debt. Say: "I respect your experience, but the process says we should understand WHY before fixing. Can we take 30 minutes to trace through the middleware?" If overruled, document your concern.

---

## Related Skills

- **`$superpower-tdd`** — For creating failing test case (Phase 4, Step 1)
- **`$superpower-verification`** — Verify fix worked before claiming success
- **`$superpower-writing-plans`** — For larger remediation plans when architecture is questioned

To invoke related skills: use `activate_skill` with the skill name.

---

## Real-World Impact

From debugging sessions:
- Systematic approach: 15-30 minutes to fix
- Random fixes approach: 2-3 hours of thrashing
- First-time fix rate: 95% vs 40%
- New bugs introduced: Near zero vs common

From condition-based waiting:
- Fixed 15 flaky tests across 3 files
- Pass rate: 60% -> 100%
- Execution time: 40% faster
- No more race conditions

From root cause tracing:
- Found root cause through 5-level trace
- Fixed at source (getter validation)
- Added 4 layers of defense
- 1847 tests passed, zero pollution
