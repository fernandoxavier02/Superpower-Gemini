<div align="center">
  <img src="assets/fx-studio-ai-logo.png" alt="FX Studio AI" width="600"/>
</div>

<h1 align="center">Superpower Gemini</h1>

<p align="center">
  <strong>14 Agentic Development Skills for Google Gemini CLI</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Google%20Gemini%20CLI-4285F4?style=flat-square" alt="Platform"/>
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License"/>
  <img src="https://img.shields.io/badge/language-Python-3776AB?style=flat-square" alt="Language"/>
</p>

## What It Does

Superpower Gemini is a professional port of the Superpowers agentic skills framework to Google Gemini CLI. It brings 14 specialized development skills — from brainstorming and TDD to code review, debugging, and subagent delegation — into Gemini's native ecosystem.

Each skill follows the **1% rule methodology**: focus on one concern at a time, delegate execution via subagents, and produce structured, auditable outputs. The framework transforms Gemini CLI from a general-purpose assistant into a disciplined development partner.

## Features

- **14 Specialized Skills** — Brainstorming, TDD, code review, debugging, plan execution, subagent delegation, git worktrees, and more
- **Subagent Delegation** — Each skill spawns focused subagents for execution, keeping concerns separated
- **1% Rule Methodology** — Structured approach where each step does exactly one thing well
- **Native Gemini Integration** — Skills adapted to work with Gemini CLI's agent architecture and tool system
- **Structured Development Lifecycle** — From ideation through implementation, review, and deployment
- **Git Worktree Support** — Parallel branch development with isolated working directories

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/fernandoxavier02/Superpower-Gemini.git
   ```

2. Navigate to the project directory:
   ```bash
   cd Superpower-Gemini
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Copy or symlink the skills into your `~/.gemini/` directory as described in the project documentation.

## Usage

Invoke any skill through Gemini CLI:

```
# Brainstorm a feature
@brainstorm "Add user authentication to the API"

# Run TDD workflow
@tdd "Implement rate limiting middleware"

# Code review
@review "Check the latest PR for security issues"

# Debug an issue
@debug "API returns 500 on POST /users"
```

Each skill produces structured output with clear next steps, and can delegate subtasks to specialized subagents automatically.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <strong>Built by <a href="https://github.com/fernandoxavier02">Fernando Xavier</a></strong>
  <br/>
  <a href="https://fxstudioai.com">FX Studio AI</a> — Business Automation with AI
</div>
