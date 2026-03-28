# Herald Pipeline - Orchestrator Instructions

This file tells Claude Code how to run the full automated pipeline. Agents are domain-agnostic — they receive project-specific context (tech stack, conventions, supported languages) via Herald's Layer 4 briefs, not from hardcoded instructions.

---

## Entry Rule — PM and BA Always Run First

**Every feature request, no matter how small, starts with PM and BA.**

When the user describes anything that involves building, changing, or removing functionality — even a one-liner — trigger Phase 1 (PM Brief → BA → PM Summary) before any other agent runs. No exceptions.

After Phase 1 completes, the orchestrator selects only the phases and agents needed for that specific feature. Not every feature needs every phase.

---

## Agent Roster

```
Phase 1   → PM (brief) → [human checkpoint] → BA → PO (user stories + AC) → PM (summary) → Architect
Phase 2   → UI-Designer  +  Content-Writer         (parallel, if UI changes needed)
Phase 3   → DB-Agent → Backend-Agent → Frontend-Agent  (sequential, as needed)
Phase 4   → UI-Tester  +  QA-Happy  +  QA-Breaker  +  Security-Agent  (parallel)
Phase 5   → Data-Agent                              (if schema changes involved)
Phase 6   → Marketing-Agent  +  Content-Auditor    (parallel, if customer-facing)
Phase 7   → DOC-Agent → Commit + Push
Phase 8   → Post-Release-Agent                     (after deployment platform deploy confirms)
```

Standalone (not part of default pipeline):
```
DevOps-Agent  — call independently: "Run DevOps check for [feature]"
```

---

## Pipeline Trigger

The user will say something like:
> "Run the pipeline for: [feature description]"
> "Start the Herald pipeline: [feature description]"
> "New feature: [feature description]"
> "Build [feature]"
> "Add [feature]"
> "Change [feature]"

**When you see any of these, you are the orchestrator. Phase 1 always runs first.**

---

## PHASE 1 — Planning (Always Required)

All four steps run **sequentially**. No other phase begins until Phase 1 completes.

### Step 1a — PM Brief (Product Brief + Human Checkpoint)

Use the PM subagent in **Mode 1** with the raw feature description.

- PM interviews the user with `AskUserQuestion` to clarify goals, success metrics, and constraints
- PM may pause mid-assessment for strategic decisions (scope conflict, timing, priority)
- PM produces a Product Brief at `/docs/[feature-name]/pm/pm-brief-[feature-name].md`
- **PM presents the brief and WAITS for user approval**
- User types: `approve`, `revise: [changes]`, or `reject: [reason]`
- If approved → Step 1b
- If revise → PM updates brief and re-presents
- If reject → pipeline stops

### Step 1b — BA (Requirements)

Use the BA subagent with the approved PM brief.

- BA reads the PM brief at `/docs/[feature-name]/pm/pm-brief-[feature-name].md`
- BA uses `AskUserQuestion` to conduct the requirements interview
- BA pauses on any scope fork, role/access ambiguity, or edge case policy decision
- BA produces the SRS at `/docs/[feature-name]/ba/srs-[feature-name].md`
- Wait for BA COMPLETE

### Step 1c — PO (User Stories + Acceptance Criteria)

Use the PO subagent with the approved PM brief and completed SRS.

- PO reads both the PM brief and SRS
- PO breaks the SRS into user stories with measurable acceptance criteria
- Each acceptance criterion is classified as `auto` (testable by code) or `human` (requires user eyes)
- PO produces a JSON checklist at `/docs/[feature-name]/po/user-stories-[feature-name].json`
- PO produces a readable summary at `/docs/[feature-name]/po/user-stories-[feature-name].md`
- QA agents (Phase 4) will verify against these criteria and update the checklist
- Users can also mark `human` criteria as passed/failed directly
- Wait for PO COMPLETE

### Step 1d — PM Summary (Post-BA Alignment Check)

Use the PM subagent in **Mode 2** with the PM brief, completed SRS, and PO user stories.

- PM compares the SRS against the approved brief: scope alignment, coverage, open questions resolved, new risks
- If **ALIGNED or MINOR DRIFT** → auto-proceeds, no user input needed
- If **SIGNIFICANT DRIFT** → PM uses `AskUserQuestion` to present the drift and ask: proceed, ask BA to revise, or update the brief
- PM summary is appended to `/docs/[feature-name]/pm/pm-brief-[feature-name].md`
- Wait for PM SUMMARY COMPLETE

### Step 1e — Architect (Technical Blueprint)

Use the Architect subagent with the PM brief, SRS, and PO user stories.

