# Contrato de Compatibilidade Runtime (CC/Cursor/Codex/OpenCode vs Gemini)

## Objetivo

Esta camada existe para permitir que o mesmo repositório rode com comportamento canônico de
Superpowers no ambiente suportado e com adaptação mínima no ambiente Gemini.

## 1) O que é canônico (imutável)

- Estrutura de plugin CC: `commands/`, `skills/`, `agents/`, `hooks/` na forma canônica.
- Conectores de runtime canônico:
  - `.claude-plugin/plugin.json`
  - `.cursor-plugin/plugin.json`
  - `.codex/INSTALL.md` + `~/.agents/skills` bootstrap
  - `.opencode/INSTALL.md` + `.opencode/plugins/superpowers.js`
- Regras de manifesto e testes de integração correspondentes ao 5.0.7.

## 2) O que é Gemini (adaptador)

- `gemini-extension.json` (manifesto de extensão Gemini).
- `GEMINI.md` (contexto carregado por Gemini na sessão).
- `BRIDGE_SPEC.md` (mapeamento declarativo de diferenças).
- Comandos/aliases de compatibilidade (ex.: `superpower-*`) para não romper usuários já acostumados.
- Scripts de instalação/uninstall e validações locais de parity operacional.

## 3) Invariantes de ponte

1. Se runtime suportar hooks canônicos, usar `hooks/session-start` do canônico sem alteração de semântica.
2. No Gemini, quando hook automático não estiver disponível, a execução manual de `hooks/session-start` deve retornar contexto útil e não falhar.
3. Erros de compatibilidade devem falhar em modo silencioso quando o runtime não suporta o recurso (sem quebrar o restante do plugin).

