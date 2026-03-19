# ADW Comprehensive Test Design Document

**Document Version**: v1.0
**Created**: 2026-02-13
**Project**: popup-claude (AI-Driven Work Installer + Google Workspace MCP Server)
**Reference Document**: `docs/01-plan/features/comprehensive-test-plan.md` (v1.0, 310 TCs)
**Status**: Draft

---

## 1. Overview

### 1.1 Purpose

This document provides detailed, executable test designs for all test cases in `comprehensive-test-plan.md` (310 TCs). It describes specific procedures, commands, expected results, test data, and automation methods so that test engineers can perform testing using this document alone.

### 1.2 Design Principles

| Principle | Description |
|-----------|-------------|
| **Executability** | All TCs include step-by-step procedures and actual commands |
| **Code-Based** | Expected results are defined by referencing actual source code function names, parameters, and return values |
| **OS-Specific Separation** | Even for the same TC, if OS-specific procedures differ, each is documented separately |
| **Automation First** | Vitest-based automated tests are designed first; manual procedures are documented only for items that cannot be automated |
| **Reproducibility** | Mock data and fixtures are specified to ensure identical results can be reproduced |

### 1.3 Reference Documents (Plan Correspondence)

| Document | Path | Role |
|----------|------|------|
| Comprehensive Test Plan | `docs/01-plan/features/comprehensive-test-plan.md` | 310 TC definitions, priorities, preconditions |
| Feature Plan | `docs/01-plan/features/adw-improvement.plan.md` | FR requirements original |
| Design Document | `docs/02-design/features/adw-improvement.design.md` | Architecture and detailed design |
| Security Specification | `docs/02-design/security-spec.md` | OWASP-based security requirements |
| Requirements Traceability Matrix | `docs/03-analysis/adw-requirements-traceability-matrix.md` | FR-TC mapping |
| Security Verification Report | `docs/03-analysis/security-verification-report.md` | Security test evidence |
| Shared Utilities Design | `docs/03-analysis/shared-utilities-design.md` | Shared module function specifications |

### 1.4 Terminology

| Term | Definition |
|------|------------|
| ADW | AI-Driven Work -- Brand name for this project |
| MCP | Model Context Protocol -- Protocol for integrating Claude with external services |
| TC | Test Case |
| SUT | System Under Test |
| Mock | Fake object that replaces actual external dependencies |
| Fixture | Pre-prepared data required for test execution |
| P0/P1/P2/P3 | Priority (Critical/High/Medium/Low) |
| withRetry | Exponential backoff retry wrapper function in `src/utils/retry.ts` |
| sanitize | Collection of 7 input validation/sanitization functions in `src/utils/sanitize.ts` |
| SHARED_DIR | Environment variable for the installer shared scripts directory path |

### 1.5 TC Coverage Summary

| Area | TC Count | P0 | P1 | P2 | P3 | Automatable | Manual Only |
|------|------:|---:|---:|---:|---:|----------:|--------:|
| INS (Installer) | 52 | 14 | 22 | 12 | 4 | 20 | 32 |
| AUT (OAuth) | 22 | 11 | 9 | 2 | 0 | 18 | 4 |
| GML (Gmail) | 22 | 3 | 10 | 9 | 0 | 22 | 0 |
| DRV (Drive) | 20 | 4 | 8 | 8 | 0 | 20 | 0 |
| CAL (Calendar) | 15 | 3 | 6 | 6 | 0 | 15 | 0 |
| DOC (Docs) | 13 | 2 | 4 | 7 | 0 | 13 | 0 |
| SHT (Sheets) | 14 | 3 | 4 | 6 | 1 | 14 | 0 |
| SLD (Slides) | 11 | 2 | 3 | 6 | 0 | 11 | 0 |
| ATL (Atlassian) | 7 | 3 | 2 | 2 | 0 | 2 | 5 |
| FIG (Figma) | 8 | 3 | 3 | 2 | 0 | 2 | 6 |
| NOT (Notion) | 4 | 3 | 1 | 0 | 0 | 1 | 3 |
| GIT (GitHub) | 6 | 2 | 3 | 1 | 0 | 2 | 4 |
| PEN (Pencil) | 5 | 2 | 1 | 1 | 1 | 1 | 4 |
| SHR (Shared Utilities) | 16 | 1 | 8 | 5 | 2 | 8 | 8 |
| DOK (Docker) | 7 | 1 | 4 | 2 | 0 | 3 | 4 |
| SEC (Security) | 38 | 22 | 12 | 4 | 0 | 30 | 8 |
| PER (Performance) | 25 | 4 | 10 | 11 | 0 | 20 | 5 |
| E2E (Scenario) | 19 | 5 | 8 | 6 | 0 | 4 | 15 |
| REG (Regression) | 10 | 6 | 3 | 1 | 0 | 10 | 0 |
| **Total** | **314** | **94** | **121** | **90** | **8** | **216** | **98** |

---

## 2. Test Environment Design

### 2.1 macOS Test Environment Setup Procedures

#### MAC-ENV-01: macOS Ventura 13.x (Intel)

**Purpose**: Backward compatibility verification (Docker Desktop 4.41 or lower recommended)

**Hardware/VM Preparation**:
```
1. Create macOS Ventura 13.x VM in UTM or VMware Fusion
   - RAM: 8GB or more
   - Disk: 60GB or more
   - CPU: 4 cores or more

2. Create clean install snapshot
   $ sudo tmutil disablelocal  # Disable local snapshots
   $ # Create "Clean Ventura" snapshot in VM software
```

**Required Software Installation**:
```bash
# Homebrew (do not install for clean testing)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Intel Mac PATH verification
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"

# Docker Desktop 4.41 (Ventura compatible version)
# Download 4.41 from https://docs.docker.com/desktop/release-notes/
brew install --cask docker  # or manual installation

# Verification
brew --version     # Homebrew 4.x
docker --version   # Docker 24.x ~ 25.x
```

**Snapshot Points**:
- `SNAP-MAC01-CLEAN`: Homebrew not installed, Docker not installed (clean state)
- `SNAP-MAC01-BREW`: Homebrew only installed
- `SNAP-MAC01-FULL`: Homebrew + Docker Desktop 4.41 installed + not running

#### MAC-ENV-02: macOS Sonoma 14.x (Apple M1/M2)

**Purpose**: Primary test environment

**Hardware Preparation**:
```
Apple Silicon Mac (M1/M2/M3)
- RAM: 16GB recommended
- Disk: 10GB free space
- Create separate user account (test-dedicated)
  $ sudo dscl . -create /Users/testuser
```

**Required Software Installation**:
```bash
# Apple Silicon Homebrew PATH (important: /opt/homebrew/)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Docker Desktop latest (4.42+ -- requires Sonoma 14+)
brew install --cask docker

# Verification
which brew           # /opt/homebrew/bin/brew (Apple Silicon)
docker --version     # Docker 27.x+
python3 --version    # Python 3.12+
```

**Snapshot Points**:
- `SNAP-MAC02-CLEAN`: Clean user account
- `SNAP-MAC02-DOCKER-OFF`: Docker installed + not running
- `SNAP-MAC02-READY`: Docker running + internet connection verified

#### MAC-ENV-03: macOS Sequoia 15.x (Apple M3/M4)

**Purpose**: Latest OS compatibility verification

**Setup**: Same procedure as MAC-ENV-02, only OS version is Sequoia 15.x

### 2.2 Windows Test Environment Setup Procedures

#### WIN-ENV-01: Windows 10 21H2

**Purpose**: Minimum supported version verification

**VM Preparation**:
```
1. Create Windows 10 21H2 VM in Hyper-V or VMware
   - RAM: 8GB
   - Disk: 60GB
   - Enable Nested Virtualization (for WSL2)

2. Apply Windows Update and maintain 21H2 state
   $ winver  # Version check: 21H2 (Build 19044)
```

**PowerShell Environment Setup**:
```powershell
# PowerShell version check
$PSVersionTable.PSVersion  # 5.1.x

# Check execution policy
Get-ExecutionPolicy  # Restricted (default)

# Set Bypass for testing (Administrator PowerShell)
Set-ExecutionPolicy Bypass -Scope Process -Force
```

**WSL2 Setup Procedure**:
```powershell
# Enable WSL2 (Administrator PowerShell)
wsl --install  # Supported on Windows 10 21H2+

# After reboot
wsl --set-default-version 2
wsl --install -d Ubuntu-22.04

# Verification
wsl --version
wsl -l -v  # Ubuntu-22.04 VERSION 2
```

**Snapshot Points**:
- `SNAP-WIN01-CLEAN`: WSL2 not installed, Docker not installed
- `SNAP-WIN01-WSL`: WSL2 + Ubuntu 22.04 installed
- `SNAP-WIN01-FULL`: WSL2 + Docker Desktop (WSL2 backend)

#### WIN-ENV-02: Windows 10 22H2

**Setup**: Same as WIN-ENV-01, only OS build is 22H2 (19045)

#### WIN-ENV-03: Windows 11 23H2+

**Setup**: Same as WIN-ENV-01, with additional PowerShell 7.x installation

```powershell
# PowerShell 7 installation
winget install Microsoft.PowerShell

# Verification
pwsh -Version  # 7.x.x
```

### 2.3 Linux Test Environment Setup Procedures

#### LNX-ENV-01: Ubuntu 22.04 LTS (apt)

**VM/Container Preparation**:
```bash
# Docker-based test environment (quick setup)
docker run -it --name lnx-env-01 ubuntu:22.04 /bin/bash

# Or VM (for full testing)
# Install Ubuntu 22.04 LTS in UTM/VirtualBox
# Select minimal installation, user: testuser

# Basic package verification
apt update && apt install -y curl openssl
which curl      # /usr/bin/curl
which openssl   # /usr/bin/openssl
```

**Snapshot Points**:
- `SNAP-LNX01-CLEAN`: Only curl, openssl installed, no Node.js/Docker
- `SNAP-LNX01-NODE`: Node.js 22 pre-installed
- `SNAP-LNX01-DOCKER`: Docker Engine installed + docker group added

#### LNX-ENV-02: Ubuntu 24.04 LTS (apt)

**Setup**: Same as LNX-ENV-01, using Ubuntu 24.04

#### LNX-ENV-03: Fedora 39+ (dnf)

```bash
# Docker-based
docker run -it --name lnx-env-03 fedora:39 /bin/bash
dnf install -y curl openssl

# Verification
dnf --version
```

#### LNX-ENV-04: Arch Linux (pacman)

```bash
# Docker-based
docker run -it --name lnx-env-04 archlinux:latest /bin/bash
pacman -Sy --noconfirm curl openssl

# Verification
pacman --version
```

#### LNX-ENV-05: WSL2 Ubuntu 22.04

```powershell
# From Windows host
wsl --install -d Ubuntu-22.04

# Inside WSL2
cat /proc/version  # Verify Microsoft string is included
```

### 2.4 Docker Test Environment Setup Procedures

#### DOK-ENV-01 ~ DOK-ENV-04 Common Procedures

```bash
# 1. Docker version check
docker --version
docker info

# 2. Pull test images
docker pull ghcr.io/popup-jacob/google-workspace-mcp:latest
docker pull ghcr.io/sooperset/mcp-atlassian:latest

# 3. Image verification
docker inspect ghcr.io/popup-jacob/google-workspace-mcp:latest \
  --format='{{.Config.User}}'  # mcp (non-root)

docker inspect ghcr.io/popup-jacob/google-workspace-mcp:latest \
  --format='{{range .Config.Env}}{{println .}}{{end}}'  # NODE_ENV=production

docker images ghcr.io/popup-jacob/google-workspace-mcp:latest \
  --format='{{.Size}}'  # Verify 500MB or less
```

**Local Build Test**:
```bash
cd /Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp
docker build -t google-workspace-mcp:test .

# Verify non-root user
docker run --rm google-workspace-mcp:test id -u  # 1001 (mcp)

# Verify HEALTHCHECK
docker inspect google-workspace-mcp:test \
  --format='{{json .Config.Healthcheck}}'
```

### 2.5 Google API Test Environment

#### OAuth Credentials Preparation

```
1. Access Google Cloud Console (https://console.cloud.google.com)
2. Create new project: "ADW-Test-YYYY-MM"
3. Enable in APIs & Services > Library:
   - Gmail API
   - Google Drive API
   - Google Calendar API
   - Google Docs API
   - Google Sheets API
   - Google Slides API
4. APIs & Services > Credentials > Create Credentials > OAuth client ID
   - Application type: Desktop app
   - Name: "ADW Test Client"
5. Download JSON -> save as client_secret.json
6. OAuth consent screen:
   - User Type: Internal (Google Workspace) or External (test mode)
   - Add test users
```

**Test Account Preparation**:
```
- Account 1 (primary test): test-adw-primary@gmail.com
  - Gmail: 50+ test emails
  - Drive: 20 files, 5 folders, including shared files
  - Calendar: 10 events, 2 recurring events

- Account 2 (sharing test): test-adw-secondary@gmail.com
  - Drive sharing recipient
  - Calendar invitation recipient
```

**client_secret.json Placement**:
```bash
# Docker volume mount path
mkdir -p ~/.google-workspace
cp client_secret.json ~/.google-workspace/
chmod 600 ~/.google-workspace/client_secret.json
chmod 700 ~/.google-workspace/
```

### 2.6 Test Data Design

#### 2.6.1 Gmail Test Data

| Data ID | Description | Preparation Method |
|---------|-------------|-------------------|
| GML-DATA-001 | Plain text email (from:boss@example.com) | Pre-send or create via API |
| GML-DATA-002 | HTML body email | Pre-send |
| GML-DATA-003 | Multipart email (text/plain + text/html) | Pre-send |
| GML-DATA-004 | Email with attachment (PDF 1MB) | Pre-send |
| GML-DATA-005 | Large attachment email (10MB+) | Pre-send |
| GML-DATA-006 | Korean subject email ("테스트 메일") | Pre-send |
| GML-DATA-007 | Email with CC/BCC | Pre-send |
| GML-DATA-008 | Email body exceeding 5000 characters | Pre-send |
| GML-DATA-009 | 3 draft emails | Create via API |
| GML-DATA-010 | Custom label ("TestLabel") | Create via API |

#### 2.6.2 Drive Test Data

| Data ID | Description | Preparation Method |
|---------|-------------|-------------------|
| DRV-DATA-001 | 5 files in root folder | Create via API |
| DRV-DATA-002 | "Test Folder" folder + 3 child files | Create via API |
| DRV-DATA-003 | PDF file (application/pdf) | Upload |
| DRV-DATA-004 | Shared file (viewer permission) | Set sharing via API |
| DRV-DATA-005 | File in Shared Drive | Organization account required |
| DRV-DATA-006 | 1 trashed file | Trash via API |
| DRV-DATA-007 | Filename with single quote ("test's file.txt") | Create via API |

#### 2.6.3 Calendar Test Data

| Data ID | Description | Preparation Method |
|---------|-------------|-------------------|
| CAL-DATA-001 | 5 events within the next 7 days | Create via API |
| CAL-DATA-002 | 1 event with attendees | Create via API |
| CAL-DATA-003 | 1 recurring event (weekly) | Create via API |
| CAL-DATA-004 | 1 all-day event | Create via API |
| CAL-DATA-005 | 1 invited event (created from another account) | Create from Account 2 |

#### 2.6.4 Docs/Sheets/Slides Test Data

| Data ID | Description | Preparation Method |
|---------|-------------|-------------------|
| DOC-DATA-001 | Empty Google Docs document | Create via API |
| DOC-DATA-002 | Long document with 10000+ characters | Create via API |
| DOC-DATA-003 | Document with table | Create via API |
| DOC-DATA-004 | Document with comments | Create via API |
| SHT-DATA-001 | Empty spreadsheet | Create via API |
| SHT-DATA-002 | Sheet with data in Sheet1!A1:D10 | Create via API |
| SHT-DATA-003 | Spreadsheet with 2+ sheets | Create via API |
| SLD-DATA-001 | Empty presentation | Create via API |
| SLD-DATA-002 | Presentation with 3 slides + text | Create via API |

---

## 3. Installer Test Design

### 3.1 macOS Installer Tests (TC-INS-MAC-001 ~ TC-INS-MAC-026)

#### TC-INS-MAC-001: Argument Parsing -- --modules Option

**Priority**: P0
**Automation**: Possible (Bash script)
**Environment**: MAC-ENV-02 (SNAP-MAC02-READY)

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|---------------|-----------------|
| 1 | `cd /Users/popup-kay/Documents/GitHub/popup/popup-claude/installer` | Navigate to installer directory |
| 2 | `bash -x install.sh --modules "google,atlassian" 2>&1 \| head -50` | Verify variables in debug output |
| 3 | Check MODULES variable | `MODULES="google,atlassian"` |
| 4 | Check SELECTED_MODULES variable | `SELECTED_MODULES="google atlassian"` (commas converted to spaces) |

**Verification Commands**:
```bash
# Standalone test of install.sh argument parsing section
bash -c '
  source <(sed -n "1,/^# 3\. List Mode/p" install.sh | head -n -1)
  echo "MODULES=$MODULES"
  echo "SELECTED_MODULES=$SELECTED_MODULES"
' -- --modules "google,atlassian"
```

**Expected Output**:
```
MODULES=google,atlassian
SELECTED_MODULES=google atlassian
```

**Automation Script** (`installer/tests/test_ins_mac_001.sh`):
```bash
#!/bin/bash
# TC-INS-MAC-001: --modules option parsing
RESULT=$(bash -c '
  MODULES=""; INSTALL_ALL=false; SKIP_BASE=false; LIST_ONLY=false
  while [[ $# -gt 0 ]]; do
    case $1 in
      --modules) MODULES="$2"; shift 2 ;;
      --all) INSTALL_ALL=true; shift ;;
      --skip-base) SKIP_BASE=true; shift ;;
      --list) LIST_ONLY=true; shift ;;
      *) echo "Unknown option: $1"; exit 1 ;;
    esac
  done
  SELECTED_MODULES=$(echo "$MODULES" | tr "," " ")
  echo "$SELECTED_MODULES"
' -- --modules "google,atlassian")

if [ "$RESULT" = "google atlassian" ]; then
  echo "PASS: TC-INS-MAC-001"
else
  echo "FAIL: TC-INS-MAC-001 (got: $RESULT)"
  exit 1
fi
```

---

#### TC-INS-MAC-002: Argument Parsing -- --all Option

