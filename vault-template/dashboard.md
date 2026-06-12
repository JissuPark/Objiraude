# Dashboard

## Tasks (by epic)
```dataview
TABLE jira-task AS "Task", epic-title AS "Epic", status AS "Status"
FROM "projects"
WHERE jira-task
SORT jira-epic ASC, file.name ASC
```

## All open tasks
```tasks
path includes daily
not done
group by function task.description.match(/\[[^\]]+\]/)?.[0] ?? 'untagged'
sort by description
```

## Recently done
```tasks
path includes daily
done
sort by done reverse
limit 20
```
