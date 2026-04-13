# Ledger de decisão de compatibilidade — Superpower-Gemini

## Contexto

- **Fonte canônica oficial:** `C:\Users\ferna\.claude\plugins\cache\claude-plugins-official\superpowers\5.0.7`
- **Objetivo de paridade:** identidade estrutural e comportamental máxima com camada de execução Gemini preservada.
- **Estratégia:** manter `superpowers` canônico como padrão de comportamento e expor
  camada de compatibilidade em `gemini-extension.json`, wrappers de bootstrap e aliases de comando.

## Regra 1 — Fronteira de identidade

| Escopo | Regra | Status planejado |
|---|---|---|
| **Canônico puro (CC/CLI)** | `plugin.json` da família de plugins CC, estrutura canônica de `commands/`, `hooks/`, `skills/`, `agents/`, conectores de ambiente | **Preservado no repositório em paralelo ao layer Gemini** |
| **Runtime Gemini** | `gemini-extension.json`, instalação Gemini, `GEMINI.md`, `BRIDGE_SPEC.md`, comandos `superpower-*` de compatibilidade | **Preservado como camada explícita de compatibilidade** |

## Regra 2 — Diferença permitida (intencional)

| Item | Preservado do canônico | Diferença intencional no Gemini |
|---|---|---|
| Comandos canônicos | `brainstorm`, `write-plan`, `execute-plan` | Mantidos como compat wrappers `deprecated` |
| Skills canônicas | 14 skills com nomes canônicos e artefatos associados | Mantido nome canônico + wrappers `superpower-*` para legado |
| Hooks | `hooks.json`, `hooks-cursor.json`, `hooks/session-start` | Mantidos com proteção de fallback e mensagem de não-automação quando indisponível no runtime |
| Testes | `tests/claude-code`, `tests/opencode`, `tests/explicit-skill-requests`, etc. | Incluídos; no runtime Gemini os testes de integração CC permanecem estruturados, com validações estruturais locais para parity |
| Manifestos auxiliares | `.claude-plugin`, `.cursor-plugin`, `.codex`, `.opencode` | Inseridos como camada canônica adicional para descoberta em múltiplos runtimes |
| Conectores Gemini | `gemini-extension.json`, scripts de instalação/desinstalação | Mantidos como camada adaptadora com metadados e contagem explícita de compatibilidade |

## Regra 3 — Invariantes de risco técnico

1. Não remover nenhum caminho canônico esperado pela fonte 5.0.7 sem manter equivalente de compatibilidade mapeado.
2. Não alterar comportamento de entrada de `superpower-*` sem manter fallback para comando/skill canônico.
3. Não alterar semântica de bootstrap de sessão do canônico quando runtime suportado.
4. Toda divergência só pode aparecer em `docs`, `hooks/` (fallback gemini), e `gemini-extension.json`.

## Critérios de aceitação deste lote

- Este documento existir e versionar as regras acima.
- Mapa explícito de preservado x divergente registrado.
- Pipeline de lote possuir estado `PASS/BLOCK` com evidência (sem alterações de produção antes do gate).

## Lote 1 — Manifestos e metadados (status)

- **Critério de aceitação**: concluído.
- **Evidências aplicadas**:
  - `package.json`, `CHANGELOG.md`, `LICENSE`, `CODE_OF_CONDUCT.md`, `RELEASE-NOTES.md`, `CLAUDE.md`, `AGENTS.md` presentes no repositório local.
  - Conectores canônicos (`.claude-plugin`, `.cursor-plugin`, `.codex`, `.opencode`) replicados do canônico.
- **Riscos aceitos (intencionais)**:
  - `gemini-extension.json` continua no formato de compatibilidade e versão de extensão 2.0.0 até o Lote 2, porque ele é o ponto de integração com Gemini CLI.
  - `README.md`, `GEMINI.md` e instaladores atuais já mantêm documentação e fluxos específicos de Gemini; serão harmonizados no Lote 4 sem remover os ajustes compatíveis.

## Lote 2 — Hooks e bootstrap de sessão (status)

- **Critério de aceitação**: concluído.
- **Evidências aplicadas**:
  - `hooks.json` no formato canônico com matcher `startup|clear|compact` e execução via `hooks/run-hook.cmd`.
  - `hooks-cursor.json` com `version: 1` e `sessionStart`.
  - `run-hook.cmd` em formato poliglota canônico.
  - `hooks/session-start` com saída estruturada por plataforma e proteção explícita de compatibilidade Gemini.
- **Risco aceito (intencional)**:
  - O modo Gemini ainda funciona por compatibilidade quando `GEMINI_PLUGIN_ROOT`/`GEMINI_PROJECT_ROOT`/`GEMINI_HOME` está ativo; nesse caso, a saída permanece amigável para execução manual, sem injetar JSON no canal canônico.

## Lote 3 — Compatibilidade de comandos/skills (status)

- **Critério de aceitação**: concluído.
- **Evidências aplicadas**:
  - Comandos canônicos presentes: `commands/brainstorm.md`, `commands/write-plan.md`, `commands/execute-plan.md`.
  - Camada de compatibilidade mantida: `commands/*.toml` (`brainstorm`, `write-plan`, `execute-plan`, `plan`, `superpower-*`).
  - Skills canônicas e de compatibilidade coexistem em `skills/`:
    - Canônicas: `brainstorming`, `dispatching-parallel-agents`, `executing-plans`, `finishing-a-development-branch`, `receiving-code-review`, `requesting-code-review`, `subagent-driven-development`, `systematic-debugging`, `test-driven-development`, `using-git-worktrees`, `using-superpowers`, `verification-before-completion`, `writing-plans`, `writing-skills`.
    - Compatíveis: `superpower-bootstrap`, `superpower-brainstorming`, `superpower-debugging`, `superpower-dispatching-parallel`, `superpower-executing-plans`, `superpower-finish`, `superpower-git-worktrees`, `superpower-receiving-code-review`, `superpower-review`, `superpower-subagents`, `superpower-tdd`, `superpower-verification`, `superpower-writing-plans`, `superpower-writing-skills`.
  - Migração de estrutura executada: diretórios canônicos foram movidos de `skills/skills/*` para `skills/*`, evitando camada extra que quebraria descoberta nativa.
- **Riscos aceitos (intencionais)**:
  - Compatibilidade `superpower-*` permanece como camada de fallback; não há 1:1 estrito de nomes, mas há 1:1 funcional via mapeamentos no `BRIDGE_SPEC.md`.

## Lote 4 — Testes e documentação de operação (status)

- **Critério de aceitação**: concluído.
- **Evidências aplicadas**:
  - Suítes canônicas de teste copiadas para `tests/brainstorm-server`, `tests/claude-code`, `tests/explicit-skill-requests`, `tests/opencode`, `tests/skill-triggering`, `tests/subagent-driven-dev`.
  - Gate de paridade reforçado:
    - `tests/validate-parity.sh`
    - `tests/validate-parity.ps1`
  - Documentação operacional atualizada por runtime:
    - `docs/testing.md`
    - `docs/README.codex.md`
    - `docs/README.opencode.md`
- **Resultado de gate**: `PASS`.
- **Risco aceito (intencional)**:
  - Testes de integração que dependem de runtimes externos (`claude`, `opencode`) ainda são manuais/ambientais; a validação de pacote interno permanece automatizada via `validate-parity`.