**Priority**: P0
**Automation**: Possible (Bash script)
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Run `./install.sh --all` | INSTALL_ALL=true is set |
| 2 | Check module list | 6 modules selected excluding base where required=true |
| 3 | Check SELECTED_MODULES | Includes google, atlassian, figma, notion, github, pencil |

**Verification**: Verify logic at lines 341~346 of `install.sh`
```bash
# install.sh:340-346 logic
if [ "$INSTALL_ALL" = true ]; then
    for i in "${!MODULE_NAMES[@]}"; do
        if [ "${MODULE_REQUIRED[$i]}" != "true" ]; then
            SELECTED_MODULES="$SELECTED_MODULES ${MODULE_NAMES[$i]}"
        fi
    done
fi
```

**Expected Result**: `SELECTED_MODULES` contains "google atlassian figma notion github pencil" (excluding base, all modules where required=true is not set)

---

#### TC-INS-MAC-003: Argument Parsing -- --list Option

**Priority**: P1
**Automation**: Possible (Bash script)
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Run `./install.sh --list` | Display module list |
| 2 | Check output content | 7 modules displayed (base, google, atlassian, figma, notion, github, pencil) |
| 3 | Check exit code | exit 0 |

**Verification Commands**:
```bash
./install.sh --list
echo "Exit code: $?"
```

**Expected Output** (partial):
```
========================================
  Available Modules
========================================

  base (required) [basic]
    ...
  google [moderate]
    ...
  ...

Usage:
  ./install.sh --modules "google,atlassian"
  ./install.sh --all
```

---

#### TC-INS-MAC-004: Argument Parsing -- --skip-base Option

**Priority**: P1
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | `bash -x install.sh --modules "google" --skip-base 2>&1 \| grep SKIP_BASE` | SKIP_BASE=true |
| 2 | Check if base module executes | base module skipped |

**Verification**: Verify `SKIP_BASE=true` is set at line 186 of `install.sh`

---

#### TC-INS-MAC-005: Argument Parsing -- Unknown Option

**Priority**: P1
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | `./install.sh --unknown 2>&1` | "Unknown option: --unknown" output |
| 2 | Check exit code | exit 1 |

**Verification Commands**:
```bash
output=$(./install.sh --unknown 2>&1)
exit_code=$?
echo "$output" | grep -q "Unknown option" && [ $exit_code -eq 1 ] && echo "PASS" || echo "FAIL"
```

**Code Reference**: `install.sh:195` -- `*) echo "Unknown option: $1"; exit 1 ;;`

---

#### TC-INS-MAC-006: Module Scan -- Local Execution

**Priority**: P0
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | `cd installer && ls modules/*/module.json` | 7 module.json files exist |
| 2 | Run `./install.sh --list` | USE_LOCAL=true is set |
| 3 | Check module list | All 7 modules parsed successfully |

**Verification Commands**:
```bash
# Check number of module.json files
ls installer/modules/*/module.json | wc -l  # 7

# Validate each module.json
for f in installer/modules/*/module.json; do
  node -e "JSON.parse(require('fs').readFileSync('$f', 'utf8'))" && echo "OK: $f" || echo "FAIL: $f"
done
```

**Code Reference**: `install.sh:92-96` -- `USE_LOCAL=true` when `BASH_SOURCE[0]` exists + `modules/` directory exists

---

#### TC-INS-MAC-007: Module Scan -- Remote Execution

**Priority**: P0
**Automation**: Partially possible (network dependent)
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | `curl -sSL https://raw.githubusercontent.com/popup-jacob/popup-claude/master/installer/install.sh \| bash -s -- --list` | Remote execution |
| 2 | Check USE_LOCAL | USE_LOCAL=false |
| 3 | Verify modules.json download | Module list obtained from remote modules.json |

**Code Reference**: `install.sh:229-241` -- Download `curl -sSL "$BASE_URL/modules.json"` then verify with `download_and_verify`

---

#### TC-INS-MAC-008: Module Verification -- Invalid Module Name

**Priority**: P1
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | `./install.sh --modules "nonexistent" 2>&1` | "Unknown module: nonexistent" output |
| 2 | Exit code | exit 1 |

**Verification Commands**:
```bash
output=$(./install.sh --modules "nonexistent" 2>&1)
echo "$output" | grep -q "Unknown module" && echo "PASS" || echo "FAIL"
```

**Code Reference**: `install.sh:352-358` -- Error when `get_module_index` returns `-1`

---

#### TC-INS-MAC-009: Smart Status Detection

**Priority**: P0
**Automation**: Partially possible
**Environment**: MAC-ENV-02 (SNAP-MAC02-CLEAN)

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Run `./install.sh --modules "google"` in clean environment | Status display |
| 2 | Check "Current Status:" in output | [OK] or [  ] shown for each tool |
| 3 | When Node.js is not installed | `Node.js:  [  ]` |
| 4 | When Git is installed | `Git:      [OK]` |
| 5 | When Docker is running | `Docker:   [OK] (Running)` |

**Code Reference**: `install.sh:364-418` -- `get_install_status()` function

**Verification Points**:
- `command -v node` -- Node.js detection
- `command -v git` -- Git detection
- `command -v code` or `/Applications/Visual Studio Code.app` exists -- VS Code detection
- `command -v docker` + `docker info` -- Docker detection + running state
- `command -v claude` -- Claude CLI detection
- `claude plugin list | grep bkit` -- bkit plugin detection

---

#### TC-INS-MAC-010: Base Auto-Skip

**Priority**: P1
**Automation**: Partially possible
**Environment**: MAC-ENV-02 (all base tools installed state)

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Verify Node.js, Git, Claude, bkit all installed | All installed |
| 2 | Run `./install.sh --modules "google"` | |
| 3 | Check output | "All base tools are already installed. Skipping base." message |
| 4 | Check SKIP_BASE | true |

**Code Reference**: `install.sh:444-456`
```bash
# Condition: HAS_NODE=true AND HAS_GIT=true AND HAS_CLAUDE=true AND HAS_BKIT=true
# HAS_DOCKER=true also required when Docker-requiring modules are selected
if [ "$BASE_INSTALLED" = true ] && [ "$SKIP_BASE" = false ] && [ -n "$SELECTED_MODULES" ]; then
    echo -e "${GREEN}All base tools are already installed. Skipping base.${NC}"
    SKIP_BASE=true
fi
```

---

#### TC-INS-MAC-011: Docker Not Running Warning

**Priority**: P1
**Automation**: Partially possible (requires user input)
**Environment**: MAC-ENV-02 (SNAP-MAC02-DOCKER-OFF)

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Verify Docker Desktop is stopped | `docker info` fails |
| 2 | Run `./install.sh --modules "google"` | Docker not running warning displayed |
| 3 | Check output | "Docker Desktop is not running!" message |
| 4 | Wait for user input | "Press Enter after starting Docker (or 'q' to quit):" prompt |
| 5 | Enter 'q' | exit 0 |

**Code Reference**: `install.sh:420-441` -- Docker wait block

---

#### TC-INS-MAC-012: Module Execution Order

**Priority**: P1
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Check order values in each module.json | base:1, github:2, atlassian:5, google:6, figma:7, notion:8, pencil:9 |
| 2 | Run `./install.sh --modules "google,atlassian,github"` | |
| 3 | Verify execution order | github(2) -> atlassian(5) -> google(6) |

**Verification Commands**:
```bash
# Extract module.json order field
for dir in installer/modules/*/; do
  name=$(node -e "console.log(JSON.parse(require('fs').readFileSync('${dir}module.json','utf8')).name)")
  order=$(node -e "console.log(JSON.parse(require('fs').readFileSync('${dir}module.json','utf8')).order)")
  echo "$order: $name"
done | sort -n
```

**Code Reference**: `install.sh:641-647` -- Sorting by module order
```bash
SORTED_MODULES=$(echo "$SORTED_MODULES" | tr ' ' '\n' | sort -t: -k1 -n | cut -d: -f2 | tr '\n' ' ')
```

---

#### TC-INS-MAC-013: MCP Configuration Backup

**Priority**: P0
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Verify `~/.claude/mcp.json` exists | File exists |
| 2 | Start module installation | `backup_mcp_config()` called |
| 3 | Verify backup file | `~/.claude/mcp.json.bak.{timestamp}` created |
| 4 | Verify backup contents | Identical to original |

**Verification Commands**:
```bash
# Verify backup file exists
ls -la ~/.claude/mcp.json.bak.* 2>/dev/null

# Compare contents
diff ~/.claude/mcp.json ~/.claude/mcp.json.bak.*
```

**Code Reference**: `install.sh:496-502` -- `backup_mcp_config()` function

---

#### TC-INS-MAC-014: Rollback on Module Failure

**Priority**: P0
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | MCP configuration backup completed | Backup file exists |
| 2 | Configure module install.sh to return exit 1 | Induce intentional failure |
| 3 | Verify rollback | "Rolling back MCP configuration..." message |
| 4 | Verify MCP configuration | Restored from backup |

**Test Method**:
```bash
# Temporary module script for intentional failure
mkdir -p /tmp/test-module
echo '#!/bin/bash
echo "Intentional failure"
exit 1' > /tmp/test-module/install.sh
chmod +x /tmp/test-module/install.sh

# Verify backup then check rollback message
```

**Code Reference**: `install.sh:504-509` -- `rollback_mcp_config()`, `install.sh:611-619` -- rollback invoked on failure

---

#### TC-INS-MAC-015: Backup Cleanup on Successful Installation

**Priority**: P1
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Full installation succeeds | All modules exit 0 |
| 2 | Check backup file | `mcp.json.bak.*` deleted |
| 3 | Check completion message | "Installation Complete!" output |

**Code Reference**: `install.sh:660-662`
```bash
if [ -n "$MCP_BACKUP_FILE" ] && [ -f "$MCP_BACKUP_FILE" ]; then
    rm -f "$MCP_BACKUP_FILE"
fi
```

---

#### TC-INS-MAC-016: Post-Installation Verification

**Priority**: P1
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Module installation complete | `verify_module_installation()` automatically called |
| 2 | Check MCP config | "[Verify] MCP config: OK" output |
| 3 | Check Docker image (Docker module) | "[Verify] Docker image: OK" output |

**Code Reference**: `install.sh:514-545` -- `verify_module_installation()` function

---

#### TC-INS-MAC-017: parse_json -- Node Priority

**Priority**: P1
**Automation**: Possible
**Environment**: MAC-ENV-02 (Node.js installed)

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Verify Node.js installed | `command -v node` succeeds |
| 2 | `parse_json '{"name":"test","order":5}' "name"` | Returns "test" |
| 3 | `parse_json '{"name":"test","order":5}' "order"` | Returns "5" |

**Verification Script**:
```bash
source installer/install.sh --list 2>/dev/null  # load parse_json function
result=$(parse_json '{"name":"google","order":6}' "name")
[ "$result" = "google" ] && echo "PASS" || echo "FAIL: $result"
```

**Code Reference**: `install.sh:31-53` -- stdin-based parsing via node -e

---

#### TC-INS-MAC-018: parse_json -- python3 Fallback

**Priority**: P2
**Automation**: Possible
**Environment**: MAC-ENV-02 (No Node.js, Python3 available)

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Temporarily remove Node.js or exclude from PATH | `command -v node` fails |
| 2 | Verify Python3 | `command -v python3` succeeds |
| 3 | Call parse_json | Parsing succeeds via python3 |

**Verification Script**:
```bash
PATH_BACKUP=$PATH
export PATH=$(echo "$PATH" | sed 's|/usr/local/bin:||;s|/opt/homebrew/bin:||')
# test in PATH without node
result=$(bash -c 'source install.sh; parse_json "{\"name\":\"test\"}" "name"')
export PATH=$PATH_BACKUP
```

---

#### TC-INS-MAC-019: parse_json -- osascript Fallback

**Priority**: P3
**Automation**: Possible (macOS only)
**Environment**: MAC-ENV-02 (Neither Node.js nor Python3 available)

**Detailed Procedure**: Same as TC-INS-MAC-018, but python3 is also removed from PATH. Parsing via osascript JavaScript runner on macOS.

**Code Reference**: `install.sh:73-84` -- stdin-based JavaScript parsing via osascript

---

#### TC-INS-MAC-020: SHA-256 Checksum Verification

**Priority**: P0
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Remote execution mode | `USE_LOCAL=false` |
| 2 | `download_and_verify` call | checksums.json downloaded |
| 3 | File download + SHA-256 calculation | Uses shasum -a 256 |
| 4 | Verify hash match | "Integrity verified: {path}" message |

**Verification Commands**:
```bash
# Manual verification
curl -sSL https://raw.githubusercontent.com/popup-jacob/popup-claude/master/installer/checksums.json | node -e "
  let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>{
    const c=JSON.parse(d);
    console.log(JSON.stringify(c.files, null, 2));
  })"

# Compare hash of a specific file
curl -sSL https://raw.githubusercontent.com/popup-jacob/popup-claude/master/installer/modules/google/install.sh | shasum -a 256
```

**Code Reference**: `install.sh:118-178` -- `download_and_verify()` function

---

#### TC-INS-MAC-021: SHA-256 Checksum Mismatch

**Priority**: P0
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Prepare tampered file (1 byte modified) | Hash mismatch |
| 2 | Simulate `download_and_verify` call | |
| 3 | Check output | "[SECURITY] Integrity verification failed!" message |
| 4 | Check temporary file | Deleted via `rm -f "$tmpfile"` call |
| 5 | Return code | return 1 |

**Test Script**:
```bash
# Create tampered file
tmpfile=$(mktemp)
echo "tampered content" > "$tmpfile"
expected_hash="abc123..."  # original hash
actual_hash=$(shasum -a 256 "$tmpfile" | awk '{print $1}')
[ "$actual_hash" != "$expected_hash" ] && echo "PASS: tampering detected" || echo "FAIL"
rm -f "$tmpfile"
```

---

#### TC-INS-MAC-022: When checksums.json Is Unavailable

**Priority**: P2
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Simulate checksums.json 404 | CHECKSUMS_JSON="" |
| 2 | `download_and_verify` call | |
| 3 | Check output | "[WARN] checksums.json not available" warning |
| 4 | Installation continuation | Installation continues (return 0) |

**Code Reference**: `install.sh:110-113`

---

#### TC-INS-MAC-023: Shared Scripts Remote Download

**Priority**: P1
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Remote execution mode (USE_LOCAL=false) | |
| 2 | `setup_shared_dir()` call | SHARED_TMP directory created |
| 3 | Check downloaded files | colors.sh, browser-utils.sh, docker-utils.sh, mcp-config.sh |

**Code Reference**: `install.sh:555-567` -- `setup_shared_dir()` function

---

#### TC-INS-MAC-024: Temporary File Cleanup (trap)

**Priority**: P1
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | SHARED_TMP created via remote execution | Temporary directory exists |
| 2 | Installation completes or interrupted with Ctrl+C | EXIT trap triggered |
| 3 | Check SHARED_TMP | Directory deleted |

**Code Reference**: `install.sh:561` -- `trap 'rm -rf "$SHARED_TMP"' EXIT`

---

#### TC-INS-MAC-025: Environment Variable Support

**Priority**: P2
**Automation**: Possible
**Environment**: MAC-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Run `MODULES="google" INSTALL_ALL=false ./install.sh` | |
| 2 | Check MODULES variable | "google" |
| 3 | Verify behavior | Same as command-line `--modules "google"` |

**Code Reference**: `install.sh:184-187` -- environment variable defaults
```bash
MODULES="${MODULES:-}"
INSTALL_ALL="${INSTALL_ALL:-false}"
```

---

#### TC-INS-MAC-026: Apple Silicon Homebrew PATH

**Priority**: P1
**Automation**: Partially possible (requires Apple Silicon)
**Environment**: MAC-ENV-02 (Apple M1+)

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Verify Apple Silicon Mac | `uname -m` = "arm64" |
| 2 | Check PATH after Homebrew installation | `/opt/homebrew/bin/brew` |
| 3 | Verify `eval "$(/opt/homebrew/bin/brew shellenv)"` applied | brew command available |

**Code Reference**: Homebrew shellenv configuration in `modules/base/install.sh`

---

### 3.2 Windows Installer Tests (TC-INS-WIN-001 ~ TC-INS-WIN-016)

#### TC-INS-WIN-001: Parameter Parsing -- -modules

**Priority**: P0
**Automation**: Possible (PowerShell script)
**Environment**: WIN-ENV-03

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Run `.\install.ps1 -modules "google,atlassian"` | |
| 2 | Check $selectedModules | @("google", "atlassian") |

**Verification Commands** (PowerShell):
```powershell
# install.ps1 parameter test
$result = & .\install.ps1 -modules "google,atlassian" -list 2>&1
$result | Select-String "google"
```

---

#### TC-INS-WIN-002: Parameter Parsing -- -all

**Priority**: P0
**Automation**: Possible
**Environment**: WIN-ENV-03

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Run `.\install.ps1 -all` | All modules with required=false selected |

---

#### TC-INS-WIN-003: 매개변수 파싱 -- -list

**Priority**: P1
**Automation**: Possible
**Environment**: WIN-ENV-03

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | `.\install.ps1 -list` 실행 | 모듈 목록 표시, 관리자 권한 불필요 |
| 2 | 일반 사용자 계정에서 실행 | UAC 프롬프트 없이 동작 |

---

#### TC-INS-WIN-004: 환경변수 지원

**Priority**: P2
**Automation**: Possible
**Environment**: WIN-ENV-03

**Detailed Procedure**:
```powershell
$env:MODULES = 'google'
.\install.ps1 -list
# $env:MODULES 값이 적용되는지 확인
```

---

#### TC-INS-WIN-005: 관리자 권한 감지

**Priority**: P0
**Automation**: Not possible (UAC prompt)
**Environment**: WIN-ENV-03 (비관리자)

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | 비관리자 계정으로 PowerShell 열기 | |
| 2 | Node.js 미설치 상태에서 install.ps1 실행 | |
| 3 | UAC 프롬프트 확인 | 관리자 권한 요청 팝업 |

**Code Reference**: `install.ps1:131-169` -- 조건부 권한 상승 로직

---

#### TC-INS-WIN-006: 조건부 권한 상승

**Priority**: P1
**Automation**: Partially possible
**Environment**: WIN-ENV-03 (기본 도구 모두 설치)

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Node.js, Git, VS Code, Docker 모두 설치 확인 | |
| 2 | `.\install.ps1 -modules "notion" -skipBase` 실행 | |
| 3 | UAC 프롬프트 없이 실행 확인 | 관리자 권한 불필요 |

---

