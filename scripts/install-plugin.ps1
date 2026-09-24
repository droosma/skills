param(
    [Parameter(Mandatory)]
    [string]$Manifest,

    [Parameter(Mandatory)]
    [ValidateSet('Claude Code', 'Copilot CLI', 'Pi', 'OpenCode')]
    [string]$Tool,

    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'

$plugin = Get-Content -LiteralPath $Manifest -Raw | ConvertFrom-Json
$target = $plugin.targets.PSObject.Properties[$Tool].Value

if (-not $target) {
    Write-Host "   - $($plugin.name): $Tool is not supported" -ForegroundColor DarkGray
    exit 0
}

function Assert-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found."
    }
}

function Invoke-Native {
    param(
        [string]$Command,
        [string[]]$Arguments
    )

    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "'$Command $($Arguments -join ' ')' exited with code $LASTEXITCODE."
    }
}

function Get-NativeOutput {
    param(
        [string]$Command,
        [string[]]$Arguments
    )

    $output = & $Command @Arguments 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        throw "'$Command $($Arguments -join ' ')' exited with code $LASTEXITCODE.`n$output"
    }
    return $output
}

switch ($target.mode) {
    'marketplace-plugin' {
        $marketplaceCommand = "$($target.command) plugin marketplace add $($target.marketplaceSource)"
        $installCommand = "$($target.command) plugin install $($target.plugin)"
        if ($target.yes) { $installCommand += ' -y' }

        if ($WhatIf) {
            Write-Host "   - $($plugin.name) for ${Tool}: $marketplaceCommand; $installCommand"
            exit 0
        }

        Assert-Command $target.command
        $marketplaces = Get-NativeOutput $target.command @('plugin', 'marketplace', 'list')
        if ($marketplaces -notmatch [regex]::Escape($target.marketplaceMatch)) {
            Invoke-Native $target.command @('plugin', 'marketplace', 'add', $target.marketplaceSource)
        }

        $plugins = Get-NativeOutput $target.command @('plugin', 'list')
        if ($plugins -match [regex]::Escape($target.installedMatch)) {
            Write-Host "   - $($plugin.name): already installed for $Tool" -ForegroundColor DarkGray
            exit 0
        }

        $arguments = @('plugin', 'install', $target.plugin)
        if ($target.yes) { $arguments += '-y' }
        Invoke-Native $target.command $arguments
        Write-Host "   + $($plugin.name): installed for $Tool" -ForegroundColor Green
    }
    'pi-package' {
        if ($WhatIf) {
            Write-Host "   - $($plugin.name) for Pi: pi install $($target.source)"
            exit 0
        }

        Assert-Command 'pi'
        $installedPackages = Get-NativeOutput 'pi' @('list')
        if ($installedPackages -match [regex]::Escape($target.installedMatch)) {
            Write-Host "   - $($plugin.name): already installed for Pi" -ForegroundColor DarkGray
            exit 0
        }

        Invoke-Native 'pi' @('install', $target.source)
        Write-Host "   + $($plugin.name): installed for Pi" -ForegroundColor Green
    }
    'opencode-plugin' {
        $configDir = if ($env:APPDATA) {
            Join-Path $env:APPDATA 'opencode'
        }
        else {
            Join-Path $HOME '.config/opencode'
        }
        $configPath = Join-Path $configDir 'opencode.json'

        if ($WhatIf) {
            Write-Host "   - $($plugin.name) for OpenCode: add '$($target.plugin)' to $configPath"
            exit 0
        }

        if (Test-Path $configPath) {
            $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
        }
        else {
            New-Item -ItemType Directory -Path $configDir -Force | Out-Null
            $config = [pscustomobject]@{}
        }

        $plugins = @()
        if ($config.PSObject.Properties.Name -contains 'plugin') {
            $plugins = @($config.plugin)
        }
        if ($plugins -contains $target.plugin) {
            Write-Host "   - $($plugin.name): already configured for OpenCode" -ForegroundColor DarkGray
            exit 0
        }

        $plugins += $target.plugin
        if ($config.PSObject.Properties.Name -contains 'plugin') {
            $config.plugin = $plugins
        }
        else {
            $config | Add-Member -NotePropertyName plugin -NotePropertyValue $plugins
        }

        $tempPath = "$configPath.tmp"
        $config | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $tempPath -Encoding utf8
        Move-Item -LiteralPath $tempPath -Destination $configPath -Force
        Write-Host "   + $($plugin.name): configured for OpenCode" -ForegroundColor Green
    }
    'skill-fallback' {
        Write-Host "   - $($plugin.name): $Tool uses the portable '$($target.skill)' skill" -ForegroundColor DarkGray
    }
    default {
        throw "Unknown plugin mode '$($target.mode)' in $Manifest."
    }
}
