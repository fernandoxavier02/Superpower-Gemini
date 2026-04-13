# Harmonização de Comportamento: clarificação obrigatória e painel de progresso em fluxos de superpowers

> **For agentic workers:** RECOMMENDED SKILL: Use $superpower-executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking via inline YAML blocks.

**Goal:** Implementar um comportamento mais idêntico de execução entre as fases, inserindo clarificação obrigatória com 3 opções (+ alternativa) e um painel de progresso por etapas para as skills de coordenação.

**Architecture:**
Vamos centralizar a lógica de controle de fluxo nos arquivos de skill em `skills/` e manter a execução no Gemini como wrapper sem alterar os mecanismos de automação externos. As fases de fluxo vão seguir uma sequência única: contexto -> clarificação -> plano -> execução por lotes -> revisão -> validação -> fechamento, com rastreamento visual no chat via bloco de status.

**Tech Stack:**
Markdown SKILLs, PowerShell/rg para validação documental, Git para rastreabilidade.

---

### Task 1: Definir contrato de clarificação obrigatória (fase e formato)

**Files:**
- Modify: `skills\superpower-bootstrap\SKILL.md`
- Modify: `skills\superpower-writing-plans\SKILL.md`
- Modify: `skills\superpower-executing-plans\SKILL.md`

- [ ] **Step 1: Adicionar regra global: não avançar sem sanar lacunas explícitas**

No trecho de fluxo de decisão de cada skill, inserir etapa obrigatória "Ambiguidades abertas -> perguntar em 4 opções (3 opções + Outra)".

- Em `skills\superpower-bootstrap\SKILL.md`, abaixo da decisão `Using [skill] to [purpose]`, incluir:
  - "If any ambiguity exists, block execution and ask exactly one structured clarification question with 4 options (3 opções + 1 opção recomendada + 1 opção Outro)."
  - Especificar que a pergunta é obrigatória antes de qualquer passo de plano/executável.

- Em `skills\superpower-writing-plans\SKILL.md`, inserir no início da seção **Process Flow** que o Discovery/Scope check só começa após a pergunta estruturada se houver lacunas.

- Em `skills\superpower-executing-plans\SKILL.md`, inserir uma mini-checklist de pergunta antes de `Step 1`, com texto exato de bloqueio: "No questions -> no execution."

- Run check to verify phrase exists:

```powershell
rg -n "clarification|3 options|other|blocked" skills/superpower-bootstrap/SKILL.md skills/superpower-writing-plans/SKILL.md skills/superpower-executing-plans/SKILL.md
```

Expected output: all 3 arquivos mostrados com as novas ocorrências.

- [ ] **Step 2: Definir template obrigatório de pergunta com 3 sugestões**

Adicionar bloco de padrão em `skills\superpower-writing-plans\SKILL.md`:

```text
Pergunta de clareza:
- [1] Opção recomendada (menor risco)
- [2] Opção alternativa
- [3] Opção alternativa
- [4] Outra (descreva)

Exigir resposta explícita antes de seguir.
```

- Registrar formato equivalente em `skills\superpower-bootstrap\SKILL.md` e `skills\superpower-executing-plans\SKILL.md` para consistência.

- [ ] **Step 3: Validar documentação do formato de resposta**

Run:

```powershell
$patterns = @('Pergunta de clareza', '[1] Opção recomendada', '[4] Outra')
foreach ($p in $patterns) {
  rg -n $p skills/superpower-bootstrap/SKILL.md
  rg -n $p skills/superpower-writing-plans/SKILL.md
  rg -n $p skills/superpower-executing-plans/SKILL.md
}
```

Expected output: cada padrão encontrado nos 3 arquivos-alvo.

### Task 2: Padronizar pergunta clicável com fallback textual

**Files:**
- Modify: `skills\superpower-bootstrap\SKILL.md`
- Modify: `skills\superpower-writing-plans\SKILL.md`

- [ ] **Step 1: Especificar intenção de UI de seleção**

Incluir texto explícito em ambos:

> “Emitir pergunta em formato de escolhas clicáveis quando a interface suportar (4 botões/itens)."

Fallback textual:

> “Se UI clicável não estiver disponível, liste as 4 opções e peça resposta pelo identificador 1-4.”

- [ ] **Step 2: Inserir bloco de transição com exemplo pronto**

Adicionar no `superpower-bootstrap`:

```text
Escopo da execução:
1) Foco mínimo (implementa apenas clarificação + blocagem de risco)
2) Foco padrão (inclui plano, progressão e revisão por lote)
3) Foco amplo (inclui telemetria extra e documentação de decisão)
4) Outra (descreva claramente)
```

