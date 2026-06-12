---
project: misc
status: active
---
# misc (non-project ad-hoc work)

> Auto-collects `[misc]` items from `daily/`. One-off / operational work not tied to a task.
> To send it to Jira, put a related issue key `(<PROJECT_KEY>-####)` (epic or task) on the line. No key → personal record only; `/jira-sync` skips it.
> Collection-only — no `## Progress` rollup (too heterogeneous).

## Open tasks
```tasks
path includes daily
description includes [misc]
not done
sort by description
```

## Timeline (by key)
```tasks
path includes daily
description includes [misc]
group by function task.description.match(/<PROJECT_KEY>-\d+/)?.[0] ?? 'no key'
sort by done
```
