# monthly-wrapup

`/month [YYYY-MM]` (default = last month) — close out a month: tally → **debt audit** → collect decisions worth keeping → write `projects/retro-YYYY-MM.md` → commit the vault.

**This is not a bigger `/wrapup`.** It looks only at what a single day can't show — lines that have been open for weeks, publish and rollup holes, misjudgements that keep repeating. The tally tables are the garnish, not the point.
> Why: an item like "decide whether to put X under monitoring" can sit in the carryover for 27 days and then become a production incident. In the daily view it reads as "carried over again" and nobody sees it.

**Built to run unattended — external writes (Jira write, Confluence, company repo) are fully prohibited.**

## Env
- Vault = the current working directory (a scheduled routine should launch Claude Code with the vault as cwd).
- Source = **all** of `daily/*.md`, not just the target month's files — backfilled lines land in the next month's file.

## 0. Pin the period (mandatory first — never guess)
- **Run** `date +"%Y-%m-%d"` to measure today. Never infer it from conversation context or filenames.
- No argument: if today is the 1st–7th, take **last month**; otherwise this month. For this month, say `(partial, as of MM-DD)` in the title and the summary.
- If the target month has no daily file at all, stop and report just that.

## 1. Tally (mechanical — next month must reproduce it exactly)
- In scope = `- [x] … ✅ YYYY-MM-DD` lines whose **completion date** falls in the target month. Not the filename.
- Count indented child checkboxes too (note the depth separately).
- **Duplicate check**: if two or more lines share their first 80 characters, list them (a sign the carryover misfired).
- Four axes — count and share for each:
  1. **Project** = `[tag]`
  2. **Subtask** = the trailing `(<PROJECT_KEY>-####)`. Several → the last one. None → `(no key)`
  3. **Activity type** = the 7 below
  4. **Week** = ISO week
- Also produce the project × activity-type cross table.

### Classifying activity type (single label, priority order — it must be the same every month)
Strip the `[tag]` and any leading emoji, then apply the rows below **in order** to the **first clause** (the text before ` — ` or `(<PROJECT_KEY>-`), and take the first match. If nothing matches there, run once more over the whole line.

| Rank | Type | Keywords |
| --- | --- | --- |
| 1 | decision·planning | decide·decision·confirm·whether·judgement·scope out·spec review·intake |
| 2 | collaboration·reply | request·hand over·share·reply·ask·align·report·approve·answer·notify·mail |
| 3 | docs·records | doc·diagram·skill·confluence·wiki·Jira·publish·comment·record·flowchart·README |
| 4 | investigation·verification | check·verify·measure·prove·identify·judge·compare·cause·analyse·observe·reproduce·narrow·investigate·inspect·cross-check·trace·diagnose·test·review·demo·pass·gap |
| 5 | deploy·ops | deploy·restart·start·swap·tag·image·build·stack·cron·firewall·server·account·migrate·register·rollback·push·recover |
| 6 | data·DB | load·backfill·DDL·schema·table·query·partition·grant·aggregate·delete·populate |
| 7 | implementation·dev | implement·fix·add·write·create·improve·patch·automate·construct·apply·introduce·convert·split·remove·harden·port·correct·complete·switch·filter |

- The keyword sets are **language-specific** — if your daily is not in English, replace them with your own wording and keep the ranking.
- A line that matches nothing is **not classified on a hunch.** Collect those, ask the user once, and propose the confirmed wording as new keywords for this table.
- Always state the limitation at the end of the document: overlapping items are counted under the earlier type.

## 2. Debt audit (the actual point)
1. **Long-open lines** — the scope is every `- [ ]` line in the **first daily of the following month** (or the most recent daily if there is none). Do not read the target month's last daily: `move-on-plan` moves open leaves to the next day, so that file is **always empty**. The next month's first file *is* the snapshot of what the month handed over.
   - For each line, find **the day it first appeared** by searching all dailies (match on the leading part, with emoji, `**` and the clause after `—` stripped) and compute `N days`. Over 30 days → 🔴, over 14 → ⚠️.
   - Include indented open children — for a grouped item the real bottleneck is usually a child.
