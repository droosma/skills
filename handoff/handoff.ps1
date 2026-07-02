# Helper for the Handoff skill.
# Computes the canonical handoff path for the current repo+branch,
# archives existing handoffs, or lists active ones.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('path', 'archive', 'list')]
    [string]$Action,

    # Catchy, conversation-based title for the handoff (e.g. "Trim the Fat: Affected-Only Builds").
    # Required for 'path' and 'archive'. Sanitized into a slug used as the filename.
    [string]$Title,

    [string]$RepoPath = (Get-Location).Path
)

# Vault location: override with HANDOFF_VAULT_DIR; defaults to the OneDrive vault under the user's home.
$VaultDir = if ($env:HANDOFF_VAULT_DIR) {
    $env:HANDOFF_VAULT_DIR
} else {
    Join-Path $HOME 'OneDrive\SecondBrain\Work\Handoffs'
}
$ArchiveDir = Join-Path $VaultDir 'archive'

function Get-RepoName {
    param([string]$RepoPath)

    if (-not (Test-Path $RepoPath)) {
        throw "Repo path not found: $RepoPath"
    }

    Push-Location $RepoPath
    try {
        $repoRoot = & git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $repoRoot) {
            $repoName = Split-Path $repoRoot -Leaf
        } else {
            $repoName = Split-Path $RepoPath -Leaf
        }
    } finally {
        Pop-Location
    }

    return ($repoName.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
}

function Get-HandoffKey {
    param([string]$Title, [string]$RepoPath)

    if (-not $Title -or -not $Title.Trim()) {
        throw "A -Title is required. Pass a catchy, conversation-based title (e.g. 'Trim the Fat: Affected-Only Builds')."
    }

    # Slugify: lowercase, strip invalid/punctuation chars, collapse whitespace to single hyphens.
    $slug = $Title.ToLowerInvariant()
    $slug = $slug -replace "[\\/:*?`"<>|]", ' '   # filesystem-invalid chars
    $slug = $slug -replace '[^a-z0-9]+', '-'      # any non-alphanumeric run -> hyphen
    $slug = $slug.Trim('-')
    if (-not $slug) {
        throw "Title '$Title' produced an empty slug. Choose a title with alphanumeric characters."
    }

    # Prefix with the repo/project name so handoffs are grouped per project.
    $repo = Get-RepoName -RepoPath $RepoPath
    return "$repo--$slug"
}

function Get-HandoffPath {
    param([string]$Title, [string]$RepoPath)
    $key = Get-HandoffKey -Title $Title -RepoPath $RepoPath
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
        Get-HandoffPath -Title $Title -RepoPath $RepoPath
    }

    'archive' {
        $current = Get-HandoffPath -Title $Title -RepoPath $RepoPath
        if (-not (Test-Path $current)) {
            Write-Output 'No existing handoff to archive.'
            return
        }
        if (-not (Test-Path $ArchiveDir)) {
            New-Item -ItemType Directory -Path $ArchiveDir -Force | Out-Null
        }
        $key       = Get-HandoffKey -Title $Title -RepoPath $RepoPath
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
