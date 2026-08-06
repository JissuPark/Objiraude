# wrapup

`/wrapup [YYYY-MM-DD]` (default = last working day) — end-of-day close-out: collect sessions → backfill logs → roll up reports → write the pending-publish list → draft the next working day's plan. The body an evening local routine (e.g. a Claude Desktop Scheduled Task) invokes. **Built to run unattended — external writes (Jira write, Confluence, company repo) are fully prohibited.**

## Env
- cloudId `<ATLASSIAN_CLOUD_ID>`, project `<PROJECT_KEY>` (read-only).
- Vault = the current working directory (a scheduled routine should launch Claude Code with the vault as cwd).

## 0. Pin the date (mandatory first — never guess)
- **Run** `date +"%Y-%m-%d %H:%M"` to measure the current time. Never infer today from conversation context or filenames (a recurring source of past-date accidents).
- **Close-out day** = the argument date; else the last working day with records in `daily/*.md` (usually: evening run = today, morning catch-up = yesterday).
- **Plan day** = today (the next business day when run in the evening). Weekend/holiday → the next business day.
- A morning catch-up run should naturally behave as "close out yesterday + plan today".

## 1. Collect sessions (across all project folders)
- List **every project's sessions** active on the close-out day with the session-management tools (`mcp__ccd_session_mgmt__list_sessions`); when a summary is thin, supplement with `get_session` / `search_session_transcripts`.
- From each session extract: what was done (summary) / the git branch's `<PROJECT_KEY>-####` / done or not / links (MR·doc).
- Tools unsupported or failing: continue with only what the vault daily already holds, and leave one line in Notes: `⚠️ session collection failed — manual /log needed` (do not abort).

## 2. Backfill logs (reuses the daily-log rules)
- Diff the close-out day's `daily/<date>.md` `## Tasks` against the collected sessions — backfill **only completed work missing from the daily**.
- Format: `- [x] [tag] summary (KEY) ⏰ HH:MM ✅ <date>` + indented narrative children (Problem/Fix/Result, one fact per line). ⏰ may be omitted when the time is unknown (✅ is mandatory).
- Tag/key routing: branch `<PROJECT_KEY>-####` → existing daily lines / `projects/*.md` frontmatter mapping. Unknown → `[misc]`.
- **Never bring source code into the vault** — summaries, file paths, links only.
- Idempotent: skip already-recorded work. When done-ness is ambiguous, don't backfill — park it in step 4's list as "needs review" (a miss beats a duplicate or a wrong record).

## 3. Roll up reports (in-vault only, sync-report step 2)
- Group the close-out day's completed items by key → append a cumulative bullet `- {date} (<PROJECT_KEY>-####): one-line summary` to each `projects/<task>.md` `## Progress`.
- If a bullet with the same `{date}+(key)` already exists, update only that line (no duplicate adds). If rollup holes (unreflected days) show up since the previous working day, backfill them too.

## 4. Pending-publish list (write only — never publish)
- Append a block at the end of the close-out day's daily `## Notes` (refresh on re-run):
  ```
  ### Pending publishes (wrapup)
  - Jira comments: <PROJECT_KEY>-#### — <gist> (done + narrative + key, lines without a 🔼 marker)
  - Status-transition candidates: <PROJECT_KEY>-#### <current>→<proposed> — <why>
  - Confluence promotion candidates: <doc> → <CONFLUENCE_TEAM_SPACE>
  - Needs review: <items with ambiguous done-ness or tag>
  ```
- This is the next day's input: the user reviews it and publishes via `/jira-sync` and `/report`.

## 5. Draft the plan (reuses the daily-plan rules)
- Create the plan day's `daily/` file + query your open Jira (excluding on-hold statuses) + **move-on-plan carryover** (move/delete the previous daily's open leaves, preserve completed/logged lines — daily-plan's safety clause verbatim).
- Jira query fails (expired connector etc.): build the plan from vault carryover only and note `⚠️ Jira unqueried — reconnect and re-run /plan recommended` (do not abort).
- If the plan file already exists, don't overwrite — merge open items only.

## 6. Vault commit & push (only when the vault is a git repo)
- No `.git` in the vault, or nothing changed → skip.
- **Secret guard**: grep the pending diff for secret patterns (`api[_-]?key`, `secret`, `token`, `password`, `BEGIN .* PRIVATE KEY`, …) — on a hit, don't commit or push; list the matches under step 4's "Needs review" and report.
- Else commit everything (e.g. `wrapup: close out {date}`) and `git push`. A failed push (auth/network) is reported in the summary and skipped — never abort the close-out, **never force-push**.

## 7. Summary output
- The final message: N backfilled / N rolled up / N pending publishes / plan created (day) / commit·push result / failures & needs-review items. The routine's run log should need nothing beyond this summary.

## Safety (unattended — top priority)
- **External writes fully prohibited**: Jira comments·worklogs·status transitions·issue creation, Confluence create/update, company-repo push. Jira is JQL **read-only**. The only push is the vault's own private repo (step 6).
- Only vault files are modified. The only deletion is move-on-plan's open-leaf move (never delete completed lines, narratives, or 🔼 markers).
- When unsure, don't act — leave it as "needs review". Every step is idempotent on re-run (backfill, rollup, pending list, plan, commit).