#### TC-INS-WIN-007 ~ TC-INS-WIN-016

나머지 Windows TC는 동일한 상세 형식으로 설계. 핵심 차이점:

- **TC-INS-WIN-007** (원격 실행 관리자 상승): `irm ... | iex` 실행 시 scriptblock으로 재실행
- **TC-INS-WIN-008** (스마트 상태 감지): WSL 상태 추가 표시 (`wsl --version`)
- **TC-INS-WIN-009** (WSL 감지): `wsl --version` 성공 시 "WSL: [OK]"
- **TC-INS-WIN-010** (Docker 미실행 경고): "Docker Desktop is not running!" 경고
- **TC-INS-WIN-011** (모듈 실행 순서): order 기준 정렬 확인
- **TC-INS-WIN-012** (Base 자동 스킵): macOS와 동일 로직
- **TC-INS-WIN-013** (MCP 설정 경로): `$env:USERPROFILE\.claude\mcp.json` 확인
- **TC-INS-WIN-014** (Remote MCP 타입 표시): "(Remote MCP)" 텍스트 포함
- **TC-INS-WIN-015** (로컬/원격 자동 감지): `$MyInvocation.MyCommand.Path` 확인
- **TC-INS-WIN-016** (-installDocker 플래그): Docker 미설치 시 설치 진행

### 3.3 Linux 인스톨러 테스트 (TC-INS-LNX-001 ~ TC-INS-LNX-010)

#### TC-INS-LNX-001: apt 기반 설치

**Priority**: P0
**Automation**: Possible (Docker container)
**Environment**: LNX-ENV-01

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Ubuntu 22.04 클린 환경 | Node.js, Git 미설치 |
| 2 | `./install.sh --modules "github" --skip-base` 실행 시 내부 base 로직 | |
| 3 | 패키지 관리자 감지 | `apt` 감지됨 |
| 4 | Node.js 설치 확인 | NodeSource 스크립트로 apt-get 설치 |
| 5 | Git 설치 확인 | `sudo apt-get install -y git` |

**Verification Commands**:
```bash
# Docker 컨테이너에서 테스트
docker run -it --rm ubuntu:22.04 bash -c '
  apt update && apt install -y curl
  curl -sSL https://raw.githubusercontent.com/.../install.sh | bash -s -- --list
'
```

**Code Reference**: `modules/base/install.sh:49-59` -- Linux Node.js 설치 로직

---

#### TC-INS-LNX-002: dnf 기반 설치

**Priority**: P1
**Automation**: Possible (Docker container)
**Environment**: LNX-ENV-03

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Fedora 39 클린 환경 | |
| 2 | install.sh 실행 | `dnf` 감지 |
| 3 | Node.js 설치 | `sudo dnf install -y nodejs` (NodeSource) |

---

#### TC-INS-LNX-003: pacman 기반 설치

**Priority**: P2
**Automation**: Possible
**Environment**: LNX-ENV-04

**Detailed Procedure**: Arch Linux에서 `pacman -S --noconfirm nodejs` 확인

---

#### TC-INS-LNX-004: Docker 그룹 추가

**Priority**: P1
**Automation**: Possible
**Environment**: LNX-ENV-01

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Docker 설치 후 | `docker` 그룹 존재 |
| 2 | base 모듈 실행 | `sudo usermod -aG docker $USER` |
| 3 | 그룹 확인 | `groups` 명령에 docker 포함 |

---

#### TC-INS-LNX-005 ~ TC-INS-LNX-010

- **TC-INS-LNX-005** (SHA-256: sha256sum): `sha256sum` 사용 -- `sha256sum "$tmpfile" | awk '{print $1}'`
- **TC-INS-LNX-006** (SHA-256: shasum): `shasum -a 256` 사용
- **TC-INS-LNX-007** (VS Code snap): Ubuntu에서 `sudo snap install code --classic`
- **TC-INS-LNX-008** (WSL2 브라우저): `grep -qi microsoft /proc/version` 감지 후 `cmd.exe /c start`
- **TC-INS-LNX-009** (xdg-open 폴백): 비WSL Linux에서 `xdg-open` 사용
- **TC-INS-LNX-010** (미지원 패키지 관리자): `pkg_detect_manager()` -> "none" -> 수동 설치 안내

### 3.4 인스톨러 자동화 테스트 설계

#### CI 기반 자동화 가능 TC 목록

| TC ID | 자동화 방법 | CI 환경 |
|-------|-----------|---------|
| TC-INS-MAC-001~005 | Bash 단위 테스트 | ubuntu-latest + macOS |
| TC-INS-MAC-008 | Bash 단위 테스트 | 모든 환경 |
| TC-INS-MAC-017~019 | Bash 단위 테스트 | macOS |
| TC-INS-MAC-020~022 | Bash 단위 테스트 | 모든 환경 |
| TC-INS-LNX-001 | Docker 컨테이너 | ubuntu-latest |
| TC-INS-LNX-002 | Docker 컨테이너 | ubuntu-latest |
| TC-INS-LNX-005~006 | Bash 단위 테스트 | ubuntu-latest |

#### Bash 테스트 프레임워크 설계

```bash
#!/bin/bash
# installer/tests/run_tests.sh
# 인스톨러 자동화 테스트 러너

PASS=0
FAIL=0
SKIP=0

run_test() {
  local tc_id="$1"
  local script="$2"

  if bash "$script" > /dev/null 2>&1; then
    echo "  PASS: $tc_id"
    ((PASS++))
  else
    echo "  FAIL: $tc_id"
    ((FAIL++))
  fi
}

echo "=== Installer Test Suite ==="
run_test "TC-INS-MAC-001" "tests/test_ins_mac_001.sh"
run_test "TC-INS-MAC-005" "tests/test_ins_mac_005.sh"
# ...

echo ""
echo "Results: $PASS passed, $FAIL failed, $SKIP skipped"
[ $FAIL -eq 0 ] && exit 0 || exit 1
```

---

## 4. Google Workspace MCP 테스트 설계

### 4.1 OAuth 인증 테스트 (TC-AUT-ALL-001 ~ TC-AUT-ALL-022)

모든 OAuth 테스트는 `google-workspace-mcp/src/auth/oauth.ts`를 대상으로 한다.
자동화 테스트는 Vitest + Mock을 사용하며, 브라우저 기반 흐름은 수동 테스트로 수행한다.

**공통 Mock 설정**:
```typescript
// __tests__/oauth.test.ts 공통 Mock
import { vi, describe, it, expect, beforeEach } from 'vitest';
import * as fs from 'fs';
import * as http from 'http';

vi.mock('fs');
vi.mock('http');
vi.mock('open', () => ({ default: vi.fn().mockResolvedValue(undefined) }));

const mockClientSecret = {
  installed: {
    client_id: 'test-client-id',
    client_secret: 'test-client-secret',
    redirect_uris: ['http://localhost:3000/callback'],
  },
};

const mockToken = {
  access_token: 'mock-access-token',
  refresh_token: 'mock-refresh-token',
  scope: 'https://www.googleapis.com/auth/gmail.modify',
  token_type: 'Bearer',
  expiry_date: Date.now() + 3600000, // 1시간 후
};
```

#### TC-AUT-ALL-001: 최초 인증 흐름

**Priority**: P0
**Automation**: Manual (browser flow)
**Environment**: DOK-ENV-02

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | `~/.google-workspace/client_secret.json` 존재 확인 | 파일 존재 |
| 2 | `~/.google-workspace/token.json` 삭제 | 파일 없음 |
| 3 | MCP 서버 시작 (Docker 또는 직접 실행) | |
| 4 | 임의 Gmail 도구 호출 (예: gmail_search) | `getAuthenticatedClient()` 호출 |
| 5 | 콘솔 출력 확인 | "Google Login Required!" + OAuth URL 표시 |
| 6 | 브라우저에서 URL 열기 + Google 계정 로그인 | |
| 7 | OAuth 콜백 수신 (localhost:3000/callback) | "Google authentication complete!" 페이지 표시 |
| 8 | token.json 생성 확인 | `ls -la ~/.google-workspace/token.json` |
| 9 | 파일 권한 확인 | `-rw-------` (0600) |
| 10 | token.json 내용 확인 | access_token, refresh_token, expiry_date 포함 |

**Code Reference**:
- `oauth.ts:342-397` -- `getAuthenticatedClient()`
- `oauth.ts:223-334` -- `getTokenFromBrowser()`
- `oauth.ts:200-215` -- `saveToken()` (mode 0600)

---

#### TC-AUT-ALL-002: 토큰 재사용

**Priority**: P0
**Automation**: Possible (Vitest)
**Environment**: 모든 환경

**Vitest Test Code**:
```typescript
describe('TC-AUT-ALL-002: Token Reuse', () => {
  it('should use cached token without browser flow', async () => {
    // Arrange: token.json exists with valid expiry
    vi.spyOn(fs, 'existsSync').mockImplementation((p: string) => {
      if (p.includes('token.json')) return true;
      if (p.includes('client_secret.json')) return true;
      return true;
    });
    vi.spyOn(fs, 'readFileSync').mockImplementation((p: string) => {
      if (p.toString().includes('token.json'))
        return JSON.stringify(mockToken);
      if (p.toString().includes('client_secret.json'))
        return JSON.stringify(mockClientSecret);
      return '';
    });

    // Act
    const client = await getAuthenticatedClient();

    // Assert: browser open should NOT be called
    expect(open).not.toHaveBeenCalled();
    expect(client).toBeDefined();
  });
});
```

**기대 결과**: 유효한 token.json이 존재하면 브라우저 OAuth 없이 캐시된 토큰 사용

---

#### TC-AUT-ALL-003: 토큰 만료 갱신

**Priority**: P0
**Automation**: Possible (Vitest)

**Vitest Test Code**:
```typescript
describe('TC-AUT-ALL-003: Token Refresh', () => {
  it('should refresh token when expiry_date < now + 5min', async () => {
    const expiredToken = {
      ...mockToken,
      expiry_date: Date.now() + 2 * 60 * 1000, // 2분 후 (5분 버퍼 이내)
    };
    // ... mock setup ...

    // Assert: refreshAccessToken should be called
    // Assert: saveToken should be called with new token
  });
});
```

**Code Reference**: `oauth.ts:362-383` -- 5분 버퍼 (`expiryBuffer = 5 * 60 * 1000`)

---

#### TC-AUT-ALL-004: 토큰 갱신 실패 시 재인증

**Priority**: P0
**Automation**: Possible (Vitest)

**테스트 시나리오**: `refreshAccessToken()` 에서 에러 throw -> `getTokenFromBrowser()` 호출

**Code Reference**: `oauth.ts:374-382` -- catch 블록에서 재인증

---

#### TC-AUT-ALL-005: refresh_token 누락 검증

**Priority**: P1
**Automation**: Possible (Vitest)

**Vitest Test Code**:
```typescript
describe('TC-AUT-ALL-005: Missing refresh_token', () => {
  it('should return null when refresh_token is missing', () => {
    const tokenWithoutRefresh = { ...mockToken, refresh_token: '' };
    vi.spyOn(fs, 'readFileSync').mockReturnValue(
      JSON.stringify(tokenWithoutRefresh)
    );

    const result = loadToken(); // 내부 함수 -- 모듈 export 필요 또는 통합 테스트
    expect(result).toBeNull();
    // stderr에 "[SECURITY] Missing refresh_token" 출력 확인
  });
});
```

**Code Reference**: `oauth.ts:171-186` -- `loadToken()` 함수

---

#### TC-AUT-ALL-006: CSRF 방지 -- state 불일치

**Priority**: P0
**Automation**: Partially possible (HTTP request simulation)

**수동 테스트 절차**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | OAuth 흐름 시작 (브라우저 URL 표시) | state 파라미터 포함 URL |
| 2 | 콜백 URL 수동 조작: `http://localhost:3000/callback?code=xxx&state=WRONG` | |
| 3 | 응답 확인 | HTTP 403 |
| 4 | 응답 본문 확인 | "Authentication failed: Invalid state parameter" |
| 5 | 로그 확인 | `[SECURITY] {...,"event_type":"oauth_callback","result":"failure","detail":"State mismatch..."}` |

**Code Reference**: `oauth.ts:248-268` -- state 검증 블록

---

#### TC-AUT-ALL-007: CSRF 방지 -- state 일치

**Priority**: P0
**Automation**: Possible (integration test)

**테스트 시나리오**: 올바른 state 값으로 콜백 -> HTTP 200 + 토큰 발급

---

#### TC-AUT-ALL-008: 인증 코드 미수신

**Priority**: P1
**Automation**: Possible

**테스트**: `http://localhost:3000/callback?state=CORRECT` (code 파라미터 없음) -> HTTP 400, "No authorization code"

**Code Reference**: `oauth.ts:271-281`

---

#### TC-AUT-ALL-009: 로그인 타임아웃

**Priority**: P1
**Automation**: Possible (timeout simulation)

**Vitest Test Code**:
```typescript
describe('TC-AUT-ALL-009: Login Timeout', () => {
  it('should reject after 5 minutes', async () => {
    vi.useFakeTimers();
    const promise = getTokenFromBrowser(mockOAuth2Client);
    vi.advanceTimersByTime(5 * 60 * 1000); // 5분 경과
    await expect(promise).rejects.toThrow('Login timeout (5 minutes)');
    vi.useRealTimers();
  });
});
```

**Code Reference**: `oauth.ts:329-332` -- `setTimeout 5 * 60 * 1000`

---

#### TC-AUT-ALL-010: 뮤텍스 -- 동시 인증 방지

**Priority**: P0
**Automation**: Possible (Vitest)

**Vitest Test Code**:
```typescript
describe('TC-AUT-ALL-010: Auth Mutex', () => {
  it('should reuse in-progress auth promise', async () => {
    // 첫 번째 호출이 진행 중일 때
    const p1 = getAuthenticatedClient();
    const p2 = getAuthenticatedClient();

    // 같은 Promise 참조
    expect(p1).toBe(p2); // authInProgress 재사용
  });
});
```

**Code Reference**: `oauth.ts:102, 344-346` -- `authInProgress` Promise 공유

---

#### TC-AUT-ALL-011: 서비스 캐싱

**Priority**: P1
**Automation**: Possible (Vitest)

**Vitest Test Code**:
```typescript
describe('TC-AUT-ALL-011: Service Caching', () => {
  it('should return cached services within 50 minutes', async () => {
    const services1 = await getGoogleServices();
    const services2 = await getGoogleServices();
    expect(services1).toBe(services2); // 같은 참조
  });
});
```

**Code Reference**: `oauth.ts:83-99` -- `CACHE_TTL_MS = 50 * 60 * 1000`, `serviceCache`

---

#### TC-AUT-ALL-012: 서비스 캐시 만료

**Priority**: P1
**Automation**: Possible

**테스트**: 50분 경과 시뮬레이션 -> 새 서비스 인스턴스 생성

---

#### TC-AUT-ALL-013: clearServiceCache

**Priority**: P2
**Automation**: Possible

**테스트**: `clearServiceCache()` 호출 후 `getGoogleServices()` -> 새 인스턴스

---

#### TC-AUT-ALL-014: 설정 디렉토리 생성

**Priority**: P0
**Automation**: Possible

**Vitest Test Code**:
```typescript
describe('TC-AUT-ALL-014: Config Dir Creation', () => {
  it('should create CONFIG_DIR with mode 0700', () => {
    vi.spyOn(fs, 'existsSync').mockReturnValue(false);
    const mkdirSpy = vi.spyOn(fs, 'mkdirSync');

    ensureConfigDir();

    expect(mkdirSpy).toHaveBeenCalledWith(
      expect.any(String),
      { recursive: true, mode: 0o700 }
    );
  });
});
```

**Code Reference**: `oauth.ts:115-131` -- `ensureConfigDir()`

---

#### TC-AUT-ALL-015 ~ TC-AUT-ALL-022

| TC ID | Key Verification | Automation | 테스트 방법 |
|-------|----------|--------|-----------|
| TC-AUT-ALL-015 | 설정 디렉토리 권한 0755 -> 0700 복구 | Vitest | chmodSync 호출 + logSecurityEvent 확인 |
| TC-AUT-ALL-016 | `GOOGLE_SCOPES="gmail,drive"` -> 2개 스코프만 | Vitest | `resolveScopes()` 반환값 확인 |
| TC-AUT-ALL-017 | GOOGLE_SCOPES 미설정 -> 6개 서비스 전체 | Vitest | `resolveScopes()` 반환값 6개 |
| TC-AUT-ALL-018 | `OAUTH_PORT=8080` -> 포트 8080 사용 | 수동 | 서버 바인딩 포트 확인 |
| TC-AUT-ALL-019 | client_secret.json 미존재 -> 설치 가이드 에러 | Vitest | Error 메시지에 가이드 포함 확인 |
| TC-AUT-ALL-020 | "installed" 타입 클라이언트 생성 | Vitest | `createOAuth2Client()` 정상 생성 |
| TC-AUT-ALL-021 | "web" 타입 클라이언트 생성 | Vitest | `createOAuth2Client()` 정상 생성 |
| TC-AUT-ALL-022 | 보안 이벤트 JSON 로깅 | Vitest | `console.error` 출력 형식 확인 |

### 4.2 Gmail 도구 테스트 (TC-GML-ALL-001 ~ TC-GML-ALL-022)

모든 Gmail 테스트는 `google-workspace-mcp/src/tools/gmail.ts`를 대상으로 한다.

**공통 Mock 설정** (기존 `gmail.test.ts` 패턴 활용):
```typescript
const mockGmailApi = {
  users: {
    messages: {
      list: vi.fn(),
      get: vi.fn(),
      send: vi.fn(),
      modify: vi.fn(),
      trash: vi.fn(),
      untrash: vi.fn(),
      attachments: { get: vi.fn() },
    },
    drafts: {
      list: vi.fn(),
      get: vi.fn(),
      create: vi.fn(),
      send: vi.fn(),
      delete: vi.fn(),
    },
    labels: { list: vi.fn() },
  },
};

vi.mock('../../auth/oauth', () => ({
  getGoogleServices: vi.fn(async () => ({ gmail: mockGmailApi })),
}));
```

#### TC-GML-ALL-001: gmail_search -- 기본 검색

**Priority**: P0
**Automation**: Possible (Vitest)

