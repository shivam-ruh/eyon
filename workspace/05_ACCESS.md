# Step 5 of 5 — Access

## User Access

### Authorized Teams

| Team               | Access Level | Members (approx) |
|--------------------|-------------|-------------------|
| general users | read/write | everyone |

### Restricted From

| Team / Role          | Reason                          |
|----------------------|---------------------------------|
| operators | Do not broaden the scope into multi-channel or fully autonomous growth tooling. |

## HiTL Approvers

| Skill                | Action                         | Approver             | Fallback Approver    |
|----------------------|--------------------------------|----------------------|----------------------|
| x-mention-reply | approve risky or ambiguous replies | operator review | skip the reply and log the mention |
| x-daily-report | approve reporting changes | operator review | regenerate the summary from the same daily window |

## Model Configuration

| Field                | Value                          |
|----------------------|--------------------------------|
| **Primary Model**    | gpt-4.1-mini   |
| **Fallback Model**   | gpt-4o-mini  |

## Token Budget

| Field                  | Value                  |
|------------------------|------------------------|
| **Monthly Budget**     | 50000 tokens |
| **Alert Threshold**    | 40000 tokens |
| **Auto-Pause on Limit**| Yes |

## Security & Permissions

| Permission                         | Allowed    |
|------------------------------------|------------|
| X read mentions | ✅ |
| X post replies | ✅ |
| X post reposts | ❌ |
| database read/write | ✅ |
