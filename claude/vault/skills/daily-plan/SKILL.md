# daily-plan

`/plan` — draft today's daily `## Tasks`. Expands by **subtask (the real to-do unit), not by parent task**.

## Behavior
1. If today's `daily/YYYY-MM-DD.md` is missing, create it from `daily/_template.md`.
2. **Collect my open tasks**: JQL `assignee = currentUser() AND statusCategory != Done AND project = <PROJECT_KEY> AND issuetype not in subTaskIssueTypes() ORDER BY updated DESC`.
3. **Expand each task into its subtasks** (the core step):
   - Query the task's open subtasks: `parent = <KEY> AND statusCategory != Done`.
   - For each subtask, one line: `- [ ] [task] subtask summary (SUBTASK-KEY)`. `[task]` = the parent's `projects/*.md` filename (mapped via the `jira-task` frontmatter).
   - If a task has **no** subtasks, fall back to a single task-level line `- [ ] [task] summary (TASK-KEY)` and offer once: "this task has no subtasks — split it?" (create in Jira on confirm, e.g. via `/subtask`).
4. **Also include open subtasks assigned directly to me** (even if the parent task isn't mine).
5. **Yesterday's unfinished**: carry over the previous daily's `- [ ]` lines.
6. If a brand-new task appears (no project doc yet), ask once "create a project doc?" and offer to generate from `projects/_template.md`.
7. Tell the user to "review (5 min)".
8. Non-Jira ad-hoc work is not auto-generated — add it manually as a `[misc]` line (collected by `projects/misc.md`).

## Format / constraints
- Every line is flat: `- [ ] [task] content (KEY)`. No nested indentation — a child line without `[task]` won't be collected by the project doc.
- `(KEY)` priority: subtask key > (else) task key. The project-doc timeline groups by this key.

## Safety
- Jira is read-only here. Subtask **creation** is proposed and confirmed before running (never unattended).
