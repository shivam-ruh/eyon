---
name: x-daily-report
version: 1.0.0
description: Compile one concise internal daily summary of reply and repost activity for Eyon.
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3, jq, date]
      env: [DATABASE_URL, X_API_KEY, X_API_SECRET, X_ACCESS_TOKEN, X_ACCESS_TOKEN_SECRET]
    primaryEnv: DATABASE_URL
---
# X Daily Report

## I/O Contract

- **Input:** `/tmp/x-daily-report_${RUN_ID}.json`
- **Output:** `/tmp/x-daily-report_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
