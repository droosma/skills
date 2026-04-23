<#
.SYNOPSIS
    Symlinks skills from this repo into AI coding tool config directories.

.DESCRIPTION
    Interactive multi-select for both tools and skills.
    Will NOT overwrite existing skills — only creates new symlinks.

.NOTES
    Requires Developer Mode enabled or an elevated prompt for symlinks on Windows.
#>

param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$SkillRoot = $PSScriptRoot

# ── Tool definitions ────────────────────────────────────────────────
$Tools = @(
    @{ Name = 'Copilot CLI';  Path = Join-Path $env:USERPROFILE '.copilot\skills' }
    @{ Name = 'Claude Code';  Path = Join-Path $env:USERPROFILE '.claude\skills' }
    @{ Name = 'OpenCode';     Path = Join-Path $env:APPDATA     'opencode\skills' }
)

# ── Discover skills (top-level dirs that are not .git / scripts) ───
$SkillDirs = Get-ChildItem -Directory $SkillRoot |
    Where-Object { $_.Name -notin '.git', 'node_modules' -and $_.Name -notmatch '^\.' }

if (-not $SkillDirs) {
    Write-Host '❌ No skill folders found in repo.' -ForegroundColor Red
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

# ── Step 1: Select tools ───────────────────────────────────────────
$toolNames     = $Tools | ForEach-Object { $_.Name }
$selectedTools = Show-MultiSelect -Title 'Select target tools:' -Items $toolNames

if (-not $selectedTools -or $selectedTools.Count -eq 0) {
    Write-Host '⚠  No tools selected. Exiting.' -ForegroundColor Yellow
    exit 0
}

# ── Step 2: Select skills ──────────────────────────────────────────
$skillNames     = $SkillDirs | ForEach-Object { $_.Name }
$selectedSkills = Show-MultiSelect -Title 'Select skills to link:' -Items $skillNames

if (-not $selectedSkills -or $selectedSkills.Count -eq 0) {
    Write-Host '⚠  No skills selected. Exiting.' -ForegroundColor Yellow
    exit 0
}

# ── Step 3: Create symlinks ────────────────────────────────────────
$created  = 0
$skipped  = 0
$errors   = 0

foreach ($tool in $Tools) {
    if ($tool.Name -notin $selectedTools) { continue }

    Write-Host "`n📁 $($tool.Name) → $($tool.Path)" -ForegroundColor Cyan

    if (-not (Test-Path $tool.Path)) {
        New-Item -ItemType Directory -Path $tool.Path -Force | Out-Null
        Write-Host "   Created directory: $($tool.Path)" -ForegroundColor DarkGray
    }

    foreach ($skillName in $selectedSkills) {
        $linkPath   = Join-Path $tool.Path $skillName
        $targetPath = Join-Path $SkillRoot $skillName

        if (Test-Path $linkPath) {
            Write-Host "   ⏭  $skillName (already exists — skipped)" -ForegroundColor Yellow
            $skipped++
            continue
        }

        try {
            New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath | Out-Null
            Write-Host "   ✅ $skillName → linked" -ForegroundColor Green
            $created++
        }
        catch {
            Write-Host "   ❌ $skillName — $($_.Exception.Message)" -ForegroundColor Red
            $errors++
        }
    }
}

# ── Summary ─────────────────────────────────────────────────────────
Write-Host "`n── Summary ───────────────────────────────" -ForegroundColor DarkGray
Write-Host "   Created : $created" -ForegroundColor Green
Write-Host "   Skipped : $skipped" -ForegroundColor Yellow
Write-Host "   Errors  : $errors" -ForegroundColor $(if ($errors -gt 0) { 'Red' } else { 'DarkGray' })
Write-Host ''

if ($errors -gt 0) {
    Write-Host '💡 Tip: Enable Developer Mode (Settings → For developers) or run as Admin for symlinks.' -ForegroundColor Magenta
}
