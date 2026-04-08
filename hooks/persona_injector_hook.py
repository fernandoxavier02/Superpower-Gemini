import sys
import json
import os
import re

# ── Configuration (From agent-context-injector.cjs) ────────────────────────────────

AGENT_SOURCE_MAP = {
    'auditor-senior': {
        'agentFile': '.claude/agents/auditor-senior.md',
        'sections': ['## Responsabilidade', '## Analise'],
        'roleFile': '.kiro/agent-roles/AGENT_AUDITOR_SENIOR.md',
    },
    'redteam': {
        'agentFile': '.claude/agents/redteam.md',
        'sections': ['## Responsabilidade', '## Eixos'],
        'roleFile': '.kiro/agent-roles/AGENT_REDTEAM.md',
    },
}

PERSONA_ROLE_MAP = {
    'IMPLEMENTER': '.kiro/agent-roles/AGENT_IMPLEMENTER.md',
    'BUGFIX_LIGHT': '.kiro/agent-roles/AGENT_BUGFIX_LIGHT.md',
    'BUGFIX_HEAVY': '.kiro/agent-roles/AGENT_BUGFIX_HEAVY.md',
    'USER_STORY_TRANSLATOR': '.kiro/agent-roles/AGENT_USER_STORY_TRANSLATOR.md',
    'AUDITOR': '.kiro/agent-roles/AGENT_AUDITOR.md',
    'ADVERSARIAL': '.kiro/agent-roles/AGENT_ADVERSARIAL.md',
    'AUDITOR_SENIOR': '.kiro/agent-roles/AGENT_AUDITOR_SENIOR.md',
    'REDTEAM': '.kiro/agent-roles/AGENT_REDTEAM.md',
    'PRE_TESTER': '.kiro/agent-roles/AGENT_PRE_TESTER.md',
}

# ── Helper Functions ───────────────────────────────────────────────────────────

def read_file_section(file_path, section_name):
    if not os.path.exists(file_path):
        return ""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            # Basic section extractor
            match = re.search(f"({section_name}.*?)(\n## |$)", content, re.DOTALL | re.IGNORECASE)
            if match:
                return match.group(1).strip()
    except Exception:
        pass
    return ""

def get_agent_context(subagent_type):
    mapping = AGENT_SOURCE_MAP.get(subagent_type)
    if not mapping:
        return ""
        
    parts = []
    if 'agentFile' in mapping:
        for section in mapping.get('sections', []):
            content = read_file_section(mapping['agentFile'], section)
            if content: parts.append(content)
            
    if 'roleFile' in mapping:
        content = read_file_section(mapping['roleFile'], '## Fluxo')
        if content: parts.append(content)
        
    return "\n\n".join(parts)

# ── Main Hook Logic ─────────────────────────────────────────────────────────────

def main():
    try:
        input_data = sys.stdin.read()
        if not input_data:
            return
            
        data = json.loads(input_data)
        tool_name = data.get("tool", "")
        arguments = data.get("arguments", {})
        
        # In Gemini CLI, subagents are tools like 'codebase_investigator', 'generalist'
        # Their input is usually 'objective' or 'request'
        objective = arguments.get("objective", "") or arguments.get("request", "")
        
        context = ""
        source_info = ""
        
        # Case 1: Known subagent type (mapping subagent tools to personas)
        subagent_mapping = {
            'codebase_investigator': 'auditor-senior', # Map deep investigation to senior auditor
            'generalist': None # Will check prompt/objective for persona
        }
        
        target_persona = subagent_mapping.get(tool_name)
        if target_persona and target_persona in AGENT_SOURCE_MAP:
            agent_ctx = get_agent_context(target_persona)
            if agent_ctx:
                context = agent_ctx
                source_info = AGENT_SOURCE_MAP[target_persona]['agentFile']

        # Case 2: Check objective/prompt for persona keywords
        if not context and objective:
            for persona, role_file in PERSONA_ROLE_MAP.items():
                if persona.upper() in objective.upper():
                    role_ctx = read_file_section(role_file, '## Fluxo')
                    if role_ctx:
                        context = role_ctx
                        source_info = role_file
                    break

        response = {"decision": "allow"}
        
        if context:
            # Inject context into the tool arguments or as a system message
            # For BeforeTool, adding 'additionalContext' might influence the agent
            response["additionalContext"] = f"""
## ⚖️ Constituição e Persona (Auto-injetado)
Fonte: {source_info}
Regra: golden-rule.md > authority-map.md > CONSTITUTION.md > AGENT_*.md > PATTERNS.md

{context}
""".strip()
            
        sys.stdout.write(json.dumps(response))
        sys.stdout.flush()
        
    except Exception:
        sys.stdout.write(json.dumps({"decision": "allow"}))
        sys.stdout.flush()

if __name__ == "__main__":
    main()
