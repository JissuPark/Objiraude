---
name: data-request
description: Handle an incoming data request from another team (the "could we get the numbers for…" that arrives by chat or mail) end to end — open a Jira issue under the standing support epic (requester's words quoted, assigned to you, team and start date set, title "[tag] summary"), move it to In Progress, run the analysis in an agent, then record and close it after you review the result. Use for "a data request came in", "take a ticket for this and work it", "/data-request". $ARGUMENTS = the request verbatim (+ optional tag·summary); if absent, take it from the request pasted earlier in the conversation.
---

# data-request (global)

Handles one data request as a single flow: **create the issue → In Progress → agent analysis → your review → record and close.**
Runs from any session (including source-code repos) off the fixed values below.

## Fixed values
- cloudId `<ATLASSIAN_CLOUD_ID>`, project `<PROJECT_KEY>`
- Parent = **`<SUPPORT_EPIC>`** (the team's standing support/intake epic) → because it sits under an epic, the issue type is **`<TASK_TYPE>`**, not a subtask
- Assignee (you) accountId `<YOUR_ATLASSIAN_ACCOUNT_ID>`
- Team `<TEAM_FIELD_ID>` = `<TEAM_ID>`
- Start date `<START_DATE_FIELD_ID>` = today `YYYY-MM-DD` — **a date-only field, it cannot carry a time.** The time goes on the daily line
- (optional) if your project has a requester/department field, fill it only when `lookupJiraAccountId` resolves the requester unambiguously. Never guess
- (optional) labels — only when the subject clearly overlaps an existing label
- `VAULT = <VAULT_PATH>`

## Steps
1. **Tidy the request**
   - Scan the original for sensitive values (phone, email, national id, account number, secrets, production IPs). If present, use a copy with just those values masked.
   - Title = `[tag] summary`. The default tag is **`[request]`**; if the user gives a tag, use theirs. The summary says in one line *what is being checked*.
   - Vault tag (for the daily line): the filename of the matching `$VAULT/projects/*.md`. If none, `[misc]`.
2. **Create in Jira** — calling `/data-request` is itself the approval to create and to move to In Progress. Don't ask again.
   `createJiraIssue`(projectKey=`<PROJECT_KEY>`, issueType=`<TASK_TYPE>`, parent=`<SUPPORT_EPIC>`, summary, assignee=you,
   additional_fields={team, start date}, description in the format below). On failure, report the error verbatim and stop.
   ```
   ## Request

   > (the request verbatim — `> ` on every line, `>` for blank lines)

   ## Work log

   - (filled in after the work)
   ```
   After creating, `getJiraIssue` and read back whether team and start date actually landed.
3. **Move to In Progress** — list the transitions (`listJiraIssueTransitions` via `executeRead`) and run the one whose destination is your in-progress status. Pick it by `to.name`, never by guessing the transition's own name.
4. **Daily line** — append to today's `$VAULT/daily/YYYY-MM-DD.md` `## Tasks`:
   `- [ ] [vault-tag] [request] summary (NEW-KEY)`.
5. **Delegate the work to an agent** — hand an `Agent` (general-purpose, background) a self-contained prompt carrying:
   - the request verbatim, the relevant repos·precedent SQL paths, and the metric definitions (**verified by definition, not by field name**)
   - the execution constraints (which engine is for short queries only, which is ad-hoc only, …) from that repo's CLAUDE.md and memory
   - **read-only** (no writes to Jira·DB·Redis), aggregates only (never a list of individuals), a reproducible SQL file + a result file + a draft reply
   - reporting format: one-sentence conclusion → the key numbers → definitions·assumptions → verified vs. assumed → how it was checked
   While waiting, never predict the agent's result.
6. **Your review** — summarize the agent's result and have the numbers, the definitions and the draft reply reviewed. For fixes, continue the same agent (`SendMessage`).
   **Nothing is written to Jira and nothing is closed before this approval.**
7. **Record and close** (after approval)
   - `editJiraIssue` to fill `## Work log` in the description (definitions·period·key numbers·artifact paths). Leave the quoted request untouched.
     Read the existing description with `getJiraIssue`(responseContentFormat=html) and write it back as html so the quote block survives.
   - Close it: re-read the transition list at **each** step and walk the issue through to the done-category status.
   - Ticking the daily line `[x]` is left to `/log` — say so.

## Safety
- Creating the issue and moving it to In Progress are covered by the call. Recording the result and closing happen **only after the user's review.**
- Never send the reply to the requester yourself — produce the draft only.
- Company data and code never go to an external service.
