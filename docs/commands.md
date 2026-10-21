# Commands reference

Each command is a thin `.md` in `commands/` that invokes a skill (`SKILL.md`). "Global" = installed in `~/.claude/` (run anywhere); "Vault" = installed in `<vault>/.claude/` (run in the vault). Two entries (`/runbook`, `/data-request`) ship as skills with no command file — invoke them by name.

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

## `/todo` — capture an open line  ·  *Global*

Appends a single open `- [ ]` line to today's daily — a quick capture for something that needs recording but isn't worth a Jira subtask. The keyless sibling of `/subtask`, and the open counterpart of `/log`. **No Jira write, no key created.**

```
/todo "ping infra about the quota bump"            # → [misc], no key
/todo [migrate-db] "double-check the rollback path"
/todo "follow up on the review" (PROJ-1234)        # attach a related key by hand
```

- Tag routing: an explicit `[tag]` wins; else the git branch's key → its tag; else a keyword match; else `[misc]`. When unclear it stays `[misc]` rather than prompting — capture should be frictionless.
- A single line, **no child block** (nothing's been done yet). Complete it later with `/log`; promote it to a tracked ticket with `/subtask`.

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

## `/wrapup` — unattended end-of-day close-out  ·  *Vault*

Runs the whole evening routine hands-free: collects the day's Claude sessions across your repos, backfills missed `/log` lines, rolls up task docs, writes a **pending-publish list** (instead of publishing), drafts the next working day's plan, then commits & pushes the vault. Built to be invoked by a local routine — e.g. a Claude Desktop Scheduled Task every evening.

```
/wrapup               # close out the last working day
/wrapup 2026-06-12    # close out a specific day
```

- **No external writes** — Jira is read-only; comments / status transitions / Confluence go into a `### Pending publishes (wrapup)` block in the daily's `## Notes`, for you to review next morning via `/jira-sync` and `/report`.
- Backfill and rollup are idempotent; anything ambiguous is parked as "needs review" rather than guessed (a miss beats a wrong record).
- If the vault is a git repo, it auto-commits & pushes at the end — skipped when nothing changed, secret-pattern guard before pushing, a failed push is reported (never forced).
- A morning run naturally becomes a catch-up: close out yesterday + plan today.

---

## `/doc` — conversation → Confluence draft  ·  *Global*

Reads the current conversation, distills it into a typed draft in your **personal** Confluence space, and updates that same page the next time you call it on the same topic. A registry (`confluence/index.md`) maps topic → page id.

```
/doc design "chapter-split API"
/doc worklog "cutover"
```

- Body types (`plan`, `criteria`, `design`) merge into the page body and add a changelog line; thread types (`worklog`, `discussion`) keep the body and append the round as a footer comment. Anything else is free form.
- **Preview → confirm → publish**, personal space only. Promotion to the team space is `/report`'s proposal.
- After saving it tells you `/compact` is now safe — that's the point: capture the conversation once, then drop it.

---

## `/runbook` — handover runbook  ·  *Global (skill only)*

Turns the build·config·deploy work done in this session into a document someone else can use to **produce the same result again**: environment, the commands actually run, where to check, how to roll back, why each decision was made. Where `/doc guide` is "how to read it", a runbook is "how it was built".

```
/runbook "Grafana for the GPU hosts"
```

- 11 fixed sections → Confluence draft in the personal space, one registry line, one daily line.
- **Only commands that actually ran** (anything abandoned goes under "Tried and rejected"); secrets and production IPs become placeholders; an empty section says "N/A" instead of being padded with guesses.
- Invoked by skill name — there is no `commands/runbook.md`.

---

## `/data-request` — intake → ticket → analysis → close  ·  *Global (skill only)*

Handles one incoming data request from another team end to end: open an issue under the standing support epic with the request quoted verbatim, move it to In Progress, run the analysis in a background agent, and — after you review the numbers — write the result into the issue and close it.

```
/data-request "could we get last month's signups by channel?"
```

- Creating the issue and the In Progress transition are covered by the call itself. **Recording the result and closing happen only after your review.**
- The agent is read-only, returns aggregates (never a list of individuals), a reproducible SQL file and a draft reply. The reply is never sent for you.
- Transitions are chosen by reading the live transition list at each step (`to.name`), never by guessing a transition's name.
- Needs five extra config values — see [setup](setup.md#4-install-the-commands--skills). Invoked by skill name; there is no `commands/data-request.md`.

---

## `/month` — close out a month  ·  *Vault*

Not a bigger `/wrapup`. It looks only at what a single day can't show: lines that have been open for weeks, publish and rollup holes, misjudgements that keep repeating. Writes `projects/retro-YYYY-MM.md`.

```
/month            # last month (or this month, mid-month, marked partial)
/month 2026-09
```

- Tally on four axes (project · subtask · activity type · ISO week) + a cross table. A line matching no activity type is **asked about, never guessed** — inventing a number is this command's worst failure.
- Long-open lines are counted from the **next month's first daily**: the month's own last daily is always empty, because `move-on-plan` has already moved the open leaves out of it.
- Audit only — holes are written down and handed to `/jira-sync` and `/report`, not fixed. Unattended (no external writes) and idempotent; a re-run preserves the hand-written section.

---

## Placement cheat-sheet

| | Global (`~/.claude/`) | Vault (`<vault>/.claude/`) |
|---|---|---|
| Commands | `log`, `subtask`, `todo`, `doc` | `plan`, `report`, `jira-sync`, `wrapup`, `month` |
| Skills, no command | `runbook`, `data-request` | — |
| Why | route by git branch, run from any repo | need the whole vault + Jira |

## What writes where

| Command | Vault | Jira | Confluence |
|---|---|---|---|
| `/plan` | ✍ daily | read | — |
| `/todo` | ✍ daily | — | — |
| `/subtask` | ✍ daily | ✍ create (confirm) | — |
| `/log` | ✍ daily | — | — |
| `/report` | ✍ project docs | propose status (confirm) | propose (confirm) |
| `/jira-sync` | ✍ marker | ✍ comments (confirm) | — |
| `/wrapup` | ✍ daily + project docs (+ git push) | read | — |
| `/doc` | ✍ registry | — | ✍ draft (confirm) |
| `/runbook` | ✍ daily + registry | — | ✍ draft (confirm) |
| `/data-request` | ✍ daily | ✍ create + close (close confirmed) | — |
| `/month` | ✍ retro doc (+ git push) | read | — |
