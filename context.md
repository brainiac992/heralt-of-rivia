# HERALD Context Store

## Decisions
- [2026-03-27] Merged the 8-phase development pipeline into Herald as a specialized dispatch pattern within Layer 5. Herald's 6 layers govern all pipeline execution. Chose this over keeping them as separate systems because it eliminates orchestration conflicts and gives pipeline agents the benefit of Herald's safety gates.

## Constraints
- All pipeline doc outputs use nested paths: `/docs/[feature-name]/[agent-role]/[filename]` — flat paths are deprecated
- Agent definitions must reference `.claude/agent-conventions.md` for shared boilerplate — do not duplicate context rules, severity scales, or completion formats in individual agent files

- [2026-03-27] Made all 18 pipeline agents domain-agnostic. Agents define roles and workflows, not tech stacks. Project-specific context (frameworks, languages, deployment platforms) comes from Layer 2 context harvesting and Layer 4 briefs. This makes Herald portable across any project.

## Failed Approaches

## Stakeholder Notes

## Open Questions
