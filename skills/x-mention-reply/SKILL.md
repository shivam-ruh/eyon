---
name: x-mention-reply
version: 1.0.0
description: "Normalize one X mention, decide whether to reply, post a short reply, and persist the mention outcome."
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3, curl, jq, date]
      env: [DATABASE_URL, X_API_KEY, X_API_SECRET, X_ACCESS_TOKEN, X_ACCESS_TOKEN_SECRET]
    primaryEnv: X_ACCESS_TOKEN
---
# X Mention Reply

## I/O Contract

- **Input:** `/tmp/x-mention-reply_${RUN_ID}.json`
- **Output:** `/tmp/x-mention-reply_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
