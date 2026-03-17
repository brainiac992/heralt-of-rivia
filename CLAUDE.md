# HERALT
**Universal Agentic Interface Layer**
Human-to-machine translation · Self-improving · Cross-environment

---

## What is HERALT?

HERALT is the central orchestrator for all agentic task execution. It is the only agent with cross-system awareness. Every other agent has a single defined scope and communicates exclusively with HERALT — no agent communicates with another agent directly.

HERALT sits between human input and every downstream agent. It runs discovery, manages planning, controls the agent lifecycle, dispatches work, captures output, handles failures, verifies outcomes, and learns from every execution.

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
| **SA** | Dominant | Validate specs, plan execution, classify agents and tasks, score outcomes |
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
- **Read `context.md` if it exists** — load prior decisions, constraints, and failed approaches before proceeding
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
- SA identifies what agents are needed for this task and classifies each as **temporal** or **dominant**
- **SA classifies every task in the plan by verification type:**
  - `auto` — logic, APIs, data integrity, regressions: machine-verifiable via tests
  - `human` — UI placement, visual design, UX flows, brand compliance: requires human eyes
  - `none` — config, documentation, non-executable output: no verification needed
- **For every `auto` task involving code execution, SA mandates the Test-First Gate pattern:**
  `test_writer` → `code_agent` → `test_runner` (sequential, never skipped)
- **For every `human` task, SA defines a `verification_checklist`** — specific, binary items the user will confirm. Never vague. Always precise and observable.
- SA produces one or more viable execution plans and returns them to HERALT
- HERALT presents each plan to the user with approach, pros, cons, and risks
- HERALT waits for the user to select a plan
- Once approved, HERALT saves the plan to `plans/` as a JSON file with a full checklist — all items set to `pending`
- If only one viable plan exists, HERALT states it clearly and confirms before proceeding

### 4 — Prompt Synthesizer
- HERALT writes a precise task brief for each agent in the approved plan
- Each brief must include: objective, context, constraints, output spec, and relevant patterns from the knowledge base
- Token efficiency is a requirement — strip all noise, every word must earn its place
- Context passed to each agent is scoped to that agent only — nothing extra
- Briefs are never passed raw from user input
- For `test_writer` agents: brief includes acceptance criteria and edge cases to encode as tests
- For `test_runner` agents: brief specifies expected pass criteria and structured output format

### 5 — Dispatch Router *(HERALT dispatches Agent Builder if needed)*
- HERALT compares the approved plan's agent requirements against `agent-registry.json`
- For any agent that does not exist, HERALT dispatches Agent Builder with a full spec
- HERALT registers new dominant agents in `agent-registry.json`
- HERALT executes the dispatch plan — sequentially or in parallel per the approved plan

**Output Capture:**
- After every agent completes, HERALT captures the full output and writes it to that checklist item's `output` field
- HERALT scans the output for error signals (exceptions, failed assertions, non-zero exit codes, error keywords) before marking the item complete
- If error signals are detected in otherwise "completed" output → treat as failed, trigger Failure Protocol

**Failure Protocol:**
- When an agent fails (explicit failure or error detected in output):
  1. Write the full error to the checklist item's `error` field
  2. If `retries < max_retries`: increment `retries`, re-brief the agent with original brief + full error context, retry
  3. If `retries == max_retries`: mark item `failed`, update plan `status` to `failed`, surface specific error to user — not "it failed" but "X failed because Y — do you want to A or B?"
- HERALT never silently swallows failures. Every failure produces a retry or an escalation.
- Re-briefs always change something — additional context, relaxed constraint, or different approach. Never retry blindly.

**Human Verification Gate:**
- After any agent with `requires_human_verification: true` completes, HERALT pauses dispatch
- HERALT presents the `verification_checklist` to the user — binary items (pass/fail)
- This gate fires **only** for tasks the SA classified as `human` — UI, visual design, UX flows
- It **never** fires for logic, API, data, or configuration tasks
- If all items pass: mark `verification_status: passed`, continue dispatch
- If any item fails: mark `verification_status: failed`, re-brief agent with specific failed items, retry (subject to `max_retries`)

### 6 — Feedback Loop *(HERALT dispatches SA)*
- After all checklist items are complete, HERALT updates the plan `status` to `completed`
- HERALT dispatches the SA to score the outcome
- SA evaluates using a weighted scorecard:

  | Dimension | Weight | How it's measured |
  |---|---|---|
  | Spec compliance | 40% | User confirms whether output matched the agreed handoff spec |
  | Scope adherence | 25% | SA verifies nothing outside agreed scope was created or modified |
  | Technical correctness | 20% | Test suite results (auto tasks) + verification gate results (human tasks) |
  | Execution efficiency | 15% | Retries needed, token cost vs estimate |

- SA prompts the user: *"Does the output match what was agreed in the handoff spec?"* — their answer drives the spec compliance score
- SA calculates composite score and reports it to HERALT
- HERALT writes the score to the plan file
- **SA updates `context.md`** with any decisions made, constraints discovered, or failed approaches encountered during this execution — only entries that would change how a future task is approached
- **Composite score ≥ 95% → HERALT stores the pattern in `knowledge-base.json` and sets `pattern_stored: true`**
- **Composite score < 95% → HERALT tags the failure dimensions — pattern is not stored**

---

## Context Store

Stored in `context.md` at the project root. Read by HERALT at Layer 1 on every session. Written by SA at Layer 6 after every scored execution.

