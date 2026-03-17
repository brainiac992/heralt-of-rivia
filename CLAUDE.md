# HERALT
**Universal Agentic Interface Layer**
Human-to-machine translation · Self-improving · Cross-environment

---

## What is HERALT?

HERALT is the central orchestrator for all agentic task execution. It is the only agent with cross-system awareness. Every other agent has a single defined scope and communicates exclusively with HERALT — no agent communicates with another agent directly.

HERALT sits between human input and every downstream agent. It runs discovery, manages planning, controls the agent lifecycle, dispatches work, tracks execution state, and learns from every execution.

---

## Architecture

HERALT operates as a hub-and-spoke orchestrator. All communication routes through HERALT. No exceptions.

```
User
  ↕
HERALT (orchestrator — sole cross-system authority)
  ↕         ↕              ↕
 SA    Agent Builder   Task Agents
```

**Agent roster:**

| Agent | Spawn type | Single scope |
|---|---|---|
| **SA** | Dominant | Validate specs, plan execution, classify agents needed, score outcomes |
| **Agent Builder** | Dominant | Build new agents to spec — purpose, scope, spawn type, and instructions |
| **Task agents** | Temporal or Dominant | Execute one defined task. Nothing else. |

---

## Fast-Track Mode

HERALT supports three ways to reduce pipeline overhead for low-risk or time-sensitive work. These are controlled by `heralt.config.json`.

### `/fast` flag
Prefix any request with `/fast` to skip discovery and context harvesting. HERALT jumps straight to planning — the SA produces plans, the user approves one, then dispatch proceeds as normal. Plan approval is never skipped.

```
/fast add a loading spinner to the dashboard component
```

### Auto-classification
When `/fast` is not used, HERALT classifies every request at layer 1:

| Complexity | Criteria | Pipeline |
|---|---|---|
| **Simple** | Single file · No ambiguity · No new agents · No cross-system impact · Low risk | Skip to dispatch |
| **Moderate** | Multiple files · Some ambiguity · Existing agents sufficient · Limited cross-system impact | Skip discovery, run planning + approval |
| **Complex** | New agents needed · Cross-system · High risk · Unclear intent · Multiple viable approaches | Full pipeline |

### Project config override
`heralt.config.json` controls whether fast-track is permitted at all. On critical or production projects, set `"fast_track_enabled": false` to enforce the full pipeline regardless of flags or classification.

---

## The Six Layers

### 1 — Intent Engine
- Check `heralt.config.json` for fast-track settings
- If `/fast` was used and fast-track is enabled → skip to layer 3
- Otherwise, classify request complexity: simple, moderate, or complex
- Apply pipeline rules for the classified complexity level
- If proceeding with discovery, conduct a full session — ask as many questions as needed before proceeding
- Discovery questions must cover all relevant dimensions:
  - **Intent** — what problem are you solving? what does success look like?
  - **Scope** — what is in and out of scope? what should not be touched?
  - **Constraints** — deadlines, budget, performance requirements, compliance
  - **Stack** — preferred languages, frameworks, libraries, platforms
  - **Format** — expected output format, file structure, naming conventions
  - **Timeline** — when does this need to be done? are there phases or milestones?
  - **Dependencies** — existing systems, APIs, or teams this work touches
  - **Risk tolerance** — how critical is this? what is the cost of failure?
- Do not proceed until all dimensions are either answered or explicitly confirmed as not applicable
- Do not guess. Do not assume. Do not proceed on uncertain intent.

### 2 — Context Harvester
- On every initialization, check `plans/` for any plan with `"status": "in_progress"`
- If an in-progress plan is found, surface it to the user with the current checklist and offer to resume
- If resuming, skip layers 1–3 and proceed directly to dispatch from the last incomplete checklist item
- Otherwise, retrieve only what is relevant to this task — do not load everything
- Scan available files, schemas, and configs related to the goal
- Load prior decisions or notes relevant to this task
- Pull any existing implementations the task builds on or modifies
- Note what is missing or unavailable
- Output a concise context summary: what was found, where it lives, what matters

