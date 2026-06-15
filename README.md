<p align="center">
  <img src="assets/logo.svg" width="124" alt="Objiraude logo"/>
</p>

<h1 align="center">Objiraude</h1>

**Obsidian × Jira × Claude** — a daily worklog pipeline that records your work **once** and turns it into Jira comments, Confluence drafts, and per-task timelines automatically.

You write a single checkbox line in your Obsidian daily note. Claude Code routes it to the right Jira issue, rolls it up into per-task timelines, and — on your confirmation — posts comments and syncs status. No re-typing the same update in four places.

> **Objiraude** = **Ob**sidian + **jira** + cla**ude**

---

## Why

Engineers keep the same work in four places: a personal to-do, a daily journal, Jira tickets, and Confluence reports. They drift apart. Objiraude makes the **daily note the single source of truth** and treats everything else as a *derived view* or a *confirmed push*.

## How it works — write once, see two views

- **You write once** — one checkbox line per subtask in `daily/YYYY-MM-DD.md`.
- **Date view** = the daily file itself.
- **Task view** = `projects/<task>.md`, whose Tasks/Dataview queries auto-collect the matching daily lines into a per-task timeline. You never copy anything by hand.

```
daily/2026-06-12.md                      projects/migrate-db.md
─────────────────────                    ─────────────────────
## Tasks                  ── query ──▶   ## Timeline (by subtask)
- [x] [migrate-db] cut over (PROJ-12) ✅    PROJ-12  ✅ cut over
- [ ] [migrate-db] verify  (PROJ-13)        PROJ-13  ▢ verify
```

The Jira hierarchy maps cleanly:

```
Epic        (months, shared)       → frontmatter jira-epic, no doc
  └ Task    (your work unit)       → projects/<task>.md   (one doc each)
      └ Subtask (execution unit)   → one daily line:  - [ ] [task] … (KEY)
Non-project ad-hoc (one-off/ops)   → [misc] tag + projects/misc.md
```

## The pipeline — 6 Claude Code commands

| Command | Runs in | What it does | Writes |
|---|---|---|---|
| `/plan` | vault | Draft today's tasks from your open Jira, expanded **by subtask** | daily |
| `/todo` | anywhere | Capture an ad-hoc open line — no Jira, no key | daily |
| `/subtask` | anywhere | Create a Jira subtask + add its daily line | Jira + daily |
| `/log` | anywhere | Record finished work (auto-routed by the git branch's issue key) | daily |
| `/report` | vault | Roll up task progress; **propose** Jira status / Confluence | daily (+ proposes) |
| `/jira-sync` | vault | Post the daily's completed blocks to Jira issues as comments | Jira |

`/log`, `/subtask`, and `/todo` are **global** — run them from any source-code repo. `/log` and `/subtask` read the current git branch (e.g. `feature/PROJ-13-...`), extract the issue key, and write back to the vault; `/todo` just appends an open line (branch key used only if present). `/plan`, `/report`, `/jira-sync` live in the vault (they need the whole vault + Jira access).

## A day with Objiraude

```
morning   /plan                          → today's daily filled from your open Jira
anytime   /todo "ping infra re: quota"   → open [misc] line, no Jira — jot before you forget
in repo   /subtask PROJ-11 "migrate db"  → new Jira subtask + a daily line
in repo   /log "cut over done, MR !42"   → checkbox ticked; branch PROJ-12 auto-routed
EOD       /report                        → task docs rolled up; status & comments proposed
          /jira-sync                      → comments posted to each issue (after preview)
```

## Quick start

1. **Prerequisites** — [Obsidian](https://obsidian.md), [Claude Code](https://claude.com/claude-code), and an Atlassian (Jira/Confluence) MCP connected in Claude Code.
2. **Create your vault** — copy `vault-template/` into a new folder and open it in Obsidian.
3. **Plugins** — install **Tasks**, **Dataview**, **Obsidian Git**; in Tasks settings enable **Custom searches** (required by the timeline queries).
4. **Fill config** — replace the `<PLACEHOLDERS>` in `CLAUDE.md` and the skills (Jira cloud id, project key, vault path, account id).
5. **Install commands/skills** — copy `claude/global/*` → `~/.claude/` and `claude/vault/*` → `<vault>/.claude/`.
6. Run `/plan`.

→ Full walk-through: **[docs/setup.md](docs/setup.md)**.

## Configuration

| Placeholder | What it is | Appears in |
|---|---|---|
| `<VAULT_PATH>` | absolute path to your Obsidian vault | global skills, CLAUDE.md |
| `<PROJECT_KEY>` | Jira project key (e.g. `PROJ`) | skills, templates, CLAUDE.md |
| `<ATLASSIAN_CLOUD_ID>` | Jira/Confluence cloud id | `jira-*` skills, CLAUDE.md |
| `<ATLASSIAN_SITE>` | `yourco.atlassian.net` | CLAUDE.md |
| `<YOUR_ATLASSIAN_ACCOUNT_ID>` | your account id (subtask assignee) | jira-subtask, CLAUDE.md |
| `<CONFLUENCE_PERSONAL_SPACE>` | draft space key | sync-report, CLAUDE.md |
| `<CONFLUENCE_TEAM_SPACE>` | published space key | sync-report, CLAUDE.md |

## Repo layout

```
Objiraude/
├── README.md
├── docs/
│   ├── concept.md        # the model in depth
│   ├── setup.md          # detailed install & config
│   └── commands.md       # per-command reference
├── claude/
│   ├── global/           # → copy to ~/.claude/   (run from anywhere)
│   │   ├── commands/      #   log.md, subtask.md, todo.md
│   │   └── skills/        #   daily-log/, jira-subtask/, todo/
│   └── vault/            # → copy to <vault>/.claude/  (run in the vault)
│       ├── commands/      #   plan.md, report.md, jira-sync.md
│       └── skills/        #   daily-plan/, sync-report/, jira-sync/
└── vault-template/        # → copy into a new Obsidian vault
    ├── CLAUDE.md          #   vault rules + your config
    ├── daily/_template.md
    ├── projects/_template.md
    ├── projects/misc.md
    ├── dashboard.md
    └── .obsidian/community-plugins.json
```

## Design choices

- **Single source of truth.** Only the daily is written by hand. Project docs and Jira comments are derived; status transitions and external publishes are always confirmed.
- **Branch-key routing.** `/log` and `/subtask` work from your code repos because the branch name carries the Jira key — no need to tell Claude which task you mean.
- **Separation of concerns.** `/report` *proposes* (status, Confluence); `/jira-sync` *posts* comments. Each is one job, composable.
- **Safety.** Company code never enters the vault — only summaries and links. Anything leaving for the company is confirmed first.

## Limitations

- Jira comment **image attachment isn't automated** (the Atlassian MCP has no upload tool) — captures are referenced in text and attached by hand.
- The timeline view relies on the Tasks plugin's scripting, so **Tasks → Custom searches** must be enabled.

## Docs

- **[Concept](docs/concept.md)** — the model, in depth
- **[Setup](docs/setup.md)** — detailed install & configuration
- **[Commands](docs/commands.md)** — per-command reference

## License

[MIT](LICENSE)
