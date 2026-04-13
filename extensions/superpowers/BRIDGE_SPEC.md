# BRIDGE_SPEC: Claude Code → Gemini CLI Superpowers

> Mapeamento canônico entre a fonte (CC plugin) e o port (Gemini extension).
> Atualizado: 2026-04-12 | CC superpowers v5.0.7 | Gemini superpowers v1.0.0

## Architecture Differences

| Aspecto | Claude Code (CC) | Gemini CLI |
|---------|-------------------|------------|
| Plugin system | plugin.json + skills/ + agents/ + commands/ | gemini-extension.json + agents/ + commands/ |
| Skill location | Plugin-scoped `skills/` dir | Global `~/.gemini/skills/superpower-{name}/` |
| Skill activation | `Skill` tool | `activate_skill` |
| Agent dispatch | `Task` tool (subagents) | Inline mega-prompts (no subagents) |
| Tool: shell | `Bash` | `run_shell_command` |
| Tool: user input | `AskUserQuestion` | `ask_user` |
| Tool: files | `Read/Write/Edit` | `read_file/write_file/edit_file` |
| Tool: search | `Grep/Glob` | `run_shell_command` with grep/find |
| Tool: tasks | `TodoWrite` | Inline YAML tracking blocks |
| Auxiliary files | Separate .md files referenced by skills | Inlined directly into SKILL.md |
| Cross-references | `$superpower-{name}` (both platforms) | `$superpower-{name}` (preserved) |

## Skill Mapping (14 skills)

| # | Gemini Skill | CC Source Skill | CC Lines | Gemini Lines | Aux Files Inlined |
|---|-------------|-----------------|----------|-------------|-------------------|
| 1 | superpower-brainstorming | brainstorming | 164 | 497 | spec-document-reviewer-prompt.md, visual-companion.md |
| 2 | superpower-debugging | systematic-debugging | 296 | 911 | root-cause-tracing.md, defense-in-depth.md, condition-based-waiting.md, 3 test-pressure files |
| 3 | superpower-executing-plans | executing-plans | 70 | 196 | (none) |
| 4 | superpower-finish | finishing-a-development-branch | 200 | 268 | (none) |
| 5 | superpower-review | requesting-code-review | 105 | 338 | code-reviewer.md |
| 6 | superpower-subagents | subagent-driven-development | 277 | 551 | implementer-prompt.md, spec-reviewer-prompt.md, code-quality-reviewer-prompt.md |
| 7 | superpower-tdd | test-driven-development | 371 | 707 | testing-anti-patterns.md |
| 8 | superpower-verification | verification-before-completion | 139 | 207 | (none) |
| 9 | superpower-writing-plans | writing-plans | 152 | 256 | plan-document-reviewer-prompt.md |
| 10 | superpower-bootstrap | using-superpowers | 117 | 203 | references/gemini-tools.md |
| 11 | superpower-dispatching-parallel | dispatching-parallel-agents | 182 | 336 | (none — restructured to sequential) |
| 12 | superpower-receiving-code-review | receiving-code-review | 213 | 286 | (none) |
| 13 | superpower-git-worktrees | using-git-worktrees | 218 | 277 | (none) |
| 14 | superpower-writing-skills | writing-skills | 655 | 1200 | anthropic-best-practices.md, persuasion-principles.md, testing-skills-with-subagents.md, graphviz-conventions.dot, CLAUDE_MD_TESTING.md |

**Totals:** CC ~3,159 lines (skills only) + ~2,500 lines (aux files) → Gemini 6,233 lines (all inlined)

## Agent Mapping (1 agent)

| # | Gemini Agent | CC Source | CC Lines | Gemini Lines |
|---|-------------|-----------|----------|-------------|
| 1 | code-reviewer | agents/code-reviewer.md | 48 | ~100 |

**Note:** CC's code-reviewer is a thin 48-line agent definition with inline system prompt. Gemini's version expands this into a mega-prompt with explicit review process steps, output format template, and tool reference table.

## Command Mapping (3 commands)

