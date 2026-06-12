# sync-report

`/report [today|week]` — read the daily and ① roll up task-doc progress (auto, in-vault) ② sync Jira status ③ Confluence. Anything leaving for the company is confirmed first.
**Does NOT post Jira comments/worklogs** — it only points out targets and hands off to `/jira-sync` (separate).

## Scope
- No arg / `today` = today's daily. `week` = all dailies this week (Mon–today) → grouped by epic (for a Friday weekly report).

## Behavior
1. **Read**: in-range daily `## Tasks` (checkbox + its child blocks) + `## Notes`. Group lines by `[tag]` / `(KEY)`.
2. **Task-doc rollup (auto, in-vault)**: append a cumulative bullet to each `projects/<task>.md` `## Progress`:
   - Format `- {date} (KEY): one-line summary` — compress the child block (problem/fix/result) to one line.
   - Don't overwrite. If a bullet with the same `{date}+(key)` exists, update only that line (no duplicate). Remove the placeholder (`(updated by /report)`) on the first real entry.
   - Timeline / open-tasks are handled by queries → don't touch them.
3. **Keyless line check**: gather completed lines without `(KEY)`, ask once "fill the key?" (prerequisite for rollup / Jira linking).
4. **Jira status sync (propose then run, project=<PROJECT_KEY>)**:
   - Propose transitioning `[x]`-done **subtask keys → Done** in Jira.
   - When all of a task's subtasks are done, propose **transitioning the parent task**.
   - Status transitions only here. Comments/worklogs → step 5.
5. **Hand off Jira comments**: list the blocks worth posting (completed + has narrative/links) and suggest "post via `/jira-sync`?". Actual posting / image attach is `/jira-sync`'s job.
6. **Confluence (confirm)**: draft → personal space `<CONFLUENCE_PERSONAL_SPACE>`, finished → team space `<CONFLUENCE_TEAM_SPACE>` (show what goes where, confirm). `week` → an epic-grouped weekly report.
7. **Company repo promotion (confirm, selective)**: polish only the deliverables meant for the company → code-repo `docs/` or an MR.

## Safety / never
- Status transitions, Confluence publish, and repo push are confirmed before running. Never unattended.
- No full vault→company mirroring / no unattended company push / no company code into the vault.
- Dedupe: already-applied progress/transitions are compared by date·key and not repeated.
