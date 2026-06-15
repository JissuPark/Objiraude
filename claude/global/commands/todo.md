Add an open to-do line to today's daily `## Tasks` (`$ARGUMENTS` = [tag]? summary (key)?). Follow the `todo` skill.

- No Jira write — appends an open `- [ ]` line only (key creation is `/subtask`).
- Tag: from the argument if given, else the branch key / keyword match, else `[misc]`.
- One line, no child block. Completion & narrative come later via `/log`.
