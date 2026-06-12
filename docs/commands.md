# Commands reference

Each command is a thin `.md` in `commands/` that invokes a skill (`SKILL.md`). "Global" = installed in `~/.claude/` (run anywhere); "Vault" = installed in `<vault>/.claude/` (run in the vault).

---

## `/plan` — draft today's tasks  ·  *Vault*

Pulls your open Jira tasks (`assignee = currentUser() AND statusCategory != Done AND project = <PROJECT_KEY>`) and expands each into its **open subtasks**, one daily line each. Carries over yesterday's unfinished lines.

```
/plan
```

- Each line: `- [ ] [task] subtask summary (SUBTASK-KEY)`.
- A task with no subtasks falls back to a single task-level line and offers to split it.
- Jira **read-only**. New tasks prompt to create a project doc.

---

## `/subtask` — create a subtask  ·  *Global*

Creates a Jira subtask under a parent task and adds its line to today's daily. The counterpart of `/log` (adding *planned* work). No need to re-run `/plan`.

```
/subtask                              # lists your project tasks to pick a parent
/subtask PROJ-11 "migrate read path"  # parent by key
/subtask migrate-db "verify cutover"  # parent by tag (projects filename)
```

- Confirms before the Jira write. Assigns the subtask to you (so `/plan` picks it up).
- Adds `- [ ] [task] summary (NEW-KEY)` to today's daily.

---

## `/log` — record finished work  ·  *Global*

Ticks off (or appends) a completed item in today's daily. Run it from a **code repo**: it reads the git branch's `PROJECT_KEY-####` to know which line to complete.

```
/log "cut over the replica, MR !42, dashboard green"
```

- Branch `feature/PROJ-12-cutover` → routes to the `(PROJ-12)` line / tag automatically.
- Writes `- [x] [tag] summary (key) ⏰ HH:MM ✅ today` + an optional `Problem / Fix / Result(links)` block (auto-derived from the diff/MR in a code session).
- **Summaries & links only — never source code.** Simple items stay a single line; captures go as `![[...]]` children (pasted in Obsidian).

---

## `/report` — roll up & propose  ·  *Vault*

End-of-day (or `week`) sync. Reads the daily, rolls the day's blocks into each task doc's `## Progress`, and **proposes** outward actions — it does not post comments.

```
/report
/report week     # Mon–today, grouped by epic for a weekly report
```

- Auto (in-vault): append `- {date} (KEY): summary` to `projects/<task>.md` `## Progress`.
- Propose (confirmed): transition done subtasks → Done; transition a parent when all its subtasks are done; Confluence drafts; company-repo promotion.
- Hands the comment-worthy items to `/jira-sync`.

---

## `/jira-sync` — post comments to Jira  ·  *Vault*

Posts the daily's completed blocks to their Jira issues as **comments**. Idempotent.

```
/jira-sync               # today
/jira-sync week
/jira-sync PROJ-12       # just one key
```

- Collects done lines with a `(KEY)` and a narrative child; skips already-posted ones (a `🔼 Jira #id` marker is added after posting).
- One comment per key (merges that key's blocks). **Preview per issue → confirm → post.**
- Keyless `[misc]` items are offered a key first. Captures are referenced in text and listed for manual attach (the MCP can't upload files).

---

## Placement cheat-sheet

| | Global (`~/.claude/`) | Vault (`<vault>/.claude/`) |
|---|---|---|
| Commands | `log`, `subtask` | `plan`, `report`, `jira-sync` |
| Why | route by git branch, run from any repo | need the whole vault + Jira |

## What writes where

| Command | Vault | Jira | Confluence |
|---|---|---|---|
| `/plan` | ✍ daily | read | — |
| `/subtask` | ✍ daily | ✍ create (confirm) | — |
| `/log` | ✍ daily | — | — |
| `/report` | ✍ project docs | propose status (confirm) | propose (confirm) |
| `/jira-sync` | ✍ marker | ✍ comments (confirm) | — |
