# todo (global)

`/todo "<summary>"` — add a single **open `- [ ]` line** to today's daily `## Tasks`. No Jira write (no key created). The counterpart of `/log` (the open line vs. the done line) — for a quick capture that isn't worth a Jira subtask but you don't want to forget.

## Vault / env
- `VAULT = <VAULT_PATH>`  (absolute path to your Obsidian vault)
- Today's file = `$VAULT/daily/YYYY-MM-DD.md` (create from `$VAULT/daily/_template.md` if missing).

## Behavior
1. Append `- [ ] [tag] <summary> (key?)` to today's `## Tasks` (at the end). No completion emoji (`⏰`/`✅`) — leave it open.
2. **Tag routing** (keep it frictionless — when unclear, don't ask, use `[misc]`):
   - If `$ARGUMENTS` carries an explicit `[tag]`, use it.
   - Else the git branch's `<PROJECT_KEY>-\d+` → the `[tag]` of the line / `projects` doc that owns that key.
   - Else match the summary keywords against open `## Tasks` / `projects/*.md` → if clear, use that tag.
   - Else `[misc]` (collected by `projects/misc.md`).
3. **Key is optional, none by default.** Creating a key (= a Jira subtask) is `/subtask`'s job; `/todo` never creates one. If a related issue exists, pass `(KEY)` and it's kept verbatim.

## Rules
- A single checkbox line is all — **no child block** (nothing's been done yet, so no narrative). Detail/completion comes later via `/log`.
- The checkbox stays one line + `[tag]` required (the project-doc collection condition).
- Promotion: when it later needs tracking, promote the line with `/subtask` (creates the Jira issue + injects the key); finish it with `/log`.

## Safety
- **Local only** — no Jira/external write, no confirmation needed (it's one vault line).
- The vault may be outside the cwd → write by absolute path; grant permission on first run.
- Summaries & links only (never source code).
