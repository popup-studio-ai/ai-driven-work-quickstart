# ADW Improvement Project - Shared Utilities Design

**Author**: Frontend Architect (bkit)
**Date**: 2026-02-12
**Version**: 1.0
**Related FRs**: FR-S3-05 (Code Deduplication)

## Executive Summary

This document presents the complete shared utilities architecture for the ADW Improvement project, addressing code duplication across:
- **Installer modules** (7 shell scripts with ~40% code duplication)
- **Google MCP tools** (6 TypeScript files with ~35% code duplication)

The proposed refactoring will reduce codebase size by ~30%, improve maintainability, and establish consistent patterns across the project.

---

## 1. Installer Shared Utilities Design

### 1.1 Duplication Analysis

| Category | Current State | Files Affected | Lines Duplicated |
|----------|--------------|----------------|------------------|
| **Color constants** | Defined in every module | 7 files | 7 × 6 = 42 lines |
| **Docker checks** | Duplicated logic | google, atlassian | 2 × 30 = 60 lines |
| **MCP config updates** | Node.js JSON manipulation | google, atlassian | 2 × 25 = 50 lines |
| **Browser open logic** | Platform detection | atlassian, google, figma, notion | 4 × 10 = 40 lines |
| **OAuth flow** | Already shared | oauth-helper.sh | ✅ Centralized |

**Total Duplication**: ~192 lines across 7 modules

### 1.2 Proposed Directory Structure

```
installer/modules/shared/
├── colors.sh              # Color constants (ANSI escape codes)
├── docker-utils.sh        # Docker availability, wait, cleanup
├── mcp-config.sh          # MCP JSON config read/write operations
├── browser-utils.sh       # Cross-platform browser opening
├── oauth-helper.sh        # (existing) OAuth PKCE flow
└── package-manager.sh     # Cross-platform package installation
```

---

### 1.3 Shared Utility Implementations

#### **1.3.1 colors.sh** (Color Constants)

**File**: `/Users/popup-kay/Documents/GitHub/popup/popup-claude/installer/modules/shared/colors.sh`

```bash
#!/bin/bash
# ============================================
# Shared Color Definitions
# ============================================
# Standard ANSI color codes for consistent terminal output
# Usage: source "${SCRIPT_DIR}/../shared/colors.sh"

# Base colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export CYAN='\033[0;36m'
export GRAY='\033[0;90m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export WHITE='\033[1;37m'

# Reset
export NC='\033[0m'  # No Color

# Semantic colors (for consistency)
export COLOR_SUCCESS="${GREEN}"
export COLOR_ERROR="${RED}"
export COLOR_WARNING="${YELLOW}"
export COLOR_INFO="${CYAN}"
export COLOR_DEBUG="${GRAY}"

# Print utilities (optional convenience functions)
print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

print_info() {
    echo -e "${CYAN}$1${NC}"
}

print_debug() {
    echo -e "${GRAY}$1${NC}"
}
```

**Usage in modules**:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../shared/colors.sh"

echo -e "${GREEN}Installation complete!${NC}"
# Or use convenience functions:
print_success "Installation complete!"
```

---

#### **1.3.2 docker-utils.sh** (Docker Management)

**File**: `/Users/popup-kay/Documents/GitHub/popup/popup-claude/installer/modules/shared/docker-utils.sh`

```bash
#!/bin/bash
# ============================================
# Docker Utilities
# ============================================
# Shared functions for Docker availability checks, startup, and cleanup
# Prerequisites: colors.sh must be sourced first

# Check if Docker command exists
docker_is_installed() {
    command -v docker > /dev/null 2>&1
}

# Check if Docker daemon is running
docker_is_running() {
    docker info > /dev/null 2>&1
}

# Get Docker status (installed, running, not_installed, not_running)
docker_get_status() {
    if ! docker_is_installed; then
        echo "not_installed"
        return 1
    fi

    if docker_is_running; then
        echo "running"
        return 0
    else
        echo "not_running"
        return 2
    fi
}

# Check Docker with user-friendly output
# Returns: 0 if running, 1 if not installed, 2 if installed but not running
docker_check() {
    local status
    status=$(docker_get_status)

    case "$status" in
        "running")
            echo -e "  ${GREEN}Docker is running${NC}"
            return 0
            ;;
        "not_installed")
            echo -e "  ${RED}Docker is not installed${NC}"
            return 1
            ;;
        "not_running")
            echo -e "  ${YELLOW}Docker is installed but not running${NC}"
            return 2
            ;;
    esac
}

# Wait for Docker to start (with user prompt)
# Usage: docker_wait_for_start
docker_wait_for_start() {
    if docker_is_running; then
        return 0
    fi

    echo ""
    echo -e "${YELLOW}Docker is not running!${NC}"
    echo "Please start Docker Desktop."
    echo ""
    read -p "Press Enter after starting Docker (q to cancel): " wait_response < /dev/tty

    if [ "$wait_response" = "q" ] || [ "$wait_response" = "Q" ]; then
        echo "Cancelled."
        return 1
    fi

    # Verify Docker started
    if ! docker_is_running; then
        echo -e "${RED}Docker is still not running.${NC}"
        return 1
    fi

    echo -e "  ${GREEN}Docker is now running${NC}"
    return 0
}

