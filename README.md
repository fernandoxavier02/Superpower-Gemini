<div align="center">
  <img src="assets/fx-studio-ai-logo.png" alt="FX Studio AI" width="600"/>
</div>

<h1 align="center">Superpower Gemini</h1>

<p align="center">
  <strong>14 Agentic Development Skills for Google Gemini CLI</strong><br/>
  <em>Ported from <a href="https://github.com/obra/superpowers">obra/superpowers</a> v5.0.7 (Claude Code) — fully adapted for Gemini's native architecture</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Google%20Gemini%20CLI-4285F4?style=flat-square&logo=google&logoColor=white" alt="Platform"/>
  <img src="https://img.shields.io/badge/skills-14-blueviolet?style=flat-square" alt="Skills"/>
  <img src="https://img.shields.io/badge/agents-1-orange?style=flat-square" alt="Agents"/>
  <img src="https://img.shields.io/badge/commands-3-teal?style=flat-square" alt="Commands"/>
  <img src="https://img.shields.io/badge/lines-6%2C528-informational?style=flat-square" alt="Lines of content"/>
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License"/>
</p>

---

## Overview

Superpower Gemini transforms Google Gemini CLI from a general-purpose assistant into a **disciplined development partner**. It ports all 14 skills from the Claude Code [superpowers](https://github.com/obra/superpowers) plugin — complete with hard gates, anti-patterns, checklists, process flows, and output contracts — into Gemini-native format.

Every auxiliary file (~2,500 lines across 22 files in the original) has been **inlined directly** into each SKILL.md, making every skill fully self-contained. No external references, no broken links.

## Architecture

```
~/.gemini/
├── extensions/superpowers/              # Extension manifest + agent + commands
│   ├── gemini-extension.json            # Extension manifest (v1.0.0)
│   ├── BRIDGE_SPEC.md                   # Canonical CC → Gemini mapping document
│   ├── agents/
│   │   └── code-reviewer.md             # Senior code reviewer agent (100 lines)
│   └── commands/
│       ├── brainstorm.toml              # /brainstorm → activate_skill
│       ├── write-plan.toml              # /write-plan → activate_skill
│       └── execute-plan.toml            # /execute-plan → activate_skill
│
└── skills/                              # 14 self-contained skills
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

## Skills Reference

| # | Skill | Lines | What It Does |
|---|-------|------:|--------------|
| 1 | `superpower-bootstrap` | 203 | Introduction to the skills system — how to discover and invoke skills |
| 2 | `superpower-brainstorming` | 497 | Structured ideation before plan mode — spec document review, visual companion |
| 3 | `superpower-debugging` | 911 | Systematic root-cause tracing with defense-in-depth and test pressure analysis |
| 4 | `superpower-dispatching-parallel` | 336 | Sequential multi-pass execution for independent tasks (adapted from CC parallel agents) |
| 5 | `superpower-executing-plans` | 196 | Step-by-step plan execution with adaptive batching and checkpoints |
| 6 | `superpower-finish` | 269 | Branch completion workflow: merge, PR, keep, or discard with verification gates |
| 7 | `superpower-git-worktrees` | 277 | Parallel branch development with isolated git worktrees |
| 8 | `superpower-receiving-code-review` | 286 | Process and act on received code review feedback systematically |
| 9 | `superpower-review` | 338 | Request code review with structured output and severity classification |
| 10 | `superpower-subagents` | 551 | 5-phase inline workflow: implement → spec review → quality review → final |
| 11 | `superpower-tdd` | 707 | Test-Driven Development with red-green-refactor cycle and anti-pattern detection |
| 12 | `superpower-verification` | 207 | Evidence-before-claims verification — the Iron Law of completion |
| 13 | `superpower-writing-plans` | 256 | Structured plan authoring with plan document review |
| 14 | `superpower-writing-skills` | 1,200 | Meta-skill for creating new skills — Anthropic best practices, persuasion principles |
| | **Total** | **6,233** | |

## Key Adaptations from Claude Code

The port follows a strict tool-mapping protocol documented in [`BRIDGE_SPEC.md`](extensions/superpowers/BRIDGE_SPEC.md):

| Claude Code | Gemini CLI | Notes |
|-------------|------------|-------|
| `Bash` | `run_shell_command` | All shell execution |
| `AskUserQuestion` | `ask_user` | User input/confirmation |
| `Read` / `Write` / `Edit` | `read_file` / `write_file` / `edit_file` | File operations |
| `Grep` / `Glob` | `run_shell_command` with `grep` / `find` | Search operations |
| `Skill` tool | `activate_skill` | Skill invocation |
| `Task` / `Agent` tool | Inline execution | No subagent dispatch in Gemini |
| `TodoWrite` | Inline YAML tracking blocks | Progress tracking |
| `EnterPlanMode` | Sequential read-only analysis | No plan mode in Gemini |

### What's Preserved

- Hard gates and stop conditions
- Anti-pattern tables
- Checklists and verification protocols
- Process flow diagrams
- Output contracts
- Cross-references (`$superpower-{name}` pattern)

### What's Adapted

- Subagent dispatch → inline mega-prompts with "mental model reset" boundaries
- Parallel agent execution → sequential multi-pass with explicit checkpoints
- External auxiliary files → inlined directly into each SKILL.md

## Installation

### Option 1: Symlink (recommended — stays in sync with repo)

```bash
git clone https://github.com/fernandoxavier02/Superpower-Gemini.git
cd Superpower-Gemini

# Extension
ln -s "$(pwd)/extensions/superpowers" ~/.gemini/extensions/superpowers

# Skills (one symlink per skill)
for skill in skills/superpower-*/; do
  ln -s "$(pwd)/$skill" ~/.gemini/skills/$(basename "$skill")
done
```

### Option 2: Copy

```bash
git clone https://github.com/fernandoxavier02/Superpower-Gemini.git
cd Superpower-Gemini

cp -R extensions/superpowers ~/.gemini/extensions/superpowers
cp -R skills/superpower-* ~/.gemini/skills/
```

### Verify Installation

```bash
ls ~/.gemini/extensions/superpowers/gemini-extension.json  # Should exist
ls ~/.gemini/skills/ | grep superpower | wc -l              # Should be 14
```

## Usage

Skills are activated automatically by Gemini CLI when their trigger conditions match, or invoked explicitly:

```bash
# Brainstorm before building
/brainstorm "Design a notification system for mobile and web"

# Write a structured plan
/write-plan "Implement OAuth2 with PKCE flow"

# Execute a plan step by step
/execute-plan "Follow the approved auth implementation plan"
```

Skills also chain naturally — `$superpower-verification` runs before `$superpower-finish`, which references `$superpower-git-worktrees` for cleanup.

## Credits

- **Original Plugin**: [obra/superpowers](https://github.com/obra/superpowers) v5.0.7 by [Jesse Vincent](https://github.com/obra)
- **Gemini Port**: [Fernando Xavier](https://github.com/fernandoxavier02)

## License

MIT License. See [LICENSE](LICENSE) for details.

---

<div align="center">
  <strong>Built by <a href="https://github.com/fernandoxavier02">Fernando Xavier</a></strong>
  <br/>
  <a href="https://fxstudioai.com">FX Studio AI</a> — Business Automation with AI
</div>
