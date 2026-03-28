# Agent Conventions

Universal guidelines for all Herald pipeline agents. Every agent file references this document instead of repeating these rules.

---

## Domain Agnosticism

Agents define **roles and workflows**, not tech stacks. Never assume a specific framework, language, database, or deployment platform. All project-specific context comes from Herald's Layer 4 briefs, which are assembled from Layer 2 context harvesting of the actual codebase.

When your instructions say "follow the project's conventions" — read the existing codebase patterns (2-3 files max) to understand what conventions are in use, then match them.

---

## Context Rules (Cost Efficiency)

- Read CLAUDE.md once per session — do not re-read it
- Read only files directly relevant to this feature's domain — not the full codebase
- In QA/review rounds 2+, read only files that changed since the last round
- Keep output concise and structured — no padding, no filler, no restating what the SRS already said
- If a section has nothing to say, write "N/A" rather than filler text

---

## Severity Scale

All agents use this single scale for classifying issues:

| Level | Label | Criteria |
|-------|-------|----------|
| :red_circle: | BLOCKER | Blocks deployment, breaks core flow, data loss risk, security vulnerability exploitable now |
| :orange_circle: | HIGH | Significant issue, workaround required or rollback recommended, key flow degraded |
| :yellow_circle: | MEDIUM | Minor issue, fix before next release, non-critical deviation from spec |
| :green_circle: | LOW | Enhancement suggestion, cosmetic, stylistic preference |

Use these labels consistently in all reports. Do not invent per-agent scales.

---

## When to Ask the User (Universal Framework)

Use `AskUserQuestion` when you encounter a decision that:
1. Has two or more valid options with meaningfully different outcomes
2. Cannot be resolved from the SRS, PM brief, ADR, or existing codebase conventions
3. Would cost significantly more to fix later if guessed wrong

Present options with clear trade-offs. One question per decision point. Do not ask about every detail — only escalate real forks.

---

## Completion Announcement Format

Every agent announces completion in this format:

```
[PASS_ICON] [AGENT NAME] COMPLETE
[1-2 line summary of what was done]
Saved to: [output file path]
```

Or if the agent found issues:

```
[FAIL_ICON] [AGENT NAME]: FAIL
[Issue type] found: [count]
Report: [output file path]
[Which agent must fix the issues]
```

Do **not** include a "Next:" line. The orchestrator decides what runs next based on the pipeline plan — agents do not direct the pipeline.

---

## Doc Path Convention

All pipeline outputs use nested paths per feature:

```
/docs/[feature-name]/
  pm/pm-brief-[feature-name].md
  ba/srs-[feature-name].md
  po/user-stories-[feature-name].json
  po/user-stories-[feature-name].md
  architect/adr-[feature-name].md
  ui-designer/ui-[feature-name].md
  content-writer/content-[feature-name].md
  db-agent/db-agent-[feature-name].md
  backend-agent/backend-agent-[feature-name].md
  frontend-agent/frontend-agent-[feature-name].md
  qa/qa-report-happy-[feature-name].md
  qa/qa-report-breaker-[feature-name].md
  qa/ui-test-[feature-name].md
  security/security-report-[feature-name].md
  data/data-report-[feature-name].md
  marketing/marketing-[feature-name].md
  marketing/content-audit-[feature-name].md
  post-release/post-release-[feature-name].md
  devops/devops-report-[feature-name].md
```

Global docs: `/docs/_global/changelog.md`
Wireframes: `/wireframes/[feature-name].jsx`
