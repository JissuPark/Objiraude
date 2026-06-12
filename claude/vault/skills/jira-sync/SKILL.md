# jira-sync

`/jira-sync [today|YYYY-MM-DD|week|<PROJECT_KEY>-####]` (default today) — post the daily's completed items to their Jira issues as **comments**. The structured blocks `/log` accumulated are the input. This is where `/report` hands off.

## Env
- cloudId `<ATLASSIAN_CLOUD_ID>`, project `<PROJECT_KEY>` (see CLAUDE.md).

## Behavior
1. **Collect**: in-range `daily/*.md` `## Tasks` lines that are **done (`- [x]`)** + have a `(KEY)` + have a narrative/link child. Skip lines that already carry a `🔼 Jira` marker child (idempotent). A `<PROJECT_KEY>-####` arg limits to that key. Tag-agnostic (incl. `[misc]` — only the key matters).
2. **Keyless completed items** (e.g. `[misc]` with narrative but no `(KEY)`): list them and ask once per line "attach a related issue key (epic/task)? → if yes, add `(key)` to the daily line then post / else skip". **No issue creation here** (create it first, e.g. via `/subtask`, then provide the key).
3. **Compose**: group by `(KEY)` → **one comment per key** (merge that range's blocks). Body in markdown, problem/fix/result (+links) from the child block.
   - If `![[capture.png]]` is present, add `> 📎 capture: capture.png (attach manually in Jira)`.
   - If a fenced code block (```) is present, exclude it (post the summary only).
4. **Preview + confirm (batch)**: show "where / what comment" per issue. No posting before confirm.
5. **Post**: `addCommentToJiraIssue` (contentFormat=markdown). If a marker id exists for that key, **update** via `commentId`; else create new.
6. **Marker**: add a child under each posted line `    - 🔼 Jira #<commentId> ({today})`. Lines of the same key share the comment id.
7. **Manual-attach notice**: if any item referenced an image, print the "captures to attach manually in Jira" list after posting.

## Safety / never
- Jira writes → preview then confirm. No unattended posting.
- Completed + has-narrative only. No source code in comments (the daily holds summaries/links only; exclude fenced code).
- Comments only. No status transition (= `/report`), no worklog.

> Note: image attachment isn't possible programmatically — the Atlassian MCP has no attachment-upload tool, so captures are referenced in text and attached by hand.
