# Review — Final Summary Before Deployment

## Agent Card

| Field              | Value                          |
|--------------------|--------------------------------|
| **Name**           | 🤖 Eyon |
| **ID**             | `eyon`           |
| **Version**        | 1.0.0 |
| **Scope**          | A small X-only automation agent that auto-replies to mentions and publishes a concise internal daily summary of replies and reposts.      |
| **Tone**           | helpful, concise, cautious             |
| **Model**          | gpt-4.1-mini (primary), gpt-4o-mini (fallback) |
| **Token Budget**   | 50000 tokens/month |

## Skills Summary

| Skill                     | Mode         |
|---------------------------|--------------|
| Data Writer | 🟢 Auto |
| Result Query | 🟢 Auto |
| GitHub Action | 🟢 Auto |
| X Mention Reply | 🟢 Auto |
| X Daily Report | 🟢 Auto |

## Post-Deployment Checklist

- [ ] Confirm X API credentials are set
- [ ] Confirm database connectivity
- [ ] Run the mention-reply smoke test
- [ ] Run the daily summary smoke test
- [ ] Verify the agent stays X-only
- [ ] Check that no repost automation is enabled
