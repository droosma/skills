<#
.SYNOPSIS
    Configures skills, plugins, agents, and settings from this repo for AI
    coding tools. The repo is the source of truth.

.DESCRIPTION
    Interactive multi-select for tools, skills, and plugins (or -All for
    everything, non-interactive). Link behavior:
      - missing target            -> create symlink
      - symlink into this repo    -> repaired to the current repo path
      - symlink elsewhere         -> skipped
      - real file (settings only) -> backed up to <name>.pre-repo.bak, then linked
      - real file/dir (skills)    -> skipped (merge into the repo manually first)

.NOTES
    Requires Developer Mode enabled or an elevated prompt for symlinks on Windows.
#>

param(
    [switch]$All
)

$ErrorActionPreference = 'Stop'
$SkillRoot  = $PSScriptRoot
$SkillsDir  = Join-Path $SkillRoot 'skills'
$PluginsDir = Join-Path $SkillRoot 'plugins'
$AgentsDir  = Join-Path $SkillRoot 'agents'
$ExtensionsDir = Join-Path $SkillRoot 'extensions'
$SettingsDir = Join-Path $SkillRoot 'settings'

# ── Tool definitions ────────────────────────────────────────────────
$Tools = @(
    @{ Name = 'Copilot CLI';  Path = Join-Path $env:USERPROFILE '.copilot\skills' }
    @{ Name = 'Claude Code';  Path = Join-Path $env:USERPROFILE '.claude\skills' }
    @{ Name = 'Pi';           Path = Join-Path $env:USERPROFILE '.pi\agent\skills' }
    @{ Name = 'OpenCode';     Path = Join-Path $env:APPDATA     'opencode\skills' }
)

# ── Discover skills (skills/* dirs containing a SKILL.md) ──────────
$SkillDirs = Get-ChildItem -Directory $SkillsDir |
    Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }
$PluginDirs = @()
if (Test-Path $PluginsDir) {
    $PluginDirs = Get-ChildItem -Directory $PluginsDir |
        Where-Object { Test-Path (Join-Path $_.FullName 'plugin.json') }
}

if (-not $SkillDirs) {
    Write-Host '❌ No skill folders found under skills/.' -ForegroundColor Red
    exit 1
}

# ── Interactive multi-select helper ─────────────────────────────────
function Show-MultiSelect {
    param(
        [string]   $Title,
        [string[]] $Items
    )

    $selected = [bool[]]::new($Items.Count)
    $cursor   = 0

    # Select all by default
    for ($i = 0; $i -lt $Items.Count; $i++) { $selected[$i] = $true }

    [Console]::CursorVisible = $false
    Write-Host "`n  $Title" -ForegroundColor Cyan
    Write-Host "  (↑/↓ navigate, Space toggle, A select all, N select none, Enter confirm)`n" -ForegroundColor DarkGray

    $startRow = [Console]::CursorTop

    # Render loop
    function Render {
        [Console]::SetCursorPosition(0, $startRow)
        for ($i = 0; $i -lt $Items.Count; $i++) {
            $marker = if ($selected[$i]) { '[✔]' } else { '[ ]' }
            $prefix = if ($i -eq $cursor) { ' ▸ ' } else { '   ' }
            $color  = if ($i -eq $cursor) { 'Yellow' } else { 'White' }
            Write-Host "$prefix$marker $($Items[$i])".PadRight(60) -ForegroundColor $color
        }
    }

    Render

    while ($true) {
        $key = [Console]::ReadKey($true)

        switch ($key.Key) {
            'UpArrow'   { $cursor = [Math]::Max(0, $cursor - 1) }
            'DownArrow' { $cursor = [Math]::Min($Items.Count - 1, $cursor + 1) }
            'Spacebar'  { $selected[$cursor] = -not $selected[$cursor] }
            'A'         { for ($i = 0; $i -lt $Items.Count; $i++) { $selected[$i] = $true } }
            'N'         { for ($i = 0; $i -lt $Items.Count; $i++) { $selected[$i] = $false } }
            'Enter'     { break }
        }

        Render

        if ($key.Key -eq 'Enter') { break }
    }

    [Console]::CursorVisible = $true
    Write-Host ''

    $result = @()
    for ($i = 0; $i -lt $Items.Count; $i++) {
        if ($selected[$i]) { $result += $Items[$i] }
    }
    return $result
}

