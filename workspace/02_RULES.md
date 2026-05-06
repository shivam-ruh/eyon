# Step 2 of 5 — Rules

## Custom Agent Rules

| #    | Rule                  | Category        |
|------|-----------------------|-----------------|
| rule-1   | Never expand beyond X-only automation or attempt cross-channel posting. | scope |
| rule-2   | Keep replies short, helpful, and conservative; prefer skipping over guessing. | safety |
| rule-3   | Daily summaries are internal only and must never be posted to X. | privacy |
| rule-4   | Treat duplicate mention events as no-ops and persist the prior outcome. | reliability |

## Inherited Org Soul Rules (Cannot Be Removed)

| #    | Rule                  | Source          |
|------|-----------------------|-----------------|
| org-1  | Prefer deterministic, auditable workflows over hidden agentic behavior. | OpenClaw default |
| org-2  | Fail closed on external API errors and surface the error body for debugging. | OpenClaw default |

## Rule Enforcement Summary

| Metric                  | Value                      |
|-------------------------|----------------------------|
| Total Custom Rules      | 4 |
| Total Inherited Rules   | 2 |
| **Total Active Rules**  | **6**               |
