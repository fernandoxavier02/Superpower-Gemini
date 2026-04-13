# Behavioral Parity Checklist for Superpowers Flow Controls

## Scenario A: Ambiguous request shows 4-option question before plan
- Input must contain ambiguity in scope, risk, or sequencing.
- Expected behavior:
  - The active execution path must present a single structured question block with exactly 4 options.
  - At least one option is explicitly marked as recommended.
  - One option is `Outra (descreva)`.
  - Execution remains blocked until an explicit option is returned.

## Scenario B: Unambiguous request continues without blocking
- Input with clear scope and explicit task boundaries should skip clarification.
- Expected behavior:
  - No clarification block is shown.
  - Discovery and plan execution flow begins directly.
  - Progress reporting starts in planning phase immediately.

## Scenario C: UI without clickable controls uses textual fallback
- Expected behavior when no clickable UI is available:
  - The same 4 options are listed in text.
  - User is asked to reply with identifier `1`, `2`, `3`, or `4`.
  - Response handling remains deterministic and explicit.

## Validation anchors
- Required textual blocks must exist in:
  - `skills\superpower-bootstrap\SKILL.md`
  - `skills\superpower-writing-plans\SKILL.md`
  - `skills\superpower-executing-plans\SKILL.md`
  - `skills\superpower-review\SKILL.md`
  - `skills\superpower-debugging\SKILL.md`

## Regression checks
- `powershell -File tests\validate-parity.ps1` returns `validate-parity-ok` semantics by including all required keys and files.

## Conversas reais de referência (exemplos)

### Exemplo 1 — Ambiguidade de escopo (bloqueio obrigatório)
- **Input do usuário:** “quero sincronizar o fluxo de revisão e execução, mas não sei quais arquivos impactar”
- **Resposta esperada do assistente:** bloco `Pergunta de clareza` com 4 opções, incluindo “Opção recomendada”, 2 alternativas e “Outra (descreva)”, e resposta bloqueada até o usuário escolher.
- **Sinal de conformidade:** nenhum passo de plano/executável aparece antes da escolha explícita.

### Exemplo 2 — Sem ambiguidade (continuidade imediata)
- **Input do usuário:** “siga com o item 2 do plano e execute apenas o Task 2 do checklist”
- **Resposta esperada do assistente:** sem `Pergunta de clareza`; entra em modo de plano/execução com `plan_progress` iniciando em fase `clarificacao` ou `planning` conforme a skill.
- **Sinal de conformidade:** apresenta trilha de progresso por lote antes das ações.

### Exemplo 3 — UI sem clique (fallback textual)
- **Input do usuário:** “pergunta de clareza apresentada sem botões disponíveis”
- **Resposta esperada do assistente:** repete as mesmas 4 opções como texto e exige retorno com identificador `1`, `2`, `3` ou `4`.
- **Sinal de conformidade:** o mapeamento textual permanece idêntico ao bloco clicável.