# Install Docker Desktop (platform-specific)
# Sets global variable: DOCKER_NEEDS_RESTART
docker_install() {
    echo -e "  ${GRAY}Installing Docker Desktop...${NC}"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - use Homebrew with progress spinner
        echo -e "  ${GRAY}This may take 3~5 minutes. Please wait...${NC}"

        # Run brew install in background with spinner
        brew install --cask docker > /dev/null 2>&1 &
        BREW_PID=$!
        SPINNER='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

        while kill -0 $BREW_PID 2>/dev/null; do
            for (( i=0; i<${#SPINNER}; i++ )); do
                kill -0 $BREW_PID 2>/dev/null || break
                printf "\r  ${GRAY}%s Installing Docker Desktop...${NC}" "${SPINNER:$i:1}"
                sleep 0.3
            done
        done

        wait $BREW_PID
        BREW_EXIT=$?
        printf "\r%-65s\r" ""  # Clear spinner line

        if [ $BREW_EXIT -eq 0 ]; then
            DOCKER_NEEDS_RESTART=true
            echo -e "  ${YELLOW}Installed (start Docker Desktop after setup)${NC}"
            return 0
        else
            echo -e "  ${RED}Installation failed. Please install Docker Desktop manually.${NC}"
            return 1
        fi
    else
        # Linux - use official install script
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker $USER
        DOCKER_NEEDS_RESTART=true
        echo -e "  ${YELLOW}Installed (logout/login required)${NC}"
        return 0
    fi
}

# Pull Docker image with progress
# Usage: docker_pull_image "IMAGE_NAME"
docker_pull_image() {
    local image_name="$1"
    echo -e "  ${YELLOW}Pulling Docker image: $image_name${NC}"
    docker pull "$image_name" 2>/dev/null
    echo -e "  ${GREEN}OK${NC}"
}

# Stop and remove container by image name
# Usage: docker_cleanup_container "IMAGE_NAME"
docker_cleanup_container() {
    local image_name="$1"
    local container_id
    container_id=$(docker ps -q --filter "ancestor=$image_name" 2>/dev/null)

    if [ -n "$container_id" ]; then
        docker stop "$container_id" > /dev/null 2>&1
        docker rm "$container_id" > /dev/null 2>&1
    fi
}

# Show Docker installation guide
docker_show_install_guide() {
    echo ""
    echo -e "${RED}Docker is not installed!${NC}"
    echo "Please install Docker Desktop first:"
    echo -e "  ${CYAN}https://www.docker.com/products/docker-desktop/${NC}"
    echo ""
}
```

**Usage in modules**:
```bash
source "$SCRIPT_DIR/../shared/colors.sh"
source "$SCRIPT_DIR/../shared/docker-utils.sh"

# Check Docker status
if ! docker_check; then
    docker_show_install_guide
    exit 1
fi

# Wait for Docker to start
if ! docker_wait_for_start; then
    exit 1
fi

# Pull image
docker_pull_image "ghcr.io/popup-jacob/google-workspace-mcp:latest"
```

---

#### **1.3.3 mcp-config.sh** (MCP Configuration Management)

**File**: `/Users/popup-kay/Documents/GitHub/popup/popup-claude/installer/modules/shared/mcp-config.sh`

```bash
#!/bin/bash
# ============================================
# MCP Configuration Management
# ============================================
# JSON manipulation utilities for .mcp.json and .claude/mcp.json
# Uses Node.js for reliable JSON parsing/writing

# Determine MCP config path based on OS
mcp_get_config_path() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
        # Windows or WSL
        echo "$HOME/.claude/mcp.json"
    else
        # Mac/Linux
        echo "$HOME/.mcp.json"
    fi
}

# Check if Node.js is available
mcp_check_node() {
    if ! command -v node > /dev/null 2>&1; then
        echo -e "${RED}Node.js is required for MCP configuration.${NC}"
        echo -e "${YELLOW}Please install Node.js first.${NC}"
        return 1
    fi
    return 0
}

# Add MCP server configuration (Docker command)
# Usage: mcp_add_docker_server "SERVER_NAME" "IMAGE_NAME" "ENV_VAR1=value1" "ENV_VAR2=value2" ...
mcp_add_docker_server() {
    if ! mcp_check_node; then return 1; fi

    local server_name="$1"
    local image_name="$2"
    shift 2
    local env_vars=("$@")

    local config_path
    config_path=$(mcp_get_config_path)

    # Build environment variables JSON array
    local env_json="["
    for env_var in "${env_vars[@]}"; do
        env_json="${env_json}'${env_var}',"
    done
    env_json="${env_json%,}]"  # Remove trailing comma

    node -e "
const fs = require('fs');
const configPath = '$config_path';
let config = { mcpServers: {} };

if (fs.existsSync(configPath)) {
    const content = fs.readFileSync(configPath, 'utf8');
    config = JSON.parse(content);
    if (!config.mcpServers) config.mcpServers = {};
}

const envVars = $env_json;
const args = ['run', '-i', '--rm'];
envVars.forEach(env => {
    args.push('-e', env);
});
args.push('$image_name');

config.mcpServers['$server_name'] = {
    command: 'docker',
    args: args
};

const dir = require('path').dirname(configPath);
if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
}

fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
console.log('OK');
"
}

# Add MCP server configuration (stdio command)
# Usage: mcp_add_stdio_server "SERVER_NAME" "COMMAND" "ARG1" "ARG2" ...
mcp_add_stdio_server() {
    if ! mcp_check_node; then return 1; fi

    local server_name="$1"
    local command="$2"
    shift 2
    local args=("$@")

    local config_path
    config_path=$(mcp_get_config_path)

    # Build args JSON array
    local args_json="["
    for arg in "${args[@]}"; do
        args_json="${args_json}'${arg}',"
    done
    args_json="${args_json%,}]"  # Remove trailing comma

    node -e "
const fs = require('fs');
const configPath = '$config_path';
let config = { mcpServers: {} };

if (fs.existsSync(configPath)) {
    const content = fs.readFileSync(configPath, 'utf8');
    config = JSON.parse(content);
    if (!config.mcpServers) config.mcpServers = {};
}

config.mcpServers['$server_name'] = {
    command: '$command',
    args: $args_json
};

const dir = require('path').dirname(configPath);
if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
}

fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
console.log('OK');
"
}

