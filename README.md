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

## What HERALD solves

| Documented issue | Source | HERALD's fix |
|---|---|---|
| Weak plan mode — no persistence, no control | HN thread, 591 comments | Persistent JSON plan files, user-approved before any execution |
| Binary permission model — all or nothing | Repeated pattern across HN + GitHub | Risk Gate with `safe / caution / destructive` classification per task |
| Token bloat from over-broad context | Multiple independent workarounds built | Layer 4 scopes context to each agent only — nothing extra |
| Transparency removed — "Read 3 files" tells you nothing | HN #4 ranking, 702 comments | Full output captured per checklist item — complete record of every action |
| Code quality drift and over-engineered solutions | CodeRabbit: 1.7× more issues in AI PRs | Acceptance criteria defined before code is written; dependency review flags bloat |
| Sycophancy — "You're absolutely right!" on everything | GitHub #3382, 874 upvotes | Every plan must include a genuine challenge; agreement is never the default |
| Context rot — output degrades as sessions grow | Near-universal among heavy users | Proactive checkpoint at 75% context — SA summarizes state, clears noise, continues cleanly |
| Destructive actions without warning | Production incidents at AWS, Replit, others | Risk Gate + Destructive Pattern Scan fires before any irreversible operation |

## The pipeline

```
1. Intent Engine      — domain detection, discovery, complexity classification
2. Context Harvester  — load only what's relevant; resume in-progress plans
3. Plan Architect     — SA produces plans with token estimates and genuine challenges; user selects one
4. Prompt Synthesizer — scoped briefs per agent; no raw input passthrough
5. Dispatch Router    — Risk Gate, Destructive Pattern Scan, Context Checkpoint, token tracking
6. Feedback Loop      — mandatory scoring; SA updates context store; patterns stored at ≥ 95%
```

## Safety & quality gates

**Risk Gate** — before any `destructive` task executes, HERALD surfaces what could be lost, the safe default, and the risky alternative. Silence always takes the safe default.

**Destructive Pattern Scan** — after an agent generates artifacts (SQL, migrations, shell scripts), HERALD scans for `DROP TABLE`, `TRUNCATE`, `DELETE FROM` without `WHERE`, `rm -rf`, and similar patterns before execution. Catches cases where the task description looked safe but the generated code isn't.

**Test-First Gate** — for every logic or API task: `test_writer → code_agent → test_runner`. Acceptance criteria are encoded as tests before any implementation begins.

**Human Verification Gate** — for UI, visual design, and UX tasks: HERALD presents a binary checklist to the user before continuing dispatch.

**Context Checkpoint** — at 75% context usage, SA writes a compact state summary to `context.md` and the plan file, clears non-essential history, and continues. Never relies on `/compact`.

**Anti-sycophancy** — every plan must include at least one genuine challenge — a risk, a hidden assumption, or a viable alternative. "This looks good" alone is never sufficient.

## Modes

| Mode | Activation | What it does |
|---|---|---|
| **Fast-track** | `/fast [request]` | Skips discovery and context loading — jumps straight to planning |
| **Brainstorm** | `/brainstorm [topic]` | Structured thinking mode: Critique → Design → Benchmark → Recommend. No dispatch. Output can be promoted to a real plan. |
| **Score** | `/score` | Manually triggers Layer 6 if it was missed — runs full scoring, updates context store, conditionally stores pattern |

## Architecture

```
User
  ↕
HERALD (orchestrator — sole cross-system authority)
  ↕              ↕               ↕
 SA        Agent Builder    Task Agents
```

All communication routes through HERALD. No agent communicates with another agent directly.

| Agent | Spawn type | Scope |
|---|---|---|
| **SA** | Dominant | Validate specs, plan, classify, score, update context store |
| **Agent Builder** | Dominant | Build new agents to spec |
| **Task agents** | Temporal or Dominant | Execute one defined task. Nothing else. |

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
mkdir -p your-project/plans your-project/.claude/commands
cp herald-tmp/.claude/commands/* your-project/.claude/commands/
```

Open in Claude Code. HERALD activates on the next request.

## Files

| File | Purpose |
|---|---|
| `CLAUDE.md` | Full HERALD spec — drop-in activation file |
| `herald.config.json` | Fast-track, brainstorm, token budget, pipeline config |
| `agent-registry.json` | Registry of all dominant agents |
| `knowledge-base.json` | Patterns from scored executions (grows over time) |
| `context.md` | Session context store — decisions, constraints, failed approaches |
| `.claude/commands/brainstorm.md` | `/brainstorm` slash command |
| `.claude/commands/score.md` | `/score` slash command |
| `plans/` | Created at runtime — approved plans with live checklists |
| `examples/` | Sample handoff, plan, and pattern files |
| `export/herald.html` | Full visual presentation (open in browser) |

## Core rules

- HERALD is the sole orchestrator — no agent-to-agent communication
- Every agent has one defined scope and does not exceed it
- No agent receives raw user input — all input is translated by HERALD
- Nothing executes without the user approving a plan first
- Destructive tasks are flagged at plan approval, not at execution
- Silence is safe — no stated preference means safe default, always
- Layer 6 is mandatory — no execution closes without scoring
- Patterns are only stored when composite score ≥ 95%

## Architectural limits

HERALD is an instruction layer. Its gates are instructions read and followed by the same model that executes the work. Under context pressure — long sessions, approaching token limits, a user bypassing a gate — the model may comply and skip enforcement. This is a fundamental property of instruction-following systems, not a flaw unique to HERALD.

**What is reliable:** Human-in-the-loop gates (plan approval, Risk Gate) require explicit user confirmation and do not depend on model compliance. Plan files and `context.md` create recoverable state. `/score` provides a recovery path when Layer 6 is missed.

**What the hook provides:** `.claude/hooks/herald-safety.sh` blocks `rm -rf` and `DROP DATABASE / DROP SCHEMA` at the Bash tool level — before the model has any opportunity to comply or not comply. This fires regardless of model behavior, context length, or user pressure.

**What the hook does not cover:** Destructive patterns in generated files, `DELETE FROM` without `WHERE`, `TRUNCATE`, `DROP TABLE` — too context-dependent for a hook to distinguish approved from unapproved without false positives. The Destructive Pattern Scan in Layer 5 handles these, but it is model-enforced.

**The right mental model:** HERALD makes the right behavior explicit and likely. The hook catches catastrophic Bash-level cases. Human approval gates are the reliable enforcement mechanism for everything in between. The system is as strong as the user's willingness to hold the gates.

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