- [ ] **Step 3: Validar coerência de linguagem obrigatória**

Run:

```powershell
rg -n "4 opções|4 boto|clic" skills/superpower-bootstrap/SKILL.md skills/superpower-writing-plans/SKILL.md
```

Expected output: pelo menos 3 correspondências por arquivo.

### Task 3: Introduzir painel de progresso por fase em todos os fluxos de plano

**Files:**
- Modify: `skills\superpower-executing-plans\SKILL.md`
- Modify: `skills\superpower-writing-plans\SKILL.md`

- [ ] **Step 1: Padronizar bloco de progresso por etapa (YAML + tabela de status)**

Em `skills\superpower-writing-plans\SKILL.md`, substituir/ajustar exemplo de progresso para incluir:

```yaml
plan_progress:
  phase: planning
  current_step: 1
  steps:
    - id: clarificacao
      status: pending        # pending | in_progress | done | blocked
      output: "Perguntas de ambiguidade"
    - id: design_do_fluxo
      status: pending
      output: "Estrutura do plano"
    - id: execucao_lote
      status: pending
      output: "Execução com validação"
    - id: revisao_adversarial
      status: pending
      output: "Revisão entre lotes"
    - id: fechamento
      status: pending
      output: "Resumo + próximos passos"
```

- [ ] **Step 2: Adicionar checklist de painel obrigatório em execução**

Em `skills\superpower-executing-plans\SKILL.md`, inserir seção:

- Exibir esse painel no início de cada tarefa de lote.
- Atualizar pelo menos 1 campo após cada batch.
- Nunca avançar da fase de execução para revisão final sem `plan_progress.phase` em `fechamento`.

- [ ] **Step 3: Verificar bloco com padrão único**

Run:

```powershell
rg -n "plan_progress|clarificacao|revisao_adversarial|fases" skills/superpower-writing-plans/SKILL.md skills/superpower-executing-plans/SKILL.md
```

Expected output: todas as chaves encontradas com nomes idênticos.

### Task 4: Mapear decisão de clareza e riscos no fechamento

**Files:**
- Modify: `skills\superpower-writing-plans\SKILL.md`
- Modify: `skills\superpower-review\SKILL.md`
- Modify: `skills\superpower-debugging\SKILL.md`

- [ ] **Step 1: Atualizar `superpower-writing-plans` para incluir seção de decisão explícita no fim do plano**

Adicionar obrigatoriedade de incluir:

- `Decisões tomadas`
- `Riscos remanescentes`
- `Pendências para o usuário`
- `Próximo passo recomendado`

- [ ] **Step 2: Garantir consistência em skills de revisão/depuração**

No fechamento de `superpower-review` e `superpower-debugging`, incluir a mesma estrutura de decisão curta para permitir continuidade sem fricção.

- [ ] **Step 3: Validar consistência de headers comuns**

Run:

```powershell
rg -n "Decis\w+ tomadas|Riscos remanescentes|Pr\u00f3ximo passo recomendado|Pend\u00eancias para o usu\u00e1rio" skills/superpower-writing-plans/SKILL.md skills/superpower-review/SKILL.md skills/superpower-debugging/SKILL.md
```

Expected output: correspondências em todos os 3 arquivos.

### Task 5: Criar/atualizar plano de teste comportamental e prova de execução documental

**Files:**
- Add: `docs\superpowers\plans\2026-04-13-behavioral-parity-checklist.md`
- Add: `tests\validate-parity.ps1` (se não existir, validar antes e manter idempotente)
- Modify: `tests\validate-parity.ps1`

- [ ] **Step 1: Criar cenário de teste textual de clarificação**

Adicionar no novo `docs/superpowers/plans/2026-04-13-behavioral-parity-checklist.md`:

- Cenário A: pedido com ambiguidade => pergunta de 4 opções aparece antes do plano.
- Cenário B: pedido sem ambiguidade => fluxo segue sem bloqueio.
- Cenário C: ambiente sem UI clicável => fallback textual com 1-4.

- [ ] **Step 2: Criar script de validação com busca de regras obrigatórias**

No `tests\validate-parity.ps1`, incluir:

