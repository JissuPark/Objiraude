# Setup

A concrete, end-to-end install. Estimated time: ~20 minutes.

## 0. Prerequisites

- **[Obsidian](https://obsidian.md)** (desktop).
- **[Claude Code](https://claude.com/claude-code)**.
- An **Atlassian MCP** connected in Claude Code, with access to your Jira project and Confluence spaces. Verify with a read call (e.g. ask Claude to list your open Jira issues) before continuing.
- A **private** GitHub repo for the vault (it will hold internal ticket ids and project names — keep it private).

## 1. Create the vault

```bash
cp -r vault-template/ ~/path/to/my-worklog
```

Open the folder in Obsidian ("Open folder as vault"). Trust the author when prompted.

## 2. Install & enable plugins

Install three community plugins (Settings → Community plugins → Browse):

- **Tasks** — checkbox done-dates, per-task timelines.
- **Dataview** — the dashboard tables.
- **Obsidian Git** — auto commit/push.

`vault-template/.obsidian/community-plugins.json` already lists them, so Obsidian will offer to enable them on open. Then:

- **Tasks → Settings → enable "Custom searches"** (a.k.a. allow JavaScript functions in queries). **Required** — the `## Timeline` queries use `group by function …`. Without it you'll see a JavaScript error in the timeline headings.

## 3. Fill in your config

Edit **`CLAUDE.md`** in the vault and replace every `<PLACEHOLDER>`:

| Placeholder | How to find it |
|---|---|
| `<PROJECT_KEY>` | your Jira project key, e.g. `PROJ` (in any issue id `PROJ-123`) |
| `<ATLASSIAN_SITE>` | `yourco.atlassian.net` |
| `<ATLASSIAN_CLOUD_ID>` | ask Claude: "what's my Atlassian cloud id?" (via the MCP), or visit `https://<site>/_edge/tenant_info` |
| `<YOUR_ATLASSIAN_ACCOUNT_ID>` | ask Claude for your account id via the MCP |
| `<CONFLUENCE_PERSONAL_SPACE>` | your personal/draft Confluence space key |
| `<CONFLUENCE_TEAM_SPACE>` | your team's published space key |
| `<SUBTASK_TYPE>` | your Jira project's subtask issue-type name (e.g. `Sub-task`, or a localized name) |

Also replace `<PROJECT_KEY>` in the timeline queries inside `projects/_template.md` and `projects/misc.md` (the regex `/<PROJECT_KEY>-\d+/`).

## 4. Install the commands & skills

Two destinations (see [Concept](concept.md) for why):

```bash
# global — runnable from any repo (route by git branch key, write back to the vault)
cp -r claude/global/commands/* ~/.claude/commands/
cp -r claude/global/skills/*   ~/.claude/skills/

# vault — run inside the vault (need the whole vault + Jira)
cp -r claude/vault/commands/*  ~/path/to/my-worklog/.claude/commands/
cp -r claude/vault/skills/*    ~/path/to/my-worklog/.claude/skills/
```

Then replace placeholders in the copied skills:

- **Global skills** (`~/.claude/skills/daily-log/SKILL.md`, `jira-subtask/SKILL.md`, `todo/SKILL.md`): set `<VAULT_PATH>` to your vault's absolute path, plus `<PROJECT_KEY>`, `<ATLASSIAN_CLOUD_ID>`, `<YOUR_ATLASSIAN_ACCOUNT_ID>`, `<SUBTASK_TYPE>`.
- **Vault skills** (`jira-sync`, `sync-report`, `daily-plan`): set `<PROJECT_KEY>`, `<ATLASSIAN_CLOUD_ID>`, the Confluence spaces.

> Tip: a single find-and-replace across the copied files for each placeholder is fastest.

### Windows (PowerShell): scripted install

`install.ps1` does the copy + placeholder substitution for you — handy when you run Claude Code natively on Windows in addition to WSL/macOS. It installs the **global** commands/skills into `%USERPROFILE%\.claude\` (the vault-level ones already travel with the vault repo).

```powershell
# one-time: create your local config from the example and fill in real values
Copy-Item install.config.example.json install.config.json
notepad install.config.json           # set VAULT_PATH, PROJECT_KEY, cloud id, account id, subtask type…

# install / update (run again any time after `git pull`)
git pull
./install.ps1
```

`install.config.json` holds your private values and is git-ignored — never commit it. It's JSON (read as UTF-8) so a localized `SUBTASK_TYPE` such as `하위 작업` survives intact.

## 5. Connect the vault to GitHub

```bash
cd ~/path/to/my-worklog
git init && git add -A && git commit -m "init worklog vault"
git branch -M main
git remote add origin https://github.com/<you>/<repo>.git
git push -u origin main
```

**Authentication (HTTPS):** GitHub no longer accepts passwords. Use one of:

- **Git Credential Manager** (bundled with Git for Windows; great on WSL): `git config --global credential.helper "<path-to>/git-credential-manager.exe"` → push → browser login. Cached after.
- **Personal Access Token (classic, scope `repo`)** as the password when prompted.

**Obsidian Git auto-sync:** on desktop it reuses your system Git's credentials (so once the CLI push works, the plugin works). On mobile, set username + a PAT under Obsidian Git → Authentication. Set the **Commit author** name/email to your GitHub identity if you want commits attributed to you.

## 6. First run

In Claude Code, open the vault as the working directory and run:

```
/plan
```

It creates today's daily from your open Jira and lists subtasks to do. From there:

- finished something in a code repo → `/log "what you did"`
- need a new subtask → `/subtask <PARENT-KEY> "summary"`
- end of day → `/report`, then `/jira-sync`

See **[commands.md](commands.md)** for the full reference.

## Troubleshooting

- **Timeline shows a JavaScript error** → enable Tasks → Custom searches (step 2).
- **`/log` from a code repo tags `[misc]`** → the branch had no `PROJECT_KEY-####`; name your branches with the issue key, or pass context.
- **`git push` says "Authentication failed"** → you used a password; use a PAT or Git Credential Manager (step 5).
- **`/jira-sync` skips an item** → it needs a `(KEY)` and a narrative child; keyless items are offered a key first.
