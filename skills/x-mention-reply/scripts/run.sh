#!/usr/bin/env bash
# Auto-generated script for x-mention-reply
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="x-mention-reply"
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
INPUT_FILE="/tmp/x-mention-reply_${RUN_ID}.json"
OUTPUT_FILE="/tmp/x-mention-reply_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY'
import base64
import hashlib
import hmac
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid
from datetime import datetime, timezone

INPUT_FILE = os.environ["INPUT_FILE"]
OUTPUT_FILE = os.environ["OUTPUT_FILE"]
PROJECT_ROOT = os.environ["PROJECT_ROOT"]

X_API_BASE = "https://api.x.com/2"


def eprint(*args):
    print(*args, file=sys.stderr)


def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def dump_json(path, payload):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")


def iso_now():
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def parse_dt(value):
    if not value:
        return None
    if isinstance(value, (int, float)):
        return datetime.fromtimestamp(value, tz=timezone.utc)
    text = str(value).strip()
    if not text:
        return None
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    try:
        dt = datetime.fromisoformat(text)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt.astimezone(timezone.utc)
    except ValueError:
        return None


def oauth1_header(method, url, query_params=None):
    query_params = query_params or {}
    consumer_key = os.environ["X_API_KEY"]
    consumer_secret = os.environ["X_API_SECRET"]
    token = os.environ["X_ACCESS_TOKEN"]
    token_secret = os.environ["X_ACCESS_TOKEN_SECRET"]

    oauth_params = {
        "oauth_consumer_key": consumer_key,
        "oauth_nonce": uuid.uuid4().hex,
        "oauth_signature_method": "HMAC-SHA1",
        "oauth_timestamp": str(int(time.time())),
        "oauth_token": token,
        "oauth_version": "1.0",
    }

    base_params = {**query_params, **oauth_params}
    encoded = []
    for key in sorted(base_params):
        encoded.append((urllib.parse.quote(str(key), safe="~"), urllib.parse.quote(str(base_params[key]), safe="~")))
    param_string = "&".join(f"{k}={v}" for k, v in encoded)
    base_elems = [
        method.upper(),
        urllib.parse.quote(url, safe="~"),
        urllib.parse.quote(param_string, safe="~"),
    ]
    base_string = "&".join(base_elems)
    signing_key = f"{urllib.parse.quote(consumer_secret, safe='~')}&{urllib.parse.quote(token_secret, safe='~')}"
    signature = base64.b64encode(
        hmac.new(signing_key.encode("utf-8"), base_string.encode("utf-8"), hashlib.sha1).digest()
    ).decode("utf-8")
    oauth_params["oauth_signature"] = signature

    header_parts = []
    for key in sorted(oauth_params):
        header_parts.append(f'{urllib.parse.quote(key, safe="~")}="{urllib.parse.quote(oauth_params[key], safe="~")}"')
    return "OAuth " + ", ".join(header_parts)