# Remove MCP server configuration
# Usage: mcp_remove_server "SERVER_NAME"
mcp_remove_server() {
    if ! mcp_check_node; then return 1; fi

    local server_name="$1"
    local config_path
    config_path=$(mcp_get_config_path)

    node -e "
const fs = require('fs');
const configPath = '$config_path';

if (!fs.existsSync(configPath)) {
    console.log('Config file does not exist');
    process.exit(0);
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
if (config.mcpServers && config.mcpServers['$server_name']) {
    delete config.mcpServers['$server_name'];
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
    console.log('Removed');
} else {
    console.log('Server not found');
}
"
}

# Check if MCP server exists
# Usage: if mcp_server_exists "SERVER_NAME"; then ...
mcp_server_exists() {
    if ! mcp_check_node; then return 1; fi

    local server_name="$1"
    local config_path
    config_path=$(mcp_get_config_path)

    local result
    result=$(node -e "
const fs = require('fs');
const configPath = '$config_path';

if (!fs.existsSync(configPath)) {
    console.log('false');
    process.exit(0);
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
console.log(config.mcpServers && config.mcpServers['$server_name'] ? 'true' : 'false');
")

    [ "$result" = "true" ]
}
```

**Usage in modules**:
```bash
source "$SCRIPT_DIR/../shared/colors.sh"
source "$SCRIPT_DIR/../shared/mcp-config.sh"

# Add Google MCP server
echo -e "${YELLOW}[Config] Updating MCP configuration...${NC}"
mcp_add_docker_server \
    "google-workspace" \
    "ghcr.io/popup-jacob/google-workspace-mcp:latest" \
    "-v" "$CONFIG_DIR:/app/.google-workspace"

echo -e "  ${GREEN}OK${NC}"
```

---

#### **1.3.4 browser-utils.sh** (Cross-Platform Browser Opening)

**File**: `/Users/popup-kay/Documents/GitHub/popup/popup-claude/installer/modules/shared/browser-utils.sh`

```bash
#!/bin/bash
# ============================================
# Browser Utilities
# ============================================
# Cross-platform browser opening and URL handling

# Open URL in default browser
# Usage: browser_open "https://example.com"
browser_open() {
    local url="$1"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open "$url" 2>/dev/null
        return $?
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        # Windows (Git Bash / MSYS2)
        start "$url" 2>/dev/null
        return $?
    elif command -v xdg-open > /dev/null 2>&1; then
        # Linux with xdg-open
        xdg-open "$url" 2>/dev/null
        return $?
    elif command -v gnome-open > /dev/null 2>&1; then
        # Older GNOME
        gnome-open "$url" 2>/dev/null
        return $?
    else
        # Fallback - show URL
        echo -e "  ${YELLOW}Could not auto-open browser. Please open manually:${NC}"
        echo "  $url"
        return 1
    fi
}

# Open URL with user confirmation
# Usage: browser_open_with_prompt "Description" "https://example.com"
browser_open_with_prompt() {
    local description="$1"
    local url="$2"

    echo ""
    read -p "Open $description in browser? (y/n): " open_response < /dev/tty

    if [ "$open_response" = "y" ] || [ "$open_response" = "Y" ]; then
        if browser_open "$url"; then
            echo -e "${GREEN}Browser opened${NC}"
        fi
    else
        echo -e "${GRAY}Skipped. Manual URL: $url${NC}"
    fi
}

# Open URL and display it for manual fallback
# Usage: browser_open_or_show "https://example.com" "Optional description"
browser_open_or_show() {
    local url="$1"
    local description="${2:-URL}"

    echo ""
    echo -e "${CYAN}Opening $description...${NC}"

    if browser_open "$url"; then
        echo -e "  ${GREEN}Browser opened successfully${NC}"
    else
        echo ""
        echo -e "  ${YELLOW}Please open this URL manually:${NC}"
        echo "  $url"
    fi
    echo ""
}

# Wait for user to complete browser action
# Usage: browser_wait_for_completion "login" (shows "Press Enter after completing login")
browser_wait_for_completion() {
    local action="${1:-completing the action}"
    read -p "Press Enter after $action: " < /dev/tty
}
```

**Usage in modules**:
```bash
source "$SCRIPT_DIR/../shared/colors.sh"
source "$SCRIPT_DIR/../shared/browser-utils.sh"

# Simple open
browser_open "https://id.atlassian.com/manage-profile/security/api-tokens"

# With user prompt
browser_open_with_prompt \
    "Google Cloud Console" \
    "https://console.cloud.google.com/apis/credentials/consent?project=$PROJECT_ID"

# Open and show URL
browser_open_or_show \
    "https://accounts.google.com/o/oauth2/auth?..." \
    "Google login page"

browser_wait_for_completion "login"
```

---

#### **1.3.5 package-manager.sh** (Cross-Platform Package Installation)

**File**: `/Users/popup-kay/Documents/GitHub/popup/popup-claude/installer/modules/shared/package-manager.sh`

```bash
#!/bin/bash
# ============================================
# Package Manager Utilities
# ============================================
# Cross-platform package installation abstraction

# Detect package manager
pkg_detect_manager() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew > /dev/null 2>&1; then
            echo "brew"
        else
            echo "none"
        fi
    elif command -v apt > /dev/null 2>&1; then
        echo "apt"
    elif command -v dnf > /dev/null 2>&1; then
        echo "dnf"
    elif command -v yum > /dev/null 2>&1; then
        echo "yum"
    elif command -v pacman > /dev/null 2>&1; then
        echo "pacman"
    else
        echo "none"
    fi
}

# Install package using detected package manager
# Usage: pkg_install "package-name"
pkg_install() {
    local package_name="$1"
    local manager
    manager=$(pkg_detect_manager)

    case "$manager" in
        brew)
            brew install "$package_name"
            ;;
        apt)
            sudo apt update && sudo apt install -y "$package_name"
            ;;
        dnf)
            sudo dnf install -y "$package_name"
            ;;
        yum)
            sudo yum install -y "$package_name"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$package_name"
            ;;
        none)
            echo -e "${RED}No package manager detected${NC}"
            return 1
            ;;
    esac
}

