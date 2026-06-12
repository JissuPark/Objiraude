# Concept

## The problem

The same piece of work shows up in four places:

1. a personal to-do list,
2. a daily journal / standup notes,
3. Jira tickets (status, comments, worklogs),
4. Confluence reports (weekly, project).

Kept by hand, they drift. You update Jira but forget the journal; you write a weekly report by re-reading Jira; your to-do and the tickets disagree. Objiraude removes the duplication.

## One record, two views

The **daily note is the single source of truth**. You record work as one checkbox line:

```
- [ ] [migrate-db] cut over the read replica (PROJ-12)
- [x] [migrate-db] cut over the read replica (PROJ-12) ⏰ 14:30 ✅ 2026-06-12
```

Two views come out of that one line, for free:

- **Date view** — the daily file `daily/YYYY-MM-DD.md` itself.
- **Task view** — `projects/migrate-db.md`, whose embedded Tasks/Dataview queries collect every daily line tagged `[migrate-db]` and group them into a timeline by issue key.

You never copy a line from the daily into the project doc. The query does it. That is the whole trick: **write once, the views assemble themselves.**

## The line format

```
- [x] [task] subtask content (PROJ-####) ⏰ HH:MM ✅ YYYY-MM-DD
       └tag┘                  └──key──┘   └time┘   └done date┘
```

- `[task]` — the **tag**. Must match a `projects/<task>.md` filename. The project doc collects via `description includes [task]`.
- `(PROJ-####)` — the **key**. The subtask key for that line (or the task key if there's no subtask). The project doc's timeline groups by this key.
- `⏰ HH:MM` — completion **time**, for the human "when in the day". (`⏰` is plain text to the Tasks plugin.)
- `✅ YYYY-MM-DD` — the Tasks plugin's **done-date field**. It powers the "recently done" view and `sort by done`. Keep it even though the filename already has the date.

A line can carry an optional indented block when there's a story to tell:

```
- [x] [migrate-db] cut over (PROJ-12) ⏰ 14:30 ✅ 2026-06-12
    - Problem: replica lag spiked during peak
    - Fix: moved traffic to the new node, drained the old one
    - Result: MR !42 merged, dashboard green
    - ![[cutover.png]]
```

The checkbox stays a single line (so queries still collect it); the block is reachable by the same key, which is exactly what `/jira-sync` later turns into a Jira comment.

## The hierarchy

Objiraude mirrors the Jira issue hierarchy:

| Jira | Obsidian | Notes |
|---|---|---|
| **Epic** (months, shared) | frontmatter `jira-epic` | no dedicated doc — used for rollup/grouping |
| **Task** (your work unit) | `projects/<task>.md` | one doc per task; frontmatter `jira-task` |
| **Subtask** (execution unit) | one daily line | each carries its own key |
| ad-hoc (one-off/ops) | `[misc]` + `projects/misc.md` | a catch-all lane; key optional |

The `[misc]` lane matters: not all work is a Jira subtask. A misc line is collected by `projects/misc.md` and stays a personal record — **unless** you put a related issue key on it, in which case `/jira-sync` can post it to that issue too.

## The pipeline

```
        ┌─────────┐     ┌──────────┐     ┌────────┐     ┌──────────┐
Jira ──▶ │ /plan   │     │ /subtask │     │ /log   │     │ /report  │ ──▶ Jira status
        │ draft   │     │ create   │     │ record │     │ roll up  │ ──▶ Confluence
        └────┬────┘     └────┬─────┘     └───┬────┘     └────┬─────┘     (both confirmed)
             │               │               │               │
             ▼               ▼               ▼               ▼
        ┌──────────────────────────────────────────────────────┐
        │             daily/YYYY-MM-DD.md  (## Tasks)            │  ◀── single source
        └──────────────────────────────────────────────────────┘
             │                                          │
             ▼ (queries)                                ▼ (/jira-sync)
        projects/<task>.md timelines              Jira issue comments
```

- **`/plan`** pulls your open Jira tasks and expands each into its open subtasks, one daily line each.
- **`/subtask`** creates a new Jira subtask and drops its line into the daily — without re-running `/plan`.
- **`/log`** ticks off finished work. Run from a code repo, it reads the git branch's issue key to know which line to complete, and writes a summary block (never the code).
- **`/report`** compresses the day's blocks into each task doc's `## Progress`, and **proposes** Jira status transitions and Confluence drafts.
- **`/jira-sync`** takes the completed blocks and posts them to their Jira issues as comments (after a preview), marking each line so it's never double-posted.

## Why split `/report` and `/jira-sync`

Posting a Jira comment is something you often want *right after finishing a subtask*, not only at end-of-day. So comment-posting is its own composable command (`/jira-sync`), and `/report` stays the end-of-day rollup that merely points at what's worth posting. Each command does one job.