| # | Gemini Command | CC Command | Status |
|---|---------------|------------|--------|
| 1 | /brainstorm | /brainstorm | Redirects to skill (deprecated in CC too) |
| 2 | /write-plan | /write-plan | Redirects to skill (deprecated in CC too) |
| 3 | /execute-plan | /execute-plan | Redirects to skill (deprecated in CC too) |

## Not Ported — CC-Specific Concepts

| CC Feature | Reason Not Ported |
|-----------|-------------------|
| `EnterPlanMode/ExitPlanMode` | Gemini has no plan mode — replaced with "sequential read-only analysis" descriptions |
| Parallel subagent dispatch | Gemini is single-session — `superpower-dispatching-parallel` restructured as sequential multi-pass |
| Subagent isolation boundaries | Replaced with "mental model reset" between inline phases in `superpower-subagents` |
| Git worktree `--worktree` flag | Gemini has no isolation flag — preserved manual worktree creation commands |

## File Structure

```
CC Plugin (superpowers/5.0.7/)
├── skills/
│   ├── brainstorming/SKILL.md + 2 aux
│   ├── systematic-debugging/SKILL.md + 6 aux
│   ├── executing-plans/SKILL.md
│   ├── finishing-a-development-branch/SKILL.md
│   ├── requesting-code-review/SKILL.md + 1 aux
│   ├── subagent-driven-development/SKILL.md + 3 aux
│   ├── test-driven-development/SKILL.md + 1 aux
│   ├── verification-before-completion/SKILL.md
│   ├── writing-plans/SKILL.md + 1 aux
│   ├── using-superpowers/SKILL.md + 1 ref
│   ├── dispatching-parallel-agents/SKILL.md
│   ├── receiving-code-review/SKILL.md
│   ├── using-git-worktrees/SKILL.md
│   └── writing-skills/SKILL.md + 5 aux
├── agents/
│   └── code-reviewer.md
├── commands/
│   ├── brainstorm.md
│   ├── write-plan.md
│   └── execute-plan.md
└── plugin.json

Gemini Extension (~/.gemini/extensions/superpowers/)
├── agents/
│   └── code-reviewer.md
├── commands/
│   ├── brainstorm.toml
│   ├── write-plan.toml
│   └── execute-plan.toml
├── gemini-extension.json
└── BRIDGE_SPEC.md              (this file)

Gemini Skills (~/.gemini/skills/)
├── superpower-bootstrap/SKILL.md
├── superpower-brainstorming/SKILL.md
├── superpower-debugging/SKILL.md
├── superpower-dispatching-parallel/SKILL.md
├── superpower-executing-plans/SKILL.md
├── superpower-finish/SKILL.md
├── superpower-git-worktrees/SKILL.md
├── superpower-receiving-code-review/SKILL.md
├── superpower-review/SKILL.md
├── superpower-subagents/SKILL.md
├── superpower-tdd/SKILL.md
├── superpower-verification/SKILL.md
├── superpower-writing-plans/SKILL.md
└── superpower-writing-skills/SKILL.md
```

## Key Adaptation Decisions

### 1. Auxiliary File Inlining
All CC auxiliary files (~2,500 lines across 22 files) were inlined directly into their parent SKILL.md. This is required because Gemini skills cannot reference external files — each SKILL.md must be self-contained.

### 2. Subagent → Sequential Inline
CC's `Task` tool dispatches isolated subagents with fresh context. Gemini has no equivalent. Two strategies were applied:
- **superpower-subagents**: 5-phase inline workflow with "mental model reset" between phases (Implementer → Spec Review → Quality Review → Final Review)
- **superpower-dispatching-parallel**: Restructured as sequential multi-pass with explicit checkpoints and context isolation boundaries

### 3. TodoWrite → Inline YAML
CC's `TodoWrite` tool manages persistent task state. Gemini replaces this with inline YAML tracking blocks in the response, which the LLM updates as it progresses.

### 4. Tool Name Translation
All 14 skills maintain a tool reference table at the bottom mapping CC tools to Gemini equivalents, ensuring consistency and discoverability.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-04-12 | Full port: 14 skills, 1 agent, 3 commands from CC superpowers v5.0.7 |
