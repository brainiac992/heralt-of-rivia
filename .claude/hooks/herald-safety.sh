#!/usr/bin/env bash
# HERALD Safety Hook
# Blocks catastrophic Bash patterns at the tool level — before execution,
# before the model has any opportunity to comply or not comply with an instruction.
#
# Scope: catches only the genuinely catastrophic, hard-to-misread cases.
# Not a substitute for the Risk Gate — a last line of defence for the worst outcomes.
#
# Patterns blocked:
#   rm -rf (and common flag variants)
#   DROP DATABASE / DROP SCHEMA
#   prisma migrate reset (always destructive — drops and recreates the entire database)
#   prisma db push --force-reset (destructive variant of db push)
#
# Patterns intentionally NOT blocked here (too context-dependent, high false positive rate):
#   prisma db push (without --force-reset) — legitimate in dev; Deployment Script Audit handles prod
#   prisma migrate dev / deploy — legitimate; Deployment Script Audit handles startup scripts
#   DELETE FROM without WHERE — common in test teardown, migration rollbacks
#   TRUNCATE — common in test fixtures
#   DROP TABLE — needs Risk Gate context to distinguish approved from unapproved

set -euo pipefail

input=$(cat)

# Extract command string from the JSON input HERALD receives on stdin
if command -v python3 &>/dev/null; then
  cmd=$(echo "$input" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except Exception:
    print('')
" 2>/dev/null)
else
  # Fallback: search raw JSON string directly
  cmd="$input"
fi

blocked=""

# rm -rf in common forms: -rf, -fr, -r -f, -f -r
if echo "$cmd" | grep -qE 'rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*[[:space:]]|rm[[:space:]]+-[a-zA-Z]*f[a-zA-Z]*r[a-zA-Z]*[[:space:]]|rm[[:space:]]+-r[[:space:]]+-f|rm[[:space:]]+-f[[:space:]]+-r'; then
  blocked="${blocked}\n  → rm -rf (recursive force delete)"
fi

# DROP DATABASE or DROP SCHEMA (case-insensitive)
if echo "$cmd" | grep -qiE 'DROP[[:space:]]+(DATABASE|SCHEMA)[[:space:]]+'; then
  blocked="${blocked}\n  → DROP DATABASE / DROP SCHEMA"
fi

# prisma migrate reset — always destructive (drops and recreates entire database)
if echo "$cmd" | grep -qE 'prisma[[:space:]]+migrate[[:space:]]+reset'; then
  blocked="${blocked}\n  → prisma migrate reset (drops and recreates entire database)"
fi

# prisma db push --force-reset — destructive variant
if echo "$cmd" | grep -qE 'prisma[[:space:]]+db[[:space:]]+push.*--force-reset'; then
  blocked="${blocked}\n  → prisma db push --force-reset (destructive schema reset)"
fi

if [ -n "$blocked" ]; then
  printf "\nHERALD SAFETY BLOCK\n" >&2
  printf "════════════════════════════════════════\n" >&2
  printf "Catastrophic pattern detected:%b\n\n" "$blocked" >&2
  printf "This command was blocked before execution.\n" >&2
  printf "If this operation was approved via the Risk Gate,\n" >&2
  printf "state that explicitly and HERALD will proceed.\n" >&2
  printf "════════════════════════════════════════\n\n" >&2
  exit 2
fi

exit 0
