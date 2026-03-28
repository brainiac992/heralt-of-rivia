# HERALD
**Universal Agentic Interface Layer**
Human-to-machine translation · Risk-aware · Self-improving · Cross-environment

---

HERALD is a drop-in orchestration layer for Claude Code. It sits between you and every downstream agent — enforcing plan approval, flagging destructive actions, preventing scope creep, managing context, and learning from every execution.

## Why it exists

AI coding agents left to their own devices guess at intent, execute without a plan, modify files they were never asked to touch, and run destructive operations without warning. These aren't theoretical risks — they are documented production failures:

- A developer lost nine days of work when an AI agent interpreted "freeze the code" as permission to delete a production database
- An AWS environment went down for 13 hours after an AI tool decided to "delete and recreate" it
- 45% of developers in Stack Overflow's 2025 survey named "almost right" AI code as their top frustration
- Claude Code GitHub issue #21451 (545 upvotes): agents abort mid-edit when tokens run out, leaving broken codebases
- Developers hit a binary choice: approve every shell command individually, or run with `--dangerously-skip-permissions`

HERALD is the orchestration layer that addresses these failures structurally.

## How it works

Herald has two systems working as one: a **6-layer governance framework** and an **8-phase development pipeline**.

### The 6 Layers (governance — runs on every request)

```
Layer 1  Intent Engine        → What do you want? What domain? What complexity?
Layer 2  Context Harvester    → What do we already know? Tech stack? In-progress plans?
Layer 3  Plan Architect       → SA produces a plan, you approve it
Layer 4  Prompt Synthesizer   → Herald writes scoped briefs for each agent
                                (includes tech stack, languages, project conventions)
Layer 5  Dispatch Router      → Agents execute. Safety gates fire here.
Layer 6  Feedback Loop        → SA scores the outcome, updates context store
```

### The 8 Phases (pipeline — runs inside Layer 5 when triggered)

```
Phase 1  Planning        PM → BA → PO → PM Summary → Architect    [ALWAYS]
Phase 2  Design          UI-Designer + Content-Writer               [if UI changes]
Phase 3  Development     DB-Agent → Backend → Frontend              [as needed]
Phase 4  Testing         UI-Tester + QA-Happy + QA-Breaker + Security  [after Phase 3]
Phase 5  Data Review     Data-Agent                                 [if schema changes]
Phase 6  Marketing       Marketing-Agent + Content-Auditor          [if customer-facing]
Phase 7  Documentation   DOC-Agent → Commit                        [ALWAYS]
Phase 8  Post-Release    Post-Release-Agent                         [after deploy]
```

**Not all phases run.** The Architect (end of Phase 1) declares what the feature touches, and Herald activates only the relevant phases. Minimum: Phase 1 + 7. Maximum: all 8.

### Domain-agnostic agents

All 19 pipeline agents define **roles and workflows**, not tech stacks. Project-specific context (frameworks, languages, deployment platform, supported locales) is captured by the PM interview and detected by Layer 2 from the codebase, then passed to agents via Layer 4 briefs. This makes Herald portable across any project.

### User stories and acceptance criteria

The PO (Product Owner) agent converts the SRS into user stories with testable acceptance criteria, stored as a JSON checklist:

1. **PO writes stories** — each criterion marked `auto` (code-testable) or `human` (needs user eyes)
2. **QA agents verify** — Phase 4 agents verify `auto` criteria and update the checklist
3. **Users verify** — `human` criteria are flagged for user confirmation
4. A story is `passed` only when ALL its criteria are `passed`

## Safety & quality gates

| Gate | What it does |
|---|---|
| **Risk Gate** | Pauses before destructive ops. Surfaces what could be lost. Silence = safe default. |
| **Destructive Pattern Scan** | Greps generated files for DROP/TRUNCATE/rm -rf before execution |
| **Test-First Gate** | Forces test → code → test sequence on code tasks |
| **Human Verification Gate** | User confirms UI/visual output before proceeding |
| **Context Checkpoint** | Auto-saves state at 75% context usage |
| **Anti-Sycophancy** | Every plan must include a genuine challenge |

## Commands

| Command | What it does |
|---|---|
| `/fast [request]` | Skips discovery — jumps to planning. Plan approval still required. |
| `/brainstorm [topic]` | Structured thinking: Critique → Design → Benchmark → Recommend. No dispatch. |
| `/score` | Manually triggers Layer 6 if missed. Runs scoring against last completed plan. |
| `/agents` | Lists all registered agents with phase and status. Shows active plan progress. |

## Quickstart

**Option A — Use HERALD as your project starter:**

