---
name: runbook
description: Turn the build/config/deploy work you just did into a handover runbook — purpose, environment, the commands you actually ran, where to verify, how to roll back, and the reasoning behind each decision. Unlike a guide (how to read it), a runbook is how it was built and how to build it again. Use for "/runbook <task>", "write a handover doc", "record this so it can be redone". Writes a Confluence draft in your personal space + a registry line + one daily line. Runs from any session (including source-code repos).
---

# runbook (global)

`/runbook "<task name>"` — turn the build·config·deploy work actually done **in this session** into a document from which someone else (or future you) can **produce the same result again**. Where a guide (`/doc guide`) answers "how do I read and use this", a runbook answers "how was it built, and how do I build it again".

## Env (same as confluence-draft)
- `VAULT = <VAULT_PATH>`
- cloudId `<ATLASSIAN_CLOUD_ID>`, personal space key `<CONFLUENCE_PERSONAL_SPACE>` (drafts only). Never write to the team space `<CONFLUENCE_TEAM_SPACE>` — promotion is the user's call. The space key → numeric spaceId is resolved once via `getConfluenceSpaces` (cached at the top of the registry).
- Registry: add one line to `$VAULT/confluence/index.md` with type `runbook`. First line of the body carries the marker `<!-- objiraude:doc type=runbook topic=<slug> -->`.
- Same topic already in the registry → **update** (`getConfluencePage` → merge section by section → `updateConfluencePage`, plus one change-history line). Else new.

## ⚠️ Content rules (these matter more than the format)
1. **Only commands you actually ran.** Extract them from this session's conversation, pasted terminal output and diffs. Anything not run, or abandoned after it failed, belongs in "Tried and rejected" only. Never invent.
2. **Commands must be copy-and-run.** Put one line before each command saying which host, which account and which directory it is typed in. Mark placeholders in angle brackets (`<PROD_IP>`) and say why each is a placeholder.
3. **Secrets become placeholders, never values.** IPs (production·DNS), tokens, passwords, account secrets and personal data stay out of the body. Identifiers such as hostnames, ports, paths, container names and uids go in as-is.
4. **Always write "where to check".** Result URLs, file paths, container names, dashboard uids, Prometheus job names, cron lines. The document alone must be enough to inspect the current state.
5. **Record decisions and their reasons.** Why this Prometheus, why this flag, why production only. One line per alternative and why it was rejected.
6. **Pitfalls as symptom → cause → fix.** So the next person doesn't burn 30 minutes in the same spot.
7. General knowledge from outside the session (official docs, links) goes under "References" only; internal facts carry evidence (Confluence page id, ticket, daily date).
8. **Reproducibility over length.** An empty section says "N/A" and moves on. Never pad a section with guesses.

## Document structure (h1 = title, sections are h2, this order is fixed)
```
<!-- objiraude:doc type=runbook topic=<slug> -->
<p><strong>In one line</strong>: what was built where and why + date + ticket + state (in production / on hold / retired)</p>

## 1. Purpose and scope
   - Requester and request (gist of the original), success criteria, what is in and out of scope (and why)
## 2. Environment
   - Table: hosts (name·role·specs), accounts (no secrets), network constraints (blocked·opened), software versions (docker·driver·image tags), prerequisites
## 3. Topology
   - Text diagram (ASCII or table): what flows from where to where, and on which ports
## 4. Build steps (in the order they were run)
   - Per step: one line of [host, account, directory] → command block → one line on the expected output / how to check
   - Config edits: "which file, where in it, what" + the changed block verbatim (including the backup command)
   - Artifacts (JSON, scripts): where they are stored and where they came from
## 5. Where to check
   - Table: what / where (URL·path·command) / what it looks like when healthy
## 6. Operations
   - Restart·stop·change (tag swap…)·extend (add a target) commands
   - Check interval and the check command (daily/weekly/monthly)
   - Order to look in during an incident (briefly; link the guide doc for detail)
## 7. Rollback
   - The undo command for each step. Say explicitly which steps cannot be undone
## 8. Decisions and rationale
   - Table: decision / alternative / why chosen / evidence (page·ticket)
## 9. Pitfalls (symptom → cause → fix)
## 10. Tried and rejected / still open
## 11. Related
   - Tickets, Confluence docs (guide·design), MRs, daily dates, people by team·role (not by name)
## Change history
   - YYYY-MM-DD: initial draft / gist of the update
```

## Behavior
1. **Fix the task name and scope**: `$ARGUMENTS` is the task name. If absent, pick the most recent build·deploy unit in the session and confirm once.
2. **Extract**: walk the session from the start and pull (a) commands run and their output, (b) config diffs, (c) URLs·paths·uids, (d) decision points and what the user said, (e) failures and workarounds. Read host·account·directory from the terminal prompts the user pasted (`[user@host dir]$`).
3. **Substitute secrets**: IPs → `<PROD_IP>`/`<DEV_IP>`, tokens·passwords → removed. If anything was substituted, add one "placeholder convention" line to section 2.
4. **Preview + confirm (required — this is company publishing)**: show the title, where it will be saved (personal space draft), new or update, and one line per section on its size, then get an explicit "go". If the user already said "write it up", that is the confirmation.
5. **Create**: `createConfluencePage` (spaceId = personal, status=draft, contentFormat=html). For an update: `getConfluencePage` (html, draft) then `updateConfluencePage` (versionMessage = "{today} /runbook update").
6. **Record**: one registry line (`| <slug> | runbook | body | <pageId> | <url> | <today> | <gist> |`), and in today's daily `## Tasks`: `- [x] [tag] <task name> runbook <pageId> (KEY) ⏰ HH:MM ✅ <today>` (daily-log rules; the key comes from the branch or context `<PROJECT_KEY>-####`).
7. **Wrap up**: the URL, 3–5 lines on what went into which section, and separately anything that could not be confirmed (unclear whether it ran, version unverified).

## Safety
- Confluence writes are personal-space drafts only, after a preview and a confirmation. No team-space publishing, no Jira status changes.
- No source code, no secret values, no production IPs in the document. IPs inside commands become placeholders.
- Anything not present in the session is marked "unverified". Never fill a section by guessing.