def post_reply(in_reply_to_tweet_id, reply_text):
    url = f"{X_API_BASE}/tweets"
    body = json.dumps({"text": reply_text, "reply": {"in_reply_to_tweet_id": in_reply_to_tweet_id}}).encode("utf-8")
    req = urllib.request.Request(url, data=body, method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("Authorization", oauth1_header("POST", url))
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            status = getattr(resp, "status", resp.getcode())
            raw = resp.read().decode("utf-8")
            if status < 200 or status >= 300:
                eprint(f"X API error status={status} body={raw}")
                raise RuntimeError(f"X API returned {status}")
            payload = json.loads(raw) if raw else {}
            tweet_id = payload.get("data", {}).get("id")
            posted_text = payload.get("data", {}).get("text") or reply_text
            return tweet_id, posted_text
    except urllib.error.HTTPError as exc:
        body_text = exc.read().decode("utf-8", errors="replace")
        eprint(f"X API error status={exc.code} body={body_text}")
        raise


def normalize_mention(payload):
    mention = payload.get("mention") or payload
    config = payload.get("config") or {}
    if not isinstance(mention, dict):
        raise ValueError("input.mention must be a JSON object")
    mention_id = str(mention.get("mention_id") or "").strip()
    if not mention_id:
        raise ValueError("mention_id is required")
    author_id = str(mention.get("x_author_id") or "").strip()
    author_handle = str(mention.get("x_author_handle") or "").strip()
    mention_text = str(mention.get("mention_text") or "").strip()
    mention_created_at = str(mention.get("mention_created_at") or "").strip()
    return mention, config, {
        "mention_id": mention_id,
        "agent_name": str(config.get("agent_name") or "Eyon").strip() or "Eyon",
        "x_author_id": author_id,
        "x_author_handle": author_handle,
        "mention_text": mention_text,
        "mention_created_at": mention_created_at,
    }


def draft_reply(payload, mention_text):
    if isinstance(payload.get("reply_text"), str) and payload["reply_text"].strip():
        text = payload["reply_text"].strip()
    else:
        style = str((payload.get("config") or {}).get("reply_style") or "concise").lower()
        lowered = mention_text.lower()
        if "thank" in lowered:
            text = "Thanks for the mention — glad it helped."
        elif "?" in mention_text:
            text = "Thanks for the mention — happy to help."
        elif style in {"warm", "friendly"}:
            text = "Thanks for the mention — happy to help."
        else:
            text = "Thanks for the mention — noted."
    return text[:260].strip()


def build_raw_mention(mention):
    return {
        "mention_id": mention.get("mention_id"),
        "x_author_id": mention.get("x_author_id"),
        "x_author_handle": mention.get("x_author_handle"),
        "mention_text": mention.get("mention_text"),
        "mention_created_at": mention.get("mention_created_at"),
    }


def main():
    payload = load_json(INPUT_FILE)
    mention, config, normalized = normalize_mention(payload)
    now = iso_now()
    mention_dt = parse_dt(normalized["mention_created_at"])
    replied_at = now if mention_dt is not None else now
    latency = None
    if mention_dt is not None:
        latency = max(0, int((datetime.now(timezone.utc) - mention_dt).total_seconds()))

    if payload.get("existing_record"):
        record = payload["existing_record"]
        if not isinstance(record, dict):
            raise ValueError("existing_record must be a JSON object")
        for key in ["mention_id", "agent_name", "x_author_id", "x_author_handle", "mention_text", "mention_created_at", "reply_status", "reply_text", "reply_post_id", "replied_at", "response_latency_seconds", "raw_mention"]:
            if key not in record:
                record[key] = None
        dump_json(OUTPUT_FILE, record)
        subprocess.run([
            "python3",
            f"{PROJECT_ROOT}/scripts/data_writer.py",
            "write",
            "--table",
            "result_mention_context",
            "--conflict",
            "mention_id",
            "--run-id",
            os.environ["RUN_ID"],
            "--records",
            json.dumps(record, ensure_ascii=False, separators=(",", ":")),
        ], check=True, env=os.environ.copy())
        return

    if payload.get("dedupe_hit"):
        record = {
            "mention_id": normalized["mention_id"],
            "agent_name": normalized["agent_name"],
            "x_author_id": normalized["x_author_id"],
            "x_author_handle": normalized["x_author_handle"],
            "mention_text": normalized["mention_text"],
            "mention_created_at": normalized["mention_created_at"],
            "reply_status": "skipped",
            "reply_text": None,
            "reply_post_id": None,
            "replied_at": None,
            "response_latency_seconds": None,
            "raw_mention": json.dumps(build_raw_mention(normalized), ensure_ascii=False),
        }
        dump_json(OUTPUT_FILE, record)
    elif not bool(config.get("reply_enabled", True)):
        record = {
            "mention_id": normalized["mention_id"],
            "agent_name": normalized["agent_name"],
            "x_author_id": normalized["x_author_id"],
            "x_author_handle": normalized["x_author_handle"],
            "mention_text": normalized["mention_text"],
            "mention_created_at": normalized["mention_created_at"],
            "reply_status": "skipped",
            "reply_text": None,
            "reply_post_id": None,
            "replied_at": None,
            "response_latency_seconds": None,
            "raw_mention": json.dumps(build_raw_mention(normalized), ensure_ascii=False),
        }
        dump_json(OUTPUT_FILE, record)
    else:
        if payload.get("should_reply") is False:
            reply_status = "skipped"
            reply_text = None
            reply_post_id = None
            replied_at_value = None
            latency_value = None
        else:
            reply_text = draft_reply(payload, normalized["mention_text"])
            if not reply_text:
                reply_status = "skipped"
                reply_post_id = None
                replied_at_value = None
                latency_value = None
            else:
                reply_status = "posted"
                tweet_id, posted_text = post_reply(normalized["mention_id"], reply_text)
                reply_post_id = tweet_id
                reply_text = posted_text or reply_text
                replied_at_value = now
                latency_value = latency

        record = {
            "mention_id": normalized["mention_id"],
            "agent_name": normalized["agent_name"],
            "x_author_id": normalized["x_author_id"],
            "x_author_handle": normalized["x_author_handle"],
            "mention_text": normalized["mention_text"],
            "mention_created_at": normalized["mention_created_at"],
            "reply_status": reply_status,
            "reply_text": reply_text,
            "reply_post_id": reply_post_id,
            "replied_at": replied_at_value,
            "response_latency_seconds": latency_value,
            "raw_mention": json.dumps(build_raw_mention(normalized), ensure_ascii=False),
        }
        dump_json(OUTPUT_FILE, record)

    subprocess.run([
        "python3",
        f"{PROJECT_ROOT}/scripts/data_writer.py",
        "write",
        "--table",
        "result_mention_context",
        "--conflict",
        "mention_id",
        "--run-id",
        os.environ["RUN_ID"],
        "--records",
        json.dumps(load_json(OUTPUT_FILE), ensure_ascii=False, separators=(",", ":")),
    ], check=True, env=os.environ.copy())


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        eprint(f"x-mention-reply failed: {exc}")
        raise
PY

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: x-mention-reply complete"
