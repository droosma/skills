<#
.SYNOPSIS
    Read-only Azure / Azure DevOps auth preflight.

.DESCRIPTION
    Runs the known-good checks in order and reports which access path works.
    Never mutates anything and never attempts an interactive login.

    Exit codes: 0 = a working path was found, 1 = login/setup needed.
#>

$ErrorActionPreference = 'SilentlyContinue'

function Test-Step {
    param(
        [string]$Label,
        [scriptblock]$Check
    )
    Write-Host ("  {0,-45}" -f $Label) -NoNewline
    $output = & $Check 2>$null
    if ($LASTEXITCODE -eq 0 -and $output) {
        Write-Host 'OK' -ForegroundColor Green
        return $output
    }
    Write-Host 'FAIL' -ForegroundColor Red
    return $null
}

Write-Host "`nAzure preflight (read-only)`n" -ForegroundColor Cyan

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host '  az CLI not found on PATH. Install Azure CLI first.' -ForegroundColor Red
    exit 1
}

# 1. Azure CLI login state
$account = Test-Step '1. az account show (CLI login)' { az account show --output json }
if ($account) {
    $acc = $account | ConvertFrom-Json
    Write-Host ("     user: {0}   subscription: {1}" -f $acc.user.name, $acc.name) -ForegroundColor DarkGray
} else {
    Write-Host "`n  Not logged in. Ask the user to run: az login" -ForegroundColor Yellow
    exit 1
}

# 2. DevOps defaults
$devopsConfig = Test-Step '2. az devops configure -l (defaults)' { az devops configure -l }
$orgLine = ($devopsConfig | Where-Object { $_ -match '^organization' })
if ($orgLine) {
    Write-Host ("     {0}" -f $orgLine.Trim()) -ForegroundColor DarkGray
} else {
    Write-Host '     No default organization. Set one with:' -ForegroundColor Yellow
    Write-Host '     az devops configure --defaults organization=https://dev.azure.com/<org>' -ForegroundColor Yellow
}

# 3. End-to-end DevOps connectivity (only meaningful with a default org)
$projects = $null
if ($orgLine) {
    $projects = Test-Step '3. az devops project list (connectivity)' { az devops project list --top 1 --output json }
    if (-not $projects) {
        Write-Host "`n  DevOps call failed. Likely fixes (user must run interactively):" -ForegroundColor Yellow
        Write-Host '    az login                (refresh AAD token)' -ForegroundColor Yellow
        Write-Host '    az devops login         (PAT-based auth)' -ForegroundColor Yellow
    }
}

Write-Host ''
if ($projects) {
    Write-Host '  Working path: az CLI login + az devops CLI (use `az devops invoke` for uncovered REST areas).' -ForegroundColor Green
    exit 0
} elseif ($account) {
    Write-Host '  Working path: az CLI (Azure resources). DevOps access not confirmed.' -ForegroundColor Yellow
    exit 0
} else {
    exit 1
}
