# Helper for the Handoff skill.
# Computes the canonical handoff path for the current repo+branch,
# archives existing handoffs, or lists active ones.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('path', 'archive', 'list')]
    [string]$Action,

    [string]$RepoPath = (Get-Location).Path
)

$VaultDir   = 'C:\Users\DuncanRoosma\OneDrive\SecondBrain\Work\Handoffs'
$ArchiveDir = Join-Path $VaultDir 'archive'

function Get-HandoffKey {
    param([string]$RepoPath)

    if (-not (Test-Path $RepoPath)) {
        throw "Repo path not found: $RepoPath"
    }

    Push-Location $RepoPath
    try {
        $repoRoot = & git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $repoRoot) {
            $repoName = Split-Path $repoRoot -Leaf
            $branch   = (& git branch --show-current 2>$null)
            if (-not $branch) { $branch = 'detached' }
        } else {
            $repoName = Split-Path $RepoPath -Leaf
            $branch   = 'no-git'
        }
    } finally {
        Pop-Location
    }

    $sanitizedBranch = $branch -replace '[\\/:*?"<>|]', '-'
    $sanitizedRepo   = $repoName -replace '[\\/:*?"<>|]', '-'
    return "$sanitizedRepo--$sanitizedBranch"
}

function Get-HandoffPath {
    param([string]$RepoPath)
    $key = Get-HandoffKey -RepoPath $RepoPath
    return (Join-Path $VaultDir "$key.md")
}

function Ensure-VaultDir {
    if (-not (Test-Path $VaultDir)) {
        New-Item -ItemType Directory -Path $VaultDir -Force | Out-Null
    }
}

switch ($Action) {
    'path' {
        Ensure-VaultDir
        Get-HandoffPath -RepoPath $RepoPath
    }

    'archive' {
        $current = Get-HandoffPath -RepoPath $RepoPath
        if (-not (Test-Path $current)) {
            Write-Output 'No existing handoff to archive.'
            return
        }
        if (-not (Test-Path $ArchiveDir)) {
            New-Item -ItemType Directory -Path $ArchiveDir -Force | Out-Null
        }
        $key       = Get-HandoffKey -RepoPath $RepoPath
        $timestamp = Get-Date -Format 'yyyy-MM-dd-HHmmss'
        $archived  = Join-Path $ArchiveDir "$key--$timestamp.md"
        Move-Item -Path $current -Destination $archived
        Write-Output "Archived to: $archived"
    }

    'list' {
        if (-not (Test-Path $VaultDir)) {
            Write-Output 'No handoffs directory.'
            return
        }
        Get-ChildItem -Path $VaultDir -Filter '*.md' -File |
            Sort-Object LastWriteTime -Descending |
            ForEach-Object {
                '{0,-60} {1:yyyy-MM-dd HH:mm}' -f $_.BaseName, $_.LastWriteTime
            }
    }
}