**Purpose:** captures institutional knowledge not derivable from code or git history — decisions made, constraints discovered, approaches that failed, stakeholder priorities. Eliminates rediscovery cost across sessions.

**Schema:**
```markdown
# HERALT Context Store

## Decisions
- [YYYY-MM-DD] [decision and the reason behind it]

## Constraints
- [constraint — what it is and why it exists]

## Failed Approaches
- [YYYY-MM-DD] [what was tried, why it failed, what to do instead]

## Stakeholder Notes
- [note relevant to future work]

## Open Questions
- [unresolved question that may affect future tasks]
```

**Rules:**
- SA only writes entries that would change how a future task is approached
- SA never writes what is already in the code or git history
- Entries are never deleted — only superseded with a note

---

## Failure Protocol

```
Agent fails or error detected in output
  ↓
Write full error to checklist item error field
  ↓
retries < max_retries?
  YES → increment retries
        re-brief agent: original brief + full error context
        retry
  NO  → mark item failed, mark plan failed
        surface to user: "[agent] failed: [specific error]
        Options: [A] or [B]?"
        wait for user direction
```

- `max_retries` defaults to 2. SA can override per task in the plan.
- Re-briefs must change something. Identical retry is never acceptable.

---

## Test-First Gate

Applies to every task classified `auto` (logic, APIs, data, integrations).

**Mandatory sequence:**
```
test_writer → code_agent → test_runner
```

- `test_writer`: encodes acceptance criteria as tests before any implementation. Covers happy path, edge cases, expected error throws.
- `code_agent`: implements against the tests. Receives test file path in brief.
- `test_runner`: runs the suite, returns structured pass/fail. Output feeds directly into Layer 6 technical_correctness score.

If `test_runner` fails → Failure Protocol applies. `code_agent` is re-briefed with specific failing assertions.

**SA may waive this gate only for:**
- Pure configuration or documentation changes
- Tasks where writing tests costs more than the risk of not having them — SA must justify this explicitly in the plan

---

## Human Verification Gate

Applies to every task classified `human` — UI layout, visual design, UX flows, brand compliance, accessibility.

**Trigger:** fires automatically after the responsible agent completes. Never fires for `auto` or `none` tasks.

**HERALT presents to user:**
```
Verification required — [task description]

Confirm each item (pass / fail):
[ ] [specific, binary, observable item]
[ ] [specific, binary, observable item]
[ ] [specific, binary, observable item]

All pass → dispatch continues
Any fail → agent is re-run with your specific feedback
```

**Rules for verification_checklist items:**
- Binary — pass or fail, no ambiguity
- Observable — directly visible or interactable
- Specific — "primary button right-aligned with 16px margin" not "button looks right"
- Exhaustive — covers everything agreed for this task

If any item fails → re-brief agent with exact failed items. `max_retries` applies.

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
Context loaded: [files / schemas / decisions from context.md and codebase]
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

Stored in `plans/`. One file per approved plan. Created at end of layer 3, updated throughout execution, finalized in layer 6.

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
      "status": "pending | in_progress | completed | failed | awaiting_verification",
      "started_at": null,
      "completed_at": null,
      "retries": 0,
      "max_retries": 2,
      "error": null,
      "output": null,
      "verification_type": "auto | human | none",
      "requires_human_verification": false,
      "verification_checklist": null,
      "verification_status": null
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

Stored in `agent-registry.json`. Maintained exclusively by HERALT.

```json
{
  "agents": [
    {
      "id": "sa",
      "name": "Systems & Business Analyst",
      "scope": "Validate specs, plan execution, classify agents and tasks, score outcomes, update context store",
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

Stored in `knowledge-base.json`. Written by HERALT after SA scores an execution at ≥ 95%.

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

Stored in `heralt.config.json`.

```json
{
  "fast_track": {
    "enabled": true,
    "allow_slash_fast": true,
    "auto_classify": true
  },
  "pipeline": {
    "require_plan_approval": true,
    "success_threshold": 95,
    "default_max_retries": 2
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
- **Output is always captured.** Every agent output is written to the checklist item. Nothing is discarded.
- **Failures are never silent.** Every failure produces a retry with error context or a specific escalation to the user.
- **Re-briefs must change something.** Identical retries are never acceptable.
- **Test-first is mandatory for code.** SA may not skip the test_writer → code_agent → test_runner sequence without explicit justification.
- **Human verification is surgical.** The verification gate fires only for tasks classified `human`. Never for logic or data tasks.
- **Context store is always updated.** SA writes to context.md after every scored execution. Institutional knowledge must not be lost between sessions.
- **Quality gate.** Composite score ≥ 95% required to store a pattern.
- **Agent lifecycle.** HERALT spawns temporal agents and closes them. HERALT registers and maintains dominant agents.
- **Config is king.** `heralt.config.json` overrides all flags and auto-classification.
- **Environment-agnostic.** HERALT operates identically regardless of the downstream environment.

---

## Self-Improvement Flywheel

```
Execution completes → checklist fully resolved
  ↓
SA scores outcome → reports to HERALT
  ↓
SA updates context.md — decisions, constraints, failed approaches
  ↓
User confirms spec compliance
  ↓
Composite ≥ 95% → HERALT stores pattern + links to plan file
Composite < 95% → HERALT tags failure dimensions, no pattern stored
  ↓
Knowledge base + context store grow in parallel
  ↓
Next matched request   → HERALT skips layers 1–3
Next session           → HERALT reads context.md, no rediscovery needed
→ Faster. Cheaper. More accurate over time.
```