- Architect reads both `/docs/[feature-name]/pm/pm-brief-[feature-name].md` and `/docs/[feature-name]/ba/srs-[feature-name].md`
- Architect may pause using `AskUserQuestion` for genuine technical trade-offs
- Architect produces the ADR at `/docs/[feature-name]/architect/adr-[feature-name].md`
- **Architect declares which subsequent phases are needed** (see Phase Selection below)
- Wait for ARCHITECT COMPLETE

---

## Phase Selection — What Runs After Phase 1

After the Architect completes, the orchestrator reads the ADR and activates only the phases that apply. Use this table:

| Condition | Phases to run |
|-----------|--------------|
| Feature has new/changed UI screens | Phase 2 (UI-Designer + Content-Writer) |
| Feature needs DB schema changes | Phase 3a (DB-Agent) |
| Feature needs new/changed API endpoints | Phase 3b (Backend-Agent) |
| Feature has any frontend changes | Phase 3c (Frontend-Agent) |
| Any Phase 3 agent ran | Phase 4 (all QA agents — always run after any dev work) |
| Phase 3a ran (schema changes) | Phase 5 (Data-Agent) |
| Feature is customer-facing | Phase 6 (Marketing-Agent + Content-Auditor) |
| Any agent ran | Phase 7 (DOC-Agent + Commit + Push) |
| Phase 7 complete and deployment platform deploys | Phase 8 (Post-Release-Agent) |

**Minimum pipeline for any feature:** Phase 1 + Phase 7.
**Maximum pipeline:** Phases 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8.

---

## PHASE 2 — Design (if UI changes needed)

Launch both agents **simultaneously**.

**UI-Designer** reads the SRS and ADR → produces:
- `/docs/[feature-name]/ui-designer/ui-[feature-name].md` (UI spec)
- `/wireframes/[feature-name].jsx` (React wireframes)
- May pause on UX pattern trade-offs

**Content-Writer** reads the SRS and PM brief → produces:
- `/docs/[feature-name]/content-writer/content-[feature-name].md` (all UI copy, labels, messages, translations)
- Always opens with a tone/language interview

Wait for both agents to complete before Phase 3.

---

## PHASE 3 — Development (DB → Backend → Frontend, sequential)

Run only the agents whose domain is touched by this feature.

**Step 3a — DB-Agent** (run if schema changes needed): Implements schema, migrations, seed data per ADR.
Wait for DB AGENT COMPLETE.

**Step 3b — Backend-Agent** (run if API changes needed): Implements API endpoints, business logic, middleware per ADR.
Wait for BACKEND AGENT COMPLETE.

**Step 3c — Frontend-Agent** (run if UI changes needed): Implements React UI per ADR, UI spec, wireframes, and content doc.
- Frontend-Agent **must use** `/docs/[feature-name]/content-writer/content-[feature-name].md` for all user-facing strings.
Wait for FRONTEND AGENT COMPLETE.

---

## PHASE 4 — Testing (Always run after any Phase 3 work)

Launch all four agents **simultaneously**.

**UI-Tester**: Visual, accessibility, responsiveness, RTL, copy implementation check
→ `/docs/[feature-name]/qa/ui-test-[feature-name].md`

**QA-Happy**: Happy path and acceptance criteria against SRS
→ `/docs/[feature-name]/qa/qa-report-happy-[feature-name].md`

**QA-Breaker**: Edge cases, adversarial inputs, logic attacks
→ `/docs/[feature-name]/qa/qa-report-breaker-[feature-name].md`

**Security-Agent**: Auth, permissions, injection, data exposure, ERP integrity
→ `/docs/[feature-name]/security/security-report-[feature-name].md`

Wait for all four to complete.

**Acceptance Criteria Verification:**
- QA agents read `/docs/[feature-name]/po/user-stories-[feature-name].json`
- For each `auto` criterion they can verify, they update `status` to `passed` or `failed`, set `verified_by` to their agent ID, and `verified_at` to the timestamp
- For `human` criteria, QA agents flag them for user verification — the user can mark them passed/failed directly
- A user story is `passed` only when ALL its acceptance criteria are `passed`

**If ALL FOUR pass** → proceed to next phase.

**If ANY fail** (Round 1 or 2):
- Collect all 🔴 BLOCKER items from all four reports
- Send to the relevant dev agent(s) to fix (Frontend for UI/copy, Backend for logic/security)
- Re-run Phase 4 (increment round counter)

**If failing after Round 3** → escalate to user with full blocker list.

---

## PHASE 5 — Data Review (run if schema changes involved)

Use the Data-Agent subagent to review the data model impact of [feature-name].

- Reviews schema, queries, integrity, scalability, and ERP compatibility
- Produces `/docs/[feature-name]/data/data-report-[feature-name].md`
- If NEEDS CHANGES → send critical findings to DB-Agent, then re-run Data-Agent
- If APPROVED → proceed to Phase 6

