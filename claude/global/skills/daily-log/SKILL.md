# daily-log (global)

`/log "<summary>"` — record the work you just did into **the vault's today daily**, structured. Runs from any session (including source-code repos). Single write target = the daily; the project doc and Jira comments are derived.

## Vault / env
- `VAULT = <VAULT_PATH>`  (absolute path to your Obsidian vault)
- Today's file = `$VAULT/daily/YYYY-MM-DD.md` (create from `$VAULT/daily/_template.md` if missing).

## Routing (which task = key & tag)
1. **Key from git branch**: if in a git repo, `git rev-parse --abbrev-ref HEAD` → extract `<PROJECT_KEY>-\d+` = the subtask (or task) key.
2. **Key → `[tag]`**: in `$VAULT/daily/*.md`, find the line containing that `(KEY)` and reuse its `[tag]`. Else match `$VAULT/projects/*.md` frontmatter `jira-task` (filename = tag). Else ask once (fallback `[misc]`).
3. If the branch has no key (e.g. a vault session): match the summary keywords against today's open `## Tasks` lines → if several match, ask once.
4. **Non-project ad-hoc** (not tied to any task): `[misc]` tag (collected by `projects/misc.md`). If it should reach Jira, also write the related issue key `(KEY)` (epic or task); otherwise record without a key.

## Format (checkbox = index, below = optional children)
- If an open `- [ ]` with the same key (or tag+keyword) exists → `- [x]` + ` ⏰ {HH:MM} ✅ {today}`. Else add a new line `- [x] [tag] <short summary> (key) ⏰ {HH:MM} ✅ {today}`.
- Time `⏰ HH:MM` = completion time (`date +%H:%M`), for the human "when in the day". Date `✅ YYYY-MM-DD` is the **Tasks done-date field — keep it** (the Recent-done view and `sort by done` use it; don't drop it even though the filename repeats the date). `⏰` is not a Tasks field emoji → treated as plain text, no query impact.
- **A single checkbox line is the default.** Simple actions (access request, confirmation, meeting, waiting) → one line, no children.
- **Only when there is narrative** add indented children (in a code session, auto-derive from the diff/MR):
  ```
      - Problem: …
      - Fix: …
      - Result: … (MR/commit/dashboard link)
  ```
- **Images/screenshots** are children too: `    - ![[capture.png]]`. Usually pasted by you in Obsidian (indent one level under the checkbox). If you say "has a capture", leave a placeholder `    - 📎 (capture):` to fill (binaries can't be inserted by /log).
- Invariant: the checkbox stays one line + `[tag]` required (the project-doc collection condition). All extra content (narrative/images) goes as indented children. `(key)` = the branch key.

## Safety (especially in code sessions)
- Only summaries & links go into the vault. Never paste source code (summary / file path / URL are fine).
- No external access (Jira/Confluence sync = `/report`).
- The vault may be outside the cwd → write by absolute path; grant permission on first run.
- Children are grouped by `(KEY)` so the Jira comment skill can collect them later.
