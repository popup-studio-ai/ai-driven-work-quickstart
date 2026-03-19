# Gemini CLI Support — Design Document

> **Feature**: gemini-cli-support
> **Plan**: `docs/01-plan/features/gemini-cli-support.plan.md` (v2)
> **Date**: 2026-02-22
> **Status**: Draft

---

## 1. Core Design Principle

**All branching is controlled by a single variable `$CLI_TYPE`.**

- `CLI_TYPE=claude` (default) -> 100% existing behavior preserved
- `CLI_TYPE=gemini` -> Switches to Gemini platform
- Main installer exports `CLI_TYPE` -> All child modules reference this variable

---

## 2. CLI_TYPE Value Mapping Table

Central mapping referenced by all branch points:

| Key | `claude` | `gemini` |
|----|----------|----------|
| CLI command | `claude` | `gemini` |
| CLI install (Mac/Linux) | `curl -fsSL https://claude.ai/install.sh \| bash` | `npm install -g @google/gemini-cli` |
| CLI install (Windows) | `irm https://claude.ai/install.ps1 \| iex` | `npm install -g @google/gemini-cli` |
| IDE install (Windows) | `winget install Microsoft.VisualStudioCode` | `winget install Microsoft.VisualStudioCode` |
| IDE install (Mac) | `brew install --cask visual-studio-code` | `brew install --cask visual-studio-code` |
| IDE install (Linux apt) | `sudo snap install code --classic` | `sudo snap install code --classic` |
| VS Code extension | `code --install-extension anthropic.claude-code` | `code --install-extension Google.gemini-cli-vscode-ide-companion` |
| Plugin install | `claude plugin marketplace add popup-studio-ai/bkit-claude-code && claude plugin install bkit@bkit-marketplace` | `gemini extensions install https://github.com/popup-studio-ai/bkit-gemini.git` |
| MCP config file | `~/.claude/mcp.json` | `~/.gemini/settings.json` |
| MCP add (http) | `claude mcp add --transport http {name} {url}` | `gemini mcp add --transport http {name} {url}` |
| MCP add (sse) | `claude mcp add --transport sse {name} {url}` | `gemini mcp add --transport sse {name} {url}` |
| MCP list | `claude mcp list` | `gemini mcp list` |

---

## 3. Detailed Per-File Change Design

### 3.1 installer/install.sh (Mac/Linux main)

**FR-01, FR-02, FR-03**

```bash
# Parameter to add to existing while loop
--cli)
    CLI_TYPE="$2"
    shift 2
    ;;

# Read environment variable (after parameter parsing)
CLI_TYPE="${CLI_TYPE:-claude}"

# Validation
if [[ "$CLI_TYPE" != "claude" && "$CLI_TYPE" != "gemini" ]]; then
    echo -e "${RED}Invalid --cli value: $CLI_TYPE (use 'claude' or 'gemini')${NC}"
    exit 1
fi

# export (pass to all child modules)
export CLI_TYPE
```

### 3.2 installer/install.ps1 (Windows main)

**FR-01, FR-02, FR-03**

```powershell
# Add to param block
param(
    [string]$cli = "",          # CLI type: claude or gemini
    # ... existing parameters ...
)

# Environment variable support
if (-not $cli -and $env:CLI_TYPE) {
    $cli = $env:CLI_TYPE
}
if (-not $cli) { $cli = "claude" }

# Validation
if ($cli -ne "claude" -and $cli -ne "gemini") {
    Write-Host "Invalid -cli value: $cli (use 'claude' or 'gemini')" -ForegroundColor Red
    exit 1
}

# Pass to child modules
$env:CLI_TYPE = $cli
```

### 3.3 modules/base/install.sh (Mac/Linux base)

**FR-04, FR-05, FR-06, FR-07**

#### IDE Installation (common VS Code)

```bash
# ============================================
# 4. VS Code
# ============================================
echo ""
echo -e "${YELLOW}[4/7] Checking VS Code...${NC}"
# ... VS Code installation logic (Claude/Gemini common) ...

# Install IDE extension based on CLI type
if command -v code > /dev/null 2>&1; then
    if [ "$CLI_TYPE" = "gemini" ]; then
        code --install-extension Google.gemini-cli-vscode-ide-companion --force
    else
        code --install-extension anthropic.claude-code --force
    fi
fi
```

#### CLI Installation Branching (replaces existing "6. Claude Code CLI" section)

```bash
# ============================================
# 6. AI CLI
# ============================================
echo ""
if [ "$CLI_TYPE" = "gemini" ]; then
    echo -e "${YELLOW}[6/7] Checking Gemini CLI...${NC}"
    if ! command -v gemini > /dev/null 2>&1; then
        echo -e "  ${GRAY}Installing Gemini CLI...${NC}"
        npm install -g @google/gemini-cli
    fi
    if command -v gemini > /dev/null 2>&1; then
        GEMINI_VERSION=$(gemini --version 2>/dev/null || echo "unknown")
        echo -e "  ${GREEN}OK - $GEMINI_VERSION${NC}"
    else
        echo -e "  ${YELLOW}Installed (restart terminal to use)${NC}"
    fi
else
    echo -e "${YELLOW}[6/7] Checking Claude Code CLI...${NC}"
    # ... existing Claude CLI installation logic preserved ...
fi
```

