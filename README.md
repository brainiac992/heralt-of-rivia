# HERALT

**Universal Agentic Interface Layer**
Human-to-machine translation · Self-improving · Cross-environment

---

HERALT is a drop-in orchestration layer for Claude Code. It sits between you and every downstream agent — running discovery, managing planning, controlling the agent lifecycle, and learning from every execution.

Every agent has a single defined scope. All communication routes through HERALT. No agent talks to another agent directly.

## Why it exists

Without an orchestration layer, AI coding agents receive unstructured input, guess at intent, and execute without a plan. This produces inconsistent results, scope creep, wasted tokens, and repeated failures on the same class of problem.

HERALT fixes this with a six-layer pipeline and a hub-and-spoke agent architecture.

## Architecture

```
User
  ↕
HERALT (orchestrator — sole cross-system authority)
  ↕         ↕              ↕
 SA    Agent Builder   Task Agents
```

| Agent | Scope |
|---|---|
| **SA** | Validate specs, plan execution, classify agents needed, score outcomes |
| **Agent Builder** | Build new agents to spec — purpose, scope, spawn type, instructions |
| **Task agents** | Execute one defined task. Nothing else. |

Agents are either **dominant** (persistent across the project) or **temporal** (spawned for one task, discarded after). HERALT manages both.

## The pipeline

1. **Intent Engine** — full BA-style discovery session across intent, scope, constraints, stack, format, timeline, dependencies, and risk
2. **Context Harvester** — load only what's relevant to the task
3. **Plan Architect** — SA analyzes project structure, checks the agent registry, produces viable plans; user selects one before anything executes
4. **Prompt Synthesizer** — HERALT writes scoped briefs for each agent
5. **Dispatch Router** — HERALT checks for missing agents, dispatches Agent Builder if needed, then executes the plan
6. **Feedback Loop** — SA scores the outcome (spec compliance, scope adherence, correctness, efficiency); ≥ 95% composite stores the pattern

## Quickstart

**Option A — Use HERALT as your project starter:**

```bash
git clone https://github.com/brainiac992/heralt-of-rivia.git my-project
cd my-project
# Open in Claude Code — HERALT is already active
```

**Option B — Add HERALT to an existing project:**

```bash
git clone https://github.com/brainiac992/heralt-of-rivia.git heralt-of-rivia

cp heralt-of-rivia/CLAUDE.md your-project/CLAUDE.md
cp heralt-of-rivia/knowledge-base.json your-project/knowledge-base.json
cp heralt-of-rivia/agent-registry.json your-project/agent-registry.json
cp heralt-of-rivia/heralt.config.json your-project/heralt.config.json
mkdir your-project/plans
```

Open in Claude Code. HERALT activates on the next request.

## Files

| File | Purpose |
|---|---|
| `CLAUDE.md` | Drop-in activation file — the full HERALT spec |
| `agent-registry.json` | Registry of all dominant agents, their scope and status |
| `knowledge-base.json` | Patterns from successful executions (grows over time) |
| `examples/handoff-example.md` | Sample HERALT handoff document |
| `examples/pattern-example.json` | Sample knowledge base entry |
| `examples/plan-example.json` | Sample plan file with live checklist |
| `export/heralt.html` | Full visual presentation (open in browser) |
| `export/heralt.pdf` | Presentation PDF for sharing |
| `plans/` | Created at runtime — HERALT writes approved plans here |

## Rules

- HERALT is the sole orchestrator — no agent-to-agent communication
- Every agent has one defined scope and does not exceed it
- No agent receives raw user input — all input is translated by HERALT
- Nothing executes without the user approving a plan first
- Patterns are only stored when composite score ≥ 95%

## Contributing

Pull requests are welcome. If you have a pattern that worked well, consider contributing it to `examples/`.

1. Fork the repo
2. Create a branch: `git checkout -b feature/your-improvement`
3. Commit your changes
4. Open a pull request

## License

MIT — see [LICENSE](LICENSE).

---

Built to make AI coding accessible to everyone.