```bash
git clone https://github.com/brainiac992/herald-of-rivia.git my-project
cd my-project
# Open in Claude Code — HERALD is already active
```

**Option B — Add HERALD to an existing project:**

```bash
git clone https://github.com/brainiac992/herald-of-rivia.git herald-tmp

cp herald-tmp/CLAUDE.md your-project/CLAUDE.md
cp herald-tmp/herald.config.json your-project/herald.config.json
cp herald-tmp/agent-registry.json your-project/agent-registry.json
cp herald-tmp/knowledge-base.json your-project/knowledge-base.json
cp herald-tmp/context.md your-project/context.md
cp herald-tmp/pipeline.md your-project/pipeline.md
cp herald-tmp/domain-library.md your-project/domain-library.md
cp -r herald-tmp/.claude your-project/.claude
mkdir -p your-project/plans
```

Open in Claude Code. HERALD activates on the next request. The PM will interview you about your tech stack and supported languages before any implementation begins.

**Option C — Install from within Claude Code:**

```
/install-herald
```

## Files

| File | Purpose |
|---|---|
| `CLAUDE.md` | Master spec — layers, gates, rules, pipeline integration |
| `pipeline.md` | Pipeline orchestration — phases, triggers, selection table |
| `herald.config.json` | Runtime config — fast-track, token budget, pipeline phases |
| `agent-registry.json` | Agent lookup table (id + status + phase) |
| `knowledge-base.json` | Patterns from scored executions (grows over time) |
| `context.md` | Institutional memory — decisions, constraints, failed approaches |
| `domain-library.md` | 24 domain constraint checklists for Layer 1 |
| `.claude/agent-conventions.md` | Shared agent rules — severity scale, doc paths, completion format |
| `.claude/agents/` | 19 agent instruction files (one per pipeline role) |
| `.claude/commands/` | Slash commands — `/agents`, `/brainstorm`, `/score`, `/install-herald` |
| `.claude/hooks/` | Safety hooks — blocks `rm -rf` and `DROP DATABASE` at tool level |
| `plans/` | Persistent plan files (created at runtime) |
| `docs/` | Pipeline output organized per feature (created at runtime) |
| `examples/` | Sample handoff, plan, and pattern files |
| `export/herald.html` | Visual presentation (open in browser) |

## Agents (21 total)

**Core (2):** SA (planning + scoring), Agent Builder (creates new agents)

**Pipeline (19):**

| Phase | Agents |
|---|---|
| 1 — Planning | PM, BA, PO, Architect |
| 2 — Design | UI-Designer, Content-Writer |
| 3 — Development | DB-Agent, Backend-Agent, Frontend-Agent |
| 4 — Testing | UI-Tester, QA-Happy, QA-Breaker, Security-Agent |
| 5 — Data Review | Data-Agent |
| 6 — Marketing | Marketing-Agent, Content-Auditor |
| 7 — Documentation | DOC-Agent |
| 8 — Post-Release | Post-Release-Agent |
| Standalone | DevOps-Agent |

## Core rules

- HERALD is the sole orchestrator — no agent-to-agent communication
- Every agent has one defined scope and does not exceed it
- No agent receives raw user input — all input is translated by HERALD
- Nothing executes without the user approving a plan first
- Destructive tasks are flagged at plan approval, not at execution
- Silence is safe — no stated preference means safe default, always
- Layer 6 is mandatory — no execution closes without scoring
- Patterns are only stored when composite score >= 95%

## Architectural limits

HERALD is an instruction layer. Its gates are behavioral commitments of the same model that executes the work. Under context pressure, long sessions, or user bypass, the model may skip enforcement.

**Reliable:** Human-in-the-loop gates (plan approval, Risk Gate) — require explicit user confirmation. Plan files and `context.md` create recoverable state. `/score` recovers missed Layer 6.

**Hook-enforced:** `.claude/hooks/herald-safety.sh` blocks `rm -rf` and `DROP DATABASE/SCHEMA` at the Bash tool level, regardless of model state.

**Model-enforced:** Test-First Gate, Destructive Pattern Scan, Context Checkpoint, anti-sycophancy. These depend on model compliance and may degrade under pressure.

The system is as strong as the user's willingness to hold the gates.

## Contributing

Pull requests are welcome. If you have a pattern that worked well, consider contributing it to `examples/`.

1. Fork the repo
2. Create a branch: `git checkout -b feature/your-improvement`
3. Commit your changes
4. Open a pull request

## License

MIT — see [LICENSE](LICENSE).

---

Built on real failure patterns. Designed to prevent the next one.
