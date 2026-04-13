---
name: superpower-bootstrap
description: Use when starting any conversation - establishes how to find and use skills, requiring activate_skill invocation before ANY response including clarifying questions. Adapted from Claude Code superpowers v5.0.7 for Gemini CLI.
---

> **Adapted from Claude Code superpowers v5.0.7 for Gemini CLI.**
> All tool references use Gemini CLI native tools. No CC dependencies remain.

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction Priority

Superpowers skills override default system prompt behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (GEMINI.md, CLAUDE.md, AGENTS.md, direct requests) — highest priority
2. **Superpowers skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

If GEMINI.md or AGENTS.md says "don't use TDD" and a skill says "always use TDD," follow the user's instructions. The user is in control.

## How to Access Skills

**In Gemini CLI:** Skills activate via the `activate_skill` tool. Gemini loads skill metadata at session start and activates the full content on demand.

When you invoke a skill via `activate_skill`, its content is loaded and presented to you — follow it directly. Never use `read_file` on skill files.

## Gemini CLI Tool Reference

Skills may reference Claude Code tool names. Use this mapping table for all Gemini CLI equivalents:

| Skill references (CC name) | Gemini CLI equivalent |
|---|---|
| `Read` (file reading) | `read_file` |
| `Write` (file creation) | `write_file` |
| `Edit` (file editing) | `replace` |
| `Bash` (run commands) | `run_shell_command` |
| `Grep` (search file content) | `grep_search` |
| `Glob` (search files by name) | `glob` |
| `TodoWrite` (task tracking) | Inline YAML tracking blocks (see below) |
| `Skill` tool (invoke a skill) | `activate_skill` |
| `WebSearch` | `google_web_search` |
| `WebFetch` | `web_fetch` |
| `Task` tool (dispatch subagent) | **No equivalent** — execute inline or use `$superpower-executing-plans` |
| `AskUserQuestion` | `ask_user` |

### Additional Gemini CLI tools (no CC equivalent)

| Tool | Purpose |
|---|---|
| `list_directory` | List files and subdirectories |
| `save_memory` | Persist facts to GEMINI.md across sessions |
| `ask_user` | Request structured input from the user |
| `tracker_create_task` | Rich task management (create, update, list, visualize) |
| `enter_plan_mode` / `exit_plan_mode` | Switch to read-only research mode before making changes |

### No subagent support

Gemini CLI has no equivalent to Claude Code's `Task` tool. Skills that rely on subagent dispatch (`subagent-driven-development`, `dispatching-parallel-agents`) will fall back to single-session execution via `$superpower-executing-plans`.

### TodoWrite replacement

Where CC skills reference `TodoWrite`, use inline YAML tracking blocks in your response:

```yaml
# Task Tracker
- id: 1
  task: "Description"
  status: pending  # pending | in_progress | done | blocked
- id: 2
  task: "Description"
  status: in_progress
```

Update the block as you complete items. For richer tracking, use `tracker_create_task`.

---

# Using Skills

## The Rule

**Invoke relevant or requested skills BEFORE any response or action.** Even a 1% chance a skill might apply means you should invoke the skill to check. If an invoked skill turns out to be wrong for the situation, you don't need to use it.

```
User message received
       │
       ▼
About to enter plan mode? ──yes──▶ Already brainstormed?
       │                                  │         │
       │                                 yes        no
       │                                  │         │
       │                                  │    Invoke brainstorming skill
       │                                  │         │
       │                                  ◀─────────┘
       │                                  │
       ▼                                  ▼
Might any skill apply? ◀─────────────────┘
       │           │
      yes         definitely not
  (even 1%)        │
       │           ▼
       ▼      Respond (including
  activate_skill   clarifications)
       │
       ▼
  Announce: "Using [skill] to [purpose]"
       │
       ▼
  Any ambiguity that changes scope, risk, or execution?
       │                         │
      yes                        no
       │                         │
       ▼                         ▼
  Block execution          Has checklist? ──yes──▶ Create YAML tracker per item
  Ask exactly one               │                         │
  structured clarification      no                        │
  question and wait             │                         │
  for explicit answer           ▼                         ▼
       │                  Follow skill exactly ◀────────┘
       └───────────────────────────────────────▶
```

## Mandatory Clarification Gate

If any ambiguity exists that materially affects scope, risk, routing, or execution, block execution before any planning step, file read, code change, or executable action.

