# Step 3 of 5 — Skills

## Added Skills

| #    | Skill ID                  | Skill Name               | Mode   | Risk Level | Description                |
|------|---------------------------|--------------------------|--------|------------|----------------------------|
| S1   | `data-writer` | Data Writer | Auto | Low | Provision, write, and query the agent database schema via scripts/data_writer.py. Use for all PostgreSQL operations and any result-table persistence. |
| S2   | `result-query` | Result Query | Auto | Low | Read stored records from the agent result tables for inspection and follow-up questions. |
| S3   | `github-action` | GitHub Action | Auto | Low | Git branch + PR workflow for syncing agent changes to GitHub. Creates feature branches, commits changes, and opens pull requests against main. NEVER pushes to main directly. MANDATORY for every agent. |
| S4   | `x-mention-reply` | X Mention Reply | Auto | Low | Normalize one X mention, decide whether to reply, post a short reply, and persist the mention outcome. |
| S5   | `x-daily-report` | X Daily Report | Auto | Low | Compile one concise internal daily summary of reply and repost activity for Eyon. |

## Skill Dependencies (Execution Order)

```
data-writer
result-query
github-action
x-mention-reply
x-daily-report ← depends on x-mention-reply
```

## Execution Mode Summary

| Mode  | Count          |
|-------|----------------|
| HiTL  | 0              |
| Auto  | 5 |
