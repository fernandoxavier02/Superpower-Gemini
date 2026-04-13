<h1 align="center">Superpowers for Gemini CLI</h1>

<p align="center">
  <strong>Disciplined AI-Assisted Development Workflows</strong><br/>
  <em>Ported from <a href="https://github.com/obra/superpowers">obra/superpowers</a> for Claude Code v5.0.7 — fully adapted for Gemini CLI</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Google%20Gemini%20CLI-4285F4?style=flat-square&logo=google&logoColor=white" alt="Platform"/>
  <img src="https://img.shields.io/badge/version-5.0.7-blue?style=flat-square" alt="Version"/>
  <img src="https://img.shields.io/badge/skills-14-blueviolet?style=flat-square" alt="Skills"/>
  <img src="https://img.shields.io/badge/commands-12-orange?style=flat-square" alt="Commands"/>
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License"/>
</p>

---

## What is Superpowers?

Superpowers transforms Gemini CLI from a chat interface into a **rigorous, autonomous, and methodologically sound developer partner**. It provides 14 specialized skills that enforce best practices at every phase of development:

- **Brainstorm** before building
- **Plan** before coding
- **TDD** for implementation
- **Debug** systematically
- **Review** adversarially
- **Verify** with evidence
- **Finish** with discipline

Each skill is a battle-tested protocol — not a simple prompt — that the agent follows to avoid common pitfalls.

## Workflow

```
Bootstrap -> Brainstorm -> Plan -> TDD/Implement -> Review -> Verify -> Finish
    |            |           |          |              |          |         |
 classify    explore     decompose   Red-Green     adversarial  evidence  merge/
  & route    & design    into tasks  Refactor      code review  of done   PR/discard
```

---

## Installation

### Prerequisites

