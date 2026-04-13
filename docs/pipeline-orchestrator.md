# Pipeline Orchestrator (Superpower-Gemini)

## Estado de execução

| Lote | Escopo | Status | Evidência | Resultado |
|---|---|---|---|---|
| 0 | Alinhamento + contrato de compatibilidade | DONE | `docs/decision-ledger.md`, `docs/runtime-compatibility-contract.md` | PASS |
| 1 | Manifestos e metadados | DONE | `package.json`, `CHANGELOG.md`, `CODE_OF_CONDUCT.md`, `RELEASE-NOTES.md`, `CLAUDE.md`, `.claude-plugin`, `.cursor-plugin`, `.codex`, `.opencode` | PASS |
| 2 | Hooks e bootstrap sessão | DONE | `hooks/hooks.json`, `hooks/hooks-cursor.json`, `hooks/run-hook.cmd`, `hooks/session-start` | PASS |
| 3 | Compatibilidade de comandos/skills | DONE | `commands/*.md`, `commands/*.toml`, `skills/*` | PASS |
| 4 | Testes e documentação de operação | DONE | `tests/validate-parity.*`, suítes `tests/*`, `docs/testing.md`, `docs/README.codex.md`, `docs/README.opencode.md` | PASS |

## Regras de avanço

- Não avançar com `PASS`/falha de gate.
- Cada lote passa por:
  1. revisão adversarial (segurança/regrão/deriva),
  2. validação estática do lote,
  3. decisão de continuidade.

## Crítica adversarial do Lote 0

- **Risco de regressão de runtime:** baixo. O contrato é só documentação, sem comportamento de execução.
- **Risco de ambiguidade:** baixo-médio. Os mapeamentos foram explicitados por seção e podem ser auditados em `BRIDGE_SPEC.md`.
- **Risco de conflito de nomenclatura:** médio. Documentos podem conflitar com textos já existentes em `GEMINI.md`; será resolvido nos lotes de manifesto.
- **Risco residual de porta em Windows:** baixo. O `validate-parity.sh` depende de bash em ambiente Unix; versão PowerShell cobre o mesmo gate no runtime Windows do usuário.

## Crítica adversarial do Lote 4

- **Risco de falso-positivo no gate:** baixo-médio. O script valida estrutura e artefatos essenciais, mas não executa os cenários de integração de alto custo (`claude`/`opencode` reais). Esse custo fica documentado como gate manual/ambiental em `tests/README.md`.
- **Risco de divergência operacional no Gemini:** baixo. Comandos/skills canônicos e camadas `superpower-*` estão preservados, com roteamento registrado no `BRIDGE_SPEC.md`.
