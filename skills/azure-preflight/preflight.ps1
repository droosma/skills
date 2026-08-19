<#
.SYNOPSIS
    Read-only, context-aware Azure / Azure DevOps auth preflight.

.DESCRIPTION
    Runs the known-good checks in order and reports which access path works.
    Never mutates anything and never attempts an interactive login.

    Which tenant/subscription is "correct" depends on where you run from, so
    nothing is hardcoded. The expected tenant/subscription is discovered, in
    priority order, from:

      1. -Tenant / -Subscription parameters, if given.
      2. AZURE_PREFLIGHT_TENANT / AZURE_PREFLIGHT_SUBSCRIPTION env vars.
      3. A .azure-preflight.json file found by walking up from the current
         directory to the drive root. Schema (all fields optional):
            {
              "tenant":       "<tenant id or domain>",
              "subscription": "<subscription id or name>",
              "devopsOrg":    "https://dev.azure.com/<org>"
            }

    When an expected tenant is known, the active account is validated against
    it and a correctly-scoped `az login` command is emitted on mismatch. When
    nothing is configured, available tenants/subscriptions are listed so the
    right one is easy to pick.

    Exit codes: 0 = a working path was found, 1 = login/setup needed or the
    active tenant does not match the expected one.
#>

[CmdletBinding()]
param(
    [string]$Tenant,
    [string]$Subscription
)

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

function Find-ExpectedConfig {
    # Walk up from the current directory looking for .azure-preflight.json.
    $dir = (Get-Location).Path
    while ($dir) {
        $candidate = Join-Path $dir '.azure-preflight.json'
        if (Test-Path $candidate) {
            try {
                $cfg = Get-Content $candidate -Raw | ConvertFrom-Json
                return [pscustomobject]@{ Config = $cfg; Path = $candidate }
            } catch {
                Write-Host ("  Warning: could not parse {0}: {1}" -f $candidate, $_.Exception.Message) -ForegroundColor Yellow
                return $null
            }
        }
        $parent = Split-Path $dir -Parent
        if ($parent -eq $dir) { break }
        $dir = $parent
    }
    return $null
}

Write-Host "`nAzure preflight (read-only)`n" -ForegroundColor Cyan

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host '  az CLI not found on PATH. Install Azure CLI first.' -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# Resolve the EXPECTED tenant/subscription from context (never hardcoded).
# Priority: params > env vars > .azure-preflight.json
# ---------------------------------------------------------------------------
$expectedTenant = $Tenant
$expectedSub    = $Subscription
$expectedOrg    = $null
$configSource   = $null

if (-not $expectedTenant) { $expectedTenant = $env:AZURE_PREFLIGHT_TENANT }
if (-not $expectedSub)    { $expectedSub    = $env:AZURE_PREFLIGHT_SUBSCRIPTION }
if ($expectedTenant -or $expectedSub) { $configSource = 'parameter/env' }

$found = Find-ExpectedConfig
if ($found) {
    if (-not $expectedTenant) { $expectedTenant = $found.Config.tenant }
    if (-not $expectedSub)    { $expectedSub    = $found.Config.subscription }
    $expectedOrg = $found.Config.devopsOrg
    if (-not $configSource) { $configSource = $found.Path }
}

if ($expectedTenant -or $expectedSub) {
    Write-Host ("  Expected context (from {0}):" -f $configSource) -ForegroundColor DarkCyan
    if ($expectedTenant) { Write-Host ("     tenant       {0}" -f $expectedTenant) -ForegroundColor DarkCyan }
    if ($expectedSub)    { Write-Host ("     subscription {0}" -f $expectedSub) -ForegroundColor DarkCyan }
    Write-Host ''
}