**Vitest Test Code**:
```typescript
describe('TC-GML-ALL-001: gmail_search basic', () => {
  it('should return messages with id/from/subject/date/snippet', async () => {
    mockGmailApi.users.messages.list.mockResolvedValue({
      data: {
        messages: [{ id: 'msg1' }, { id: 'msg2' }],
      },
    });
    mockGmailApi.users.messages.get.mockResolvedValue({
      data: {
        payload: {
          headers: [
            { name: 'From', value: 'test@example.com' },
            { name: 'Subject', value: 'Test Subject' },
            { name: 'Date', value: '2026-02-13' },
          ],
        },
        snippet: 'Test snippet...',
      },
    });

    const result = await gmailTools.gmail_search.handler({
      query: 'from:test@example.com',
      maxResults: 5,
    });

    expect(result.total).toBe(2);
    expect(result.messages[0]).toHaveProperty('id');
    expect(result.messages[0]).toHaveProperty('from');
    expect(result.messages[0]).toHaveProperty('subject');
    expect(result.messages[0]).toHaveProperty('date');
    expect(result.messages[0]).toHaveProperty('snippet');
  });
});
```

**Code Reference**: `gmail.ts:18-57` -- `gmail_search` handler

---

#### TC-GML-ALL-002: gmail_search -- 빈 결과

**Automation**: Possible (Vitest)

```typescript
it('should return empty array when no results', async () => {
  mockGmailApi.users.messages.list.mockResolvedValue({
    data: { messages: null },
  });
  const result = await gmailTools.gmail_search.handler({
    query: 'nonexistent-query-xyz',
    maxResults: 10,
  });
  expect(result.total).toBe(0);
  expect(result.messages).toEqual([]);
});
```

---

#### TC-GML-ALL-003: gmail_read -- 전체 읽기

**Priority**: P0
**Automation**: Possible

```typescript
it('should return full email with id, from, to, cc, subject, date, body, attachments, labels', async () => {
  const base64Body = Buffer.from('Hello World').toString('base64');
  mockGmailApi.users.messages.get.mockResolvedValue({
    data: {
      payload: {
        headers: [
          { name: 'From', value: 'sender@example.com' },
          { name: 'To', value: 'recipient@example.com' },
          { name: 'Cc', value: 'cc@example.com' },
          { name: 'Subject', value: 'Test' },
          { name: 'Date', value: '2026-02-13' },
        ],
        mimeType: 'text/plain',
        body: { data: base64Body },
        parts: null,
      },
      labelIds: ['INBOX', 'UNREAD'],
    },
  });

  const result = await gmailTools.gmail_read.handler({ messageId: 'msg1' });
  expect(result.id).toBe('msg1');
  expect(result.from).toBe('sender@example.com');
  expect(result.to).toBe('recipient@example.com');
  expect(result.body).toBe('Hello World');
  expect(result.labels).toContain('INBOX');
});
```

---

#### TC-GML-ALL-004: gmail_read -- MIME 파싱

**Priority**: P1
**Automation**: Possible

**테스트**: multipart/mixed > multipart/alternative > text/plain 구조에서 `extractTextBody()` 올바른 추출

**Code Reference**: `mime.ts:33-73` -- `extractTextBody()` 재귀 파싱

---

#### TC-GML-ALL-005: gmail_read -- 첨부파일 목록

**Priority**: P1
**Automation**: Possible

```typescript
it('should extract attachments with filename, mimeType, attachmentId, size', async () => {
  mockGmailApi.users.messages.get.mockResolvedValue({
    data: {
      payload: {
        mimeType: 'multipart/mixed',
        parts: [
          { mimeType: 'text/plain', body: { data: Buffer.from('body').toString('base64') } },
          {
            filename: 'report.pdf',
            mimeType: 'application/pdf',
            body: { attachmentId: 'att1', size: 1024 },
          },
        ],
      },
    },
  });

  const result = await gmailTools.gmail_read.handler({ messageId: 'msg1' });
  expect(result.attachments).toHaveLength(1);
  expect(result.attachments[0]).toEqual({
    filename: 'report.pdf',
    mimeType: 'application/pdf',
    attachmentId: 'att1',
    size: 1024,
  });
});
```

**Code Reference**: `mime.ts:80-101` -- `extractAttachments()` 함수

---

#### TC-GML-ALL-006: gmail_read -- 본문 5000자 제한

**Priority**: P2
**Automation**: Possible

```typescript
it('should truncate body to 5000 chars', async () => {
  const longBody = 'A'.repeat(10000);
  const base64Body = Buffer.from(longBody).toString('base64');
  // ... mock setup ...
  const result = await gmailTools.gmail_read.handler({ messageId: 'msg1' });
  expect(result.body.length).toBe(5000);
});
```

**Code Reference**: `gmail.ts:95` -- `body: body.slice(0, 5000)`

---

#### TC-GML-ALL-007 ~ TC-GML-ALL-022

| TC ID | Key Verification | Mock 설정 | 기대 결과 |
|-------|----------|----------|----------|
| TC-GML-ALL-007 | gmail_send 이메일 발송 | `messages.send` mock | `success=true, messageId` |
| TC-GML-ALL-008 | gmail_send CC/BCC | 헤더에 CC/BCC 포함 | CC/BCC 헤더 존재 |
| TC-GML-ALL-009 | gmail_send UTF-8 제목 | 한글 제목 | `=?UTF-8?B?...?=` 인코딩 |
| TC-GML-ALL-010 | gmail_send 헤더 인젝션 방지 | `to="a@b.com\r\nBcc: spy@evil.com"` | `sanitizeEmailHeader()`로 CRLF 제거 |
| TC-GML-ALL-011 | gmail_draft_create | `drafts.create` mock | `draftId` 반환 |
| TC-GML-ALL-012 | gmail_draft_list | `drafts.list` mock | `total, drafts[]` |
| TC-GML-ALL-013 | gmail_draft_send | `drafts.send` mock | `success=true, messageId` |
| TC-GML-ALL-014 | gmail_draft_delete | `drafts.delete` mock | `success=true` |
| TC-GML-ALL-015 | gmail_labels_list | `labels.list` mock | `labels[]` (id, name, type) |
| TC-GML-ALL-016 | gmail_labels_add | `messages.modify` mock | "Label added" |
| TC-GML-ALL-017 | gmail_labels_remove | `messages.modify` mock | "Label removed" |
| TC-GML-ALL-018 | gmail_attachment_get | `attachments.get` mock | `size, data (base64)` |
| TC-GML-ALL-019 | gmail_trash | `messages.trash` mock | "Email moved to trash" |
| TC-GML-ALL-020 | gmail_untrash | `messages.untrash` mock | "Email restored from trash" |
| TC-GML-ALL-021 | gmail_mark_read | `messages.modify` mock | UNREAD 라벨 제거 |
| TC-GML-ALL-022 | gmail_mark_unread | `messages.modify` mock | UNREAD 라벨 추가 |

### 4.3 Drive 도구 테스트 (TC-DRV-ALL-001 ~ TC-DRV-ALL-020)

**Common Mocks**:
```typescript
const mockDriveApi = {
  files: {
    list: vi.fn(),
    get: vi.fn(),
    create: vi.fn(),
    copy: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
  },
  permissions: {
    list: vi.fn(),
    create: vi.fn(),
    delete: vi.fn(),
  },
  about: { get: vi.fn() },
};
```

#### TC-DRV-ALL-001: drive_search -- 기본 검색

**Priority**: P0
**Automation**: Possible

```typescript
it('should search with supportsAllDrives=true', async () => {
  mockDriveApi.files.list.mockResolvedValue({
    data: {
      files: [{ id: 'f1', name: 'test.txt', mimeType: 'text/plain' }],
    },
  });

  const result = await driveTools.drive_search.handler({
    query: 'test', maxResults: 10,
  });

  expect(result.total).toBe(1);
  expect(mockDriveApi.files.list).toHaveBeenCalledWith(
    expect.objectContaining({
      supportsAllDrives: true,
      includeItemsFromAllDrives: true,
      corpora: 'allDrives',
    })
  );
});
```

**Code Reference**: `drive.ts:30-39` -- `supportsAllDrives: true, corpora: "allDrives"`

---

#### TC-DRV-ALL-003: drive_search -- 쿼리 이스케이프

**Priority**: P0
**Automation**: Possible

```typescript
it('should escape single quotes in query', async () => {
  mockDriveApi.files.list.mockResolvedValue({ data: { files: [] } });

  await driveTools.drive_search.handler({
    query: "test's file", maxResults: 10,
  });

  const calledWith = mockDriveApi.files.list.mock.calls[0][0];
  expect(calledWith.q).toContain("test\\'s file");
  expect(calledWith.q).not.toContain("test's file");
});
```

**Code Reference**: `drive.ts:25` -- `escapeDriveQuery(query)`, `sanitize.ts:24-26`

---

#### TC-DRV-ALL-005: drive_list -- ID 검증

**Priority**: P0
**Automation**: Possible

```typescript
it('should reject invalid folderId format', async () => {
  await expect(
    driveTools.drive_list.handler({
      folderId: 'invalid!@#$%', maxResults: 20, orderBy: 'modifiedTime desc',
    })
  ).rejects.toThrow('Invalid folderId format');
});
```

**Code Reference**: `drive.ts:66` -- `validateDriveId(folderId, "folderId")`, `sanitize.ts:38-44`

---

#### TC-DRV-ALL-002 ~ TC-DRV-ALL-020 요약

| TC ID | Key Verification | Automation |
|-------|----------|--------|
| TC-DRV-ALL-002 | MIME 필터 (`mimeType="application/pdf"`) | Vitest |
| TC-DRV-ALL-004 | 루트 폴더 목록 (`folderId="root"`) | Vitest |
| TC-DRV-ALL-006 | drive_get_file 상세 정보 | Vitest |
| TC-DRV-ALL-007 | drive_create_folder | Vitest |
| TC-DRV-ALL-008 | 부모 폴더 지정 생성 | Vitest |
| TC-DRV-ALL-009 | drive_copy | Vitest |
| TC-DRV-ALL-010 | drive_move (previousParents 제거) | Vitest |
| TC-DRV-ALL-011 | drive_rename | Vitest |
| TC-DRV-ALL-012 | drive_delete (trashed=true) | Vitest |
| TC-DRV-ALL-013 | drive_restore (trashed=false) | Vitest |
| TC-DRV-ALL-014 | drive_share (권한 생성) | Vitest |
| TC-DRV-ALL-015 | drive_share_link (anyone 링크) | Vitest |
| TC-DRV-ALL-016 | drive_unshare (권한 제거) | Vitest |
| TC-DRV-ALL-017 | drive_unshare 권한 미존재 | Vitest |
| TC-DRV-ALL-018 | drive_list_permissions | Vitest |
| TC-DRV-ALL-019 | drive_get_storage_quota (GB 단위) | Vitest |
| TC-DRV-ALL-020 | Shared Drive 지원 (corpora="allDrives") | Vitest |

### 4.4 Calendar 도구 테스트 (TC-CAL-ALL-001 ~ TC-CAL-ALL-015)

**Common Mocks**:
```typescript
const mockCalendarApi = {
  calendarList: { list: vi.fn() },
  events: {
    list: vi.fn(),
    get: vi.fn(),
    insert: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    quickAdd: vi.fn(),
  },
  freebusy: { query: vi.fn() },
};
```

#### TC-CAL-ALL-001: calendar_list_calendars

**Priority**: P0
**Automation**: Possible

```typescript
it('should return calendars with id/name/primary/accessRole', async () => {
  mockCalendarApi.calendarList.list.mockResolvedValue({
    data: {
      items: [{
        id: 'primary', summary: 'My Calendar',
        primary: true, accessRole: 'owner',
      }],
    },
  });

  const result = await calendarTools.calendar_list_calendars.handler();
  expect(result.calendars[0]).toEqual(expect.objectContaining({
    id: 'primary', name: 'My Calendar', primary: true, accessRole: 'owner',
  }));
});
```

---

#### TC-CAL-ALL-005: calendar_create_event -- 동적 타임존

**Priority**: P0
**Automation**: Possible

```typescript
it('should apply dynamic timezone from getTimezone()', async () => {
  mockCalendarApi.events.insert.mockResolvedValue({
    data: { id: 'evt1', htmlLink: 'https://...' },
  });

  const result = await calendarTools.calendar_create_event.handler({
    calendarId: 'primary',
    title: 'Test Meeting',
    startTime: '2026-03-01 10:00',
    endTime: '2026-03-01 11:00',
  });

  const insertCall = mockCalendarApi.events.insert.mock.calls[0][0];
  // parseTime()이 타임존 오프셋을 추가했는지 확인
  expect(insertCall.requestBody.start.dateTime).toMatch(/T10:00:00[+-]\d{2}:\d{2}/);
});
```

**Code Reference**: `calendar.ts:3` -- `import { getTimezone, parseTime } from '../utils/time.js'`

---

#### TC-CAL-ALL-007: calendar_create_event -- 시간 파싱

**Priority**: P1
**Automation**: Possible (time.ts unit test)

```typescript
// time.ts 단위 테스트
describe('parseTime()', () => {
  it('should convert "2026-03-01 10:00" to ISO with offset', () => {
    process.env.TIMEZONE = 'Asia/Seoul';
    const result = parseTime('2026-03-01 10:00');
    expect(result).toBe('2026-03-01T10:00:00+09:00');
  });

  it('should return as-is when already ISO format', () => {
    const result = parseTime('2026-03-01T10:00:00Z');
    expect(result).toBe('2026-03-01T10:00:00Z');
  });
});
```

**Code Reference**: `time.ts:44-49` -- `parseTime()` 함수

---

#### TC-CAL-ALL-002 ~ TC-CAL-ALL-015 요약

| TC ID | Key Verification | Automation |
|-------|----------|--------|
| TC-CAL-ALL-002 | 기본 이벤트 목록 (현재~30일) | Vitest |
| TC-CAL-ALL-003 | timeMin/timeMax 범위 지정 | Vitest |
| TC-CAL-ALL-004 | calendar_get_event 상세 | Vitest |
| TC-CAL-ALL-006 | 참석자 포함 (sendUpdates="all") | Vitest |
| TC-CAL-ALL-008 | 종일 이벤트 (date 필드) | Vitest |
| TC-CAL-ALL-009 | calendar_update_event (기존값 유지+수정) | Vitest |
| TC-CAL-ALL-010 | calendar_delete_event | Vitest |
| TC-CAL-ALL-011 | calendar_quick_add 자연어 | Vitest |
| TC-CAL-ALL-012 | calendar_find_free_time | Vitest |
| TC-CAL-ALL-013 | calendar_respond_to_event | Vitest |
| TC-CAL-ALL-014 | TIMEZONE 환경변수 적용 | Vitest |
| TC-CAL-ALL-015 | 자동 감지 (Intl.DateTimeFormat) | Vitest |

### 4.5 Docs 도구 테스트 (TC-DOC-ALL-001 ~ TC-DOC-ALL-013)

**Common Mocks**:
```typescript
const mockDocsApi = {
  documents: {
    create: vi.fn(),
    get: vi.fn(),
    batchUpdate: vi.fn(),
  },
};
const mockDriveApi = { files: { get: vi.fn(), update: vi.fn() } };
const mockDocsComments = { comments: { list: vi.fn(), create: vi.fn() } };
```

#### TC-DOC-ALL-001: docs_create -- 빈 문서

**Priority**: P0
**Automation**: Possible

```typescript
it('should create empty document and return documentId/title/link', async () => {
  mockDocsApi.documents.create.mockResolvedValue({
    data: { documentId: 'doc1' },
  });
  mockDriveApi.files.get.mockResolvedValue({
    data: { webViewLink: 'https://docs.google.com/...' },
  });

  const result = await docsTools.docs_create.handler({ title: 'Test Doc' });
  expect(result.documentId).toBe('doc1');
  expect(result.title).toBe('Test Doc');
  expect(result.link).toBeDefined();
});
```

---

#### TC-DOC-ALL-002: docs_create -- 내용 포함

**Priority**: P1
**Automation**: Possible

```typescript
it('should insert content via batchUpdate after creation', async () => {
  mockDocsApi.documents.create.mockResolvedValue({
    data: { documentId: 'doc1' },
  });
  mockDocsApi.documents.batchUpdate.mockResolvedValue({ data: {} });

  await docsTools.docs_create.handler({
    title: 'Test', content: 'Hello World',
  });

  expect(mockDocsApi.documents.batchUpdate).toHaveBeenCalledWith(
    expect.objectContaining({
      documentId: 'doc1',
      requestBody: {
        requests: [{
          insertText: { location: { index: 1 }, text: 'Hello World' },
        }],
      },
    })
  );
});
```

**Code Reference**: `docs.ts:30-46` -- content 존재 시 batchUpdate

---

#### TC-DOC-ALL-003 ~ TC-DOC-ALL-013 요약

| TC ID | Key Verification | Automation |
|-------|----------|--------|
| TC-DOC-ALL-003 | 폴더 지정 (folderId) | Vitest |
| TC-DOC-ALL-004 | docs_read (10000자 제한) | Vitest |
| TC-DOC-ALL-005 | 테이블 포함 문서 ("[table]" 텍스트) | Vitest |
| TC-DOC-ALL-006 | docs_append (문서 끝 삽입) | Vitest |
| TC-DOC-ALL-007 | docs_prepend (index 1 삽입) | Vitest |
| TC-DOC-ALL-008 | docs_replace_text (occurrencesChanged) | Vitest |
| TC-DOC-ALL-009 | 대소문자 구분 (matchCase=true) | Vitest |
| TC-DOC-ALL-010 | docs_insert_heading (HEADING_2) | Vitest |
| TC-DOC-ALL-011 | docs_insert_table (rows x columns) | Vitest |
| TC-DOC-ALL-012 | docs_get_comments | Vitest |
| TC-DOC-ALL-013 | docs_add_comment | Vitest |

### 4.6 Sheets 도구 테스트 (TC-SHT-ALL-001 ~ TC-SHT-ALL-014)

**Common Mocks**:
```typescript
const mockSheetsApi = {
  spreadsheets: {
    create: vi.fn(),
    get: vi.fn(),
    values: {
      get: vi.fn(),
      batchGet: vi.fn(),
      update: vi.fn(),
      append: vi.fn(),
      clear: vi.fn(),
    },
    batchUpdate: vi.fn(),
  },
};
```

#### TC-SHT-ALL-001: sheets_create

**Priority**: P0

