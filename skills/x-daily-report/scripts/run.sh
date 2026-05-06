#!/usr/bin/env bash
# Auto-generated script for x-daily-report
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="x-daily-report"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────
: "${DATABASE_URL:?ERROR: DATABASE_URL not set}"
: "${X_API_KEY:?ERROR: X_API_KEY not set}"
: "${X_API_SECRET:?ERROR: X_API_SECRET not set}"
: "${X_ACCESS_TOKEN:?ERROR: X_ACCESS_TOKEN not set}"
: "${X_ACCESS_TOKEN_SECRET:?ERROR: X_ACCESS_TOKEN_SECRET not set}"

# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/x-daily-report_${RUN_ID}.json"
OUTPUT_FILE="/tmp/x-daily-report_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY'
import json
import os
import subprocess
import sys
from datetime import datetime, timezone

INPUT_FILE = os.environ["INPUT_FILE"]
OUTPUT_FILE = os.environ["OUTPUT_FILE"]
PROJECT_ROOT = os.environ["PROJECT_ROOT"]


def eprint(*args):
    print(*args, file=sys.stderr)


def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def dump_json(path, payload):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")


def count_replies(reply_rows):
    total = 0
    for row in reply_rows or []:
        if not isinstance(row, dict):
            continue
        status = str(row.get("reply_status") or row.get("status") or "").lower()
        if status == "posted":
            total += 1
        elif isinstance(row.get("count"), int):
            total += row["count"]
    return total


def count_reposts(repost_rows):
    total = 0
    for row in repost_rows or []:
        if not isinstance(row, dict):
            continue
        if isinstance(row.get("count"), int):
            total += row["count"]
        elif row.get("repost_id") or row.get("id"):
            total += 1
        else:
            total += 1
    return total


def main():
    payload = load_json(INPUT_FILE)
    summary_date = str(payload.get("summary_date") or "").strip()
    agent_name = str(payload.get("agent_name") or "Eyon").strip() or "Eyon"
    window = payload.get("window") or {}
    mention_rows = payload.get("mention_rows") or []
    reply_rows = payload.get("reply_rows") or []
    repost_rows = payload.get("repost_rows") or []

    if not summary_date:
        raise ValueError("summary_date is required")
    if not isinstance(window, dict):
        raise ValueError("window must be a JSON object")
    if not isinstance(mention_rows, list):
        raise ValueError("mention_rows must be a list")
    if not isinstance(reply_rows, list):
        raise ValueError("reply_rows must be a list")
    if not isinstance(repost_rows, list):
        raise ValueError("repost_rows must be a list")

    total_mentions = len(mention_rows)
    total_replies = count_replies(reply_rows)
    total_reposts = count_reposts(repost_rows)

    if total_mentions == 0 and total_replies == 0 and total_reposts == 0:
        summary_text = f"{summary_date}: no mentions, replies, or reposts."
    else:
        summary_text = (
            f"{summary_date}: {total_mentions} mentions, {total_replies} replies, {total_reposts} reposts."
        )

    record = {
        "summary_date": summary_date,
        "agent_name": agent_name,
        "total_mentions": total_mentions,
        "total_replies": total_replies,
        "total_reposts": total_reposts,
        "summary_text": summary_text[:500],
        "generated_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "source_window": json.dumps({**window, "mention_rows": len(mention_rows), "reply_rows": len(reply_rows), "repost_rows": len(repost_rows)}, ensure_ascii=False),
    }

    dump_json(OUTPUT_FILE, record)
    subprocess.run([
        "python3",
        f"{PROJECT_ROOT}/scripts/data_writer.py",
        "write",
        "--table",
        "result_daily_summary",
        "--conflict",
        "summary_date,agent_name",
        "--run-id",
        os.environ["RUN_ID"],
        "--records",
        json.dumps(record, ensure_ascii=False, separators=(",", ":")),
    ], check=True, env=os.environ.copy())


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        eprint(f"x-daily-report failed: {exc}")
        raise
PY

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: x-daily-report complete"
