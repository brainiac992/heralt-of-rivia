#!/usr/bin/env bash
# HERALD Deployment Script Audit
# Mandatory for any plan touching database schema, ORM models, or migration files.
#
# Greps all deployment scripts for DDL commands that would execute on startup or deploy.
# This is a mechanical check — run it, don't rely on the model's judgment.
#
# Usage: bash .claude/hooks/deployment-audit.sh
# Exit 0: clean — no dangerous patterns found
# Exit 1: patterns found — surface to user before proceeding

DEPLOY_SCRIPTS=(
  "start.sh"
  "Dockerfile"
  "docker-compose.yml"
  "docker-compose.yaml"
  "docker-compose.prod.yml"
  "docker-compose.production.yml"
  "railway.json"
  ".railway.json"
  "Procfile"
  "app.json"
)

PATTERNS=(
  "prisma db push"
  "prisma migrate dev"
  "prisma migrate deploy"
  "prisma migrate reset"
  "prisma migrate reset"
  "DROP TABLE"
  "DROP DATABASE"
  "DROP SCHEMA"
  "TRUNCATE"
)

found=0
results=""

# Check known deployment files
for f in "${DEPLOY_SCRIPTS[@]}"; do
  if [ -f "$f" ]; then
    for pattern in "${PATTERNS[@]}"; do
      matches=$(grep -in "$pattern" "$f" 2>/dev/null || true)
      if [ -n "$matches" ]; then
        results="${results}\n  [$f] → $matches"
        found=1
      fi
    done
  fi
done

# Check CI/CD workflow directories
for dir in ".github/workflows" ".gitlab-ci.yml" ".circleci"; do
  if [ -e "$dir" ]; then
    for pattern in "${PATTERNS[@]}"; do
      matches=$(grep -rn "$pattern" "$dir" 2>/dev/null || true)
      if [ -n "$matches" ]; then
        results="${results}\n  [$dir] → $matches"
        found=1
      fi
    done
  fi
done

if [ "$found" -eq 1 ]; then
  printf "\nHERALD DEPLOYMENT AUDIT — DDL commands found in deployment scripts\n" >&2
  printf "═══════════════════════════════════════════════════════════════\n" >&2
  printf "%b\n\n" "$results" >&2
  printf "These commands will execute automatically on startup or deploy.\n" >&2
  printf "This is a destructive risk in production environments.\n" >&2
  printf "\nOptions:\n" >&2
  printf "  A) Remove the DDL command from the deployment script\n" >&2
  printf "  B) Explicitly confirm via the Risk Gate that this is intentional\n" >&2
  printf "═══════════════════════════════════════════════════════════════\n\n" >&2
  exit 1
fi

printf "HERALD DEPLOYMENT AUDIT — clean. No DDL commands found in deployment scripts.\n"
exit 0