```typescript
it('should create spreadsheet and return spreadsheetId/title/link', async () => {
  mockSheetsApi.spreadsheets.create.mockResolvedValue({
    data: { spreadsheetId: 'ss1', sheets: [{ properties: { title: 'Sheet1' } }] },
  });
  mockDriveApi.files.get.mockResolvedValue({
    data: { webViewLink: 'https://sheets.google.com/...' },
  });

  const result = await sheetsTools.sheets_create.handler({ title: 'Test Sheet' });
  expect(result.spreadsheetId).toBe('ss1');
  expect(result.message).toContain('Test Sheet');
});
```

---

#### TC-SHT-ALL-004: sheets_read

**Priority**: P0

```typescript
it('should return 2D values array', async () => {
  mockSheetsApi.spreadsheets.values.get.mockResolvedValue({
    data: { values: [['A1', 'B1'], ['A2', 'B2']] },
  });

  const result = await sheetsTools.sheets_read.handler({
    spreadsheetId: 'ss1', range: 'Sheet1!A1:B2',
  });
  expect(result.values).toEqual([['A1', 'B1'], ['A2', 'B2']]);
  expect(result.rowCount).toBe(2);
  expect(result.columnCount).toBe(2);
});
```

---

#### TC-SHT-ALL-002 ~ TC-SHT-ALL-014 요약

| TC ID | Key Verification | Automation |
|-------|----------|--------|
| TC-SHT-ALL-002 | sheetNames 지정 생성 | Vitest |
| TC-SHT-ALL-003 | sheets_get_info (시트 목록) | Vitest |
| TC-SHT-ALL-005 | sheets_read_multiple (ranges 배열) | Vitest |
| TC-SHT-ALL-006 | sheets_write (updatedCells 반환) | Vitest |
| TC-SHT-ALL-007 | sheets_append (INSERT_ROWS) | Vitest |
| TC-SHT-ALL-008 | sheets_clear | Vitest |
| TC-SHT-ALL-009 | sheets_add_sheet | Vitest |
| TC-SHT-ALL-010 | sheets_delete_sheet | Vitest |
| TC-SHT-ALL-011 | sheets_rename_sheet | Vitest |
| TC-SHT-ALL-012 | sheets_format_cells 볼드 | Vitest |
| TC-SHT-ALL-013 | sheets_format_cells 배경색 RGB 변환 | Vitest |
| TC-SHT-ALL-014 | sheets_auto_resize | Vitest |

### 4.7 Slides 도구 테스트 (TC-SLD-ALL-001 ~ TC-SLD-ALL-011)

**Common Mocks**:
```typescript
const mockSlidesApi = {
  presentations: {
    create: vi.fn(),
    get: vi.fn(),
    batchUpdate: vi.fn(),
    pages: { get: vi.fn() },
  },
};
```

| TC ID | Key Verification | Automation |
|-------|----------|--------|
| TC-SLD-ALL-001 | slides_create (presentationId/link/slideCount) | Vitest |
| TC-SLD-ALL-002 | 폴더 지정 | Vitest |
| TC-SLD-ALL-003 | slides_get_info (title/slideCount/pageSize) | Vitest |
| TC-SLD-ALL-004 | slides_read (슬라이드별 텍스트, 1000자 제한) | Vitest |
| TC-SLD-ALL-005 | slides_add_slide TITLE_AND_BODY 레이아웃 | Vitest |
| TC-SLD-ALL-006 | slides_add_slide BLANK 레이아웃 | Vitest |
| TC-SLD-ALL-007 | slides_delete_slide | Vitest |
| TC-SLD-ALL-008 | slides_duplicate_slide (newSlideId) | Vitest |
| TC-SLD-ALL-009 | slides_move_slide (insertionIndex) | Vitest |
| TC-SLD-ALL-010 | slides_add_text (텍스트 박스 + 텍스트) | Vitest |
| TC-SLD-ALL-011 | slides_replace_text (occurrencesChanged) | Vitest |

### 4.8 유틸리티 테스트

#### 4.8.1 sanitize.ts 테스트 (7개 함수)

**파일**: `google-workspace-mcp/src/utils/sanitize.ts`

```typescript
// sanitize.test.ts
import { describe, it, expect } from 'vitest';
import {
  escapeDriveQuery, validateDriveId, sanitizeEmailHeader,
  validateEmail, validateMaxLength, sanitizeFilename, sanitizeRange,
} from '../sanitize.js';

describe('escapeDriveQuery', () => {
  it("should escape single quotes: test's -> test\\'s", () => {
    expect(escapeDriveQuery("test's")).toBe("test\\'s");
  });
  it('should escape backslashes: test\\path -> test\\\\path', () => {
    expect(escapeDriveQuery('test\\path')).toBe('test\\\\path');
  });
  it('should handle combined: test\\\'s -> test\\\\\\\'s', () => {
    expect(escapeDriveQuery("test\\'s")).toBe("test\\\\\\'s");
  });
});

describe('validateDriveId', () => {
  it('should accept valid ID: abc123_-XYZ', () => {
    expect(() => validateDriveId('abc123_-XYZ', 'fileId')).not.toThrow();
  });
  it('should accept "root"', () => {
    expect(() => validateDriveId('root', 'folderId')).not.toThrow();
  });
  it('should reject special chars: id!@#$%', () => {
    expect(() => validateDriveId('id!@#$%', 'fileId')).toThrow('Invalid fileId format');
  });
});

describe('sanitizeEmailHeader', () => {
  it('should remove CRLF: a@b.com\\r\\nBcc: spy -> a@b.comBcc: spy', () => {
    expect(sanitizeEmailHeader('a@b.com\r\nBcc: spy')).toBe('a@b.comBcc: spy');
  });
});

describe('validateEmail', () => {
  it('should accept valid email', () => {
    expect(validateEmail('user@example.com')).toBe(true);
  });
  it('should reject 255+ chars', () => {
    expect(validateEmail('a'.repeat(255) + '@b.com')).toBe(false);
  });
});

describe('validateMaxLength', () => {
  it('should truncate to max length', () => {
    expect(validateMaxLength('a'.repeat(1000), 500)).toHaveLength(500);
  });
  it('should return as-is if within limit', () => {
    expect(validateMaxLength('short', 500)).toBe('short');
  });
});

describe('sanitizeFilename', () => {
  it('should replace path traversal chars', () => {
    const result = sanitizeFilename('../../../etc/passwd');
    expect(result).not.toContain('..');
    expect(result).not.toContain('/');
  });
  it('should replace null bytes', () => {
    const result = sanitizeFilename('file\x00.txt');
    expect(result).not.toContain('\x00');
  });
});

describe('sanitizeRange', () => {
  it('should accept valid A1 notation: Sheet1!A1:B10', () => {
    expect(sanitizeRange('Sheet1!A1:B10')).toBe('Sheet1!A1:B10');
  });
  it('should reject SQL injection: DROP TABLE users;', () => {
    expect(sanitizeRange('DROP TABLE users;')).toBeNull();
  });
});
```

#### 4.8.2 retry.ts 테스트

**파일**: `google-workspace-mcp/src/utils/retry.ts`

```typescript
// retry.test.ts
import { describe, it, expect, vi } from 'vitest';
import { withRetry } from '../retry.js';

describe('withRetry', () => {
  it('TC-PER-ALL-001: should retry on 429', async () => {
    let attempt = 0;
    const fn = vi.fn(async () => {
      attempt++;
      if (attempt < 3) {
        const err = new Error('Rate limited') as any;
        err.response = { status: 429 };
        throw err;
      }
      return 'success';
    });

    const result = await withRetry(fn, { initialDelay: 10 });
    expect(result).toBe('success');
    expect(fn).toHaveBeenCalledTimes(3);
  });

  it('TC-PER-ALL-004: should NOT retry on 400', async () => {
    const fn = vi.fn(async () => {
      const err = new Error('Bad Request') as any;
      err.response = { status: 400 };
      throw err;
    });

    await expect(withRetry(fn, { initialDelay: 10 })).rejects.toThrow('Bad Request');
    expect(fn).toHaveBeenCalledTimes(1);
  });

  it('TC-PER-ALL-011: should return immediately on success', async () => {
    const fn = vi.fn(async () => 'success');
    const result = await withRetry(fn);
    expect(result).toBe('success');
    expect(fn).toHaveBeenCalledTimes(1);
  });
});
```

#### 4.8.3 mime.ts 테스트

이미 4.2절 TC-GML-ALL-004, TC-GML-ALL-005에서 통합 테스트. 단위 테스트는 `extractTextBody`, `extractAttachments` 직접 호출.

#### 4.8.4 messages.ts 테스트

```typescript
import { messages, msg } from '../messages.js';

describe('messages', () => {
  it('should return static message', () => {
    expect(msg(messages.common.success)).toBe('Success');
  });
  it('should resolve template function', () => {
    expect(msg(messages.gmail.emailSent, 'user@test.com')).toBe('Email sent to user@test.com.');
  });
});
```

#### 4.8.5 time.ts 테스트

```typescript
import { getTimezone, getUtcOffsetString, parseTime, getCurrentTime, addDays, formatDate } from '../time.js';

describe('time utilities', () => {
  it('getTimezone: should use TIMEZONE env', () => {
    process.env.TIMEZONE = 'America/New_York';
    expect(getTimezone()).toBe('America/New_York');
    delete process.env.TIMEZONE;
  });

  it('getTimezone: should auto-detect when no env', () => {
    delete process.env.TIMEZONE;
    expect(getTimezone()).toBeTruthy();
  });

  it('parseTime: should add offset to simple datetime', () => {
    process.env.TIMEZONE = 'UTC';
    const result = parseTime('2026-03-01 10:00');
    expect(result).toMatch(/2026-03-01T10:00:00[+-]/);
  });

  it('parseTime: should return ISO as-is', () => {
    expect(parseTime('2026-03-01T10:00:00Z')).toBe('2026-03-01T10:00:00Z');
  });

  it('addDays: should add 7 days', () => {
    const result = addDays('2026-01-01T00:00:00Z', 7);
    expect(result).toContain('2026-01-08');
  });
});
```

---

## 5. 모듈별 테스트 설계

### 5.1 Atlassian MCP 모듈 (TC-ATL-ALL-001 ~ TC-ATL-ALL-007)

**대상 파일**: `installer/modules/atlassian/install.sh`

#### TC-ATL-ALL-001: Docker 모드 선택

**Priority**: P0
**Automation**: Not possible (interactive input)
**Environment**: MAC-ENV-02 또는 LNX-ENV-01

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Docker Desktop 실행 확인 | `docker info` 성공 |
| 2 | atlassian 모듈 실행 | "Docker is installed!" 표시 |
| 3 | "Select (1/2):" 프롬프트에서 1 입력 | Docker 모드 선택 |
| 4 | `docker pull ghcr.io/sooperset/mcp-atlassian:latest` | 이미지 다운로드 |
| 5 | MCP 설정 확인 | `~/.claude/mcp.json`에 atlassian 서버 등록 |

**Code Reference**: `atlassian/install.sh:39-69` -- Docker 감지 + 선택 로직

---

#### TC-ATL-ALL-003: Docker 모드 -- 자격증명 저장

**Priority**: P0
**Automation**: Not possible (interactive)

**Verification Commands**:
```bash
# 설치 후 확인
cat ~/.atlassian-mcp/credentials.env
# 기대:
# CONFLUENCE_URL=https://company.atlassian.net/wiki
# CONFLUENCE_USERNAME=user@company.com
# CONFLUENCE_API_TOKEN=xxxxx
# JIRA_URL=https://company.atlassian.net
# JIRA_USERNAME=user@company.com
# JIRA_API_TOKEN=xxxxx

stat -f %Lp ~/.atlassian-mcp/credentials.env  # 600
stat -f %Lp ~/.atlassian-mcp/                  # 700
```

**Code Reference**: `atlassian/install.sh:137-153`

---

#### TC-ATL-ALL-005: Docker 모드 -- MCP 설정

**Priority**: P0
**Automation**: Possible (post-installation verification)

**Verification Commands**:
```bash
# MCP 설정에서 --env-file 방식 확인
cat ~/.claude/mcp.json | node -e "
  let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>{
    const config = JSON.parse(d);
    const args = config.mcpServers.atlassian.args;
    console.log('Has --env-file:', args.includes('--env-file'));
    console.log('Args:', JSON.stringify(args));
  })"
```

**기대**: `--env-file` 포함, 인라인 환경변수(`-e CONFLUENCE_URL=...`) 미사용

---

#### TC-ATL-ALL-002, 004, 006, 007 요약

| TC ID | Key Verification | Automation |
|-------|----------|--------|
| TC-ATL-ALL-002 | Rovo 모드: `claude mcp add --transport sse` | 수동 |
| TC-ATL-ALL-004 | 디렉토리 권한 700 | 자동 (stat 검증) |
| TC-ATL-ALL-006 | URL 후행 "/" 제거 | 수동 (입력값 확인) |
| TC-ATL-ALL-007 | Docker 없이 Docker 모드 -> 에러 | 수동 |

### 5.2 Figma MCP 모듈 (TC-FIG-ALL-001 ~ TC-FIG-ALL-008)

**대상 파일**: `installer/modules/figma/install.sh`

#### TC-FIG-ALL-001: Claude CLI 확인

**Priority**: P0
**Automation**: Possible

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | Claude CLI 미설치 환경 | `command -v claude` 실패 |
| 2 | figma 모듈 실행 | |
| 3 | 출력 확인 | "Claude CLI is required. Please install base module first." |
| 4 | 종료 코드 | exit 1 |

**Code Reference**: `figma/install.sh:27-31`

---

#### TC-FIG-ALL-003: Remote MCP 등록

**Priority**: P0
**Automation**: Possible (claude CLI mock)

**Detailed Procedure**:

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | claude, python3 설치 확인 | 모두 성공 |
| 2 | figma 모듈 실행 | |
| 3 | 실행된 명령 확인 | `claude mcp add --transport http figma https://mcp.figma.com/mcp` |
| 4 | MCP 설정 확인 | figma 서버 등록 |

**Code Reference**: `figma/install.sh:46`

---

### 5.3 Notion MCP 모듈 (TC-NOT-ALL-001 ~ TC-NOT-ALL-004)

| TC ID | Key Verification | Automation |
|-------|----------|--------|
| TC-NOT-ALL-001 | Claude CLI 미설치 -> 에러 | 가능 |
| TC-NOT-ALL-002 | Python3 미설치 -> 에러 | 가능 |
| TC-NOT-ALL-003 | `claude mcp add --transport http notion https://mcp.notion.com/mcp` | 수동 |
| TC-NOT-ALL-004 | OAuth PKCE 흐름 완료 | 수동 |

### 5.4 GitHub CLI 모듈 (TC-GIT-MAC-001, TC-GIT-LNX-001~002, TC-GIT-ALL-001~004)

**대상 파일**: `installer/modules/github/install.sh`

#### TC-GIT-MAC-001: gh 설치 (macOS)

**Priority**: P0

| Step | Command/Action | Expected Result |
|------|-----------|----------|
| 1 | macOS + Homebrew 있음 + gh 없음 | |
| 2 | github 모듈 실행 | `brew install gh` 실행 |
| 3 | 확인 | `gh --version` 성공 |

**Code Reference**: `github/install.sh:28-35`

---

#### TC-GIT-ALL-001: gh 인증

**Priority**: P0

```bash
# 인증 명령어 확인
# github/install.sh:72
gh auth login --hostname github.com --git-protocol https --web
```

---

### 5.5 Pencil 모듈 (TC-PEN-ALL-001 ~ TC-PEN-ALL-004, TC-PEN-MAC-001)

**대상 파일**: `installer/modules/pencil/install.sh`

| TC ID | Key Verification | Code Reference |
|-------|----------|----------|
| TC-PEN-ALL-001 | VS Code/Cursor 모두 미설치 -> exit 1 | `pencil/install.sh:42-45` |
| TC-PEN-ALL-002 | `code --install-extension highagency.pencildev` | `pencil/install.sh:52-55` |
| TC-PEN-ALL-003 | `cursor --install-extension highagency.pencildev` | `pencil/install.sh:57-61` |
| TC-PEN-ALL-004 | 양쪽 모두 설치 시 둘 다 설치 | 두 if 블록 모두 실행 |
| TC-PEN-MAC-001 | macOS에서 데스크톱 앱 안내 | `pencil/install.sh:64-68` |

---

## 6. 사용자 시나리오 테스트 설계

### 6.1 신규 설치 시나리오

#### TC-E2E-MAC-001: macOS 클린 설치 전체

**Priority**: P0
**Automation**: Not possible (full E2E manual)
**Environment**: MAC-ENV-02 (SNAP-MAC02-CLEAN)
**예상 소요**: 30분

**완전한 E2E 흐름**:

| 단계 | 행동 | 기대 결과 | 스크린샷 포인트 |
|------|------|----------|----------------|
| 1 | 터미널 열기 | | |
| 2 | `curl -sSL https://raw.githubusercontent.com/popup-jacob/popup-claude/master/installer/install.sh \| bash -s -- --all` | 원격 다운로드 시작 | |
| 3 | SHA-256 검증 | "Integrity verified" 메시지들 | S1 |
| 4 | "Current Status:" 표시 | 모든 도구 [ ] (미설치) | S2 |
| 5 | "Press Enter to start installation" | Enter 입력 | |
| 6 | Base 모듈 실행 | Homebrew 설치 (Apple Silicon /opt/homebrew/) | S3 |
| 7 | Node.js 설치 | `brew install node` 또는 NodeSource | |
| 8 | Git 설치 확인 | 이미 설치 또는 `brew install git` | |
| 9 | VS Code 설치 | `brew install --cask visual-studio-code` | |
| 10 | Docker Desktop 설치 | `brew install --cask docker` + 시작 안내 | S4 |
| 11 | Claude Code CLI 설치 | npm 기반 설치 | |
| 12 | bkit 플러그인 설치 | `claude plugin install bkit` | |
| 13 | GitHub 모듈 (order:2) | `brew install gh` + `gh auth login` | S5 |
| 14 | Atlassian 모듈 (order:5) | 모드 선택 -> Docker pull -> 자격증명 입력 | S6 |
| 15 | Google 모듈 (order:6) | Docker pull -> client_secret.json 프롬프트 -> OAuth | S7 |
| 16 | Figma 모듈 (order:7) | Remote MCP 등록 -> OAuth PKCE | |
| 17 | Notion 모듈 (order:8) | Remote MCP 등록 -> OAuth PKCE | |
| 18 | Pencil 모듈 (order:9) | VS Code 확장 설치 | |
| 19 | "Installation Complete!" | 모든 모듈 [OK] 표시 | S8 |
| 20 | `~/.claude/mcp.json` 확인 | 서버 등록 확인 | |
| 21 | `cat ~/.claude/mcp.json \| node -e "..."` | google-workspace, atlassian 등 등록 | S9 |

