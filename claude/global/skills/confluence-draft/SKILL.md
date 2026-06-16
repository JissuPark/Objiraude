# confluence-draft

`/doc <type> [title/topic]` — read the current **conversation**, distill it into a `<type>` **Confluence draft** (personal space). Call it again on the same topic to update the existing page per the type's rules. After saving, advise "now safe to `/compact`". Capture the conversation once and keep it as a document.

## Env
- Global skill — runs from anywhere. `VAULT = <VAULT_PATH>` (registry/markers use this absolute path).
- cloudId `<ATLASSIAN_CLOUD_ID>`. personal space key `<CONFLUENCE_PERSONAL_SPACE>` (drafts only). team `<CONFLUENCE_TEAM_SPACE>` is **not used** (promotion to the finished version is `/report`).
- Registry = `$VAULT/confluence/index.md` (topic ↔ pageId · url · type · update-mode · updated date). Create it if missing.
- space key → numeric spaceId is resolved once via `getConfluenceSpaces` (cached at the top of the registry).

## Types (template + update mode)
| type | aliases | section structure | update |
|---|---|---|---|
| `plan` | plan | background·goal / scope / approach·steps / schedule / risks | **body** |
| `criteria` | criteria·policy | background / definition·criteria / rationale / scope / change history | **body** |
| `design` | design | overview / requirements / architecture·data flow / interfaces / alternatives·decisions / open issues | **body** |
| `worklog` | worklog | summary header + progress | **thread** |
| `discussion` | discussion·meeting | topic / agreements·decisions + discussion progress | **thread** |
| (free form) | arbitrary string | infer structure from the conversation | body by default, thread if the name contains `log/progress/discussion/meeting/retro` |

> **body** = refresh (merge) the page body + one changelog line at the bottom. **thread** = keep the body, accumulate this round's additions as a footer comment.

## Behavior
1. **Resolve type**: first token of `$ARGUMENTS` = type (aliases allowed). The rest = title/topic. If no title, infer from the conversation and confirm once. Unknown types are handled as free form (structure inferred).
2. **Look up registry**: search `confluence/index.md` for the same topic (or the document the user pointed at) → if found, **update mode**, else **new**.
3. **Extract from conversation**: scan the current conversation from the start and pull **only the content matching that type** into the section structure. Focus on decisions·criteria·rationale·links. No guessing — leave undecided/open items as "open issues". (No company source code·credentials·internal secrets — summaries·decisions·links only.)
4. **Preview + confirm (required, company publishing)**: show "what / where (personal space draft) / new or update / body or thread" and confirm. No create·update before confirmation.
5. **New**: `createConfluencePage` (spaceId=personal, status=draft, contentFormat=html, title, body).
   - Identification marker at the top of the body (comment): `<!-- objiraude:doc type=<type> topic=<slug> -->`.
   - For body types, add a `## Change History` section at the bottom + first line `- {today}: initial draft`.
   - Add one line to the registry (topic·pageId·url·type·mode·{today}).
6. **Update** (existing document):
   - **body**: `getConfluencePage` (html) for the current body → **merge sections** with the new content (no overwrite — keep existing + add/edit) → `updateConfluencePage` (versionMessage="{today} /doc update"). Add `- {today}: one-line summary` to `## Change History`.
   - **thread**: keep the body, add only this round's additions via `createConfluenceFooterComment` (html).
   - Update the registry's updated date.
7. **Wrap up**: report the page URL + advise "the conversation's core is saved in the document → now safe to `/compact`".

## Safety / never
- Confluence writes (personal space drafts) also **preview then confirm**. No unattended runs. No publishing to team `<CONFLUENCE_TEAM_SPACE>`.
- No company source code·credentials·internal secrets — summaries·decisions·links only.
- Idempotent: identify the same document via the body marker + registry, no duplicate pages.
- Source is **the conversation only**. If unknown, don't guess — leave it as "open issues".