- [Gemini CLI](https://github.com/google-gemini/gemini-cli) installed and configured

### Option 1: Gemini CLI Native (recommended)

```bash
gemini extensions install https://github.com/fernandoxavier02/Superpower-Gemini
```

To update later:

```bash
gemini extensions update superpowers
```

### Option 2: Symlink (for development)

```bash
git clone https://github.com/fernandoxavier02/Superpower-Gemini.git
cd Superpower-Gemini
gemini extensions link .
```

### Option 3: Script

```bash
git clone https://github.com/fernandoxavier02/Superpower-Gemini.git
cd Superpower-Gemini
chmod +x install.sh
./install.sh
```

### Verify

```bash
gemini extensions list                    # Should show "superpowers"
/skills list                              # Should show 14 superpower-* skills
```

Operational parity (hooks/tests/docs):

```bash
bash tests/validate-parity.sh             # Cross-platform
# or
powershell -ExecutionPolicy Bypass -File tests/validate-parity.ps1
```

### Uninstall

```bash
gemini extensions disable superpowers     # Disable
# or
chmod +x uninstall.sh && ./uninstall.sh   # Remove completely
```

---

## Skills Reference

### Phase 0: Bootstrap
| Skill | Description |
|-------|-------------|
| `superpower-bootstrap` | **Entry point** — classifies task, routes to appropriate skill |

### Phase 1: Design
| Skill | Description |
|-------|-------------|
| `superpower-brainstorming` | Explores intent, requirements, and design before implementation |

### Phase 2: Planning
| Skill | Description |
|-------|-------------|
| `superpower-writing-plans` | Creates decision-complete implementation plans with TDD tasks |

### Phase 3: Implementation
| Skill | Description |
|-------|-------------|
| `superpower-executing-plans` | Executes approved plans in controlled batches with checkpoints |
| `superpower-tdd` | Red-Green-Refactor cycle with testing anti-pattern detection |
| `superpower-subagents` | Multi-phase inline implementation with spec + quality review |
| `superpower-dispatching-parallel` | Sequential multi-pass for independent tasks |
| `superpower-git-worktrees` | Isolated feature work via git worktrees |
| `superpower-debugging` | Systematic root cause analysis with 911 lines of methodology |

### Phase 4: Quality
| Skill | Description |
|-------|-------------|
| `superpower-review` | Adversarial code review with severity classification |
| `superpower-receiving-code-review` | Responding to review feedback with technical rigor |

### Phase 5: Completion
| Skill | Description |
|-------|-------------|
| `superpower-verification` | Evidence-based completion verification — run commands, prove success |
| `superpower-finish` | Branch finalization — merge, create PR, keep, or discard |

### Meta
| Skill | Description |
|-------|-------------|
| `superpower-writing-skills` | Creating, testing, and deploying new Gemini CLI skills (1,200 lines) |

---

## Commands

### Core Commands (from original superpowers)
| Command | Action |
|---------|--------|
| `/brainstorm` | Activate brainstorming skill |
| `/write-plan` | Activate writing-plans skill |
| `/execute-plan` | Activate executing-plans skill |
| `/plan` | Alias for write-plan |

### Shortcut Commands
| Command | Skill Activated |
|---------|----------------|
| `/superpower-bootstrap` | `superpower-bootstrap` |
| `/superpower-brainstorming` | `superpower-brainstorming` |
| `/superpower-debug` | `superpower-debugging` |
| `/superpower-finish` | `superpower-finish` |
| `/superpower-plan` | `superpower-writing-plans` |
| `/superpower-review` | `superpower-review` |
| `/superpower-tdd` | `superpower-tdd` |
| `/superpower-verify` | `superpower-verification` |

---

## File Structure

```
superpowers/
    ├── gemini-extension.json              # Extension manifest (v5.0.7)
├── GEMINI.md                          # Context file (auto-loaded at session start)
├── BRIDGE_SPEC.md                     # Claude Code -> Gemini CLI mapping docs
├── agents/
│   └── code-reviewer.md               # Senior Code Reviewer agent
├── commands/                          # 12 slash commands
│   ├── brainstorm.toml
│   ├── write-plan.toml
│   ├── execute-plan.toml
│   ├── plan.toml
│   └── superpower-*.toml              # 8 shortcut commands
├── hooks/                              # Hook compatibility artifacts
│   ├── hooks.json
│   ├── hooks-cursor.json
│   ├── session-start
│   └── run-hook.cmd
├── tests/                              # Operational parity checks
│   ├── README.md
│   ├── validate-parity.sh
│   └── validate-parity.ps1
├── skills/                            # 14 self-contained skills
│   ├── superpower-bootstrap/SKILL.md          (203 lines)
│   ├── superpower-brainstorming/SKILL.md      (497 lines)
│   ├── superpower-debugging/SKILL.md          (911 lines)
│   ├── superpower-dispatching-parallel/SKILL.md (336 lines)
│   ├── superpower-executing-plans/SKILL.md    (196 lines)
│   ├── superpower-finish/SKILL.md             (269 lines)
│   ├── superpower-git-worktrees/SKILL.md      (277 lines)
│   ├── superpower-receiving-code-review/SKILL.md (286 lines)
│   ├── superpower-review/SKILL.md             (338 lines)
│   ├── superpower-subagents/SKILL.md          (551 lines)
│   ├── superpower-tdd/SKILL.md                (707 lines)
│   ├── superpower-verification/SKILL.md       (206 lines)
│   ├── superpower-writing-plans/SKILL.md      (256 lines)
│   └── superpower-writing-skills/SKILL.md     (1,200 lines)
├── install.sh                         # Alternative manual installer
├── uninstall.sh                       # Uninstaller
└── README.md
```

## Operational parity

```bash
gemini extensions install https://github.com/fernandoxavier02/Superpower-Gemini
```

If your Gemini host does not trigger session hooks automatically, run once after startup:

```bash
bash hooks/session-start
```

---

## Key Adaptations from Claude Code

| Claude Code | Gemini CLI | Notes |
|-------------|------------|-------|
| `Skill` tool | `activate_skill` | Skill activation |
| `Task` tool (subagents) | Inline mega-prompts | No subprocess isolation |
| `Bash` | `run_shell_command` | Shell execution |
| `Read/Write/Edit` | `read_file/write_file/edit_file` | File operations |
| `Grep/Glob` | `run_shell_command` with grep/find | Search |
| `TodoWrite` | Inline YAML tracking | Progress tracking |
| `EnterPlanMode` | Sequential read-only analysis | No plan mode in Gemini |
| Parallel subagent dispatch | Sequential multi-pass | Single session |
| 22 auxiliary files | Inlined into SKILL.md | Self-contained skills |

See `BRIDGE_SPEC.md` for the complete mapping.

---

## Credits

- **Original**: [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent
- **Gemini Port**: [Fernando Xavier](https://github.com/fernandoxavier02)

## License

MIT License

---

<div align="center">
  <strong>Built by <a href="https://github.com/fernandoxavier02">Fernando Xavier</a></strong>
  <br/>
  <a href="https://fxstudioai.com">FX Studio AI</a> — Business Automation with AI
</div>