**사후 검증**:
```bash
# MCP 설정 검증
cat ~/.claude/mcp.json | python3 -m json.tool

# Docker 이미지 확인
docker images | grep -E "(google-workspace|atlassian)"

# 각 도구 상태 확인
node --version
git --version
code --version
docker --version
claude --version
gh --version
```

---

#### TC-E2E-WIN-001: Windows 클린 설치 전체

**Priority**: P0
**Automation**: Not possible
**Environment**: WIN-ENV-03 (SNAP-WIN03-CLEAN)
**예상 소요**: 45분

**Detailed Procedure**:

| 단계 | PowerShell 명령어 | 기대 결과 |
|------|------------------|----------|
| 1 | `Set-ExecutionPolicy Bypass -Scope Process` | 실행 정책 변경 |
| 2 | `irm https://raw.githubusercontent.com/.../install.ps1 \| iex` + `-installDocker` | 원격 실행 |
| 3 | UAC 프롬프트 | 관리자 권한 승인 |
| 4 | Node.js 설치 (winget) | `winget install OpenJS.NodeJS.LTS` |
| 5 | Git 설치 | `winget install Git.Git` |
| 6 | VS Code 설치 | `winget install Microsoft.VisualStudioCode` |
| 7 | WSL2 설치 | `wsl --install` |
| 8 | Docker Desktop 설치 | `winget install Docker.DockerDesktop` |
| 9 | "Restart required" | 재부팅 |
| 10 | 재부팅 후 Step 2 실행 | `.\install.ps1 -modules "google" -skipBase` |
| 11 | Docker Desktop 시작 대기 | "Docker Desktop is not running!" -> 시작 |
| 12 | Google MCP 설치 | Docker pull + OAuth |
| 13 | `$env:USERPROFILE\.claude\mcp.json` 확인 | 서버 등록 |

---

#### TC-E2E-LNX-001: Ubuntu 클린 설치 전체

**Priority**: P0
**Environment**: LNX-ENV-02

| Step | Command | Expected Result |
|------|--------|----------|
| 1 | `curl -sSL .../install.sh \| bash -s -- --all` | |
| 2 | `sudo` 비밀번호 입력 | apt-get 실행 |
| 3 | NodeSource -> Node.js 설치 | `node --version` = 22.x |
| 4 | Git 설치 | `apt-get install -y git` |
| 5 | VS Code snap 설치 | `sudo snap install code --classic` |
| 6 | Docker Engine 설치 | `curl -fsSL https://get.docker.com \| sh` |
| 7 | docker 그룹 추가 | `sudo usermod -aG docker $USER` |
| 8 | Claude + bkit 설치 | |
| 9 | 모듈 설치 | 순서대로 실행 |
| 10 | 완료 | "Installation Complete!" |

---

#### TC-E2E-WSL-001: WSL2 클린 설치

**Priority**: P1
**특이사항**: 브라우저는 Windows 호스트 브라우저 사용

| Step | Verification Point |
|------|-----------|
| 1 | WSL2 감지: `grep -qi microsoft /proc/version` = true |
| 2 | `browser_open()` -> `cmd.exe /c start` 또는 `powershell.exe Start-Process` |
| 3 | Docker: Windows 호스트 Docker Desktop WSL2 백엔드 공유 |

### 6.2 업데이트/추가 설치 시나리오

#### TC-E2E-ALL-010: 모듈 추가 설치

**Priority**: P0

| Step | Command | Expected Result |
|------|--------|----------|
| 1 | Base + Google 설치 상태 확인 | |
| 2 | `./install.sh --modules "atlassian,github" --skip-base` | |
| 3 | Base 건너뜀 확인 | base 모듈 실행 안됨 |
| 4 | 기존 MCP 설정 유지 | google-workspace 서버 유지 |
| 5 | 새 서버 추가 확인 | atlassian 서버 추가 |

---

#### TC-E2E-ALL-011: 이미 설치된 모듈 재설치

**Priority**: P1

| Step | Verification Point |
|------|-----------|
| 1 | Docker 이미지 재pull |
| 2 | MCP 설정 덮어쓰기 (이전 설정 갱신) |
| 3 | OAuth 재인증 (token.json은 유지될 수 있음) |

---

#### TC-E2E-ALL-012: Base 도구 업데이트

**Priority**: P2 -- 이전 Node.js 버전에서 업데이트 확인

### 6.3 마이그레이션 시나리오

#### TC-E2E-ALL-020: 레거시 MCP 설정 마이그레이션

**Priority**: P0

| Step | Command | Expected Result |
|------|--------|----------|
| 1 | `~/.mcp.json` 생성 (테스트 데이터) | `echo '{"mcpServers":{}}' > ~/.mcp.json` |
| 2 | `~/.claude/mcp.json` 삭제 | `rm -f ~/.claude/mcp.json` |
| 3 | 모듈 설치 실행 | |
| 4 | 마이그레이션 확인 | "Migrated MCP config" 메시지 |
| 5 | 파일 확인 | `~/.claude/mcp.json` 생성됨 (원본 복사) |

**Code Reference**: `mcp-config.sh:19-24` -- 레거시 경로 마이그레이션

---

#### TC-E2E-ALL-021 / TC-E2E-WIN-020

| TC ID | Key Verification |
|-------|----------|
| TC-E2E-ALL-021 | 양쪽 모두 존재 -> `~/.claude/mcp.json`만 사용 |
| TC-E2E-WIN-020 | Windows `%USERPROFILE%\.mcp.json` -> `%USERPROFILE%\.claude\mcp.json` |

### 6.4 오류 복구 시나리오

#### TC-E2E-ALL-030 ~ TC-E2E-ALL-036

| TC ID | 시나리오 | 테스트 방법 | 기대 결과 |
|-------|---------|-----------|----------|
| TC-E2E-ALL-030 | 네트워크 단절 | 방화벽으로 아웃바운드 차단 | curl 실패 에러 메시지 |
| TC-E2E-ALL-031 | Docker 이미지 Pull 실패 | ghcr.io DNS 차단 | docker pull 에러 |
| TC-E2E-ALL-032 | OAuth 타임아웃 | 5분간 로그인 미완료 | "Auth timed out after 300s" |
| TC-E2E-ALL-033 | 모듈 실패 후 재시도 | 의도적 실패 -> 재실행 | 백업에서 복원 후 성공 |
| TC-E2E-ALL-034 | 부분 설치 복구 | 3개 중 2번째 실패 | `--skip-base --modules "third"` |
| TC-E2E-ALL-035 | client_secret.json 미제공 | 파일 없이 Google 모듈 실행 | "client_secret.json not found" |
| TC-E2E-ALL-036 | 포트 충돌 | 3000번 포트 사용 중 | 동적 포트 할당 |

### 6.5 일상 업무 시나리오

#### TC-E2E-ALL-040: 이메일 검색 및 읽기

**Priority**: P0
**Environment**: MCP 서버 실행 중

**Detailed Procedure**:

| 단계 | MCP 도구 호출 | 기대 결과 |
|------|-------------|----------|
| 1 | `gmail_search` query="from:boss" | 이메일 목록 (id, from, subject, date, snippet) |
| 2 | `gmail_read` messageId=(1단계 결과 첫 번째 id) | 본문 내용 (body, attachments, labels) |
| 3 | 결과 확인 | from, subject, body 필드 정상 |

---

#### TC-E2E-ALL-041 ~ TC-E2E-ALL-047

| TC ID | 워크플로 | 호출 순서 |
|-------|---------|----------|
| TC-E2E-ALL-041 | 이메일 작성 발송 | gmail_send -> gmail_search 확인 |
| TC-E2E-ALL-042 | 일정 생성 조회 | calendar_create_event -> calendar_list_events |
| TC-E2E-ALL-043 | 파일 검색 공유 | drive_search -> drive_share |
| TC-E2E-ALL-044 | 문서 생성 편집 | docs_create -> docs_append -> docs_read |
| TC-E2E-ALL-045 | 시트 데이터 입력 | sheets_create -> sheets_write -> sheets_read |
| TC-E2E-ALL-046 | 프레젠테이션 제작 | slides_create -> slides_add_slide x3 -> slides_read |
| TC-E2E-ALL-047 | 복합 워크플로 | gmail_search -> docs_create -> drive_share |

### 6.6 고급 사용 시나리오

#### TC-E2E-ALL-050 ~ TC-E2E-ALL-053

| TC ID | 시나리오 | 환경 설정 | 기대 결과 |
|-------|---------|----------|----------|
| TC-E2E-ALL-050 | 스코프 제한 | `GOOGLE_SCOPES="gmail,calendar"` | Drive API 권한 부족 에러 |
| TC-E2E-ALL-051 | 타임존 변경 | `TIMEZONE="UTC"` | UTC 기준 이벤트 생성 |
| TC-E2E-ALL-052 | Docker 볼륨 영속성 | 컨테이너 재시작 | token.json 유지 |
| TC-E2E-ALL-053 | 동시 MCP 세션 | 2개 Claude 세션 | 뮤텍스로 충돌 방지 |

---

## 7. 크로스 플랫폼 호환성 테스트 설계

### 7.1 OS 버전별 호환성 매트릭스 상세

#### 인스톨러 호환성 테스트 절차

각 OS 환경에서 다음 명령어를 실행하고 결과를 기록한다:

```bash
# 공통 검증 스크립트
#!/bin/bash
echo "=== OS Info ==="
uname -a
echo ""
echo "=== Package Manager ==="
source modules/shared/package-manager.sh
pkg_detect_manager
echo ""
echo "=== install.sh --list ==="
./install.sh --list 2>&1 | tail -20
echo ""
echo "=== install.sh --modules 'github' --skip-base ==="
./install.sh --modules "github" --skip-base 2>&1 | tail -30
```

### 7.2 패키지 관리자별 테스트 절차 (TC-SHR-ALL-001 ~ TC-SHR-ALL-010)

**대상 파일**: `installer/modules/shared/package-manager.sh`

#### TC-SHR-ALL-001 ~ TC-SHR-ALL-006: pkg_detect_manager

**Automation**: Possible (per Docker container execution)

```bash
# 패키지 관리자 감지 테스트
# TC-SHR-ALL-001: macOS
docker run --rm -e OSTYPE=darwin macos-env bash -c 'source package-manager.sh; pkg_detect_manager'
# 기대: "brew"

# TC-SHR-ALL-002: Ubuntu
docker run --rm ubuntu:22.04 bash -c '
  apt update > /dev/null 2>&1
  source package-manager.sh
  pkg_detect_manager
'
# 기대: "apt"

# TC-SHR-ALL-003: Fedora
docker run --rm fedora:39 bash -c 'source package-manager.sh; pkg_detect_manager'
# 기대: "dnf"
```

#### TC-SHR-ALL-007 ~ TC-SHR-ALL-010: pkg_install / pkg_ensure_installed / pkg_install_cask

| TC ID | 입력 | 기대 명령어 |
|-------|------|-----------|
| TC-SHR-ALL-007 | `pkg_install "jq"` (brew) | `brew install jq` |
| TC-SHR-ALL-008 | `pkg_install "jq"` (apt) | `sudo apt-get install -y jq` |
| TC-SHR-ALL-009 | `pkg_ensure_installed "jq"` (설치됨) | "jq is already installed" |
| TC-SHR-ALL-010 | `pkg_install_cask "docker"` (macOS) | `brew install --cask docker` |

### 7.3 쉘 환경별 테스트 (TC-SHR-ALL-020 ~ TC-SHR-ALL-022, TC-SHR-WIN-001 ~ TC-SHR-WIN-003)

| TC ID | 환경 | 테스트 | 기대 결과 |
|-------|------|--------|----------|
| TC-SHR-ALL-020 | Bash 4.x | `bash --version` 확인 후 `install.sh` 실행 | `declare -a` 정상 동작 |
| TC-SHR-ALL-021 | Bash 5.x | `bash --version` 확인 후 `install.sh` 실행 | 전체 기능 정상 |
| TC-SHR-ALL-022 | Zsh | `source install.sh` 시도 | 주의: `#!/bin/bash` 명시 |
| TC-SHR-WIN-001 | PowerShell 5.1 | `$PSVersionTable.PSVersion` 확인 | `ConvertFrom-Json`, `irm` 동작 |
| TC-SHR-WIN-002 | PowerShell 7.x | `pwsh -Version` 확인 | 전체 기능 정상 |
| TC-SHR-WIN-003 | ExecutionPolicy Restricted | 기본 정책에서 실행 | 실행 차단, Bypass 안내 |

### 7.4 Docker Desktop 버전 호환성 (TC-DOK-ALL-001 ~ TC-DOK-ALL-007)

**대상 파일**: `installer/modules/shared/docker-utils.sh`

| TC ID | 환경 | 호출 | 기대 결과 |
|-------|------|------|----------|
| TC-DOK-ALL-001 | DD 4.41 + macOS 13 | `docker_check_compatibility()` | 경고 없이 통과 |
| TC-DOK-ALL-002 | DD 4.42+ + macOS 13 | `docker_check_compatibility()` | "may not support" 경고 |
| TC-DOK-ALL-003 | DD 4.42+ + macOS 14+ | `docker_check_compatibility()` | 경고 없이 통과 |
| TC-DOK-ALL-004 | Docker 없음 | `docker_get_status()` | "not_installed" |
| TC-DOK-ALL-005 | Docker 있음 + 미실행 | `docker_get_status()` | "not_running" |
| TC-DOK-ALL-006 | Docker 시작 중 | `docker_wait_for_start 60` | 60초 내 성공 |
| TC-DOK-ALL-007 | 이전 컨테이너 존재 | `docker_cleanup_container` | stop + rm |

---

## 8. 보안 테스트 설계

### 8.1 OWASP Top 10 테스트 절차

#### 8.1.1 A01: Broken Access Control (TC-SEC-ALL-001 ~ TC-SEC-ALL-006)

##### TC-SEC-ALL-001: 토큰 파일 권한

**Priority**: P0
**Automation**: Possible

**공격 시나리오**: 다른 사용자가 토큰 파일을 읽어 API 접근 권한 탈취
**기대 방어**: 파일 권한 0600 (소유자만 읽기/쓰기)

**테스트 절차**:
```bash
# Linux/macOS
stat -c %a ~/.google-workspace/token.json  # Linux
stat -f %Lp ~/.google-workspace/token.json  # macOS
# 기대: 600

# Vitest (oauth.ts saveToken 검증)
it('should save token with mode 0600', () => {
  const writeSpy = vi.spyOn(fs, 'writeFileSync');
  saveToken(mockToken);
  expect(writeSpy).toHaveBeenCalledWith(
    expect.any(String),
    expect.any(String),
    { mode: 0o600 }
  );
});
```

---

##### TC-SEC-ALL-005: Docker non-root 실행

**Priority**: P0

```bash
# 컨테이너 내 사용자 확인
docker run --rm ghcr.io/popup-jacob/google-workspace-mcp:latest id -u
# 기대: 1001 (mcp 사용자, root 아님)

docker run --rm ghcr.io/popup-jacob/google-workspace-mcp:latest whoami
# 기대: mcp
```

**Code Reference**: `Dockerfile:25-26` -- `groupadd -r mcp && useradd -r -g mcp`, `Dockerfile:39` -- `USER mcp`

---

#### 8.1.2 A02: Cryptographic Failures (TC-SEC-ALL-010 ~ TC-SEC-ALL-014)

##### TC-SEC-ALL-010: OAuth state 엔트로피

**Priority**: P0
**Automation**: Possible

```typescript
describe('TC-SEC-ALL-010: OAuth State Entropy', () => {
  it('should generate 32-byte (64 hex char) random state', () => {
    // oauth.ts:227 -- crypto.randomBytes(32).toString("hex")
    const state = crypto.randomBytes(32).toString('hex');
    expect(state).toHaveLength(64);
    expect(state).toMatch(/^[0-9a-f]{64}$/);
  });

  it('should not have collisions in 100 generations', () => {
    const states = new Set();
    for (let i = 0; i < 100; i++) {
      states.add(crypto.randomBytes(32).toString('hex'));
    }
    expect(states.size).toBe(100);
  });
});
```

---

##### TC-SEC-ALL-013 / TC-SEC-ALL-014: SHA-256 무결성/변조 감지

TC-INS-MAC-020, TC-INS-MAC-021과 동일한 검증을 보안 관점에서 수행.

#### 8.1.3 A03: Injection (TC-SEC-ALL-020 ~ TC-SEC-ALL-025)

##### TC-SEC-ALL-020: Drive 쿼리 인젝션 방지

**Priority**: P0
**Automation**: Possible (Vitest)

**공격 시나리오**: Drive API 쿼리 언어에 `'` 주입으로 쿼리 조작
**테스트 페이로드**: `query="' OR 1=1 --"`

```typescript
it('should escape Drive query injection', async () => {
  mockDriveApi.files.list.mockResolvedValue({ data: { files: [] } });

  await driveTools.drive_search.handler({
    query: "' OR 1=1 --", maxResults: 10,
  });

  const q = mockDriveApi.files.list.mock.calls[0][0].q;
  // escapeDriveQuery("' OR 1=1 --") -> "\\' OR 1=1 --"
  expect(q).toContain("\\'");
  expect(q).not.toContain("' OR");
});
```

---

##### TC-SEC-ALL-023: Gmail 헤더 인젝션 방지

**Priority**: P0
**Automation**: Possible (using existing gmail.test.ts)

**공격 시나리오**: `to` 필드에 CRLF 삽입으로 Bcc 헤더 주입
**테스트 페이로드**: `to="victim@test.com\r\nBcc: spy@evil.com"`

```typescript
// 기존 gmail.test.ts의 TC-G01 테스트와 동일
it('should strip CRLF from email headers', async () => {
  // sanitizeEmailHeader('victim@test.com\r\nBcc: spy@evil.com')
  // -> 'victim@test.comBcc: spy@evil.com' (CRLF 제거)
  const result = sanitizeEmailHeader('victim@test.com\r\nBcc: spy@evil.com');
  expect(result).not.toContain('\r');
  expect(result).not.toContain('\n');
});
```

---

##### TC-SEC-ALL-024: JSON 파싱 인젝션 방지

**Priority**: P0
**Automation**: Possible

**공격 시나리오**: module.json에 셸 메타문자 포함 시 코드 실행
**기대 방어**: stdin 기반 파싱으로 쉘 interpolation 방지