2. **On hold** — `⏸️HOLD` lines (if you mark them) and their start dates.
3. **Publish holes** — completed lines that have a narrative child but no `🔼 Jira #` marker. Count them per key.
   - **Count keyless lines separately.** They are unpublished because there is nowhere to publish them; mixed in, they look like holes.
4. **Rollup holes** — keys on completed lines whose `projects/<task>.md` `## Progress` has no bullet for that date.
   - **Exclude docs that have no `## Progress` section.** `projects/misc.md` is a collection-only lane and deliberately isn't rolled up; include it and every line becomes a false positive.

The audit **only writes things down.** Fixing them is `/jira-sync` and `/report`'s job, and the end of the document hands them over.

## 3. Collect decisions worth keeping
- Take the `🔴`·`⚠️`·`📌` lines from the target month's daily `## Notes`, plus completed lines whose activity type is **decision·planning**.
- **Repeated misjudgements**: when the same subject shows up on several days, group it separately — that is a candidate rule for next month.
- Drop anything already in project memory (`~/.claude/projects/<encoded-path>/memory/`) and present only the rest as **memory candidates** (don't write them).

## 4. Write the document
- Path `projects/retro-YYYY-MM.md`. Frontmatter `type: retrospective` · `period: YYYY-MM` · `date: <written on>`.
- First line: `> Tally basis:` with the number of files, lines and duplicates (so it can be reproduced).
- Fixed section order: summary · by project · by subtask · by activity type · project × activity type · weekly trend · **debt** · **decisions kept** · what it reads like · basis and limitations.
- **Never copy individual task lines across** (vault rule: write once, read two views). The one exception is the debt list — open lines need their text. Even there, add a `[[YYYY-MM-DD]]` link.
- Follow the vault's markdown rules, and grep your own output for violations before saving.
- Baseline = the previous month's retro. If the format differs, match that one.

### Idempotent
If the file already exists, **refresh only the tables and the debt section** and preserve `## What it reads like` (that's where the human writes). Report in the summary what was preserved.

## 5. Month over month
If the previous month's retro exists, add the deltas to the summary — completed count, top 2 projects, top 2 activity types, number of debt items over 30 days. **Report the change only; never assert the cause** (business days and workload differ month to month).

## 6. Vault commit & push
- Same procedure as `/wrapup` step 6: `git status --short` → secret-pattern guard grep (`(password|api[_-]?key|secret|token)\s*[:=]`, excluding `.obsidian/plugins/`) → `git add -A` → commit → `git push origin main`.
- Message: `monthly: YYYY-MM retro (done N · debt N)`.
- A failed push doesn't abort — report it as "kept as a local commit". Never force-push, never rewrite history.

## 7. Summary output
The final message: N completed / working days and daily average / top 2 projects / top 2 activity types / **N debt items over 30 days (listed)** / N publish holes / N rollup holes / N unclassified to ask about / commit·push result.

## Safety (unattended — top priority)
- **External writes fully prohibited**: Jira comments·worklogs·status transitions·issue creation, Confluence create/update, company repos. Jira may be read if needed. The only exception is the vault's own private push (step 6).
- **The only things modified are the retro file and the vault commit.** Don't touch daily or project docs — a hole that turns up is written down and handed over, not fixed.
- **No deletions.** Completed lines, narratives and `🔼` markers stay as they are.
- When a classification is ambiguous, **ask with a list instead of estimating.** Inventing a number is the worst failure this skill can have.
- Re-runs are idempotent (including the preservation rule in step 4).

## Appendix — don't use these (metrics measured and discarded)
- **"Share closed by decision"** (counting strings like `cancel`·`exclude`·`won't do`): false positives dominate. Those words collide with ordinary domain vocabulary (`cancel a purchase`, `exclude from the load`), so most hits are normal implementation work. A string match cannot separate them.
- **Finding "first appeared" by prefix-matching the line text**: lines get rewritten as they are carried over, so every item comes back as `0 days`. Use an anchor-based match, and mark even that as an estimate.
