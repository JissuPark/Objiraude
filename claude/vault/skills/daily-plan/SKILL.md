# daily-plan

`/plan` — draft today's daily `## Tasks`. Expands by **subtask (the real to-do unit), not by parent task**.

## Behavior
1. If today's `daily/YYYY-MM-DD.md` is missing, create it from `daily/_template.md`.
2. **Collect my open tasks**: JQL `assignee = currentUser() AND statusCategory != Done AND project = <PROJECT_KEY> AND issuetype not in subTaskIssueTypes() ORDER BY updated DESC`.
3. **Expand each task into its subtasks** (the core step):
   - Query the task's open subtasks: `parent = <KEY> AND statusCategory != Done`.
   - For each subtask, one line: `- [ ] [task] subtask summary (SUBTASK-KEY)`. `[task]` = the parent's `projects/*.md` filename (mapped via the `jira-task` frontmatter).
   - If a task has **no** subtasks, fall back to a single task-level line `- [ ] [task] summary (TASK-KEY)` and offer once: "this task has no subtasks — split it?" (create in Jira on confirm, e.g. via `/subtask`).
   - **Do not create a separate parent (umbrella) line for grouping.** If subtasks exist, only the leaves get lines (the parent is already linked via each leaf's `[task]` tag and subtask key). A parent line appears only in the "no subtasks" fallback above.
4. **Also include open subtasks assigned directly to me** (even if the parent task isn't mine).
5. **Yesterday's unfinished = move, not copy (move-on-plan)**: take the previous daily's open `- [ ]` lines into today and **delete those lines from the previous file**. The same open item must live in exactly one (the latest) daily, so the Tasks query (`not done`, `path includes daily`) doesn't duplicate it per file.
   - **Move targets = open leaf lines with no completed children only.** After moving to today, remove the line from the previous file.
   - **Do not delete (leave in the previous file)**: `- [x]` completed lines, and **open lines that have completed (`- [x]`) children, narrative (problem/fix/result), or a `🔼 Jira` marker beneath them** (that day's log hangs off them).
   - **Umbrella line handling = strip the checkbox only**: for an open parent line with a log hanging off it, don't move it wholesale. ① Move only its **open child leaves** to today, ② in the previous file, **don't delete** the parent line — just remove its checkbox, turning it into a plain bullet (`- [ ] …` → `- 🗂️ …`). It then drops out of the `not done` query while the completed-child logs stay preserved.
   - Avoid creating umbrella lines at all (see step 3) — accumulated open parents are the main cause of carryover and query duplication.
6. If a brand-new task appears (no project doc yet), ask once "create a project doc?" and offer to generate from `projects/_template.md`.
7. Tell the user to "review (5 min)".
8. Non-Jira ad-hoc work is not auto-generated — add it manually as a `[misc]` line (collected by `projects/misc.md`).

## Format / constraints
- Every checkbox line **must carry `[task]`+`(KEY)`** (this is the project-doc query's collection condition — collected regardless of indentation).
- **Hierarchy**: when a subtask line and its parent task line are both in the same daily, indent the subtask line **one level (tab) under the parent**. Each child line still keeps `[task]`+`(KEY)` (collection guaranteed). If only the subtask line is present (no parent line), keep it flat.
- `(KEY)` priority: subtask key > (else) task key. The project-doc timeline groups by this key.

## Safety
- Jira is read-only here. Subtask **creation** is proposed and confirmed before running (never unattended).
- move-on-plan (5) **edits** the previous daily (deleting open leaf lines) — fine, since it's a local vault edit. Only delete step 5's safe targets (open leaves with no completed children); never delete lines carrying `- [x]`, narrative, or a `🔼 Jira` marker.