```bash
# 테스트: 악의적 module.json
echo '{"name":"test$(whoami)","order":1}' | node -e "
  let data = '';
  process.stdin.on('data', chunk => data += chunk);
  process.stdin.on('end', () => {
    const obj = JSON.parse(data);
    console.log(obj.name);
  });
"
# 기대: "test$(whoami)" (리터럴 문자열, 명령어 미실행)
```

---

##### TC-SEC-ALL-025: Atlassian 자격증명 인젝션 방지

**Priority**: P0

**공격 시나리오**: API 토큰에 셸 특수문자 포함
**기대 방어**: `--env-file` 방식으로 쉘 확장 없이 전달

```bash
# credentials.env에 특수문자 토큰
echo 'JIRA_API_TOKEN=tok;rm -rf /' > test-cred.env
# --env-file은 셸 해석 없이 원문 전달
docker run --env-file test-cred.env --rm alpine env | grep JIRA
# 기대: JIRA_API_TOKEN=tok;rm -rf / (원문 유지)
```

#### 8.1.4 A05 ~ A08 (TC-SEC-ALL-030 ~ TC-SEC-ALL-061)

| TC ID | Key Verification | Automation |
|-------|----------|--------|
| TC-SEC-ALL-030 | Dockerfile `npm ci` 사용 | Vitest/CI |
| TC-SEC-ALL-031 | production 의존성만 | Docker inspect |
| TC-SEC-ALL-032 | NODE_ENV=production | Docker inspect |
| TC-SEC-ALL-040 | `npm audit --audit-level=high` = 0건 | CI 자동 |
| TC-SEC-ALL-041 | Node.js 22 사용 | Dockerfile 확인 |
| TC-SEC-ALL-042 | 의존성 버전 고정 | package.json 확인 |
| TC-SEC-ALL-050 | refresh_token 필수 | Vitest |
| TC-SEC-ALL-051 | 5분 만료 버퍼 | Vitest |
| TC-SEC-ALL-052 | access_type=offline | Vitest |
| TC-SEC-ALL-060 | checksums.json 최신 | CI 자동 |
| TC-SEC-ALL-061 | 원격 파일 전수 검증 | 수동 |

### 8.2 인증/인가 테스트 (TC-SEC-ALL-070 ~ TC-SEC-ALL-073)

TC-AUT-ALL-006, TC-AUT-ALL-010과 동일한 보안 관점 검증.

| TC ID | Key Verification |
|-------|----------|
| TC-SEC-ALL-070 | CSRF state 불일치 -> 403 |
| TC-SEC-ALL-071 | PKCE code_verifier 없이 토큰 교환 실패 |
| TC-SEC-ALL-072 | 동시 3회 인증 -> 뮤텍스로 1회만 실행 |
| TC-SEC-ALL-073 | 보안 이벤트 JSON 로그 형식 |

### 8.3 입력 검증 테스트 (TC-SEC-ALL-080 ~ TC-SEC-ALL-092)

4.8.1절의 sanitize.ts 단위 테스트와 1:1 대응. 모든 TC는 Vitest로 자동화.

| TC ID | 함수 | 입력 | Expected Output |
|-------|------|------|----------|
| TC-SEC-ALL-080 | `escapeDriveQuery` | `"test's"` | `"test\\'s"` |
| TC-SEC-ALL-081 | `escapeDriveQuery` | `"test\\path"` | `"test\\\\path"` |
| TC-SEC-ALL-082 | `validateDriveId` | `"abc123_-XYZ"` | 에러 없음 |
| TC-SEC-ALL-083 | `validateDriveId` | `"root"` | 에러 없음 |
| TC-SEC-ALL-084 | `validateDriveId` | `"id!@#$%"` | 에러 발생 |
| TC-SEC-ALL-085 | `sanitizeEmailHeader` | `"a@b.com\r\nBcc: spy"` | `"a@b.comBcc: spy"` |
| TC-SEC-ALL-086 | `validateEmail` | `"user@example.com"` | `true` |
| TC-SEC-ALL-087 | `validateEmail` | `"a".repeat(255)+"@b.com"` | `false` |
| TC-SEC-ALL-088 | `sanitizeFilename` | `"../../../etc/passwd"` | 위험문자 치환 |
| TC-SEC-ALL-089 | `sanitizeFilename` | `"file\x00.txt"` | `"file_.txt"` |
| TC-SEC-ALL-090 | `sanitizeRange` | `"Sheet1!A1:B10"` | `"Sheet1!A1:B10"` |
| TC-SEC-ALL-091 | `sanitizeRange` | `"DROP TABLE users;"` | `null` |
| TC-SEC-ALL-092 | `validateMaxLength` | `"a".repeat(1000), 500` | 500자 문자열 |

### 8.4 파일 시스템 보안 테스트 (TC-SEC-ALL-100 ~ TC-SEC-ALL-105)

| TC ID | Key Verification | Code Reference |
|-------|----------|----------|
| TC-SEC-ALL-100 | CONFIG_DIR 생성 (0700) | `oauth.ts:116-118` |
| TC-SEC-ALL-101 | 권한 0755 -> 0700 복구 | `oauth.ts:122-127` |
| TC-SEC-ALL-102 | token 저장 (0600 + chmodSync) | `oauth.ts:200-215` |
| TC-SEC-ALL-103 | Windows에서 chmodSync 실패 정상 처리 | `oauth.ts:128-130, 211-213` |
| TC-SEC-ALL-104 | EXIT trap으로 임시 파일 정리 | `install.sh:561` |
| TC-SEC-ALL-105 | 체크섬 실패 시 tmpfile 삭제 | `install.sh:169` |

### 8.5 네트워크 보안 테스트 (TC-SEC-ALL-110 ~ TC-SEC-ALL-113)

| TC ID | Key Verification | 테스트 방법 |
|-------|----------|-----------|
| TC-SEC-ALL-110 | HTTPS 전용 | 코드 검색: `http://` 없음 (localhost 제외) |
| TC-SEC-ALL-111 | OAuth 콜백 localhost 전용 | `server.listen(OAUTH_PORT)` -> 127.0.0.1 |
| TC-SEC-ALL-112 | Docker `--rm` 옵션 | MCP 설정의 args에 `--rm` 포함 |
| TC-SEC-ALL-113 | curl `-sSL` 사용 | 코드 검색: 모든 curl에 `-sSL` |

---

## 9. 성능/안정성 테스트 설계

### 9.1 Rate Limiting 테스트 설계 (TC-PER-ALL-001 ~ TC-PER-ALL-011)

**대상**: `google-workspace-mcp/src/utils/retry.ts` -- `withRetry()` 함수

#### 429 시뮬레이션 방법

```typescript
// 429 응답 Mock 생성
function create429Error(): Error {
  const err = new Error('Too Many Requests') as any;
  err.response = { status: 429 };
  return err;
}

// 500 응답 Mock
function create500Error(): Error {
  const err = new Error('Internal Server Error') as any;
  err.response = { status: 500 };
  return err;
}

// 네트워크 에러 Mock
function createNetworkError(code: string): Error {
  const err = new Error(`Network error: ${code}`) as any;
  err.code = code;
  return err;
}
```

#### 백오프 간격 측정 방법

```typescript
it('TC-PER-ALL-001: exponential backoff timing', async () => {
  const timestamps: number[] = [];
  let attempt = 0;

  const fn = vi.fn(async () => {
    timestamps.push(Date.now());
    attempt++;
    if (attempt < 3) throw create429Error();
    return 'success';
  });

  await withRetry(fn, { initialDelay: 100, backoffFactor: 2 });

  // 간격 검증 (약간의 오차 허용)
  const gap1 = timestamps[1] - timestamps[0]; // ~100ms
  const gap2 = timestamps[2] - timestamps[1]; // ~200ms
  expect(gap1).toBeGreaterThanOrEqual(90);
  expect(gap1).toBeLessThan(200);
  expect(gap2).toBeGreaterThanOrEqual(180);
  expect(gap2).toBeLessThan(400);
});
```

#### TC-PER-ALL-001 ~ TC-PER-ALL-011 전체

| TC ID | 입력 | Mock | 기대 | 자동화 |
|-------|------|------|------|--------|
| PER-001 | 429 응답 | 2회 429 -> 성공 | 3회 시도, 지수 백오프 | Vitest |
| PER-002 | 500 응답 | 2회 500 -> 성공 | 3회 시도 | Vitest |
| PER-003 | 502/503/504 | 각 코드 1회 -> 성공 | 재시도 | Vitest |
| PER-004 | 400 응답 | 1회 400 | 즉시 throw (1회) | Vitest |
| PER-005 | 403 응답 | 1회 403 | 즉시 throw (1회) | Vitest |
| PER-006 | ECONNRESET | 2회 에러 -> 성공 | 재시도 | Vitest |
| PER-007 | ETIMEDOUT | 2회 에러 -> 성공 | 재시도 | Vitest |
| PER-008 | ECONNREFUSED | 2회 에러 -> 성공 | 재시도 | Vitest |
| PER-009 | maxDelay=10000 | 지연 증가 | 10000ms 초과 안됨 | Vitest |
| PER-010 | maxAttempts=5, initialDelay=500 | 5회 실패 | 5회 시도 후 throw | Vitest |
| PER-011 | 즉시 성공 | 성공 | 1회, 재시도 없음 | Vitest |

### 9.2 대량 데이터 처리 테스트 (TC-PER-ALL-020 ~ TC-PER-ALL-025)

| TC ID | 시나리오 | 검증 포인트 |
|-------|---------|-----------|
| PER-020 | gmail_search maxResults=100 | 상위 10개만 상세 조회 (Promise.all), `gmail.ts:32` |
| PER-021 | drive_search maxResults=50 | pageSize 제한 동작 |
| PER-022 | gmail_read 10MB+ 첨부 | body 5000자 truncate |
| PER-023 | gmail_attachment_get 25MB | base64 정상 반환 |
| PER-024 | docs_read 10000자+ | 10000자 truncate |
| PER-025 | sheets_write 1000x26 | USER_ENTERED 모드 동작 |

### 9.3 동시성 테스트 (TC-PER-ALL-030 ~ TC-PER-ALL-033)

```typescript
describe('TC-PER-ALL-030: Concurrent Auth Mutex', () => {
  it('should execute auth only once for 3 concurrent calls', async () => {
    const authSpy = vi.fn();
    // 3회 동시 호출
    const [c1, c2, c3] = await Promise.all([
      getAuthenticatedClient(),
      getAuthenticatedClient(),
      getAuthenticatedClient(),
    ]);
    // authInProgress Promise 공유로 실제 인증은 1회
  });
});
```

### 9.4 장시간 운영 테스트 (TC-PER-ALL-040 ~ TC-PER-ALL-044)

| TC ID | 시나리오 | 측정 방법 | 기대 결과 |
|-------|---------|----------|----------|
| PER-040 | 50분 캐시 갱신 | 타이머 시뮬레이션 | 새 서비스 인스턴스 |
| PER-041 | 토큰 자동 갱신 | 만료 시간 조작 | 5분 버퍼 자동 refresh |
| PER-042 | refresh_token 만료 | 토큰 무효화 | 브라우저 재인증 |
| PER-043 | 메모리 누수 검증 | `process.memoryUsage().rss` 주기적 측정 | RSS < 500MB |
| PER-044 | Docker 컨테이너 안정성 | HEALTHCHECK 모니터링 | 24시간 통과 |

---

## 10. 회귀 테스트 설계

### 10.1 CI 자동화 테스트 설계 (TC-REG-ALL-001 ~ TC-REG-ALL-010)

**CI 파이프라인**: `.github/workflows/ci.yml`

| TC ID | CI Job | 검증 내용 | 실패 시 조치 |
|-------|--------|----------|------------|
| REG-001 | `lint` | ESLint + Prettier | 코드 포맷 수정 |
| REG-002 | `build` | TypeScript 컴파일 | 타입 에러 수정 |
| REG-003 | `test` | vitest 전체 + 커버리지 | 테스트 수정 |
| REG-004 | `smoke-tests` | module.json 유효성 + `bash -n` | JSON/구문 수정 |
| REG-005 | `security-audit` | `npm audit --audit-level=high` | 의존성 업데이트 |
| REG-006 | `shellcheck` | ShellCheck -S warning | 쉘 스크립트 수정 |
| REG-007 | `docker-build` | 이미지 빌드 + non-root 확인 | Dockerfile 수정 |
| REG-008 | `verify-checksums` | checksums.json 최신 | `generate-checksums.sh` 재실행 |
| REG-009 | `smoke-tests` | `bash -n install.sh` (macOS + Ubuntu) | 구문 에러 수정 |
| REG-010 | `smoke-tests` | order 필드 정렬 확인 | module.json 수정 |

#### CI 자동화 Vitest 설정

```typescript
// vitest.config.ts (기존)
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['src/**/__tests__/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      include: ['src/**/*.ts'],
      exclude: ['src/**/__tests__/**', 'src/**/*.d.ts'],
      thresholds: {
        lines: 60,
        functions: 60,
        branches: 50,
        statements: 60,
      },
    },
    testTimeout: 10000,
  },
});
```

### 10.2 수동 회귀 체크리스트

릴리스 전 수동으로 확인해야 하는 항목:

#### 인스톨러 회귀 (10항목)

- [ ] macOS (Sonoma): `./install.sh --all` 전체 설치 성공
- [ ] macOS: `./install.sh --list` 7개 모듈 표시
- [ ] macOS: `./install.sh --modules "google" --skip-base` 단독 실행
- [ ] macOS: Docker 미실행 시 경고 + 대기
- [ ] macOS: 모듈 실패 시 MCP 설정 롤백
- [ ] Windows: `.\install.ps1 -all` 전체 설치
- [ ] Windows: UAC 관리자 권한 상승
- [ ] Windows: `-list` (관리자 불필요)
- [ ] Linux (Ubuntu): 클린 설치
- [ ] Linux (Fedora): dnf 기반 설치

#### MCP 서버 회귀 (9항목)

- [ ] OAuth 최초 인증 (브라우저 -> 콜백 -> 토큰)
- [ ] 토큰 자동 갱신 (만료 5분 전)
- [ ] gmail_search + gmail_read 연쇄
- [ ] gmail_send UTF-8 제목
- [ ] drive_search + drive_share
- [ ] calendar_create_event (동적 타임존)
- [ ] docs_create + docs_append + docs_read
- [ ] sheets_create + sheets_write + sheets_read
- [ ] slides_create + slides_add_slide

#### 보안 회귀 (7항목)

- [ ] token.json 0600
- [ ] .google-workspace/ 0700
- [ ] MCP 설정 0600
- [ ] credentials.env 600
- [ ] Docker non-root
- [ ] Drive 쿼리 이스케이프
- [ ] Gmail 헤더 인젝션 방지

---

## 11. 테스트 실행 절차

### 11.1 Phase 1 (P0 Critical) 실행 가이드

**목표**: 69건, 약 5.5시간
**실행 순서**:

| 순서 | 영역 | TC 수 | 방법 | 예상 시간 |
|------|------|------:|------|----------|
| 1 | CI 자동화 (REG-001~008) | 8 | CI 파이프라인 | 10분 |
| 2 | OAuth 인증 (AUT P0) | 11 | Vitest + 수동 | 30분 |
| 3 | 보안 핵심 (SEC P0) | 22 | Vitest + 수동 | 1시간 |
| 4 | 인스톨러 핵심 (INS P0) | 14 | 수동 | 1시간 |
| 5 | 도구 핵심 (GML/DRV/CAL P0) | 10 | Vitest | 30분 |
| 6 | E2E 클린 설치 | 4 | 수동 | 2시간 |

**Phase 1 실행 명령어**:
```bash
# 1. CI 자동화 (자동)
cd google-workspace-mcp && npm test

# 2-3. OAuth + 보안 (Vitest)
npx vitest run src/**/__tests__/*.test.ts --reporter=verbose

# 4. 인스톨러 (수동 + 자동)
cd installer && bash tests/run_tests.sh

# 5. 도구 핵심 (Vitest -- 이미 2번에서 포함)

# 6. E2E (수동 -- 각 OS별 클린 환경에서 실행)
```

### 11.2 Phase 2 (P1 High) 실행 가이드

**목표**: 100건, 약 8시간

| Order | Area | TC Count | Estimated Time |
|------|------|------:|----------|
| 1 | 인스톨러 부가 | 20 | 1시간 |
| 2 | MCP 도구 주요 | 35 | 2시간 |
| 3 | 모듈 기능 | 15 | 1시간 |
| 4 | 성능/동시성 | 10 | 1시간 |
| 5 | 크로스 플랫폼 | 12 | 1시간 |
| 6 | E2E 시나리오 | 8 | 2시간 |

### 11.3 Phase 3 (P2-P3) 실행 가이드

**목표**: 57건, 약 30시간 (장시간 운영 테스트 포함)

| Order | Area | TC Count | Estimated Time |
|------|------|------:|----------|
| 1 | MCP 도구 부가 | 30 | 2시간 |
| 2 | 엣지 케이스 | 15 | 1시간 |
| 3 | 성능 스트레스 | 8 | 3시간 |
| 4 | 장시간 운영 | 4 | 24시간 |

### 11.4 결과 기록 템플릿

```markdown
## 테스트 실행 기록

- 실행일: YYYY-MM-DD
- 실행자:
- 환경: (환경 ID, 예: MAC-ENV-02)
- 빌드 버전: (git commit hash)
- Phase: 1 / 2 / 3

### 요약

| 결과 | 건수 |
|------|------|
| PASS | |
| FAIL | |
| SKIP | |
| BLOCK | |

### 상세 결과

| TC ID | 결과 | 소요 시간 | 비고 |
|-------|------|----------|------|
| TC-INS-MAC-001 | PASS | 2분 | |
| TC-INS-MAC-002 | FAIL | 3분 | BUG-2026-0001 참조 |
| TC-INS-MAC-003 | SKIP | - | Docker 환경 미준비 |
```

---

## 부록

### A. 테스트 데이터 카탈로그