---

## PHASE 6 — Marketing & Content Audit (run if customer-facing)

Launch both agents **simultaneously**.

**Marketing-Agent**:
- Always interviews the user first (audience, tone, channels, key message)
- Skip for internal/infrastructure features
- Produces `/docs/[feature-name]/marketing/marketing-[feature-name].md`

**Content-Auditor**:
- Audits implemented copy against `/docs/[feature-name]/content-writer/content-[feature-name].md`
- Checks translation completeness (EN/AR/HE), tone, microcopy quality
- Produces `/docs/[feature-name]/marketing/content-audit-[feature-name].md`
- If FAIL → send blockers to Frontend-Agent, then re-run Content-Auditor

Wait for both agents to complete before Phase 7.

---

## PHASE 7 — Documentation + Commit (Always Required)

### Step 7a — DOC-Agent

Use the DOC-Agent subagent to document all changes for [feature-name].

- Pauses with `AskUserQuestion` on changelog visibility, README scope, version bump
- Adds JSDoc to new functions and components
- Updates `/docs/_global/changelog.md`
- Finalizes all pipeline docs with status and cross-links
- Wait for DOC AGENT COMPLETE

### Step 7b — Commit + Push

```
git add .
git commit -m "feat([feature-name]): [one-line summary]

Pipeline: [list phases that ran]
PM Brief: /docs/[feature-name]/pm/pm-brief-[feature-name].md
SRS: /docs/[feature-name]/ba/srs-[feature-name].md
ADR: /docs/[feature-name]/architect/adr-[feature-name].md"

git push origin main
```

Announce **PIPELINE COMPLETE** to the user. Note that deployment platform will auto-deploy from the push.

---

## PHASE 8 — Post-Release Inspection (after deployment platform deploy confirms)

Run after deployment platform confirms the deployment is live.

- Agent always interviews the user first (production URL, auth token, inspection depth)
- Runs: health check, auth check, endpoint probing, regression spot-check, log scan
- Severity-classifies findings (🔴 BLOCKER → 🟢 LOW)
- Produces `/docs/[feature-name]/post-release/post-release-[feature-name].md`
- If FAIL with BLOCKER → immediately notify user with rollback/hotfix recommendation

---

## Pipeline Status Tracking

Track current state in `/docs/pipeline-status.md`, updated at every phase transition.

---

## Quick Reference

| Command | What happens |
|---------|-------------|
| `Run the pipeline for: [feature]` | Phase 1 always, then phases per ADR |
| `Run BA for [feature]` | Phase 1b only |
| `Run PO for [feature]` | Phase 1c only |
| `Run UI agent for [feature]` | Phase 2 (UI-Designer) only |
| `Run content writer for [feature]` | Phase 2 (Content-Writer) only |
| `Run dev pipeline for [feature]` | Start from Phase 3 (assumes Phase 1 done) |
| `Run QA for [feature]` | Phase 4 only (all 4 agents) |
| `Run UI tester for [feature]` | Phase 4 (UI-Tester) only |
| `Run data agent for [feature]` | Phase 5 only |
| `Run marketing for [feature]` | Phase 6 (Marketing-Agent) only |
| `Run content audit for [feature]` | Phase 6 (Content-Auditor) only |
| `Run docs for [feature]` | Phase 7 only |
| `Run post-release for [feature]` | Phase 8 only |
| `Run DevOps for [feature]` | Standalone DevOps check |
| `approve` | PM brief checkpoint: approve, continue to BA |
| `revise: [changes]` | PM brief checkpoint: update brief |
| `reject: [reason]` | PM brief checkpoint: stop pipeline |

---

## Agent Decision Points (where the pipeline pauses for user input)

| Phase | Agent | Always pauses? | When it pauses |
|-------|-------|---------------|----------------|
| 1a | PM (brief) | ✅ Yes | Opening interview + brief approval |
| 1b | BA | On forks | Scope fork, role/access ambiguity, edge case policy |
| 1c | PO | On forks | Priority conflicts, scope ambiguity, AC edge cases |
| 1d | PM (summary) | On drift | Only if significant scope drift detected |
| 1e | Architect | On forks | Storage strategy, sync/async, API granularity, migration |
| 2 | UI-Designer | On forks | Interaction pattern, navigation model, density |
| 2 | Content-Writer | ✅ Yes | Opening interview (tone, language, audience) |
| 7 | DOC-Agent | On forks | Changelog visibility, README scope, version bump |
| 6 | Marketing-Agent | ✅ Yes | Opening interview (audience, tone, channels) |
| 8 | Post-Release-Agent | ✅ Yes | Opening interview (URL, token, depth) |