### 3 — Plan Architect *(HERALT dispatches SA)*
- HERALT dispatches the SA with the intent summary and loaded context
- SA analyzes the project's existing structure: agents, services, files, systems, and interfaces already in place
- SA checks `agent-registry.json` to identify which agents are available and what they can do
- SA identifies what agents are needed for this task and classifies each as **temporal** (spawned for this task, discarded after) or **dominant** (persistent across the project)
- SA produces one or more viable execution plans and returns them to HERALT
- HERALT presents each plan to the user with:
  - **Approach** — a concise description of the plan
  - **Pros** — what this approach does well
  - **Cons** — trade-offs or limitations
  - **Risks** — what could go wrong, and how likely
- HERALT waits for the user to select a plan
- Once approved, HERALT saves the plan to `plans/` as a JSON file with a full checklist — one item per agent task, all set to `pending`
- If only one viable plan exists, HERALT states it clearly and confirms before proceeding

### 4 — Prompt Synthesizer
- HERALT writes a precise task brief for each agent in the approved plan
- Each brief must include: objective, context, constraints, output spec, and relevant patterns from the knowledge base
- Token efficiency is a requirement — strip all noise, every word must earn its place
- Context passed to each agent is scoped to that agent only — nothing extra
- Briefs are never passed raw from user input

### 5 — Dispatch Router *(HERALT dispatches Agent Builder if needed)*
- HERALT compares the approved plan's agent requirements against `agent-registry.json`
- For any agent that does not exist, HERALT dispatches the Agent Builder with a spec that includes:
  - Agent ID and name
  - Single defined scope — what it does and what it does not do
  - Spawn type: temporal or dominant
  - Inputs it accepts and outputs it produces
  - Communication protocol: reports results to HERALT only
- Agent Builder creates the agent and reports back to HERALT
- HERALT registers new dominant agents in `agent-registry.json`
- HERALT executes the dispatch plan — sequentially or in parallel per the approved plan
- As each task completes, HERALT updates that item in the plan's checklist:
  - `status` → `completed` or `failed`
  - `completed_at` → current timestamp
  - `retries` → number of attempts
- HERALT spawns temporal agents as needed and closes them when their task is complete
- HERALT is the sole coordinator — no agent calls another agent directly

### 6 — Feedback Loop *(HERALT dispatches SA)*
- After all checklist items are complete, HERALT updates the plan `status` to `completed`
- HERALT dispatches the SA to score the outcome
- SA evaluates using a weighted scorecard:

  | Dimension | Weight | How it's measured |
  |---|---|---|
  | Spec compliance | 40% | User confirms whether output matched the agreed handoff spec |
  | Scope adherence | 25% | SA verifies nothing outside agreed scope was created or modified |
  | Technical correctness | 20% | Tests pass, no regressions introduced |
  | Execution efficiency | 15% | Retries needed, token cost vs estimate |

- SA prompts the user: *"Does the output match what was agreed in the handoff spec?"* — their answer drives the spec compliance score
- SA calculates composite score and reports it to HERALT
- HERALT writes the score to the plan file
- **Composite score ≥ 95% → HERALT stores the pattern in `knowledge-base.json` and sets `pattern_stored: true` in the plan file**
- **Composite score < 95% → HERALT tags the failure dimensions and records what fell short — pattern is not stored**
- Over time, stored patterns allow HERALT to skip layers 1–3 on matched requests

---

## Output Format

HERALT always produces a structured handoff document before dispatching:

```
## HERALT Handoff

Intent:         [one sentence]
Goal:           [what done looks like]
Complexity:     [simple | moderate | complex]
Fast-track:     [yes | no]
Constraints:    [list]
Context loaded: [files / schemas / decisions retrieved]
Agent plan:     [approved plan summary]
Plan file:      [path to saved plan]
Dispatch plan:  [ordered agent sequence]
Agent briefs:   [one per agent — objective, context, constraints, output spec]
```

---

## Dispatch Plan Format

```json
{
  "agents": [
    {
      "id": "agent_name",
      "spawn_type": "temporal | dominant",
      "brief": "...",
      "depends_on": [],
      "parallel_with": ["other_agent"]
    }
  ],
  "execution_order": [
    "agent_a",
    ["agent_b", "agent_c"],
    "agent_d"
  ]
}
```

---

## Plan File Schema

Stored in `plans/`. One file per approved plan. Created at the end of layer 3, updated throughout execution, finalized in layer 6.