```powershell
$requiredChecks = @{
  "skills\\superpower-bootstrap\\SKILL.md" = @(
    'Pergunta de clareza',
    '3 opções',
    'Outra',
    'plan_progress',
    'No questions -> no execution.',
    '4 opções',
    '4 bot'
  )
  "skills\\superpower-writing-plans\\SKILL.md" = @(
    'Pergunta de clareza',
    '3 opções',
    'Outra',
    'plan_progress',
    'No questions -> no execution.'
  )
  "skills\\superpower-executing-plans\\SKILL.md" = @(
    'Pergunta de clareza',
    'No questions -> no execution.',
    'plan_progress'
  )
  "skills\\superpower-review\\SKILL.md" = @(
    'Decisões tomadas',
    'Riscos remanescentes',
    'Pendências para o usuário',
    'Próximo passo recomendado'
  )
  "skills\\superpower-debugging\\SKILL.md" = @(
    'Decisões tomadas',
    'Riscos remanescentes',
    'Pendências para o usuário',
    'Próximo passo recomendado'
  )
}
foreach ($file in $requiredChecks.Keys) {
  if (!(Test-Path $file)) { throw "Arquivo faltando: $file" }
  $content = Get-Content $file -Raw
  foreach ($p in $requiredChecks[$file]) {
    if ($content -notmatch [regex]::Escape($p)) {
      throw "Padrão faltando '$p' em $file"
    }
  }
}
Write-Output 'validate-parity-ok'
```

- Run: `powershell -File tests\validate-parity.ps1`
Expected output: `validate-parity-ok`

- [ ] **Step 3: Executar validação inicial e registrar saída**

```powershell
powershell -File tests\validate-parity.ps1
```

Expected: exit code 0 e mensagem `validate-parity-ok`.

### Task 6: Executar commit de segurança comportamental

**Files:**
- Modify: `docs\superpowers\plans\2026-04-13-harmonizacao-clareacao-e-progresso-superpowers.md` (arquivo recém-criado)

- [ ] **Step 1: Revisão final de plano por gatilhos de falha (sem placeholders)**

Executar checklist:
- ausência de `TODO`, `TBD`, `implementar depois`, `ajustar validações` sem detalhe
- presença de comandos concretos com parâmetros
- passos com código quando necessário

- [ ] **Step 2: Confirmar que cada task tem artefatos de saída esperados**

Cada task deve indicar artefatos e arquivos alterados.

- [ ] **Step 3: Fechamento do plano e commit**

```powershell
$expectedFiles = @(
  "docs/superpowers/plans/2026-04-13-harmonizacao-clareacao-e-progresso-superpowers.md",
  "skills/superpower-bootstrap/SKILL.md",
  "skills/superpower-writing-plans/SKILL.md",
  "skills/superpower-executing-plans/SKILL.md",
  "skills/superpower-review/SKILL.md",
  "skills/superpower-debugging/SKILL.md",
  "tests/validate-parity.ps1",
  "docs/superpowers/plans/2026-04-13-behavioral-parity-checklist.md"
)
$modified = git status --short | ForEach-Object { $_.Substring(3).Trim() }
$unexpected = @($modified | Where-Object { $_ -and ($_ -notin $expectedFiles) })
if ($unexpected.Count -gt 0) {
  Write-Host "[ERROR] Arquivos fora do escopo do plano: $($unexpected -join ', ')"
  exit 1
}

git add @expectedFiles

git status --short

git commit -m "feat(superpowers): add mandatory clarification and progress-board workflow"
```

Expected: commit criado com mensagem acima, somente após confirmar escopo.

---

## Plan Review

**Status:** Approved

**Issues (if any):**
- Nenhuma no momento.

**Recommendations (advisory, do not block approval):**
- Ajustar o texto de opções de clarificação para as habilidades com mais volume de decisões (`superpower-review`, `superpower-debugging`) após os primeiros 3 ciclos de uso.
- Após implementação inicial, registrar 3 exemplos reais de conversa para validar a aparência do painel de progresso no runtime atual.

## Self-Review Check

- [x] Especificação coberta por tarefas no Task 1 a 6.
- [x] Não há placeholders vagos; cada passo tem ação concreta.
- [x] Tipos e nomes de campos consistentes entre tarefas (`plan_progress`, `clarificacao`, `executar`).
- [x] Arquivos alvo foram definidos com caminhos absolutos relativos ao repositório.

## Next skill: `$superpower-executing-plans`


Plan complete and saved to `docs/superpowers/plans/2026-04-13-harmonizacao-clareacao-e-progresso-superpowers.md`.

You can execute with either:

**1. Subagent-Driven (recommended)** - not available in this runtime, so use fallback.

**2. Inline Execution** - Activate `$superpower-executing-plans`.