# Install cask (macOS only)
# Usage: pkg_install_cask "docker"
pkg_install_cask() {
    local cask_name="$1"

    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${YELLOW}Cask installation only supported on macOS${NC}"
        return 1
    fi

    if ! command -v brew > /dev/null 2>&1; then
        echo -e "${RED}Homebrew not found${NC}"
        return 1
    fi

    brew install --cask "$cask_name"
}

# Check if package is installed
# Usage: if pkg_is_installed "git"; then ...
pkg_is_installed() {
    local package_name="$1"
    command -v "$package_name" > /dev/null 2>&1
}

# Install if not present
# Usage: pkg_ensure_installed "git" "version control"
pkg_ensure_installed() {
    local package_name="$1"
    local description="${2:-$package_name}"

    if pkg_is_installed "$package_name"; then
        echo -e "  ${GREEN}$description is already installed${NC}"
        return 0
    fi

    echo -e "  ${YELLOW}Installing $description...${NC}"
    if pkg_install "$package_name"; then
        echo -e "  ${GREEN}Installed $description${NC}"
        return 0
    else
        echo -e "  ${RED}Failed to install $description${NC}"
        return 1
    fi
}
```

**Usage in modules**:
```bash
source "$SCRIPT_DIR/../shared/colors.sh"
source "$SCRIPT_DIR/../shared/package-manager.sh"

# Ensure dependencies
pkg_ensure_installed "python3" "Python 3"
pkg_ensure_installed "git" "Git"

# macOS cask
if [[ "$OSTYPE" == "darwin"* ]]; then
    pkg_install_cask "visual-studio-code"
fi
```

---

### 1.4 Migration Guide for Installer Modules

#### Before (google/install.sh - lines 17-30):
```bash
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Docker check
echo -e "${YELLOW}[Check] Docker is running...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo ""
    echo -e "${RED}Docker is not running!${NC}"
    exit 1
fi
```

#### After (google/install.sh):
```bash
# Load shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../shared/colors.sh"
source "$SCRIPT_DIR/../shared/docker-utils.sh"
source "$SCRIPT_DIR/../shared/mcp-config.sh"
source "$SCRIPT_DIR/../shared/browser-utils.sh"

# Docker check
echo -e "${YELLOW}[Check] Docker is running...${NC}"
if ! docker_check; then
    docker_show_install_guide
    exit 1
fi
```

**Lines Saved**: ~50 lines per module × 7 modules = **350 lines total**

---

## 2. Google MCP Shared Utilities Design

### 2.1 Duplication Analysis

| Category | Occurrences | Files Affected | Impact |
|----------|------------|----------------|---------|
| **parseTime() function** | 2 identical copies | calendar.ts (lines 158, 282) | Code smell |
| **getGoogleServices() calls** | 69 handler invocations | All 6 tool files | Performance overhead |
| **Korean messages** | ~150 strings | All 6 tool files | i18n barrier |
| **Error handling patterns** | Inconsistent | All files | Maintenance burden |

**Total Handlers**: 69 across 6 files
**Service Instantiations**: 69 × 6 = **414 service objects created per execution**

### 2.2 Proposed Directory Structure

```
google-workspace-mcp/src/
├── utils/
│   ├── time.ts          # Time parsing and timezone utilities
│   ├── retry.ts         # Exponential backoff retry wrapper
│   ├── sanitize.ts      # Input sanitization (query escaping, header cleaning)
│   └── messages.ts      # Centralized message strings (i18n-ready)
├── services/
│   └── google-client.ts # Singleton service instance manager
├── types/
│   └── common.types.ts  # Shared type definitions
└── tools/
    ├── calendar.ts
    ├── drive.ts
    ├── gmail.ts
    ├── docs.ts
    ├── sheets.ts
    └── slides.ts
```

---

### 2.3 Shared Utility Implementations

#### **2.3.1 time.ts** (Time Parsing Utilities)

**File**: `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/utils/time.ts`

```typescript
/**
 * Time Parsing and Timezone Utilities
 *
 * Consolidates time-related functions used across Calendar and other tools.
 */

/**
 * Parse time string to ISO 8601 format
 *
 * Handles two input formats:
 * - ISO 8601: "2026-02-12T14:30:00+09:00" (returned as-is)
 * - Custom: "YYYY-MM-DD HH:mm" (converted to ISO with timezone)
 *
 * @param timeStr - Time string in ISO or custom format
 * @param timezone - IANA timezone (default: "Asia/Seoul")
 * @returns ISO 8601 formatted string
 *
 * @example
 * parseTime("2026-02-12T14:30:00+09:00") // "2026-02-12T14:30:00+09:00"
 * parseTime("2026-02-12 14:30") // "2026-02-12T14:30:00+09:00"
 * parseTime("2026-02-12 14:30", "America/New_York") // "2026-02-12T14:30:00-05:00"
 */
export function parseTime(timeStr: string, timezone: string = "Asia/Seoul"): string {
  // Already ISO 8601 format
  if (timeStr.includes("T")) {
    return timeStr;
  }

  // Parse "YYYY-MM-DD HH:mm" format
  const [date, time] = timeStr.split(" ");

  // Get timezone offset (simplified - in production use a library like date-fns-tz)
  const timezoneOffsets: Record<string, string> = {
    "Asia/Seoul": "+09:00",
    "America/New_York": "-05:00",
    "America/Los_Angeles": "-08:00",
    "Europe/London": "+00:00",
    "UTC": "+00:00",
  };

  const offset = timezoneOffsets[timezone] || "+00:00";
  return `${date}T${time}:00${offset}`;
}

/**
 * Get current time in ISO format
 *
 * @param timezone - IANA timezone (default: "Asia/Seoul")
 * @returns Current time in ISO 8601 format
 */