Ask exactly one structured clarification question at a time. Offer exactly 4 options: 3 opções, with one option explicitly marked as recommended, plus one `Outra` option.

No questions -> no execution.

Use this exact template in every applicable skill handoff:

```text
Pergunta de clareza:
- [1] Opção recomendada (recomendada)
- [2] Opção alternativa
- [3] Opção alternativa
- [4] Outra (descreva)

Se a interface suportar, emita isso como 4 opções clicáveis (4 botões/4 itens).
Se a UI clicável não estiver disponível, liste as mesmas 4 opções e peça a resposta pelo identificador 1-4.
Exigir resposta explícita antes de seguir.

Escopo da execução:
1) Foco mínimo (implementa apenas clarificação + blocagem de risco)
2) Foco padrão (inclui plano, progressão e revisão por lote)
3) Foco amplo (inclui telemetria extra e documentação de decisão)
4) Outra (descreva claramente)

Seção de bloqueio:
- If any ambiguity exists, block execution and ask exactly one structured clarification question with 4 options (3 propostas + 1 recomendada + 1 opção outro).
- No planning or execution step starts until the answer is received.
- If ambiguity remains after response, repeat this block.

### Clickable / Textual Fallback

- If the UI supports clickable choices, render the four options as interactive buttons/items.
- If clickable UI is unavailable, list the four options and require identifiers `1`, `2`, `3`, or `4` as textual reply.
```

## Progress Board

Use this exact structure before starting any multi-step execution batch:

```yaml
plan_progress:
  phase: clarification
  current_step: 1
  steps:
    - id: clarificacao
      status: in_progress
      output: "Perguntas de ambiguidade"
    - id: design_do_fluxo
      status: pending
      output: "Estrutura do fluxo"
    - id: execucao_lote
      status: pending
      output: "Execução por lote"
    - id: revisao_adversarial
      status: pending
      output: "Revisão adversarial"
    - id: fechamento
      status: pending
      output: "Resumo + próximos passos"
```

Do not continue until the user selects one option. If the answer resolves the ambiguity, proceed. If a different ambiguity remains, ask the next single structured clarification question before moving on.

## Red Flags

These thoughts mean STOP — you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept ≠ using the skill. Invoke it. |

## Skill Priority

When multiple skills could apply, use this order:

1. **Process skills first** (brainstorming, debugging) — these determine HOW to approach the task
2. **Implementation skills second** (frontend-design, mcp-builder) — these guide execution

"Let's build X" → brainstorming first, then implementation skills.
"Fix this bug" → debugging first, then domain-specific skills.

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.

**Flexible** (patterns): Adapt principles to context.

The skill itself tells you which.

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.

---

## Skill Routing Table

When you need to route to a specific skill, use `activate_skill` with the appropriate name:

| Signal | Route to |
|---|---|
| New idea, vague request, behavior change, or feature design | `$superpower-brainstorming` |
| Bug, failing test, build break, performance issue, or unexpected behavior | `$superpower-debugging` |
| Approved design or clear requirements with multiple implementation steps | `$superpower-writing-plans` |
| Approved written plan that should be executed in batches | `$superpower-executing-plans` |
| Approved written plan with mostly independent tasks and agent support available | `$superpower-subagents` (falls back to `$superpower-executing-plans` in Gemini) |
| Active implementation of a feature or bugfix | `$superpower-tdd` |
| Meaningful change ready for review or feedback processing | `$superpower-review` |
| About to claim "done", "fixed", "passing", or "ready" | `$superpower-verification` |
| Work fully verified and ready for branch or delivery decision | `$superpower-finish` |

### Routing guardrails

- Prefer process skills before implementation skills.
- Do not start coding when the task still needs design, root-cause analysis, or a written plan.
- Do not guess through ambiguity that changes architecture, risk, or scope.
- If any ambiguity exists, use the mandatory clarification gate above before proceeding. Suggest clickable UI choices when available; otherwise require a textual reply with `1`, `2`, `3`, or `4`.
- For trivial factual answers or one-step read-only tasks, answer directly and skip the family.

## Output Contract

After routing, return with four items:

- `Decision:` the chosen route
- `Why:` the evidence that led to the route
- `Next skill:` the exact `$skill-name`
- `Blockers:` only if a question must be answered before the handoff

Then invoke `activate_skill` for the chosen skill.
