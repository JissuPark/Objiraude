# <Your Vault> — Claude rules

Single source of truth for your personal work journal. = Obsidian vault = a private GitHub repo. Markdown only; no company code enters here.

## Hierarchy model (Jira ↔ Obsidian)
- **Epic** (months, shared) → frontmatter `jira-epic` (for rollup/grouping). No project doc.
- **Task** (the work unit you own) → one `projects/<task>.md` = one project doc. frontmatter `jira-task`.
- **Subtask** (the actual execution unit) → one line in the daily file. Each has its own key.
- **Non-project ad-hoc** (one-off / ops) → `[misc]` tag + `projects/misc.md` (collection-only, no `jira-task`). Key optional — add a related issue key to make it postable via `/jira-sync`, else it's a personal record.

## Core principle: write once, see two views
- Record **only as one checkbox line in the daily `## Tasks`**. Never copy into the project doc (queries collect it).
- Date view = the daily file. Task view = `projects/<task>.md` Tasks queries (grouped by subtask key).

## Task line format (the key that links both views)
```
- [ ] [task] subtask content (<PROJECT_KEY>-####)
- [x] [task] subtask content (<PROJECT_KEY>-####) ⏰ 14:30 ✅ 2026-06-12
```
- `[task]` = matches a `projects/` filename → Tasks query collects via `description includes [task]`.
- `(<PROJECT_KEY>-####)` = the **subtask key** for that line (else the task key). The project doc groups its timeline by this key.
- Done = `[x] ... ⏰ HH:MM ✅ YYYY-MM-DD`. `⏰ time` = completion time (human). `✅ date` = the Tasks done-date field (for queries; keep it even though the filename repeats the date). Claude adds both when checking off.
- Rich records may add indented `Problem / Fix / Result(link)` children under the checkbox (the checkbox stays one line → queries still collect). A code-session `/log` writes these automatically.

## Config values (fill these in)
- Jira: `<ATLASSIAN_SITE>` (cloudId `<ATLASSIAN_CLOUD_ID>`), project key **<PROJECT_KEY>**. "Project" = an epic in <PROJECT_KEY>.
- Confluence personal (draft) space: `<CONFLUENCE_PERSONAL_SPACE>` · team (published) space: `<CONFLUENCE_TEAM_SPACE>`.
- My Atlassian accountId: `<YOUR_ATLASSIAN_ACCOUNT_ID>` (for assigning created subtasks).

## Routing / safety
- Daily·notes → personal GitHub. Company code deliverables → company repo (outside the vault). Drafts → personal Confluence space. Finished → team space (promote, confirm). Status/tickets → Jira <PROJECT_KEY>.
- Company repo push · team-space publish · Jira status transition are confirmed before running. Access company code only via `/add-dir ../<repo>`.
- A code-session `/log` (global skill) routes by the git branch `<PROJECT_KEY>-####` and writes **summaries & links only** to the vault daily. Never bring source code into the vault.

## Filenames
- Tag = projects filename. Non-ASCII filenames are fine; if zipping on Windows, extract with `tar -xf` or 7-Zip to preserve them.
