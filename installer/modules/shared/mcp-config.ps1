# ============================================
# Shared MCP Configuration Utilities (PowerShell)
# Uses `claude mcp add` / `gemini mcp add` CLI
# ============================================

function Get-McpCli {
    if ($env:CLI_TYPE -eq "gemini") { return "gemini" }
    return "claude"
}

# Add a Docker-based MCP server
# Usage: Add-McpDockerServer "server_name" "image_name" @("extra", "args") @("--transport", "stdio")
function Add-McpDockerServer {
    param(
        [string]$ServerName,
        [string]$ImageName,
        [string[]]$ExtraArgs = @(),
        [string[]]$PostImageArgs = @()
    )

    $cli = Get-McpCli
    $dockerArgs = @("docker", "run", "-i", "--rm") + $ExtraArgs + @($ImageName) + $PostImageArgs

    & $cli mcp add $ServerName -s user -- @dockerArgs 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] MCP server '$ServerName' configured" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Failed to add MCP server '$ServerName'" -ForegroundColor Red
        return $false
    }
    return $true
}

# Add a stdio-based MCP server
# Usage: Add-McpStdioServer "server_name" "command" @("args")
function Add-McpStdioServer {
    param(
        [string]$ServerName,
        [string]$Command,
        [string[]]$CmdArgs = @()
    )

    $cli = Get-McpCli
    & $cli mcp add $ServerName -s user -- $Command @CmdArgs 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] MCP server '$ServerName' configured" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Failed to add MCP server '$ServerName'" -ForegroundColor Red
        return $false
    }
    return $true
}

# Remove an MCP server
function Remove-McpServer {
    param([string]$ServerName)
    $cli = Get-McpCli
    & $cli mcp remove $ServerName 2>$null
}

# Add permission to ~/.claude/settings.json
# Usage: Add-McpPermission "mcp__server-name"
function Add-McpPermission {
    param([string]$Permission)

    # Claude only
    if ($env:CLI_TYPE -eq "gemini") { return }

    $settingsPath = "$env:USERPROFILE\.claude\settings.json"
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false

    $settings = [PSCustomObject]@{ permissions = [PSCustomObject]@{ allow = @() } }
    if (Test-Path $settingsPath) {
        try {
            $raw = [System.IO.File]::ReadAllText($settingsPath).TrimStart([char]0xFEFF)
            $settings = $raw | ConvertFrom-Json
        } catch {}
    }

    $allowList = @()
    if ($settings.permissions -and $settings.permissions.allow) {
        $allowList = @($settings.permissions.allow)
    }

    if ($allowList -notcontains $Permission) {
        $allowList += $Permission
        if (-not $settings.PSObject.Properties['permissions']) {
            $settings | Add-Member -NotePropertyName 'permissions' -NotePropertyValue ([PSCustomObject]@{ allow = $allowList })
        } else {
            $settings.permissions.allow = $allowList
        }
        [System.IO.File]::WriteAllText($settingsPath, ($settings | ConvertTo-Json -Depth 10), $utf8NoBom)
        Write-Host "  Added permission: $Permission" -ForegroundColor Green
    } else {
        Write-Host "  Permission already set: $Permission" -ForegroundColor Green
    }
}

# Remove server from disabledMcpjsonServers in all project settings
# Usage: Remove-McpProjectBlock "server-name"
function Remove-McpProjectBlock {
    param([string]$ServerName)

    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    $localSettingsFiles = Get-ChildItem -Path $env:USERPROFILE -Recurse -Filter "settings.local.json" -ErrorAction SilentlyContinue |
        Where-Object { $_.DirectoryName -like "*\.claude" }
    $fixedCount = 0
    foreach ($file in $localSettingsFiles) {
        try {
            $raw = [System.IO.File]::ReadAllText($file.FullName)
            $json = $raw | ConvertFrom-Json
            if ($json.disabledMcpjsonServers -and ($json.disabledMcpjsonServers -contains $ServerName)) {
                $json.disabledMcpjsonServers = @($json.disabledMcpjsonServers | Where-Object { $_ -ne $ServerName })
                [System.IO.File]::WriteAllText($file.FullName, ($json | ConvertTo-Json -Depth 10), $utf8NoBom)
                $fixedCount++
            }
        } catch {}
    }
    if ($fixedCount -gt 0) {
        Write-Host "  Fixed $fixedCount project(s)" -ForegroundColor Green
    } else {
        Write-Host "  OK (no blocks found)" -ForegroundColor Green
    }
}
