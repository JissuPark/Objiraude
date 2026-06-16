#requires -Version 5
<#
  install.ps1 — install Objiraude's GLOBAL commands & skills into %USERPROFILE%\.claude,
  substituting the placeholders with your values from install.config.ps1.
  Re-run any time after `git pull` to update.

  Vault-level commands/skills are NOT installed here: they travel with your vault repo
  (the vault folder is shared across OSes and its .claude/ is committed). For a brand-new
  vault, copy claude/vault/* once per docs/setup.md.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$RepoRoot   = $PSScriptRoot
$ConfigPath = Join-Path $RepoRoot 'install.config.json'

if (-not (Test-Path $ConfigPath)) {
    throw "Missing install.config.json. Run:  Copy-Item install.config.example.json install.config.json  then fill in your values."
}
# Read as UTF-8 so non-ASCII values (e.g. a localized subtask type) decode correctly on PS 5.1.
$cfg = Get-Content -Raw -LiteralPath $ConfigPath -Encoding UTF8 | ConvertFrom-Json

# placeholder token -> replacement value
$map = [ordered]@{
    '<VAULT_PATH>'                = $cfg.VAULT_PATH
    '<PROJECT_KEY>'               = $cfg.PROJECT_KEY
    '<ATLASSIAN_SITE>'            = $cfg.ATLASSIAN_SITE
    '<ATLASSIAN_CLOUD_ID>'        = $cfg.ATLASSIAN_CLOUD_ID
    '<YOUR_ATLASSIAN_ACCOUNT_ID>' = $cfg.YOUR_ATLASSIAN_ACCOUNT_ID
    '<SUBTASK_TYPE>'              = $cfg.SUBTASK_TYPE
    '<CONFLUENCE_PERSONAL_SPACE>' = $cfg.CONFLUENCE_PERSONAL_SPACE
    '<CONFLUENCE_TEAM_SPACE>'     = $cfg.CONFLUENCE_TEAM_SPACE
}

foreach ($k in '<VAULT_PATH>','<PROJECT_KEY>','<ATLASSIAN_CLOUD_ID>','<YOUR_ATLASSIAN_ACCOUNT_ID>','<SUBTASK_TYPE>') {
    if ([string]::IsNullOrWhiteSpace([string]$map[$k])) { throw "Config value for $k is empty in install.config.ps1." }
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
function Read-Text([string]$p)               { [System.IO.File]::ReadAllText($p) }
function Write-Text([string]$p, [string]$t)  { [System.IO.File]::WriteAllText($p, $t, $utf8NoBom) }
function Expand-Placeholders([string]$text) {
    foreach ($token in $map.Keys) { $text = $text.Replace([string]$token, [string]$map[$token]) }
    return $text
}

$dest  = Join-Path $env:USERPROFILE '.claude'
$pairs = @(
    @{ Src = Join-Path $RepoRoot 'claude\global\commands'; Dst = Join-Path $dest 'commands' },
    @{ Src = Join-Path $RepoRoot 'claude\global\skills';   Dst = Join-Path $dest 'skills' }
)

$count = 0
foreach ($pair in $pairs) {
    if (-not (Test-Path $pair.Src)) { continue }
    Get-ChildItem -LiteralPath $pair.Src -Recurse -File | ForEach-Object {
        $rel    = $_.FullName.Substring($pair.Src.Length).TrimStart('\')
        $target = Join-Path $pair.Dst $rel
        New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
        if ($_.Extension -ieq '.md') {
            Write-Text $target (Expand-Placeholders (Read-Text $_.FullName))
        } else {
            Copy-Item -LiteralPath $_.FullName -Destination $target -Force
        }
        $count++
        Write-Host "  + $($pair.Dst.Substring($dest.Length).TrimStart('\'))\$rel"
    }
}

Write-Host ""
Write-Host "Installed $count file(s) into $dest (global commands + skills)." -ForegroundColor Green
Write-Host "Restart / reload Claude Code to pick up the new commands & skills." -ForegroundColor DarkGray
