Install HERALD into the current project by cloning the herald-of-rivia repository and copying all required files.

Run the following steps:

1. Clone the Herald repo into a temporary directory:
```
git clone https://github.com/brainiac992/herald-of-rivia.git /tmp/herald-install
```

2. Copy all Herald files into the current project:
- `CLAUDE.md` → project root
- `pipeline.md` → project root
- `herald.config.json` → project root
- `agent-registry.json` → project root
- `knowledge-base.json` → project root
- `context.md` → project root
- `domain-library.md` → project root
- `.claude/agent-conventions.md` → `.claude/`
- `.claude/agents/` → `.claude/agents/` (all 19 agent instruction files)
- `.claude/commands/brainstorm.md` → `.claude/commands/`
- `.claude/commands/score.md` → `.claude/commands/`
- `.claude/commands/agents.md` → `.claude/commands/`
- `.claude/hooks/herald-safety.sh` → `.claude/hooks/`
- `.claude/hooks/deployment-audit.sh` → `.claude/hooks/`
- `.claude/settings.json` → `.claude/` (merge with existing if present — do not overwrite existing hooks, only add Herald's PreToolUse Bash hook if not already there)

3. Create a `plans/` directory if it does not exist.

4. Remove the temporary clone at `/tmp/herald-install`.

5. Confirm to the user:
```
HERALD installed successfully.

Files added:
  CLAUDE.md                    — master orchestration spec
  pipeline.md                  — 8-phase pipeline definitions
  herald.config.json           — runtime configuration
  agent-registry.json          — agent lookup table
  knowledge-base.json          — pattern store (empty)
  context.md                   — institutional memory (template)
  domain-library.md            — 24 domain constraint checklists
  .claude/agent-conventions.md — shared agent rules
  .claude/agents/              — 19 agent instruction files
  .claude/commands/            — /brainstorm, /score, /agents
  .claude/hooks/               — safety and deployment audit hooks
  plans/                       — plan file directory (empty)

HERALD is now active in this project.
Restart or start a new Claude Code session to activate.
```