# ---------------------------------------------------------------------------
# 1. Azure CLI login state
# ---------------------------------------------------------------------------
$account = Test-Step '1. az account show (CLI login)' { az account show --output json }
$tenantMismatch = $false
if ($account) {
    $acc = $account | ConvertFrom-Json
    Write-Host ("     user: {0}   subscription: {1}" -f $acc.user.name, $acc.name) -ForegroundColor DarkGray
    Write-Host ("     tenant: {0} ({1})" -f $acc.tenantId, $acc.tenantDisplayName) -ForegroundColor DarkGray

    if ($expectedTenant) {
        $matchTenant = ($acc.tenantId -eq $expectedTenant) -or
                       ($acc.tenantDefaultDomain -eq $expectedTenant) -or
                       ($acc.tenantDisplayName -eq $expectedTenant)
        if (-not $matchTenant) {
            $tenantMismatch = $true
            Write-Host ''
            Write-Host ("  ! Active tenant does not match expected '{0}'." -f $expectedTenant) -ForegroundColor Yellow
            Write-Host '    Log in scoped to the expected tenant:' -ForegroundColor Yellow
            Write-Host ("      az login --tenant {0}" -f $expectedTenant) -ForegroundColor Yellow
        }
    }
    if ($expectedSub -and -not $tenantMismatch -and ($acc.name -ne $expectedSub) -and ($acc.id -ne $expectedSub)) {
        Write-Host ''
        Write-Host ("  ! Active subscription is not the expected '{0}'. Switch with:" -f $expectedSub) -ForegroundColor Yellow
        Write-Host ("      az account set --subscription `"{0}`"" -f $expectedSub) -ForegroundColor Yellow
    }
} else {
    Write-Host ''
    if ($expectedTenant) {
        Write-Host '  Not logged in. Ask the user to run, scoped to this project''s tenant:' -ForegroundColor Yellow
        Write-Host ("      az login --tenant {0}" -f $expectedTenant) -ForegroundColor Yellow
    } else {
        Write-Host '  Not logged in. Ask the user to run: az login' -ForegroundColor Yellow
        Write-Host '  (Tip: add `--tenant <id>` to avoid the browser defaulting to the wrong tenant.)' -ForegroundColor Yellow
    }
    exit 1
}

# When no expected tenant is configured, surface the available tenants so the
# correct context is discoverable instead of guessed.
if (-not $expectedTenant) {
    $allAccounts = az account list --query "[].{name:name, tenantId:tenantId}" -o json 2>$null | ConvertFrom-Json
    if ($allAccounts) {
        $tenants = $allAccounts | Group-Object tenantId
        if ($tenants.Count -gt 1) {
            Write-Host ''
            Write-Host ("  {0} tenants available in this CLI. Declare the intended one in" -f $tenants.Count) -ForegroundColor DarkGray
            Write-Host '  .azure-preflight.json (tenant/subscription) to auto-validate future runs:' -ForegroundColor DarkGray
            foreach ($t in $tenants) {
                Write-Host ("     {0}  ->  {1}" -f $t.Name, (($t.Group.name) -join ', ')) -ForegroundColor DarkGray
            }
        }
    }
}

# ---------------------------------------------------------------------------
# 2. DevOps defaults
# ---------------------------------------------------------------------------
$devopsConfig = Test-Step '2. az devops configure -l (defaults)' { az devops configure -l }
$orgLine = ($devopsConfig | Where-Object { $_ -match '^organization' })
if ($orgLine) {
    Write-Host ("     {0}" -f $orgLine.Trim()) -ForegroundColor DarkGray
    if ($expectedOrg -and ($orgLine -notmatch [regex]::Escape($expectedOrg))) {
        Write-Host ("     ! Expected DevOps org {0}. Set it with:" -f $expectedOrg) -ForegroundColor Yellow
        Write-Host ("       az devops configure --defaults organization={0}" -f $expectedOrg) -ForegroundColor Yellow
    }
} elseif ($expectedOrg) {
    Write-Host '     No default organization. Set the project''s org with:' -ForegroundColor Yellow
    Write-Host ("     az devops configure --defaults organization={0}" -f $expectedOrg) -ForegroundColor Yellow
} else {
    Write-Host '     No default organization. Set one with:' -ForegroundColor Yellow
    Write-Host '     az devops configure --defaults organization=https://dev.azure.com/<org>' -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# 3. End-to-end DevOps connectivity (only meaningful with a default org)
# ---------------------------------------------------------------------------
$projects = $null
if ($orgLine) {
    $projects = Test-Step '3. az devops project list (connectivity)' { az devops project list --top 1 --output json }
    if (-not $projects) {
        Write-Host "`n  DevOps call failed. Likely fixes (user must run interactively):" -ForegroundColor Yellow
        if ($expectedTenant) {
            Write-Host ("    az login --tenant {0}   (refresh AAD token, correct tenant)" -f $expectedTenant) -ForegroundColor Yellow
        } else {
            Write-Host '    az login                (refresh AAD token)' -ForegroundColor Yellow
        }
        Write-Host '    az devops login         (PAT-based auth)' -ForegroundColor Yellow
    }
}

Write-Host ''
if ($tenantMismatch) {
    Write-Host '  Logged in, but NOT on the expected tenant for this context (see above).' -ForegroundColor Yellow
    exit 1
} elseif ($projects) {
    Write-Host '  Working path: az CLI login + az devops CLI (use `az devops invoke` for uncovered REST areas).' -ForegroundColor Green
    exit 0
} elseif ($account) {
    Write-Host '  Working path: az CLI (Azure resources). DevOps access not confirmed.' -ForegroundColor Yellow
    exit 0
} else {
    exit 1
}
