List all registered Herald pipeline agents and their current status.

Read `agent-registry.json` and display the agents in a formatted table grouped by phase.

**Output format:**

```
HERALD AGENT REGISTRY
═══════════════════════════════════════════════════════

Phase 1 — Planning
  [status] pm              Product Manager
  [status] ba              Business Analyst
  [status] po              Product Owner
  [status] architect       Software Architect

Phase 2 — Design
  [status] ui_designer     UI Designer
  [status] content_writer  Content Writer

Phase 3 — Development
  [status] db_agent        DB Agent
  [status] backend_agent   Backend Agent
  [status] frontend_agent  Frontend Agent

Phase 4 — Testing
  [status] ui_tester       UI Tester
  [status] qa_happy        QA Happy Path
  [status] qa_breaker      QA Breaker
  [status] security_agent  Security Agent

Phase 5 — Data Review
  [status] data_agent      Data Agent

Phase 6 — Marketing
  [status] marketing_agent Marketing Agent
  [status] content_auditor Content Auditor

Phase 7 — Documentation
  [status] doc_agent       Documentation Agent

Phase 8 — Post-Release
  [status] post_release_agent Post-Release Agent

Standalone
  [status] devops_agent    DevOps Agent

Core (non-pipeline)
  [status] sa              Systems & Business Analyst
  [status] agent_builder   Agent Builder

═══════════════════════════════════════════════════════
Total: [count] agents | Active: [count] | Inactive: [count]
```

Replace `[status]` with:
- `●` for active agents
- `○` for inactive agents

If there is an active plan in `plans/` with `"status": "in_progress"`, also show which agents have completed, are in progress, or are pending for that plan:

```
ACTIVE PLAN: [plan id]
───────────────────────────────────────
  ✅ [agent] — [task description]
  ▶  [agent] — [task description]  (in progress)
  ◻  [agent] — [task description]  (pending)
```

If no in-progress plan exists, skip this section.
