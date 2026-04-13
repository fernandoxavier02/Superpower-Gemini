param()

$ErrorActionPreference = "Stop"

$root = (Resolve-Path "$PSScriptRoot\..").Path
$expectedCanonicalSkills = 14
$expectedCompatSkills = 14
$expectedCommands = 12

$canonicalSkills = @(
  "brainstorming",
  "dispatching-parallel-agents",
  "executing-plans",
  "finishing-a-development-branch",
  "receiving-code-review",
  "requesting-code-review",
  "subagent-driven-development",
  "systematic-debugging",
  "test-driven-development",
  "using-git-worktrees",
  "using-superpowers",
  "verification-before-completion",
  "writing-plans",
  "writing-skills"
)

$compatSkills = @(
  "superpower-bootstrap",
  "superpower-brainstorming",
  "superpower-debugging",
  "superpower-dispatching-parallel",
  "superpower-executing-plans",
  "superpower-finish",
  "superpower-git-worktrees",
  "superpower-receiving-code-review",
  "superpower-review",
  "superpower-subagents",
  "superpower-tdd",
  "superpower-verification",
  "superpower-writing-plans",
  "superpower-writing-skills"
)

$expectedCommandsList = @(
  "brainstorm.toml",
  "write-plan.toml",
  "execute-plan.toml",
  "plan.toml",
  "superpower-bootstrap.toml",
  "superpower-brainstorming.toml",
  "superpower-debug.toml",
  "superpower-finish.toml",
  "superpower-plan.toml",
  "superpower-review.toml",
  "superpower-tdd.toml",
  "superpower-verify.toml"
)

$requiredBehavioralFiles = @(
  "docs\superpowers\plans\2026-04-13-behavioral-parity-checklist.md",
  "tests\validate-parity.ps1"
)

$requiredBehavioralPatternsByFile = @{
  "skills\superpower-bootstrap\SKILL.md" = @(
    'Pergunta de clareza',
    '3 opções',
    'Outra',
    'plan_progress',
    'No questions -> no execution.',
    '4 opções',
    '4 bot'
  )
  "skills\superpower-writing-plans\SKILL.md" = @(
    'Pergunta de clareza',
    '3 opções',
    'Outra',
    'plan_progress',
    'No questions -> no execution.'
  )
  "skills\superpower-executing-plans\SKILL.md" = @(
    'Pergunta de clareza',
    'No questions -> no execution.',
    'plan_progress'
  )
  "skills\superpower-review\SKILL.md" = @(
    'Decisões tomadas',
    'Riscos remanescentes',
    'Pendências para o usuário',
    'Próximo passo recomendado'
  )
  "skills\superpower-debugging\SKILL.md" = @(
    'Decisões tomadas',
    'Riscos remanescentes',
    'Pendências para o usuário',
    'Próximo passo recomendado'
  )
}

Write-Host "Superpowers parity validation (operational layer)"
Write-Host "Root: $root"
Write-Host ""

$paths = @(
  "gemini-extension.json",
  "GEMINI.md",
  "BRIDGE_SPEC.md",
  "README.md",
  "install.sh",
  "uninstall.sh",
  "agents/code-reviewer.md",
  "hooks/hooks.json",
  "hooks/hooks-cursor.json",
  "hooks/session-start",
  "hooks/run-hook.cmd",
  "tests/README.md",
  "tests/validate-parity.sh",
  "tests/validate-parity.ps1",
  "docs/testing.md",
  "docs/README.codex.md",
  "docs/README.opencode.md",
  "tests/brainstorm-server",
  "tests/claude-code",
  "tests/explicit-skill-requests",
  "tests/opencode",
  "tests/skill-triggering",
  "tests/subagent-driven-dev"
)

$errors = 0
Write-Host "[I] Core artifact checks"
foreach ($relativePath in $paths) {
  $full = Join-Path $root $relativePath
  if (Test-Path $full) {
    Write-Host "  OK  $relativePath"
  } else {
    Write-Host "  FAIL $relativePath"
    $errors++
  }
}

Write-Host ""
$canonicalSkillCount = 0
foreach ($name in $canonicalSkills) {
  $path = Join-Path $root "skills\$name\SKILL.md"
  if (Test-Path $path) {
    $canonicalSkillCount++
  } else {
    Write-Host "[ERROR] Missing canonical skill directory: $name"
    $errors++
  }
}

$compatSkillCount = 0
foreach ($name in $compatSkills) {
  $path = Join-Path $root "skills\$name\SKILL.md"
  if (Test-Path $path) {
    $compatSkillCount++
  } else {
    Write-Host "[ERROR] Missing compatibility skill directory: $name"
    $errors++
  }
}

foreach ($commandFile in $expectedCommandsList) {
  $path = Join-Path $root "commands\$commandFile"
  if (-not (Test-Path $path)) {
    Write-Host "[ERROR] Missing command file: $commandFile"
    $errors++
  }
}

foreach ($behavioralFile in $requiredBehavioralFiles) {
  $behavioralPath = Join-Path $root $behavioralFile
  if (-not (Test-Path $behavioralPath)) {
    Write-Host "[ERROR] Missing behavioral file: $behavioralFile"
    $errors++
  }
}

foreach ($skill in $requiredBehavioralPatternsByFile.Keys) {
  $path = Join-Path $root $skill
  $content = Get-Content $path -Raw
  foreach ($pattern in $requiredBehavioralPatternsByFile[$skill]) {
    if ($content -notmatch $pattern) {
      Write-Host "[ERROR] Missing behavioral pattern '$pattern' in $skill"
      $errors++
    }
  }
}

$commandCount = (Get-ChildItem -Recurse -File -Filter "*.toml" -Path (Join-Path $root "commands") | Measure-Object).Count

Write-Host "[I] Expected counts"
Write-Host "  Canonical skills: $canonicalSkillCount/$expectedCanonicalSkills"
Write-Host "  Compatibility skills: $compatSkillCount/$expectedCompatSkills"
Write-Host "  Commands: $commandCount/$expectedCommands"

if ($canonicalSkillCount -ne $expectedCanonicalSkills) {
  Write-Host "[ERROR] Skill count mismatch"
  $errors++
}

if ($commandCount -ne $expectedCommands) {
  Write-Host "[ERROR] Command count mismatch"
  $errors++
}

if ($compatSkillCount -ne $expectedCompatSkills) {
  Write-Host "[ERROR] Compatibility skill count mismatch"
  $errors++
}

if ($errors -ne 0) {
  Write-Host ""
  Write-Host "[ERROR] Parity check FAILED: $errors issue(s)"
  exit 1
}

Write-Host ""
Write-Host "[OK] Parity check PASSED"
Write-Output "validate-parity-ok"
