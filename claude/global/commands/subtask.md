Create a subtask in Jira and add its line to today's daily (`$ARGUMENTS` = [parent] [summary], ask if missing). Follow the `jira-subtask` skill.

- Pick the parent from the vault `projects/*.md`, or pass a key/tag.
- Jira creation (`createJiraIssue`, issuetype "Sub-task", parent=parent, assigned to me) is confirmed first.
- After creation, add `- [ ] [tag] summary (NEW-KEY)` to today's daily `## Tasks`.