export function getCurrentTime(timezone: string = "Asia/Seoul"): string {
  return new Date().toISOString();
}

/**
 * Add days to a date
 *
 * @param date - Base date (ISO string or Date object)
 * @param days - Number of days to add
 * @returns ISO 8601 formatted string
 */
export function addDays(date: string | Date, days: number): string {
  const baseDate = typeof date === "string" ? new Date(date) : date;
  const newDate = new Date(baseDate.getTime() + days * 24 * 60 * 60 * 1000);
  return newDate.toISOString();
}

/**
 * Format date for display
 *
 * @param isoString - ISO 8601 date string
 * @param locale - Locale string (default: "ko-KR")
 * @returns Formatted date string
 */
export function formatDate(isoString: string, locale: string = "ko-KR"): string {
  const date = new Date(isoString);
  return date.toLocaleString(locale, {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
}
```

---

#### **2.3.2 retry.ts** (Exponential Backoff Retry Wrapper)

**File**: `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/utils/retry.ts`

```typescript
/**
 * Retry Utilities with Exponential Backoff
 *
 * Wraps async functions with automatic retry logic for transient failures.
 */

export interface RetryOptions {
  /**
   * Maximum number of retry attempts
   * @default 3
   */
  maxAttempts?: number;

  /**
   * Initial delay in milliseconds
   * @default 1000
   */
  initialDelay?: number;

  /**
   * Backoff multiplier
   * @default 2
   */
  backoffFactor?: number;

  /**
   * Maximum delay in milliseconds
   * @default 10000
   */
  maxDelay?: number;

  /**
   * Error codes that should trigger retry (Google API error codes)
   * @default [429, 500, 502, 503, 504]
   */
  retryableErrors?: number[];

  /**
   * Custom error checker
   */
  shouldRetry?: (error: any) => boolean;
}

const DEFAULT_OPTIONS: Required<RetryOptions> = {
  maxAttempts: 3,
  initialDelay: 1000,
  backoffFactor: 2,
  maxDelay: 10000,
  retryableErrors: [429, 500, 502, 503, 504],
  shouldRetry: () => true,
};

/**
 * Sleep utility
 */
const sleep = (ms: number): Promise<void> =>
  new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Check if error is retryable
 */
function isRetryableError(error: any, retryableErrors: number[]): boolean {
  // Google API errors
  if (error?.response?.status) {
    return retryableErrors.includes(error.response.status);
  }

  // Axios/Fetch errors
  if (error?.code === "ECONNRESET" || error?.code === "ETIMEDOUT") {
    return true;
  }

  return false;
}

/**
 * Wrap async function with retry logic
 *
 * @param fn - Async function to wrap
 * @param options - Retry configuration
 * @returns Promise with retry logic
 *
 * @example
 * const result = await withRetry(
 *   () => calendar.events.list({ calendarId: "primary" }),
 *   { maxAttempts: 5 }
 * );
 */
export async function withRetry<T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> {
  const opts = { ...DEFAULT_OPTIONS, ...options };
  let lastError: any;
  let delay = opts.initialDelay;

  for (let attempt = 1; attempt <= opts.maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error: any) {
      lastError = error;

      // Check if should retry
      const shouldRetryError =
        isRetryableError(error, opts.retryableErrors) &&
        opts.shouldRetry(error);

      if (!shouldRetryError || attempt === opts.maxAttempts) {
        throw error;
      }

      // Log retry attempt
      console.warn(
        `[Retry] Attempt ${attempt}/${opts.maxAttempts} failed. Retrying in ${delay}ms...`,
        error.message
      );

      // Wait before retry
      await sleep(delay);

      // Exponential backoff
      delay = Math.min(delay * opts.backoffFactor, opts.maxDelay);
    }
  }

  throw lastError;
}

/**
 * Retry decorator for class methods
 *
 * @example
 * class MyService {
 *   @retryable({ maxAttempts: 5 })
 *   async fetchData() { ... }
 * }
 */
export function retryable(options: RetryOptions = {}) {
  return function (
    target: any,
    propertyKey: string,
    descriptor: PropertyDescriptor
  ) {
    const originalMethod = descriptor.value;

    descriptor.value = async function (...args: any[]) {
      return withRetry(() => originalMethod.apply(this, args), options);
    };

    return descriptor;
  };
}
```

---

#### **2.3.3 sanitize.ts** (Input Sanitization)

**File**: `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/utils/sanitize.ts`

```typescript
/**
 * Input Sanitization Utilities
 *
 * Prevents injection attacks and ensures safe input for Google APIs.
 */

/**
 * Sanitize query string for Gmail/Drive search
 *
 * Escapes special characters to prevent query injection.
 *
 * @param query - Raw search query
 * @returns Sanitized query string
 *
 * @example
 * sanitizeQuery("from:user@example.com subject:test")
 * // Safe for use in gmail.users.messages.list({ q: ... })
 */
export function sanitizeQuery(query: string): string {
  // Remove potential injection characters
  return query
    .replace(/[\0\x08\x09\x1a\n\r"'\\\%]/g, (char) => {
      switch (char) {
        case "\0":
          return "\\0";
        case "\x08":
          return "\\b";
        case "\x09":
          return "\\t";
        case "\x1a":
          return "\\z";
        case "\n":
          return "\\n";
        case "\r":
          return "\\r";
        case '"':
        case "'":
        case "\\":
        case "%":
          return "\\" + char;
        default:
          return char;
      }
    })
    .substring(0, 500); // Limit length
}

/**
 * Sanitize email address
 *
 * Validates and normalizes email addresses.
 *
 * @param email - Raw email string
 * @returns Sanitized email or null if invalid
 */
export function sanitizeEmail(email: string): string | null {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  const trimmed = email.trim().toLowerCase();

  if (!emailRegex.test(trimmed)) {
    return null;
  }

  return trimmed;
}

/**
 * Sanitize email header (Subject, From, To)
 *
 * Removes newlines and control characters to prevent header injection.
 *
 * @param header - Raw header value
 * @returns Sanitized header string
 */
export function sanitizeEmailHeader(header: string): string {
  return header
    .replace(/[\r\n]/g, "") // Remove newlines
    .replace(/[\x00-\x1F\x7F]/g, "") // Remove control characters
    .trim()
    .substring(0, 1000); // Limit length
}

/**
 * Sanitize file name for Drive operations
 *
 * Removes or replaces invalid characters for file names.
 *
 * @param filename - Raw file name
 * @returns Sanitized file name
 */
export function sanitizeFilename(filename: string): string {
  return filename
    .replace(/[<>:"/\\|?*\x00-\x1F]/g, "_") // Replace invalid chars
    .replace(/\.+/g, ".") // Collapse multiple dots
    .replace(/^\./, "") // Remove leading dot
    .trim()
    .substring(0, 255); // Limit length
}

/**
 * Sanitize HTML content (for Docs/Slides)
 *
 * Removes dangerous HTML tags and attributes.
 *
 * @param html - Raw HTML string
 * @returns Sanitized HTML (plain text fallback)
 */
export function sanitizeHtml(html: string): string {
  // Simple implementation - in production use DOMPurify or similar
  return html
    .replace(/<script[^>]*>.*?<\/script>/gi, "")
    .replace(/<style[^>]*>.*?<\/style>/gi, "")
    .replace(/<iframe[^>]*>.*?<\/iframe>/gi, "")
    .replace(/on\w+\s*=/gi, "")
    .trim();
}

/**
 * Validate and sanitize spreadsheet range
 *
 * @param range - Range string (e.g., "Sheet1!A1:D10")
 * @returns Sanitized range or null if invalid
 */
export function sanitizeRange(range: string): string | null {
  // Basic validation for Google Sheets range notation
  const rangeRegex = /^([^!]+!)?[A-Z]+\d+:[A-Z]+\d+$|^([^!]+!)?[A-Z]+\d+$/i;

  if (!rangeRegex.test(range)) {
    return null;
  }

  return range.trim();
}

/**
 * Rate limit input size
 *
 * @param input - Input string
 * @param maxBytes - Maximum size in bytes
 * @returns Truncated input
 */
export function limitInputSize(input: string, maxBytes: number = 10000): string {
  const encoder = new TextEncoder();
  const bytes = encoder.encode(input);

  if (bytes.length <= maxBytes) {
    return input;
  }

  // Truncate safely (avoid cutting UTF-8 mid-character)
  let truncated = input;
  while (encoder.encode(truncated).length > maxBytes) {
    truncated = truncated.slice(0, -1);
  }

  return truncated + "... [truncated]";
}
```

---

#### **2.3.4 messages.ts** (Centralized Messages - i18n Ready)

**File**: `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/utils/messages.ts`

```typescript
/**
 * Centralized Message Strings
 *
 * Replaces hardcoded Korean strings with i18n-ready message system.
 *
 * Migration path:
 * 1. Phase 1: Replace Korean strings with English (this file)
 * 2. Phase 2: Add i18n library (e.g., i18next)
 * 3. Phase 3: Multi-language support
 */

export const messages = {
  // ==================== Common ====================
  common: {
    success: "Success",
    failed: "Failed",
    created: "Created successfully",
    updated: "Updated successfully",
    deleted: "Deleted successfully",
    notFound: "Not found",
    unauthorized: "Unauthorized access",
    invalidInput: "Invalid input",
  },

  // ==================== Calendar ====================
  calendar: {
    eventCreated: (title: string) => `Event "${title}" created successfully.`,
    eventUpdated: "Event updated successfully.",
    eventDeleted: "Event deleted successfully.",
    attendeesNotified: (emails: string[]) =>
      `Invitations sent to ${emails.join(", ")}.`,
    responseRecorded: (response: string) =>
      `Responded "${response}" to the event.`,
    allDayEventCreated: (title: string) =>
      `All-day event "${title}" created successfully.`,
    quickAddSuccess: (summary: string) => `Event created: ${summary}`,
  },

  // ==================== Gmail ====================
  gmail: {
    emailSent: (to: string) => `Email sent to ${to}.`,
    draftSaved: "Draft saved successfully.",
    draftDeleted: "Draft deleted successfully.",
    draftSent: "Draft sent successfully.",
    labelAdded: "Label added successfully.",
    labelRemoved: "Label removed successfully.",
    movedToTrash: "Email moved to trash.",
    restored: "Email restored from trash.",
    markedRead: "Marked as read.",
    markedUnread: "Marked as unread.",
    attachmentFetched: "Attachment data fetched (base64 encoded).",
  },

  // ==================== Drive ====================
  drive: {
    folderCreated: (name: string) => `Folder "${name}" created successfully.`,
    fileCopied: "File copied successfully.",
    fileMoved: "File moved successfully.",
    fileRenamed: (newName: string) => `File renamed to "${newName}".`,
    fileDeleted: "File moved to trash.",
    fileRestored: "File restored from trash.",
    sharedWithUser: (email: string, role: string) =>
      `Shared with ${email} as ${role}.`,
    linkShareEnabled: "Link sharing enabled.",
    unshared: (email: string) => `Sharing removed for ${email}.`,
    shareNotFound: (email: string) =>
      `No sharing settings found for ${email}.`,
  },

  // ==================== Docs ====================
  docs: {
    documentCreated: (title: string) =>
      `Document "${title}" created successfully.`,
    contentAppended: "Content appended to document.",
    contentPrepended: "Content prepended to document.",
    textReplaced: (count: number) => `${count} occurrences replaced.`,
    headingAdded: (level: number) => `Heading (H${level}) added.`,
    tableAdded: (rows: number, cols: number) =>
      `${rows}x${cols} table added.`,
    commentAdded: "Comment added successfully.",
  },

  // ==================== Sheets ====================
  sheets: {
    spreadsheetCreated: (title: string) =>
      `Spreadsheet "${title}" created successfully.`,
    cellsUpdated: (count: number) => `${count} cells updated.`,
    rowsAppended: (count: number) => `${count} rows appended.`,
    rangeCleared: (range: string) => `Data in ${range} cleared.`,
    sheetAdded: (title: string) => `Sheet "${title}" added successfully.`,
    sheetDeleted: "Sheet deleted successfully.",
    sheetRenamed: (newTitle: string) =>
      `Sheet renamed to "${newTitle}".`,
    cellsFormatted: "Cell formatting applied.",
    columnsResized: "Columns auto-resized.",
  },

  // ==================== Slides ====================
  slides: {
    presentationCreated: (title: string) =>
      `Presentation "${title}" created successfully.`,
    slideAdded: "New slide added successfully.",
    slideDeleted: "Slide deleted successfully.",
    slideDuplicated: "Slide duplicated successfully.",
    slideMoved: (index: number) =>
      `Slide moved to position ${index + 1}.`,
    textBoxAdded: "Text box added successfully.",
    textReplaced: (count: number) => `${count} occurrences replaced.`,
  },

  // ==================== Errors ====================
  errors: {
    authFailed: "Authentication failed. Please check credentials.",
    rateLimitExceeded: "Rate limit exceeded. Please try again later.",
    apiError: (message: string) => `API Error: ${message}`,
    networkError: "Network error. Please check your connection.",
    invalidRange: "Invalid range format.",
    invalidEmail: "Invalid email address.",
    invalidDate: "Invalid date format.",
    permissionDenied: "Permission denied.",
  },
};

/**
 * Helper function for parameterized messages
 *
 * @example
 * msg(messages.calendar.eventCreated, "Team Meeting")
 * // "Event "Team Meeting" created successfully."
 */
export function msg(
  template: string | ((...args: any[]) => string),
  ...args: any[]
): string {
  return typeof template === "function" ? template(...args) : template;
}
```

---

#### **2.3.5 google-client.ts** (Singleton Service Manager)

**File**: `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/services/google-client.ts`

```typescript
/**
 * Singleton Google Services Manager
 *
 * Problem: Currently, each handler calls `getGoogleServices()` which creates
 * 6 service instances (gmail, calendar, drive, docs, sheets, slides) on every
 * invocation. With 69 handlers, this creates 414 service objects per execution.
 *
 * Solution: Lazy-load and cache service instances as singletons.
 */

import { google } from "googleapis";
import { getAuthenticatedClient } from "../auth/oauth.js";

// Service instance cache
let cachedAuth: any = null;
let serviceInstances: {
  gmail?: any;
  calendar?: any;
  drive?: any;
  docs?: any;
  sheets?: any;
  slides?: any;
} = {};

/**
 * Get authenticated client (cached)
 */
async function getAuthClient() {
  if (!cachedAuth) {
    cachedAuth = await getAuthenticatedClient();
  }
  return cachedAuth;
}

/**
 * Get Google Services (singleton pattern)
 *
 * Only creates service instances once per process lifetime.
 *
 * @returns Object with all Google service instances
 */
export async function getGoogleServices() {
  const auth = await getAuthClient();

  // Lazy-load services only when needed
  if (!serviceInstances.gmail) {
    serviceInstances.gmail = google.gmail({ version: "v1", auth });
  }
  if (!serviceInstances.calendar) {
    serviceInstances.calendar = google.calendar({ version: "v3", auth });
  }
  if (!serviceInstances.drive) {
    serviceInstances.drive = google.drive({ version: "v3", auth });
  }
  if (!serviceInstances.docs) {
    serviceInstances.docs = google.docs({ version: "v1", auth });
  }
  if (!serviceInstances.sheets) {
    serviceInstances.sheets = google.sheets({ version: "v4", auth });
  }
  if (!serviceInstances.slides) {
    serviceInstances.slides = google.slides({ version: "v1", auth });
  }

  return serviceInstances as Required<typeof serviceInstances>;
}

/**
 * Clear cached services (for testing or auth refresh)
 */
export function clearServiceCache() {
  cachedAuth = null;
  serviceInstances = {};
}
```

---

### 2.4 Migration Example: calendar.ts

#### Before (lines 125-192):
```typescript
calendar_create_event: {
  handler: async ({ title, startTime, endTime, ... }) => {
    const { calendar } = await getGoogleServices(); // Creates 6 service instances

    const parseTime = (timeStr: string) => {  // Duplicated function
      if (timeStr.includes("T")) return timeStr;
      const [date, time] = timeStr.split(" ");
      return `${date}T${time}:00+09:00`;
    };

    // ... handler logic ...

    return {
      success: true,
      message: `Schedule "${title}" has been created.`, // English message
    };
  },
},
```

#### After:
```typescript
import { getGoogleServices } from "../services/google-client.js";
import { parseTime } from "../utils/time.js";
import { messages, msg } from "../utils/messages.js";
import { withRetry } from "../utils/retry.js";

calendar_create_event: {
  handler: async ({ title, startTime, endTime, ... }) => {
    const { calendar } = await getGoogleServices(); // Uses singleton

    const event = {
      summary: title,
      start: { dateTime: parseTime(startTime), timeZone: "Asia/Seoul" },
      end: { dateTime: parseTime(endTime), timeZone: "Asia/Seoul" },
      attendees: attendees?.map((email) => ({ email })),
    };

    const response = await withRetry(() =>
      calendar.events.insert({
        calendarId,
        requestBody: event,
        sendUpdates: sendNotifications ? "all" : "none",
      })
    );

    return {
      success: true,
      eventId: response.data.id,
      link: response.data.htmlLink,
      message: msg(messages.calendar.eventCreated, title),
      attendeesNotified: attendees && sendNotifications
        ? msg(messages.calendar.attendeesNotified, attendees)
        : null,
    };
  },
},
```

**Improvements**:
- No duplicate parseTime() function
- Singleton service instance (reduced memory)
- Automatic retry on transient failures
- English messages (i18n-ready)
- Cleaner, more maintainable code

---

## 3. Implementation Roadmap

### Phase 1: Installer Shared Utilities (Week 1)

**Tasks**:
1. Create `/installer/modules/shared/` directory
2. Implement shared utility files:
   - `colors.sh`
   - `docker-utils.sh`
   - `mcp-config.sh`
   - `browser-utils.sh`
   - `package-manager.sh`
3. Refactor base module first (test pattern)
4. Refactor remaining 6 modules
5. Update documentation

**Acceptance Criteria**:
- All modules source shared utilities
- No duplicate color definitions
- All modules use `docker_check()` consistently
- MCP config updates use `mcp_add_docker_server()`

**Files to Modify**:
- `installer/modules/base/install.sh`
- `installer/modules/google/install.sh`
- `installer/modules/atlassian/install.sh`
- `installer/modules/figma/install.sh`
- `installer/modules/notion/install.sh`
- `installer/modules/github/install.sh`
- `installer/modules/pencil/install.sh`

---

### Phase 2: Google MCP Shared Utilities (Week 2)

**Tasks**:
1. Create `/google-workspace-mcp/src/utils/` directory
2. Implement utility files:
   - `time.ts`
   - `retry.ts`
   - `sanitize.ts`
   - `messages.ts`
3. Create `services/google-client.ts` (singleton pattern)
4. Refactor calendar.ts first (test pattern)
5. Refactor remaining 5 tool files
6. Add unit tests for utilities

**Acceptance Criteria**:
- All tools use shared `getGoogleServices()`
- No duplicate `parseTime()` functions
- All Korean messages replaced with English
- Retry logic applied to API calls
- Input sanitization on user-provided strings

**Files to Modify**:
- `google-workspace-mcp/src/tools/calendar.ts`
- `google-workspace-mcp/src/tools/gmail.ts`
- `google-workspace-mcp/src/tools/drive.ts`
- `google-workspace-mcp/src/tools/docs.ts`
- `google-workspace-mcp/src/tools/sheets.ts`
- `google-workspace-mcp/src/tools/slides.ts`

---

### Phase 3: Testing & Documentation (Week 3)

**Tasks**:
1. End-to-end testing of all installer modules
2. Integration testing of Google MCP tools
3. Performance benchmarking (service instantiation reduction)
4. Update README files
5. Create migration guide for future modules

**Acceptance Criteria**:
- All tests pass (existing + new)
- Performance: Service instantiation reduced by 90%
- Documentation complete
- Zero regression bugs

---

## 4. Expected Outcomes

### Quantitative Improvements

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Installer LOC** | ~1,200 lines | ~850 lines | -29% |
| **Google MCP LOC** | ~1,800 lines | ~1,300 lines | -28% |
| **Service Instances** | 414 per execution | 6 per process | -99% |
| **Duplicate Functions** | 2 parseTime() copies | 1 shared util | -50% |
| **Hardcoded Messages** | 150 Korean strings | 0 (centralized) | -100% |

### Qualitative Improvements

1. **Maintainability**: Single source of truth for common logic
2. **Consistency**: Standardized error handling and retry logic
3. **i18n-Ready**: Easy to add multi-language support
4. **Performance**: Singleton services reduce memory overhead
5. **Security**: Centralized input sanitization
6. **Testing**: Utilities can be unit tested independently

---

## 5. Risk Analysis

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Breaking existing modules during refactor | Medium | High | Incremental refactor with testing after each module |
| Performance regression | Low | Medium | Benchmark before/after with realistic workloads |
| Compatibility issues with older shells | Low | Medium | Test on Mac, Linux, WSL environments |
| TypeScript compilation errors | Low | Low | Use strict type checking, incremental compilation |

---

## 6. Appendix

### A. Complete File Tree After Migration

```
popup-claude/
├── installer/
│   └── modules/
│       ├── shared/
│       │   ├── colors.sh               [NEW]
│       │   ├── docker-utils.sh         [NEW]
│       │   ├── mcp-config.sh           [NEW]
│       │   ├── browser-utils.sh        [NEW]
│       │   ├── package-manager.sh      [NEW]
│       │   └── oauth-helper.sh         [EXISTING]
│       ├── base/install.sh             [MODIFIED]
│       ├── google/install.sh           [MODIFIED]
│       ├── atlassian/install.sh        [MODIFIED]
│       ├── figma/install.sh            [MODIFIED]
│       ├── notion/install.sh           [MODIFIED]
│       ├── github/install.sh           [MODIFIED]
│       └── pencil/install.sh           [MODIFIED]
│
└── google-workspace-mcp/
    └── src/
        ├── utils/
        │   ├── time.ts                 [NEW]
        │   ├── retry.ts                [NEW]
        │   ├── sanitize.ts             [NEW]
        │   └── messages.ts             [NEW]
        ├── services/
        │   └── google-client.ts        [NEW]
        └── tools/
            ├── calendar.ts             [MODIFIED]
            ├── gmail.ts                [MODIFIED]
            ├── drive.ts                [MODIFIED]
            ├── docs.ts                 [MODIFIED]
            ├── sheets.ts               [MODIFIED]
            └── slides.ts               [MODIFIED]
```

### B. Related Documents

- [FR-S3-05: Code Deduplication](/docs/02-design/FR-S3-05-code-deduplication.md)
- [ADW Improvement Requirements](/docs/01-requirements/adw-improvement.md)
- [Installer Module Design](/docs/02-design/installer-architecture.md)

---

**Document Status**: ✅ Complete
**Approval Required**: Tech Lead, Backend Team Lead
**Next Steps**: Begin Phase 1 implementation after approval
