# ============================================
# Atlassian (Jira + Confluence) MCP Module
# ============================================
# Auto-detects Docker and recommends best option

Write-Host "Atlassian MCP lets Claude access:" -ForegroundColor White
Write-Host "  - Jira (view issues, create tasks)" -ForegroundColor Gray
Write-Host "  - Confluence (search, read pages)" -ForegroundColor Gray
Write-Host ""

# ============================================
# Auto-detect Docker
# ============================================
$hasDocker = [bool](Get-Command docker -ErrorAction SilentlyContinue)
$dockerRunning = $false
if ($hasDocker) {
    $null = docker info 2>&1
    $dockerRunning = ($LASTEXITCODE -eq 0)
}

# ============================================
# Show options based on Docker status
# ============================================
Write-Host "========================================" -ForegroundColor Cyan
if ($hasDocker) {
    Write-Host "  Docker is installed!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Select installation method:" -ForegroundColor White
    Write-Host "  1. Local install (Recommended) - Uses Docker, runs on your machine" -ForegroundColor Green
    Write-Host "  2. Simple install - Browser login only" -ForegroundColor White
} else {
    Write-Host "  Docker is not installed." -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Select installation method:" -ForegroundColor White
    Write-Host "  1. Simple install (Recommended) - Browser login only, no extra install" -ForegroundColor Green
    Write-Host "  2. Local install - Requires Docker" -ForegroundColor White
}
Write-Host ""
$choice = Read-Host "Select (1/2)"

# Determine which mode based on Docker status and choice
$useDocker = $false
if ($hasDocker) {
    # Docker installed: 1=Docker, 2=Rovo
    if ($choice -ne "2") { $useDocker = $true }
} else {
    # Docker not installed: 1=Rovo, 2=Docker
    if ($choice -eq "2") { $useDocker = $true }
}

