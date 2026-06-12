Post the daily's completed items to their Jira issues as comments (`$ARGUMENTS`, default today). Follow the `jira-sync` skill.

- Group by `(KEY)`, one comment per key, body from the daily child block (problem/fix/result/links).
- Preview per issue → confirm → post. No unattended posting.
- After posting, add a `🔼 Jira #<id>` marker (idempotent; re-run skips or updates).
- Captures are referenced in text only; print a manual-attach list (the MCP can't upload attachments).