# ── Link helper ─────────────────────────────────────────────────────
# Returns: created | repaired | ok | skipped-foreign | skipped-real | backed-up | error
function New-RepoLink {
    param(
        [string]$LinkPath,
        [string]$TargetPath,
        [switch]$BackupExisting
    )

    $item = Get-Item -LiteralPath $LinkPath -Force -ErrorAction SilentlyContinue
    if ($item) {
        if ($item.LinkType -eq 'SymbolicLink') {
            $current = $item.LinkTarget
            if ($current -eq $TargetPath) { return 'ok' }
            if ($current -and $current.StartsWith($SkillRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
                $item.Delete()   # stale link into this repo (pre-restructure) — repair
                New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath | Out-Null
                return 'repaired'
            }
            return 'skipped-foreign'
        }
        if ($BackupExisting) {
            Move-Item -LiteralPath $LinkPath -Destination "$LinkPath.pre-repo.bak" -Force
            New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath | Out-Null
            return 'backed-up'
        }
        return 'skipped-real'
    }

    New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath | Out-Null
    return 'created'
}

$counts = @{ created = 0; repaired = 0; ok = 0; skipped = 0; errors = 0 }

function Report-Link {
    param([string]$Name, [string]$Status)
    switch ($Status) {
        'created'         { Write-Host "   ✅ $Name → linked" -ForegroundColor Green;                        $counts.created++ }
        'repaired'        { Write-Host "   🔧 $Name → repaired (stale repo link)" -ForegroundColor Green;    $counts.repaired++ }
        'backed-up'       { Write-Host "   ✅ $Name → linked (original saved as .pre-repo.bak)" -ForegroundColor Green; $counts.created++ }
        'ok'              { Write-Host "   ⏭  $Name (already linked)" -ForegroundColor DarkGray;             $counts.ok++ }
        'skipped-foreign' { Write-Host "   ⏭  $Name (symlink to another location — skipped)" -ForegroundColor Yellow; $counts.skipped++ }
        'skipped-real'    { Write-Host "   ⚠  $Name (real file/dir in the way — merge into repo, then re-run)" -ForegroundColor Yellow; $counts.skipped++ }
    }
}

# ── Step 1: Select tools ───────────────────────────────────────────
$toolNames = $Tools | ForEach-Object { $_.Name }
$selectedTools = if ($All) { $toolNames } else { Show-MultiSelect -Title 'Select target tools:' -Items $toolNames }

if (-not $selectedTools -or $selectedTools.Count -eq 0) {
    Write-Host '⚠  No tools selected. Exiting.' -ForegroundColor Yellow
    exit 0
}

# ── Step 2: Select skills ──────────────────────────────────────────
$skillNames = $SkillDirs | ForEach-Object { $_.Name }
$selectedSkills = if ($All) { $skillNames } else { Show-MultiSelect -Title 'Select skills to link:' -Items $skillNames }

# ── Step 2b: Select plugins ────────────────────────────────────────
$pluginNames = $PluginDirs | ForEach-Object { $_.Name }
$selectedPlugins = if ($All) {
    $pluginNames
}
elseif ($pluginNames.Count -gt 0) {
    Show-MultiSelect -Title 'Select plugins to install:' -Items $pluginNames
}
else {
    @()
}

# ── Step 3: Link skills ────────────────────────────────────────────
foreach ($tool in $Tools) {
    if ($tool.Name -notin $selectedTools) { continue }
    if (-not $selectedSkills) { continue }

    Write-Host "`n📁 $($tool.Name) skills → $($tool.Path)" -ForegroundColor Cyan
    if (-not (Test-Path $tool.Path)) {
        New-Item -ItemType Directory -Path $tool.Path -Force | Out-Null
    }

    foreach ($skillName in $selectedSkills) {
        try {
            $status = New-RepoLink -LinkPath (Join-Path $tool.Path $skillName) -TargetPath (Join-Path $SkillsDir $skillName)
            Report-Link $skillName $status
        }
        catch {
            Write-Host "   ❌ $skillName — $($_.Exception.Message)" -ForegroundColor Red
            $counts.errors++
        }
    }
}

# ── Step 4: Link agents ────────────────────────────────────────────
# Claude Code: ~/.claude/agents/<name>.md
# Copilot CLI: ~/.copilot/agents/<name>.agent.md
$agentFiles = @()
if (Test-Path $AgentsDir) {
    $agentFiles = Get-ChildItem -File $AgentsDir -Filter '*.md' | Where-Object { $_.Name -ne 'README.md' }
}

if ($agentFiles) {
    $agentTargets = @()
    if ('Claude Code' -in $selectedTools) {
        $agentTargets += @{ Dir = Join-Path $env:USERPROFILE '.claude\agents'; Suffix = '.md' }
    }
    if ('Copilot CLI' -in $selectedTools) {
        $agentTargets += @{ Dir = Join-Path $env:USERPROFILE '.copilot\agents'; Suffix = '.agent.md' }
    }

    foreach ($t in $agentTargets) {
        Write-Host "`n🤖 Agents → $($t.Dir)" -ForegroundColor Cyan
        if (-not (Test-Path $t.Dir)) { New-Item -ItemType Directory -Path $t.Dir -Force | Out-Null }

        foreach ($agentFile in $agentFiles) {
            $linkName = $agentFile.BaseName + $t.Suffix
            try {
                $status = New-RepoLink -LinkPath (Join-Path $t.Dir $linkName) -TargetPath $agentFile.FullName
                Report-Link $linkName $status
            }
            catch {
                Write-Host "   ❌ $linkName — $($_.Exception.Message)" -ForegroundColor Red
                $counts.errors++
            }
        }
    }
}

# ── Step 4b: Link Pi extensions (pi's analog to hooks) ─────────────
# Pi extensions are TypeScript modules in ~/.pi/agent/extensions/. Each
# top-level .ts file or extension directory in the repo's extensions/ is
# linked individually so pi can hot-reload them with /reload.
if (('Pi' -in $selectedTools) -and (Test-Path $ExtensionsDir)) {
    $extTarget = Join-Path $env:USERPROFILE '.pi\agent\extensions'
    Write-Host "`n🧩 Pi extensions → $extTarget" -ForegroundColor Cyan
    if (-not (Test-Path $extTarget)) { New-Item -ItemType Directory -Path $extTarget -Force | Out-Null }
    foreach ($ext in Get-ChildItem $ExtensionsDir | Where-Object { $_.Name -ne 'README.md' }) {
        try {
            $status = New-RepoLink -LinkPath (Join-Path $extTarget $ext.Name) -TargetPath $ext.FullName
            Report-Link $ext.Name $status
        }
        catch {
            Write-Host "   ❌ $($ext.Name) — $($_.Exception.Message)" -ForegroundColor Red
            $counts.errors++
        }
    }
}

# ── Step 5: Install plugins ────────────────────────────────────────
if ($selectedPlugins) {
    Write-Host "`n📦 Plugins" -ForegroundColor Cyan
    foreach ($pluginName in $selectedPlugins) {
        $manifest = Join-Path $PluginsDir "$pluginName\plugin.json"
        $installer = Join-Path $SkillRoot 'scripts\install-plugin.ps1'
        foreach ($toolName in $selectedTools) {
            try {
                & $installer -Manifest $manifest -Tool $toolName
            }
            catch {
                Write-Host "   ❌ $pluginName for $toolName — $($_.Exception.Message)" -ForegroundColor Red
                $counts.errors++
            }
        }
    }
}

# ── Step 6: Link settings ──────────────────────────────────────────
# Real files in the way are backed up to <name>.pre-repo.bak first — merge
# anything you still need from the backup into the repo file afterwards.
$settingsLinks = @()
if ('Claude Code' -in $selectedTools) {
    $settingsLinks += @{ Link = Join-Path $env:USERPROFILE '.claude\settings.json'; Target = Join-Path $SettingsDir 'claude\settings.json' }
    $settingsLinks += @{ Link = Join-Path $env:USERPROFILE '.claude\CLAUDE.md';     Target = Join-Path $SettingsDir 'claude\CLAUDE.md' }
    $settingsLinks += @{ Link = Join-Path $env:USERPROFILE '.claude\shared';        Target = Join-Path $SettingsDir 'shared' }
}
if ('Copilot CLI' -in $selectedTools) {
    $settingsLinks += @{ Link = Join-Path $env:USERPROFILE '.copilot\settings.json';               Target = Join-Path $SettingsDir 'copilot\settings.json' }
    $settingsLinks += @{ Link = Join-Path $env:USERPROFILE '.copilot\copilot-instructions.md'; Target = Join-Path $SettingsDir 'copilot\copilot-instructions.md' }
    $settingsLinks += @{ Link = Join-Path $env:USERPROFILE '.copilot\shared';                  Target = Join-Path $SettingsDir 'shared' }
}
if ('Pi' -in $selectedTools) {
    # Pi's settings.json is deliberately NOT linked: pi writes machine state
    # (e.g. lastChangelogVersion) into it, which would churn in git.
    $settingsLinks += @{ Link = Join-Path $env:USERPROFILE '.pi\agent\AGENTS.md'; Target = Join-Path $SettingsDir 'pi\AGENTS.md' }
    $settingsLinks += @{ Link = Join-Path $env:USERPROFILE '.pi\agent\shared';    Target = Join-Path $SettingsDir 'shared' }
}

if ($settingsLinks) {
    Write-Host "`n⚙  Settings" -ForegroundColor Cyan
    foreach ($s in $settingsLinks) {
        if (-not (Test-Path $s.Target)) { continue }
        try {
            $status = New-RepoLink -LinkPath $s.Link -TargetPath $s.Target -BackupExisting
            Report-Link $s.Link $status
        }
        catch {
            Write-Host "   ❌ $($s.Link) — $($_.Exception.Message)" -ForegroundColor Red
            $counts.errors++
        }
    }
}

# ── Summary ─────────────────────────────────────────────────────────
Write-Host "`n── Summary ───────────────────────────────" -ForegroundColor DarkGray
Write-Host "   Created  : $($counts.created)"  -ForegroundColor Green
Write-Host "   Repaired : $($counts.repaired)" -ForegroundColor Green
Write-Host "   Up to date: $($counts.ok)"      -ForegroundColor DarkGray
Write-Host "   Skipped  : $($counts.skipped)"  -ForegroundColor Yellow
Write-Host "   Errors   : $($counts.errors)"   -ForegroundColor $(if ($counts.errors -gt 0) { 'Red' } else { 'DarkGray' })
Write-Host ''

if ($counts.errors -gt 0) {
    Write-Host '💡 Tip: Enable Developer Mode (Settings → For developers) or run as Admin for symlinks.' -ForegroundColor Magenta
}