# ============================================
# Execute selected mode
# ============================================
if ($useDocker) {
    # ========================================
    # MCP-ATLASSIAN (Docker)
    # ========================================

    # Check Docker is running
    if (-not $hasDocker) {
        Write-Host ""
        Write-Host "Docker is not installed!" -ForegroundColor Red
        Write-Host "Please install Docker Desktop first:" -ForegroundColor White
        Write-Host "  https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
        Write-Host ""
        throw "Docker is required for local installation"
    }

    if (-not $dockerRunning) {
        Write-Host ""
        Write-Host "Docker is not running!" -ForegroundColor Yellow
        Write-Host "Please start Docker Desktop." -ForegroundColor White
        Write-Host ""
        $waitDocker = Read-Host "Press Enter after starting Docker (q to cancel)"
        if ($waitDocker -eq 'q') { throw "Cancelled by user" }

        $null = docker info 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Docker is still not running." -ForegroundColor Red
            throw "Docker is not running"
        }
    }
    Write-Host ""
    Write-Host "[OK] Docker check complete" -ForegroundColor Green

    Write-Host ""
    Write-Host "Setting up mcp-atlassian (Docker)..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "API token required. Create one here:" -ForegroundColor White
    Write-Host "  https://id.atlassian.com/manage-profile/security/api-tokens" -ForegroundColor Cyan
    Write-Host ""

    $openToken = Read-Host "Open API token page in browser? (y/n)"
    if ($openToken -eq "y" -or $openToken -eq "Y") {
        Start-Process "https://id.atlassian.com/manage-profile/security/api-tokens"
        Write-Host "Create and copy the token." -ForegroundColor Yellow
        Read-Host "Press Enter when ready"
    }

    Write-Host ""
    $atlassianUrl = Read-Host "Atlassian URL (e.g., https://company.atlassian.net)"
    $atlassianUrl = $atlassianUrl.TrimEnd('/')
    $jiraUrl = $atlassianUrl
    $confluenceUrl = "$atlassianUrl/wiki"

    Write-Host "  Jira: $jiraUrl" -ForegroundColor Gray
    Write-Host "  Confluence: $confluenceUrl" -ForegroundColor Gray
    Write-Host ""
    $email = Read-Host "Email"
    $apiToken = Read-Host "API Token"

    # Pull Docker image
    Write-Host ""
    Write-Host "[Pull] Downloading mcp-atlassian Docker image..." -ForegroundColor Yellow
    docker pull ghcr.io/sooperset/mcp-atlassian:latest 2>$null
    Write-Host "  OK" -ForegroundColor Green

    # Update MCP config via CLI
    Write-Host ""
    Write-Host "[Config] Updating MCP config..." -ForegroundColor Yellow
    $cliCmd = if ($env:CLI_TYPE -eq "gemini") { "gemini" } else { "claude" }

    & $cliCmd mcp add atlassian -s user -- docker run -i --rm -e "CONFLUENCE_URL=$confluenceUrl" -e "CONFLUENCE_USERNAME=$email" -e "CONFLUENCE_API_TOKEN=$apiToken" -e "JIRA_URL=$jiraUrl" -e "JIRA_USERNAME=$email" -e "JIRA_API_TOKEN=$apiToken" ghcr.io/sooperset/mcp-atlassian:latest --transport stdio 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK" -ForegroundColor Green
    } else {
        Write-Host "  Failed to add MCP server" -ForegroundColor Red
    }

    # Update Claude settings.json permissions (Claude CLI only)
    if ($env:CLI_TYPE -ne "gemini") {
        $claudeSettingsPath = "$env:USERPROFILE\.claude\settings.json"
        $permissionToAdd = "mcp__atlassian"
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false

        $claudeSettings = [PSCustomObject]@{ permissions = [PSCustomObject]@{ allow = @() } }
        if (Test-Path $claudeSettingsPath) {
            try {
                $raw = [System.IO.File]::ReadAllText($claudeSettingsPath).TrimStart([char]0xFEFF)
                $claudeSettings = $raw | ConvertFrom-Json
            } catch {}
        }

        $allowList = @()
        if ($claudeSettings.permissions -and $claudeSettings.permissions.allow) {
            $allowList = @($claudeSettings.permissions.allow)
        }

        if ($allowList -notcontains $permissionToAdd) {
            $allowList += $permissionToAdd
            if (-not $claudeSettings.PSObject.Properties['permissions']) {
                $claudeSettings | Add-Member -NotePropertyName 'permissions' -NotePropertyValue ([PSCustomObject]@{ allow = $allowList })
            } else {
                $claudeSettings.permissions.allow = $allowList
            }
            [System.IO.File]::WriteAllText($claudeSettingsPath, ($claudeSettings | ConvertTo-Json -Depth 10), $utf8NoBom)
            Write-Host "  Added Claude permission: $permissionToAdd" -ForegroundColor Green
        } else {
            Write-Host "  Claude permission already set" -ForegroundColor Green
        }
    }

} else {
    # ========================================
    # ROVO MCP (Official Atlassian SSE)
    # ========================================
    Write-Host ""
    Write-Host "Setting up Atlassian Rovo MCP..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "A browser will open for Atlassian login." -ForegroundColor White
    Write-Host "Please login and authorize the access." -ForegroundColor White
    Write-Host ""

    $cliCmd = if ($env:CLI_TYPE -eq "gemini") { "gemini" } else { "claude" }
    & $cliCmd mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse

    Write-Host ""
    Write-Host "  Rovo MCP setup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Guide: https://support.atlassian.com/atlassian-rovo-mcp-server/" -ForegroundColor Gray
}

# Remove atlassian from disabledMcpjsonServers in all project settings
Write-Host ""
Write-Host "[Fix] Removing project-level blocks..." -ForegroundColor Yellow
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$localSettingsFiles = Get-ChildItem -Path $env:USERPROFILE -Recurse -Filter "settings.local.json" -ErrorAction SilentlyContinue |
    Where-Object { $_.DirectoryName -like "*\.claude" }
$fixedCount = 0
foreach ($file in $localSettingsFiles) {
    try {
        $raw = [System.IO.File]::ReadAllText($file.FullName)
        $json = $raw | ConvertFrom-Json
        if ($json.disabledMcpjsonServers -and ($json.disabledMcpjsonServers -contains "atlassian")) {
            $json.disabledMcpjsonServers = @($json.disabledMcpjsonServers | Where-Object { $_ -ne "atlassian" })
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

Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor DarkGray
Write-Host "Atlassian MCP installation complete!" -ForegroundColor Green
