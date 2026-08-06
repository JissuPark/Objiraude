Run the end-of-day close-out (`$ARGUMENTS` = target day, default the last working day). Follow the `wrapup` skill.

- Collect sessions → backfill logs → roll up reports (in-vault) → write the pending-publish list → draft the next working day's plan → commit & push the vault (git repos only).
- Unattended: no Jira/Confluence/company-repo writes (Jira read-only); when unsure, only leave "needs review".