#### Plugin Branching (replaces existing "7. bkit Plugin" section)

```bash
# ============================================
# 7. bkit Plugin
# ============================================
echo ""
if [ "$CLI_TYPE" = "gemini" ]; then
    echo -e "${YELLOW}[7/7] Installing bkit Plugin (Gemini)...${NC}"
    gemini extensions install https://github.com/popup-studio-ai/bkit-gemini.git 2>/dev/null || true
    echo -e "  ${GREEN}OK${NC}"
else
    echo -e "${YELLOW}[7/7] Installing bkit Plugin...${NC}"
    claude plugin marketplace add popup-studio-ai/bkit-claude-code 2>/dev/null || true
    claude plugin install bkit@bkit-marketplace 2>/dev/null || true
    # ... existing verification logic ...
fi
```

### 3.4 modules/base/install.ps1 (Windows base)

**FR-04, FR-05, FR-06, FR-07** — Same pattern as install.sh implemented in PowerShell

#### IDE Installation (common VS Code)

```powershell
# 4. VS Code (Claude/Gemini common)
Write-Host "[4/8] Checking VS Code..." -ForegroundColor Yellow
# ... VS Code installation logic ...

# Install IDE extension based on CLI type
if ($env:CLI_TYPE -eq "gemini") {
    Install-VSCodeExtension -ExtensionId "Google.gemini-cli-vscode-ide-companion" -DisplayName "Gemini CLI Companion" -Command $codeCmd
} else {
    Install-VSCodeExtension -ExtensionId "anthropic.claude-code" -DisplayName "Claude Code" -Command $codeCmd
}
```

#### CLI Installation Branching

```powershell
if ($env:CLI_TYPE -eq "gemini") {
    Write-Host "[7/8] Checking Gemini CLI..." -ForegroundColor Yellow
    Refresh-Path
    if (-not (Test-CommandExists "gemini")) {
        Write-Host "  Installing Gemini CLI..." -ForegroundColor Gray
        npm install -g @google/gemini-cli
        Refresh-Path
    }
    if (Test-CommandExists "gemini") {
        $geminiVersion = gemini --version 2>$null
        Write-Host "  OK - $geminiVersion" -ForegroundColor Green
    } else {
        Write-Host "  Installed (restart terminal to use)" -ForegroundColor Yellow
    }
} else {
    Write-Host "[7/8] Checking Claude Code CLI..." -ForegroundColor Yellow
    # ... existing Claude CLI installation logic preserved ...
}
```

#### Plugin Branching

```powershell
if ($env:CLI_TYPE -eq "gemini") {
    Write-Host "[8/8] Installing bkit Plugin (Gemini)..." -ForegroundColor Yellow
    gemini extensions install https://github.com/popup-studio-ai/bkit-gemini.git 2>$null
    Write-Host "  OK" -ForegroundColor Green
} else {
    Write-Host "[8/8] Installing bkit Plugin..." -ForegroundColor Yellow
    # ... existing bkit installation logic preserved ...
}
```

### 3.5 modules/shared/mcp-config.sh

**FR-12** — MCP config file path branching

```bash
# mcp_get_config_path() function modification
mcp_get_config_path() {
    if [ "$CLI_TYPE" = "gemini" ]; then
        local config_path="$HOME/.gemini/settings.json"
    else
        local config_path="$HOME/.claude/mcp.json"
    fi
    local legacy_path="$HOME/.mcp.json"

    # Migrate legacy config if needed (claude only)
    if [ "$CLI_TYPE" != "gemini" ] && [ -f "$legacy_path" ] && [ ! -f "$config_path" ]; then
        mkdir -p "$(dirname "$config_path")"
        cp "$legacy_path" "$config_path"
        echo -e "  ${YELLOW}Migrated MCP config from $legacy_path to $config_path${NC}"
    fi

    echo "$config_path"
}
```

**Note**: `mcp_add_docker_server()` and `mcp_add_stdio_server()` do not need modification since the JSON structure (`mcpServers`) is identical. Path branching in `mcp_get_config_path()` automatically writes to the correct file.

### 3.6 modules/shared/oauth-helper.sh

**FR-13**

```bash
# Before: claude mcp list > /dev/null 2>&1
# After:
if [ "$CLI_TYPE" = "gemini" ]; then
    gemini mcp list > /dev/null 2>&1
else
    claude mcp list > /dev/null 2>&1
fi

# Before: "Make sure 'claude mcp add' was run first."
# After:
echo -e "  ${YELLOW}Make sure '${CLI_TYPE:-claude} mcp add' was run first.${NC}"
```

### 3.7 modules/shared/oauth-helper.ps1

**FR-13**

```powershell
# Before: claude mcp list 2>&1 | Out-Null
# After:
if ($env:CLI_TYPE -eq "gemini") {
    gemini mcp list 2>&1 | Out-Null
} else {
    claude mcp list 2>&1 | Out-Null
}
```

