---
project: {{task-name}}
jira-task: <PROJECT_KEY>-####
jira-epic: <PROJECT_KEY>-####
epic-title: "{{epic title}}"
status: active
---
# {{task-name}} (<PROJECT_KEY>-####)

> Epic {{epic-key}} · Auto-collects `[{{task-name}}]` items from `daily/`. Don't write here — write in the daily.

## Progress
- (updated by /report)

## Open tasks
```tasks
path includes daily
description includes [{{task-name}}]
not done
sort by description
```

## Timeline (by subtask)
```tasks
path includes daily
description includes [{{task-name}}]
group by function task.description.match(/<PROJECT_KEY>-\d+/)?.[0] ?? 'no key'
sort by done
```
