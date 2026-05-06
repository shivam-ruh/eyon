#!/usr/bin/env bash
# Check required environment variables are set.
set -euo pipefail

missing=0
if [ -z "${PG_CONNECTION_STRING:-}" ]; then echo "MISSING: PG_CONNECTION_STRING"; missing=$((missing+1)); fi
if [ -z "${ORG_ID:-}" ]; then echo "MISSING: ORG_ID"; missing=$((missing+1)); fi
if [ -z "${AGENT_ID:-}" ]; then echo "MISSING: AGENT_ID"; missing=$((missing+1)); fi
if [ -z "${DATABASE_URL:-}" ]; then echo "MISSING: DATABASE_URL"; missing=$((missing+1)); fi
if [ -z "${X_API_KEY:-}" ]; then echo "MISSING: X_API_KEY"; missing=$((missing+1)); fi
if [ -z "${X_API_SECRET:-}" ]; then echo "MISSING: X_API_SECRET"; missing=$((missing+1)); fi
if [ -z "${X_ACCESS_TOKEN:-}" ]; then echo "MISSING: X_ACCESS_TOKEN"; missing=$((missing+1)); fi
if [ -z "${X_ACCESS_TOKEN_SECRET:-}" ]; then echo "MISSING: X_ACCESS_TOKEN_SECRET"; missing=$((missing+1)); fi
if [ -z "${X:-}" ]; then echo "MISSING: X"; missing=$((missing+1)); fi

if [ $missing -gt 0 ]; then
    echo "$missing required env var(s) missing"
    exit 1
fi
echo "OK: all required env vars set"
