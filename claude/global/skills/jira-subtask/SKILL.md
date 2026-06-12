# jira-subtask (global)

`/subtask [parent|key] [summary]` — **create a subtask in Jira** and add its line to today's daily `## Tasks`. Runs anywhere (including code repos). No need to re-run `/plan`. The counterpart of `/log` (= adding planned work).

## Vault / env
- `VAULT = <VAULT_PATH>`
- cloudId `<ATLASSIAN_CLOUD_ID>`, project `<PROJECT_KEY>`, subtask issuetype = **"Sub-task"** (your project's subtask type name). My accountId `<YOUR_ATLASSIAN_ACCOUNT_ID>`.

## Behavior
1. **Determine the parent task**:
   - If a parent is passed (`<PROJECT_KEY>-####` or `[tag]`/filename), use it.
   - Else list `$VAULT/projects/*.md` (excluding `_template` and `misc`) with their `jira-task` + title, and let the user pick.
   - Establish the parent key ↔ `[tag]` (= projects filename) mapping. (If the parent has no project doc, ask for the tag or offer to create one from `_template`.)
2. **Get the summary**: ask if not in the args. (Optional: a one-line description.)
3. **Confirm (required, Jira write)**: "Create subtask 'summary' under <PROJECT_KEY>-parent(title) + add `- [ ] [tag] summary (NEW-KEY)` to today's daily — proceed?"
4. **Create in Jira**: `createJiraIssue`(projectKey=<PROJECT_KEY>, issueTypeName="Sub-task", parent=parentKey, summary=summary, assignee=me) → get the new key. On failure (e.g. required fields) report the error verbatim and stop.
5. **Reflect in Obsidian**: add `- [ ] [tag] summary (NEW-KEY)` to today's `daily/YYYY-MM-DD.md` (create from template if missing). Open (`[ ]`), assigned to me so the next `/plan` picks it up.
6. Report the new key + the daily change. If a fallback task-level line for the parent exists in today's daily, offer once to remove it (now superseded by the subtask).

## Safety
- Jira issue creation is confirmed before running. Never unattended.
- Vault write by absolute path (may be outside the cwd) → grant permission on first run.
- Titles/summaries only (no source code).
