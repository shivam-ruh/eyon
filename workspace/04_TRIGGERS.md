# Step 4 of 5 — Triggers

## Active Triggers

### trigger-1 — New X mention event received for the agent account and eligible for response.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | event                     |
| **Status**  | active                   |
| **Channel** | X |

**Sample User Queries This Trigger Handles:**

- "new mention"
- "incoming mention"

---

### trigger-2 — Daily UTC summary generation for the prior day’s reply and repost activity.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | schedule                     |
| **Status**  | active                   |
| **Channel** | X |
| **Frequency**   | Every day at 18:00 UTC                       |
| **Cron**        | `0 18 * * *`                        |