### 3.8 modules/notion/install.sh

**FR-08**

```bash
# CLI check (existing claude -> branching)
CLI_CMD="${CLI_TYPE:-claude}"
echo -e "${YELLOW}[Check] $CLI_CMD CLI...${NC}"
if ! command -v "$CLI_CMD" > /dev/null 2>&1; then
    echo -e "  ${RED}$CLI_CMD CLI is required. Please install base module first.${NC}"
    exit 1
fi
echo -e "  ${GREEN}OK${NC}"

# MCP registration (existing claude mcp add -> branching)
echo -e "${YELLOW}[Config] Registering Notion Remote MCP server...${NC}"
$CLI_CMD mcp add --transport http notion https://mcp.notion.com/mcp
```

### 3.9 modules/notion/install.ps1

**FR-08**

```powershell
$cliCmd = if ($env:CLI_TYPE -eq "gemini") { "gemini" } else { "claude" }

Write-Host "[Check] $cliCmd CLI..." -ForegroundColor Yellow
if (-not (Test-CommandExists $cliCmd)) {
    Write-Host "  $cliCmd CLI is required. Please install base module first." -ForegroundColor Red
    throw "$cliCmd CLI not found"
}

# MCP registration
& $cliCmd mcp add --transport http notion https://mcp.notion.com/mcp
```

### 3.10 modules/figma/install.sh

**FR-09** — Same pattern as Notion

```bash
CLI_CMD="${CLI_TYPE:-claude}"

# CLI check
if ! command -v "$CLI_CMD" > /dev/null 2>&1; then
    echo -e "  ${RED}$CLI_CMD CLI is required. Please install base module first.${NC}"
    exit 1
fi

# MCP registration
$CLI_CMD mcp add --transport http figma https://mcp.figma.com/mcp
```

### 3.11 modules/figma/install.ps1

**FR-09** — Same pattern as Notion ps1

### 3.12 modules/atlassian/install.sh

**FR-10**

```bash
# Rovo mode MCP registration (existing claude mcp add -> branching)
CLI_CMD="${CLI_TYPE:-claude}"
$CLI_CMD mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse
```

Docker mode uses `mcp_add_docker_server()` -> automatically handled by `mcp-config.sh` path branching.

### 3.13 modules/atlassian/install.ps1

**FR-10** — Same pattern

```powershell
$cliCmd = if ($env:CLI_TYPE -eq "gemini") { "gemini" } else { "claude" }
& $cliCmd mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse
```

### 3.14 modules/google/install.sh, install.ps1

**FR-11** — Uses `mcp_add_docker_server()` so no direct modification needed.
Path branching from `mcp-config.sh` is applied, automatically writing to the correct config file.

### 3.15 modules/pencil/install.sh, install.ps1

**Pencil also supported normally when Gemini is selected**

Since Gemini also uses VS Code, Pencil is installed the same as Claude without skip processing.
(`highagency.pencildev` extension installed via `code --install-extension`)

### 3.16 README.md

```markdown
### Windows (Gemini)
powershell -ep bypass -c "$env:CLI_TYPE='gemini'; irm .../install.ps1 | iex"

### Mac/Linux (Gemini)
curl -fsSL .../install.sh | CLI_TYPE=gemini bash
```

---

## 4. Implementation Order

| Order | File | Dependency |
|:----:|------|--------|
| 1 | `install.sh` -- `--cli` parameter + export | None |
| 2 | `install.ps1` -- `-cli` parameter + export | None |
| 3 | `shared/mcp-config.sh` -- path branching | None |
| 4 | `shared/oauth-helper.sh` -- command branching | None |
| 5 | `shared/oauth-helper.ps1` -- command branching | None |
| 6 | `base/install.sh` -- IDE + CLI + plugin branching | After #1 |
| 7 | `base/install.ps1` -- IDE + CLI + plugin branching | After #2 |
| 8 | `notion/install.sh` + `install.ps1` | After #3 |
| 9 | `figma/install.sh` + `install.ps1` | After #3 |
| 10 | `atlassian/install.sh` + `install.ps1` | After #3 |
| 11 | `pencil/install.sh` + `install.ps1` | None |
| 12 | `README.md` | After all complete |

---

## 5. Test Scenarios

| # | Scenario | Expected Result |
|---|---------|----------|
| T-01 | `./install.sh` (no parameters) | Claude installation (backward compatible) |
| T-02 | `./install.sh --cli claude` | Claude installation |
| T-03 | `./install.sh --cli gemini` | Antigravity + Gemini CLI + bkit-gemini |
| T-04 | `./install.sh --cli invalid` | Error message + exit |
| T-05 | `CLI_TYPE=gemini ./install.sh` | Gemini installation (environment variable) |
| T-06 | `--cli gemini --modules notion` | Gemini + Notion MCP (gemini mcp add) |
| T-07 | `--cli gemini --modules google` | Gemini + Google MCP (written to settings.json) |
| T-08 | `--cli gemini --modules pencil` | Pencil skip + guidance message |
| T-09 | All existing tests | Pass (no regression) |