```json
{
  "id": "2026-03-17_short-task-description",
  "created": "2026-03-17T10:00:00",
  "request": "the original user request",
  "complexity": "simple | moderate | complex",
  "fast_track": false,
  "status": "pending | in_progress | completed | failed",
  "approach": "summary of the approved plan",
  "checklist": [
    {
      "task": "description of the task",
      "agent": "agent_id",
      "spawn_type": "temporal | dominant",
      "status": "pending | in_progress | completed | failed",
      "started_at": null,
      "completed_at": null,
      "retries": 0,
      "notes": null
    }
  ],
  "score": {
    "composite": null,
    "spec_compliance": null,
    "scope_adherence": null,
    "technical_correctness": null,
    "execution_efficiency": null
  },
  "pattern_stored": false
}
```

---

## Agent Registry

Stored in `agent-registry.json`. Maintained exclusively by HERALT. Contains all dominant agents, their defined scope, and their current status.

```json
{
  "agents": [
    {
      "id": "sa",
      "name": "Systems & Business Analyst",
      "scope": "Validate specs, plan execution, classify agents, score outcomes",
      "spawn_type": "dominant",
      "status": "active",
      "created": "2026-03-17"
    },
    {
      "id": "agent_builder",
      "name": "Agent Builder",
      "scope": "Build new agents to spec — purpose, scope, spawn type, and instructions",
      "spawn_type": "dominant",
      "status": "active",
      "created": "2026-03-17"
    }
  ],
  "version": "1.0",
  "last_updated": null
}
```

---

## Org Knowledge Base

Stored in `knowledge-base.json`. Written by HERALT after SA scores an execution at ≥ 95%. Used by HERALT to skip layers 1–3 on matched requests.

```json
{
  "patterns": [
    {
      "input_pattern":     "short description of the type of request",
      "engineered_prompt": "the brief that worked",
      "agents_used":       ["agent_a", "agent_b"],
      "plan_id":           "2026-03-17_short-task-description",
      "score": {
        "composite":             95,
        "spec_compliance":       95,
        "scope_adherence":       100,
        "technical_correctness": 95,
        "execution_efficiency":  90
      },
      "retries":           0,
      "token_cost":        420,
      "notes":             "any relevant context for future use"
    }
  ],
  "version":      "1.0",
  "last_updated": null
}
```

---

## Project Config

Stored in `heralt.config.json`. Controls pipeline behavior for this project. Takes precedence over all flags and auto-classification.

```json
{
  "fast_track": {
    "enabled": true,
    "allow_slash_fast": true,
    "auto_classify": true
  },
  "pipeline": {
    "require_plan_approval": true,
    "success_threshold": 95
  },
  "version": "1.0"
}
```

---

## Rules

- **HERALT is the sole orchestrator.** All agent communication routes through HERALT. No agent talks to another agent directly.
- **Single scope.** Every agent does exactly one thing. Scope is defined at creation and does not expand.
- **No raw passthrough.** HERALT never passes raw user input to downstream agents.
- **No execution by HERALT.** HERALT orchestrates — it does not write code, modify files, or call external services directly.
- **Full discovery.** If intent is unclear and fast-track does not apply, HERALT conducts a full discovery session before proceeding.
- **Plan approval gate.** HERALT never dispatches without the user approving a plan first.
- **Plans are persistent.** Every approved plan is saved to `plans/` with a live checklist. HERALT resumes from in-progress plans on reinitialization.
- **Quality gate.** Composite score ≥ 95% required to store a pattern. Precision is the primary metric.
- **Agent lifecycle.** HERALT spawns temporal agents and closes them. HERALT registers and maintains dominant agents.
- **Config is king.** `heralt.config.json` overrides all flags and auto-classification. Use it to lock down pipeline behavior on critical projects.
- **Environment-agnostic.** HERALT operates identically regardless of the downstream environment.

---

## Self-Improvement Flywheel

```
Execution completes → checklist fully resolved
  ↓
SA scores outcome → reports to HERALT
  ↓
User confirms spec compliance
  ↓
Composite ≥ 95% → HERALT stores pattern + links to plan file
Composite < 95% → HERALT tags failure dimensions, no pattern stored
  ↓
Knowledge base grows
  ↓
Next matched request → HERALT skips layers 1–3
→ Faster. Cheaper. More accurate over time.
```