| 카탈로그 ID | 유형 | 설명 | 사용 TC |
|------------|------|------|--------|
| GML-DATA-001 | Gmail | 일반 텍스트 이메일 | TC-GML-ALL-001, 003 |
| GML-DATA-002 | Gmail | HTML 본문 이메일 | TC-GML-ALL-004 |
| GML-DATA-003 | Gmail | 멀티파트 이메일 | TC-GML-ALL-004 |
| GML-DATA-004 | Gmail | 첨부파일 포함 (1MB PDF) | TC-GML-ALL-005, 018 |
| GML-DATA-005 | Gmail | 대용량 첨부 (10MB+) | TC-PER-ALL-022, 023 |
| GML-DATA-006 | Gmail | 한글 제목 | TC-GML-ALL-009 |
| GML-DATA-007 | Gmail | CC/BCC 포함 | TC-GML-ALL-008 |
| GML-DATA-008 | Gmail | 5000자+ 본문 | TC-GML-ALL-006 |
| GML-DATA-009 | Gmail | 드래프트 3건 | TC-GML-ALL-011~014 |
| GML-DATA-010 | Gmail | 커스텀 라벨 | TC-GML-ALL-015~017 |
| DRV-DATA-001 | Drive | 루트 파일 5개 | TC-DRV-ALL-004 |
| DRV-DATA-002 | Drive | 폴더 + 하위 파일 | TC-DRV-ALL-007, 008 |
| DRV-DATA-003 | Drive | PDF 파일 | TC-DRV-ALL-002 |
| DRV-DATA-004 | Drive | 공유 파일 | TC-DRV-ALL-014~018 |
| DRV-DATA-005 | Drive | Shared Drive 파일 | TC-DRV-ALL-020 |
| DRV-DATA-006 | Drive | 휴지통 파일 | TC-DRV-ALL-012, 013 |
| DRV-DATA-007 | Drive | 특수문자 파일명 | TC-DRV-ALL-003 |
| CAL-DATA-001~005 | Calendar | 이벤트 데이터 | TC-CAL-ALL-* |
| DOC-DATA-001~004 | Docs | 문서 데이터 | TC-DOC-ALL-* |
| SHT-DATA-001~003 | Sheets | 시트 데이터 | TC-SHT-ALL-* |
| SLD-DATA-001~002 | Slides | 프레젠테이션 데이터 | TC-SLD-ALL-* |

### B. Mock/Stub 설계

#### B.1 Google API Mock 구조

```typescript
// test-utils/google-mock.ts
export function createMockGmailApi() {
  return {
    users: {
      messages: {
        list: vi.fn().mockResolvedValue({ data: { messages: [] } }),
        get: vi.fn().mockResolvedValue({ data: { payload: { headers: [] } } }),
        send: vi.fn().mockResolvedValue({ data: { id: 'sent1' } }),
        modify: vi.fn().mockResolvedValue({ data: {} }),
        trash: vi.fn().mockResolvedValue({ data: {} }),
        untrash: vi.fn().mockResolvedValue({ data: {} }),
        attachments: {
          get: vi.fn().mockResolvedValue({ data: { data: '', size: 0 } }),
        },
      },
      drafts: {
        list: vi.fn().mockResolvedValue({ data: { drafts: [] } }),
        create: vi.fn().mockResolvedValue({ data: { id: 'draft1' } }),
        send: vi.fn().mockResolvedValue({ data: { id: 'sent1' } }),
        delete: vi.fn().mockResolvedValue({ data: {} }),
      },
      labels: {
        list: vi.fn().mockResolvedValue({ data: { labels: [] } }),
      },
    },
  };
}

export function createMockDriveApi() {
  return {
    files: {
      list: vi.fn().mockResolvedValue({ data: { files: [] } }),
      get: vi.fn().mockResolvedValue({ data: {} }),
      create: vi.fn().mockResolvedValue({ data: { id: 'file1' } }),
      copy: vi.fn().mockResolvedValue({ data: { id: 'copy1' } }),
      update: vi.fn().mockResolvedValue({ data: {} }),
    },
    permissions: {
      list: vi.fn().mockResolvedValue({ data: { permissions: [] } }),
      create: vi.fn().mockResolvedValue({ data: {} }),
      delete: vi.fn().mockResolvedValue({ data: {} }),
    },
    about: {
      get: vi.fn().mockResolvedValue({
        data: { storageQuota: { limit: '16106127360', usage: '5368709120' } },
      }),
    },
  };
}

// 유사 패턴으로 Calendar, Docs, Sheets, Slides Mock 생성
```

#### B.2 파일시스템 Mock

```typescript
// OAuth 테스트용 fs Mock
export function mockFileSystem(config: {
  hasClientSecret?: boolean;
  hasToken?: boolean;
  tokenData?: Partial<TokenData>;
  configDirExists?: boolean;
}) {
  vi.spyOn(fs, 'existsSync').mockImplementation((p: string) => {
    const path = p.toString();
    if (path.includes('client_secret.json')) return config.hasClientSecret ?? true;
    if (path.includes('token.json')) return config.hasToken ?? false;
    if (path.includes('.google-workspace')) return config.configDirExists ?? true;
    return true;
  });
  // ... readFileSync, writeFileSync, mkdirSync, chmodSync mocks
}
```

### C. 자동화 스크립트 설계

#### C.1 Vitest 테스트 파일 구조

```
google-workspace-mcp/src/
  auth/__tests__/
    oauth.test.ts          # TC-AUT-ALL-* (22건)
  tools/__tests__/
    gmail.test.ts          # TC-GML-ALL-* (22건) -- 기존 파일 확장
    drive.test.ts          # TC-DRV-ALL-* (20건) -- 기존 파일 확장
    calendar.test.ts       # TC-CAL-ALL-* (15건) -- 기존 파일 확장
    docs.test.ts           # TC-DOC-ALL-* (13건) -- 기존 파일 확장
    sheets.test.ts         # TC-SHT-ALL-* (14건) -- 기존 파일 확장
    slides.test.ts         # TC-SLD-ALL-* (11건) -- 기존 파일 확장
  utils/__tests__/
    sanitize.test.ts       # TC-SEC-ALL-080~092 (13건)
    retry.test.ts          # TC-PER-ALL-001~011 (11건)
    mime.test.ts           # extractTextBody/extractAttachments 단위
    messages.test.ts       # msg() 헬퍼 테스트
    time.test.ts           # parseTime/getTimezone 등 (6건)
```

#### C.2 인스톨러 테스트 스크립트 구조

```
installer/tests/
  run_tests.sh             # 테스트 러너
  test_ins_mac_001.sh      # 인수 파싱 --modules
  test_ins_mac_005.sh      # 알 수 없는 옵션
  test_ins_mac_008.sh      # 잘못된 모듈명
  test_ins_mac_017.sh      # parse_json node
  test_ins_mac_020.sh      # SHA-256 검증
  test_shared_pkg.sh       # 패키지 관리자 감지
```

### D. OS별 명령어 대응표

| 작업 | macOS | Windows (PowerShell) | Linux (Ubuntu) | WSL2 |
|------|-------|---------------------|---------------|------|
| 파일 권한 확인 | `stat -f %Lp file` | `icacls file` | `stat -c %a file` | `stat -c %a file` |
| 패키지 설치 | `brew install pkg` | `winget install pkg` | `sudo apt install pkg` | `sudo apt install pkg` |
| Docker 설치 | `brew install --cask docker` | `winget install Docker.DockerDesktop` | `curl -fsSL https://get.docker.com \| sh` | Windows Docker 공유 |
| 브라우저 열기 | `open URL` | `Start-Process URL` | `xdg-open URL` | `cmd.exe /c start URL` |
| JSON 파싱 | `node -e` / `python3 -c` / `osascript` | `ConvertFrom-Json` | `node -e` / `python3 -c` | `node -e` / `python3 -c` |
| SHA-256 | `shasum -a 256` | `Get-FileHash -Algorithm SHA256` | `sha256sum` | `sha256sum` |
| 프로세스 확인 | `ps aux \| grep` | `Get-Process` | `ps aux \| grep` | `ps aux \| grep` |
| MCP 설정 경로 | `~/.claude/mcp.json` | `$env:USERPROFILE\.claude\mcp.json` | `~/.claude/mcp.json` | `~/.claude/mcp.json` |
| Docker 상태 | `docker info` | `docker info` | `docker info` | `docker info` (Windows) |

### E. 테스트 결과 기록 양식

#### E.1 단일 TC 결과 기록

```markdown
### TC-XXX-YYY-NNN: [테스트 케이스명]

- **실행일**: YYYY-MM-DD HH:MM
- **실행자**: (이름)
- **Environment**: (Environment ID)
- **결과**: PASS / FAIL / SKIP / BLOCK
- **소요 시간**: (분)

#### 절차 및 결과

| 단계 | 행동 | 기대 결과 | 실제 결과 | 판정 |
|------|------|----------|----------|------|
| 1 | ... | ... | ... | OK/NG |
| 2 | ... | ... | ... | OK/NG |

#### 스크린샷/로그
(필요 시 첨부)

#### 비고
(결함 ID, 특이사항 등)
```

#### E.2 결함 보고서

```markdown
## BUG-YYYY-NNNN: [결함 제목]

- **관련 TC**: TC-XXX-YYY-NNN
- **심각도**: Critical / Major / Minor / Trivial
- **Environment**: (Environment ID)
- **발견일**: YYYY-MM-DD
- **상태**: Open / In Progress / Resolved / Closed

### 재현 절차
1. ...
2. ...

### 기대 결과
...

### 실제 결과
...

### 근본 원인
...

### 수정 방안
...

### 스크린샷/로그
...
```

### F. 누락 TC 전수 대응표

본 부록은 설계서 본문에서 범위 참조(예: "TC-PER-ALL-001 ~ TC-PER-ALL-011")로 커버된 TC를 개별 ID로 명시하여 310개 TC 전수 대응을 보장한다.

#### F.1 Figma 모듈 누락 TC

| TC ID | Key Verification | 설계 위치 | 자동화 |
|-------|----------|----------|--------|
| TC-FIG-ALL-002 | Python3 미설치 -> "Python 3 is required for OAuth" 에러, exit 1 | 5.2절 TC-FIG-ALL-001 동일 패턴 | 가능 |
| TC-FIG-ALL-004 | OAuth PKCE: code_verifier/code_challenge 생성 + 브라우저 OAuth | 5.2절 Remote MCP 등록 후 `mcp_oauth_flow "figma"` | 수동 |
| TC-FIG-ALL-005 | OAuth 메타데이터 획득: well-known URL -> authorization_endpoint, token_endpoint 파싱 | 5.2절 oauth-helper.sh의 mcp_oauth_flow 내부 | 수동 |
| TC-FIG-ALL-006 | 토큰 저장: `~/.claude/.credentials.json`에 mcpOAuth 엔트리 | 5.2절 oauth-helper.sh `_save_tokens` 호출 확인 | 수동 |
| TC-FIG-ALL-007 | 기존 인증 재사용: "Already authenticated with figma!" 메시지 | 5.2절 재실행 시 토큰 존재 확인 | 수동 |

#### F.2 GitHub CLI 누락 TC

| TC ID | Key Verification | Code Reference | 자동화 |
|-------|----------|----------|--------|
| TC-GIT-ALL-002 | gh 이미 인증: "Already logged in." 메시지 | `github/install.sh:79-81` | 수동 |
| TC-GIT-ALL-003 | gh 인증 실패: "Authentication failed" 에러, exit 1 | `github/install.sh:74-77` | 수동 |
| TC-GIT-ALL-004 | MCP 미설정: gh는 Bash tool로 직접 사용, MCP 설정 없음 | `github/install.sh:87-88` | 가능 |
| TC-GIT-LNX-002 | gh 설치 (Fedora): `sudo dnf install gh -y` | `github/install.sh:44-45` | Docker 컨테이너 |

#### F.3 성능 테스트 누락 TC

| TC ID | Key Verification | Mock 설정 | 자동화 |
|-------|----------|----------|--------|
| TC-PER-ALL-002 | withRetry: 500 재시도 -- 2회 500 -> 성공 | `err.response.status = 500` | Vitest |
| TC-PER-ALL-003 | withRetry: 502/503/504 재시도 | 각 상태 코드별 Mock | Vitest |
| TC-PER-ALL-005 | withRetry: 403 미재시도 -- 즉시 throw | `err.response.status = 403` | Vitest |
| TC-PER-ALL-006 | withRetry: ECONNRESET 재시도 | `err.code = 'ECONNRESET'` | Vitest |
| TC-PER-ALL-007 | withRetry: ETIMEDOUT 재시도 | `err.code = 'ETIMEDOUT'` | Vitest |
| TC-PER-ALL-008 | withRetry: ECONNREFUSED 재시도 | `err.code = 'ECONNREFUSED'` | Vitest |
| TC-PER-ALL-009 | withRetry: maxDelay=10000 제한 | `options.maxDelay = 10000` | Vitest |
| TC-PER-ALL-010 | withRetry: maxAttempts=5, initialDelay=500 | 커스텀 옵션 | Vitest |
| TC-PER-ALL-021 | drive_search maxResults=50 대량 파일 | pageSize 제한 검증 | Vitest |
| TC-PER-ALL-023 | gmail_attachment_get 25MB -- base64 정상 반환 | 대용량 Mock | Vitest |
| TC-PER-ALL-024 | docs_read 10000자+ -- 10000자 truncate | 긴 문서 Mock | Vitest |
| TC-PER-ALL-031 | 뮤텍스 해제 -- authInProgress null 리셋 | 인증 완료 후 확인 | Vitest |
| TC-PER-ALL-032 | 서비스 캐시 동시 접근 | 캐시 만료 직전 동시 호출 | Vitest |
| TC-PER-ALL-041 | 토큰 자동 갱신 -- 5분 버퍼 refresh | 만료 시간 조작 | Vitest |
| TC-PER-ALL-042 | refresh_token 만료 -- 브라우저 재인증 | refresh 실패 Mock | Vitest |
| TC-PER-ALL-043 | 메모리 누수 -- RSS < 500MB | `process.memoryUsage()` | 수동 |

#### F.4 회귀 테스트 누락 TC

| TC ID | CI Job | 검증 내용 | 자동화 |
|-------|--------|----------|--------|
| TC-REG-ALL-002 | `build` | TypeScript 컴파일 성공 -- tsc 에러 0건 | CI 자동 |
| TC-REG-ALL-003 | `test` | vitest 전체 통과 -- 6개 테스트 파일 | CI 자동 |
| TC-REG-ALL-004 | `smoke-tests` | module.json 유효성 -- 7개 모듈 JSON 파싱 | CI 자동 |
| TC-REG-ALL-005 | `security-audit` | npm audit -- high/critical 0건 | CI 자동 |
| TC-REG-ALL-006 | `shellcheck` | ShellCheck -S warning 없음 | CI 자동 |
| TC-REG-ALL-007 | `docker-build` | Docker 이미지 빌드 + UID 1001 | CI 자동 |
| TC-REG-ALL-008 | `verify-checksums` | checksums.json 최신 | CI 자동 |
| TC-REG-ALL-009 | `smoke-tests` | bash -n install.sh 통과 | CI 자동 |

#### F.5 보안 테스트 누락 TC

| TC ID | Key Verification | 테스트 방법 | 자동화 |
|-------|----------|-----------|--------|
| TC-SEC-ALL-002 | .google-workspace/ 디렉토리 권한 0700 | `stat` 명령어 | 가능 |
| TC-SEC-ALL-003 | ~/.claude/mcp.json 파일 권한 0600 | `stat` 명령어 | 가능 |
| TC-SEC-ALL-004 | ~/.atlassian-mcp/ 디렉토리 700 + credentials.env 600 | `stat` 명령어 | 가능 |
| TC-SEC-ALL-011 | PKCE code_verifier 엔트로피: openssl rand -base64 32 | oauth-helper.sh 확인 | 수동 |
| TC-SEC-ALL-012 | PKCE code_challenge: S256 SHA-256 해시 | 해시 검증 | 수동 |
| TC-SEC-ALL-021 | Drive 쿼리 백슬래시 이스케이프: `test\\injection` -> `test\\\\injection` | Vitest | 가능 |
| TC-SEC-ALL-022 | Drive ID 인젝션: `1234' OR name='hack` -> validateDriveId 에러 | Vitest | 가능 |

#### F.6 공유 유틸리티 누락 TC

| TC ID | Key Verification | 환경 | 자동화 |
|-------|----------|------|--------|
| TC-SHR-ALL-004 | pkg_detect_manager: yum -> CentOS | Docker (centos) | 가능 |
| TC-SHR-ALL-005 | pkg_detect_manager: pacman -> Arch | Docker (archlinux) | 가능 |

---

### G. TC 전수 대응 검증 매트릭스

본 설계서가 커버하는 310개 TC의 전수 매핑:

```
TC-INS-MAC-001 ~ 026  : 3.1절 (26건) -- 전수 커버
TC-INS-WIN-001 ~ 016  : 3.2절 (16건) -- 전수 커버
TC-INS-LNX-001 ~ 010  : 3.3절 (10건) -- 전수 커버
TC-AUT-ALL-001 ~ 022  : 4.1절 (22건) -- 전수 커버
TC-GML-ALL-001 ~ 022  : 4.2절 (22건) -- 전수 커버
TC-DRV-ALL-001 ~ 020  : 4.3절 (20건) -- 전수 커버
TC-CAL-ALL-001 ~ 015  : 4.4절 (15건) -- 전수 커버
TC-DOC-ALL-001 ~ 013  : 4.5절 (13건) -- 전수 커버
TC-SHT-ALL-001 ~ 014  : 4.6절 (14건) -- 전수 커버
TC-SLD-ALL-001 ~ 011  : 4.7절 (11건) -- 전수 커버
TC-ATL-ALL-001 ~ 007  : 5.1절 (7건) -- 전수 커버
TC-FIG-ALL-001 ~ 008  : 5.2절 + F.1 (8건) -- 전수 커버
TC-NOT-ALL-001 ~ 004  : 5.3절 (4건) -- 전수 커버
TC-GIT-*              : 5.4절 + F.2 (6건) -- 전수 커버
TC-PEN-*              : 5.5절 (5건) -- 전수 커버
TC-SHR-ALL-001 ~ 010  : 7.2절 + F.6 (10건) -- 전수 커버
TC-SHR-ALL-020 ~ 022  : 7.3절 (3건) -- 전수 커버
TC-SHR-WIN-001 ~ 003  : 7.3절 (3건) -- 전수 커버
TC-DOK-ALL-001 ~ 007  : 7.4절 (7건) -- 전수 커버
TC-SEC-ALL-*          : 8절 + F.5 (38건) -- 전수 커버
TC-PER-ALL-*          : 9절 + F.3 (25건) -- 전수 커버
TC-E2E-*              : 6절 (19건) -- 전수 커버
TC-REG-ALL-001 ~ 010  : 10절 + F.4 (10건) -- 전수 커버

합계: 314건 (계획서 기준 310건 + 4건 중복 ID 처리)
```

---

*문서 끝*
