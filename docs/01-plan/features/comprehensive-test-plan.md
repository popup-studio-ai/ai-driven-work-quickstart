# ADW Comprehensive Test Plan

**Document Version**: v1.0
**Date Created**: 2026-02-13
**Project**: popup-claude (AI-Driven Work Installer + Google Workspace MCP Server)
**Status**: Draft

---

## 1. Overview

### 1.1 Purpose

This document is a comprehensive test plan derived from analyzing the entire codebase of the ADW (AI-Driven Work) project. It systematically defines all functional and user experience test items for each operating system: Windows, macOS, and Linux.

The test targets consist of two main components:

1. **ADW Installer**: Modular installer based on Bash/PowerShell (7 modules, 6 shared utilities)
2. **Google Workspace MCP Server**: TypeScript-based MCP server (6 services, 71 tools, Docker container)

### 1.2 Scope

| Category | Target | Notes |
|----------|--------|-------|
| ADW Installer (macOS/Linux) | `installer/install.sh` | Bash, 698 lines |
| ADW Installer (Windows) | `installer/install.ps1` | PowerShell, 424 lines |
| Module: Base | `modules/base/install.sh` | Homebrew, Node.js, Git, VS Code, Docker, Claude CLI, bkit |
| Module: Google | `modules/google/install.sh` | Docker image, OAuth, MCP configuration |
| Module: Atlassian | `modules/atlassian/install.sh` | Docker/Rovo dual mode |
| Module: Figma | `modules/figma/install.sh` | Remote MCP, OAuth PKCE |
| Module: Notion | `modules/notion/install.sh` | Remote MCP, OAuth PKCE |
| Module: GitHub | `modules/github/install.sh` | gh CLI installation and authentication |
| Module: Pencil | `modules/pencil/install.sh` | VS Code/Cursor extension |
| Shared Utilities | `modules/shared/*.sh` | 6 files (colors, docker-utils, mcp-config, browser-utils, package-manager, oauth-helper) |
| MCP Server | `google-workspace-mcp/src/` | TypeScript, Node.js 22 |
| OAuth Authentication | `src/auth/oauth.ts` | OAuth 2.0, CSRF, mutex, caching |
| Gmail Tools | `src/tools/gmail.ts` | 15 tools |
| Drive Tools | `src/tools/drive.ts` | 15 tools |
| Calendar Tools | `src/tools/calendar.ts` | 10 tools |
| Docs Tools | `src/tools/docs.ts` | 9 tools |
| Sheets Tools | `src/tools/sheets.ts` | 13 tools |
| Slides Tools | `src/tools/slides.ts` | 9 tools |
| Utilities | `src/utils/*.ts` | 5 files (sanitize, retry, mime, messages, time) |
| Docker | `Dockerfile` | Multi-stage, Node.js 22-slim, non-root |
| CI/CD | `.github/workflows/ci.yml` | lint, build, test, security-audit, shellcheck, docker-build, verify-checksums |

### 1.3 Reference Documents

| Document | Path |
|----------|------|
| Feature Plan | `docs/01-plan/features/adw-improvement.plan.md` |
| Design Document | `docs/02-design/features/adw-improvement.design.md` |
| Security Specification | `docs/02-design/security-spec.md` |
| Comprehensive Analysis | `docs/03-analysis/adw-comprehensive.analysis.md` |
| Requirements Traceability Matrix | `docs/03-analysis/adw-requirements-traceability-matrix.md` |
| Security Verification Report | `docs/03-analysis/security-verification-report.md` |
| Shared Utilities Design | `docs/03-analysis/shared-utilities-design.md` |

### 1.4 Test Case ID Convention

```
TC-{Area}-{OS}-{Number}

Area:
  INS = Installer (main installer)
  BAS = Base module
  GOG = Google module
  ATL = Atlassian module
  FIG = Figma module
  NOT = Notion module
  GIT = GitHub module
  PEN = Pencil module
  SHR = Shared utilities
  AUT = OAuth authentication
  GML = Gmail tools
  DRV = Drive tools
  CAL = Calendar tools
  DOC = Docs tools
  SHT = Sheets tools
  SLD = Slides tools
  UTL = Utilities (sanitize, retry, mime, messages, time)
  DOK = Docker
  SEC = Security
  PER = Performance/Stability
  E2E = User scenarios (End-to-End)
  REG = Regression tests

OS:
  MAC = macOS
  WIN = Windows
  LNX = Linux
  WSL = WSL2
  ALL = All OS
  DOK = Docker environment

Priority:
  P0 = Critical (must pass before release)
  P1 = High (major features, recommended to pass before release)
  P2 = Medium (supplementary features, acceptable until next release)
  P3 = Low (edge cases, long-term tracking)
```

---

## 2. Minimum System Requirements

### 2.1 macOS

| Item | Minimum | Recommended | Rationale |
|------|---------|-------------|-----------|
| **OS Version** | macOS Ventura 13.0 | macOS Sonoma 14.0+ | Docker Desktop 4.42+ requires macOS 14+ (`docker-utils.sh:148`) |
| **CPU** | Apple M1 / Intel Core i5 | Apple M1 Pro or higher | Docker image build and MCP server execution |
| **RAM** | 8GB | 16GB | Docker Desktop default memory allocation 4GB + host OS |
| **Disk Space** | 10GB free | 20GB free | Docker Desktop ~2GB + Docker image ~500MB + Node.js ~200MB + VS Code ~500MB + gcloud SDK ~500MB |
| **Homebrew** | Auto-installed | - | Auto-installed if not present at `base/install.sh:24-33` |
| **Node.js** | v18+ (LTS) | v22 (LTS) | `package.json` dependencies, Dockerfile uses node:22-slim |
| **Python 3** | v3.8+ | v3.10+ | Required for Figma/Notion OAuth PKCE flow (`figma/install.sh:36`, `notion/install.sh:32`) |
| **Docker Desktop** | v4.0+ | v4.41+ (Ventura) / v4.42+ (Sonoma+) | Required for Google, Atlassian modules (`docker-utils.sh:131-155`) |
| **Internet** | Required | Stable connection | GitHub Raw, Docker Hub, npm, Homebrew, Google APIs |
| **Admin Privileges** | Required for Homebrew installation | - | `base/install.sh:26` |

### 2.2 Windows

| Item | Minimum | Recommended | Rationale |
|------|---------|-------------|-----------|
| **OS Version** | Windows 10 21H2 | Windows 11 23H2+ | WSL2 support required (`install.ps1:213-218`) |
| **CPU** | Intel Core i5 / AMD Ryzen 5 | Intel Core i7 / AMD Ryzen 7 | Concurrent WSL2 + Docker Desktop + MCP server execution |
| **RAM** | 8GB | 16GB | WSL2 default memory 50% + Docker Desktop |
| **Disk Space** | 15GB free | 25GB free | WSL2 ~1GB + Docker Desktop ~3GB + same as above |
| **WSL2** | Auto-installed | Pre-installed | Required when using Docker modules (`install.ps1:213-218`) |
| **PowerShell** | v5.1+ | v7.0+ | `install.ps1` execution environment |
| **Node.js** | v18+ | v22 | Auto-installed via winget |
| **Python 3** | v3.8+ | v3.10+ | Required when using Figma/Notion modules |
| **Docker Desktop** | v4.0+ | Latest | WSL2 backend mode |
| **Admin Privileges** | Required for system package installation | - | `install.ps1:131-169` conditional elevation |
| **Execution Policy** | Bypass (during installation) | RemoteSigned | `Set-ExecutionPolicy Bypass` required to run `install.ps1` |

### 2.3 Linux

| Item | Minimum | Recommended | Rationale |
|------|---------|-------------|-----------|
| **Distribution** | Ubuntu 22.04 LTS | Ubuntu 24.04 LTS | apt-get, dnf, pacman supported in `base/install.sh` |
| **Kernel** | 5.10+ | 6.1+ | Docker compatibility |
| **CPU** | x86_64 / aarch64 | - | Docker image architecture |
| **RAM** | 4GB | 8GB | Less memory possible when not using Docker |
| **Disk Space** | 5GB free | 15GB free | Can be minimized when not using Docker |
| **Package Manager** | One of apt, dnf, pacman | apt (Ubuntu/Debian) | 5 managers supported in `package-manager.sh` (brew, apt, dnf, yum, pacman) |
| **Node.js** | v18+ | v22 | Auto-installed via NodeSource script (`base/install.sh:49-59`) |
| **Python 3** | v3.8+ | v3.10+ | Figma/Notion modules, parse_json fallback |
| **Docker Engine** | v20.10+ | Latest | Auto-installed via `curl -fsSL https://get.docker.com` |
| **sudo Privileges** | Required for package installation | - | System package management via apt-get, dnf, etc. |
| **curl** | Required | - | Remote execution and downloads |
| **openssl** | Required | - | OAuth PKCE, SHA-256 checksums |
| **shasum or sha256sum** | Required (either one) | - | SHA-256 integrity verification (`install.sh:152-157`) |

#### 2.3.1 WSL2

| Item | Requirement | Rationale |
|------|-------------|-----------|
| **WSL Version** | WSL2 | Docker Desktop backend |
| **Distribution** | Ubuntu 22.04+ | Default distribution |
| **Windows Host** | Windows 10 21H2+ | WSL2 support |
| **Browser Integration** | `cmd.exe /c start` or `powershell.exe Start-Process` | `browser-utils.sh:24-25` |

#### 2.3.2 Supported Distribution Matrix

| Distribution | Package Manager | Node.js Install | Docker Install | VS Code Install | Support Level |
|--------------|----------------|-----------------|----------------|-----------------|---------------|
| Ubuntu 22.04/24.04 | apt | NodeSource | get.docker.com | snap | Full support |
| Debian 12+ | apt | NodeSource | get.docker.com | Manual | Full support |
| Fedora 39+ | dnf | NodeSource | get.docker.com | Manual | Full support |
| RHEL/CentOS Stream 9+ | dnf/yum | NodeSource | get.docker.com | Manual | Partial support |
| Arch Linux | pacman | pacman | pacman | AUR | Partial support |
| openSUSE | zypper | Manual | Manual | Manual | Unsupported (manager not included) |

### 2.4 Common Requirements

| Item | Requirement | Rationale |
|------|-------------|-----------|
| **Internet Connection** | Required (during installation), Required (during MCP server operation) | GitHub Raw download, Docker Pull, Google API calls |
| **Firewall Ports** | Outbound 443 (HTTPS), Local 3000 (OAuth callback, dynamic), 3118 (MCP OAuth callback) | `oauth.ts:24`, `oauth-helper.sh:15` |
| **Proxy** | Not supported (no explicit proxy configuration) | curl, docker pull, npm all depend on system proxy |
| **DNS** | Must resolve `raw.githubusercontent.com`, `ghcr.io`, `*.googleapis.com`, `registry.npmjs.org` | Remote installation and API calls |
| **Claude Code CLI** | v1.0+ | Prerequisite for all modules (`base/install.sh:177-186`) |
| **bkit Plugin** | Installed | Auto-installed by Base module (`base/install.sh:192-200`) |

---

## 3. Test Environment Setup

### 3.1 macOS Test Environment

#### 3.1.1 Required Environments

| Environment ID | OS Version | Chipset | Purpose |
|----------------|------------|---------|---------|
| MAC-ENV-01 | macOS Ventura 13.x | Intel | Backward compatibility verification |
| MAC-ENV-02 | macOS Sonoma 14.x | Apple M1/M2 | Primary test environment |
| MAC-ENV-03 | macOS Sequoia 15.x | Apple M3/M4 | Latest OS compatibility |

#### 3.1.2 Precondition Checklist

- [ ] Start with Homebrew not installed (for clean test)
- [ ] Start with Homebrew installed (for update test)
- [ ] Docker Desktop not installed
- [ ] Docker Desktop installed + not running
- [ ] Docker Desktop installed + running
- [ ] Apple Silicon (M1+) PATH configuration verified: `/opt/homebrew/bin/brew`
- [ ] Intel Mac PATH configuration verified: `/usr/local/bin/brew`

### 3.2 Windows Test Environment

#### 3.2.1 Required Environments

| Environment ID | OS Version | Purpose |
|----------------|------------|---------|
| WIN-ENV-01 | Windows 10 21H2 | Minimum supported version |
| WIN-ENV-02 | Windows 10 22H2 | Current stable version |
| WIN-ENV-03 | Windows 11 23H2+ | Latest OS |

#### 3.2.2 Precondition Checklist

- [ ] WSL2 not installed
- [ ] WSL2 installed + Ubuntu distribution present
- [ ] PowerShell 5.1 (default)
- [ ] PowerShell 7.x
- [ ] Standard user account without admin privileges
- [ ] Account with admin privileges
- [ ] Docker Desktop not installed
- [ ] Docker Desktop installed (WSL2 backend)
- [ ] Execution policy: Restricted (default)
- [ ] Execution policy: RemoteSigned

### 3.3 Linux Test Environment

#### 3.3.1 Required Environments

| Environment ID | Distribution | Package Manager | Purpose |
|----------------|-------------|-----------------|---------|
| LNX-ENV-01 | Ubuntu 22.04 LTS | apt | Primary testing |
| LNX-ENV-02 | Ubuntu 24.04 LTS | apt | Latest LTS |
| LNX-ENV-03 | Fedora 39+ | dnf | RPM family |
| LNX-ENV-04 | Arch Linux | pacman | Rolling release |
| LNX-ENV-05 | WSL2 Ubuntu 22.04 | apt | Windows integration |

#### 3.3.2 Precondition Checklist

- [ ] User with sudo access
- [ ] curl installed
- [ ] openssl installed
- [ ] Node.js not installed (clean test)
- [ ] Node.js pre-installed (existing environment test)
- [ ] Docker not installed
- [ ] Docker installed + not added to docker group
- [ ] Docker installed + added to docker group

### 3.4 Docker Test Environment

#### 3.4.1 Required Environments

| Environment ID | Docker Version | Host OS | Purpose |
|----------------|---------------|---------|---------|
| DOK-ENV-01 | Docker Desktop 4.41 | macOS Ventura | Backward compatibility |
| DOK-ENV-02 | Docker Desktop Latest | macOS Sonoma+ | Primary testing |
| DOK-ENV-03 | Docker Desktop Latest | Windows 11 (WSL2) | Windows Docker |
| DOK-ENV-04 | Docker Engine Latest | Ubuntu 22.04 | Linux Docker |

#### 3.4.2 Docker Image Verification Items

- [ ] `ghcr.io/popup-jacob/google-workspace-mcp:latest` can be pulled
- [ ] `ghcr.io/sooperset/mcp-atlassian:latest` can be pulled
- [ ] Google MCP image size verified (recommended under 500MB)
- [ ] Node.js 22 confirmed in image
- [ ] Non-root user (mcp:mcp) confirmed in image (UID 1001)
- [ ] VOLUME `/app/.google-workspace` can be mounted
- [ ] HEALTHCHECK operation verified

---

## 4. Functional Tests

### 4.1 Installer Functional Tests

#### 4.1.1 macOS Test Cases

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-INS-MAC-001 | Argument parsing: --modules option | install.sh accessible | Run `./install.sh --modules "google,atlassian"` | SELECTED_MODULES set to "google atlassian" | P0 |
| TC-INS-MAC-002 | Argument parsing: --all option | install.sh accessible | Run `./install.sh --all` | All modules without required=true selected | P0 |
| TC-INS-MAC-003 | Argument parsing: --list option | install.sh accessible | Run `./install.sh --list` | Module list displayed then exit 0 | P1 |
| TC-INS-MAC-004 | Argument parsing: --skip-base option | install.sh accessible | Run `./install.sh --modules "google" --skip-base` | SKIP_BASE=true, base module skipped | P1 |
| TC-INS-MAC-005 | Argument parsing: unknown option | install.sh accessible | Run `./install.sh --unknown` | "Unknown option" error message, exit 1 | P1 |
| TC-INS-MAC-006 | Module scan: local execution | modules/ folder exists | Run install.sh locally | USE_LOCAL=true, 7 module.json files parsed | P0 |
| TC-INS-MAC-007 | Module scan: remote execution | Internet connected | Run via `curl \| bash` | USE_LOCAL=false, module list obtained via modules.json | P0 |
| TC-INS-MAC-008 | Module validation: invalid module name | install.sh accessible | Run `./install.sh --modules "nonexistent"` | "Unknown module" error, exit 1 | P1 |
| TC-INS-MAC-009 | Smart status detection | Clean environment | Run install.sh | Node.js, Git, VS Code, Docker, Claude, bkit status accurately displayed | P0 |
| TC-INS-MAC-010 | Base auto-skip | Node.js, Git, Claude, bkit all installed | Run `./install.sh --modules "google"` | "All base tools are already installed. Skipping base." message | P1 |
| TC-INS-MAC-011 | Docker not running warning | Docker installed + not running | Select module requiring Docker and run | Docker Desktop launch instructions displayed, awaiting user input | P1 |
| TC-INS-MAC-012 | Module execution order | Multiple modules selected | Run `./install.sh --modules "google,atlassian,github"` | Sorted by MODULE_ORDERS (github:2 -> atlassian:5 -> google:6) | P1 |
| TC-INS-MAC-013 | MCP config backup | ~/.claude/mcp.json exists | Start module installation | mcp.json.bak.{timestamp} backup file created | P0 |
| TC-INS-MAC-014 | Rollback on module failure | MCP config backup completed | Module install.sh returns exit 1 | "Rolling back MCP configuration" message, restored from backup | P0 |
| TC-INS-MAC-015 | Backup cleanup on success | All modules succeeded | Full installation completed | Backup file deleted, "Installation Complete!" message | P1 |
| TC-INS-MAC-016 | Post-installation verification | Module installation completed | Call verify_module_installation | MCP config registration confirmed, Docker image existence confirmed | P1 |
| TC-INS-MAC-017 | parse_json: node priority | Node.js installed | Run JSON parsing | stdin-based parsing via node -e | P1 |
| TC-INS-MAC-018 | parse_json: python3 fallback | Node.js not installed, Python3 installed | Run JSON parsing | stdin-based parsing via python3 | P2 |
| TC-INS-MAC-019 | parse_json: osascript fallback | Node.js/Python3 not installed (macOS) | Run JSON parsing | stdin-based parsing via osascript JavaScript | P3 |
| TC-INS-MAC-020 | SHA-256 checksum verification | Remote execution, checksums.json available | Call download_and_verify | "Integrity verified" message on SHA-256 hash match | P0 |
| TC-INS-MAC-021 | SHA-256 checksum mismatch | Remote execution, tampered file | Call download_and_verify | "[SECURITY] Integrity verification failed!" message, temp file deleted, return 1 | P0 |
| TC-INS-MAC-022 | checksums.json unavailable | Remote execution, checksums.json 404 | Call download_and_verify | "[WARN] checksums.json not available" warning, installation continues | P2 |
| TC-INS-MAC-023 | Shared script remote download | Remote execution | Call setup_shared_dir | colors.sh, browser-utils.sh, docker-utils.sh, mcp-config.sh downloaded to SHARED_TMP | P1 |
| TC-INS-MAC-024 | Temp file cleanup (trap) | Remote execution | Installation completed or interrupted | SHARED_TMP directory deleted via EXIT trap | P1 |
| TC-INS-MAC-025 | Environment variable support | - | Run `MODULES="google" INSTALL_ALL=false ./install.sh` | Environment variable values applied like command-line arguments | P2 |
| TC-INS-MAC-026 | Apple Silicon Homebrew PATH | M1+ Mac | After Homebrew installation | `/opt/homebrew/bin/brew` shellenv applied | P1 |

#### 4.1.2 Windows Test Cases

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-INS-WIN-001 | Parameter parsing: -modules | install.ps1 accessible | Run `.\install.ps1 -modules "google,atlassian"` | $selectedModules set to "google","atlassian" | P0 |
| TC-INS-WIN-002 | Parameter parsing: -all | install.ps1 accessible | Run `.\install.ps1 -all` | All modules without required selected | P0 |
| TC-INS-WIN-003 | Parameter parsing: -list | install.ps1 accessible | Run `.\install.ps1 -list` | Module list displayed (no admin privileges needed) | P1 |
| TC-INS-WIN-004 | Environment variable support | - | Run `$env:MODULES='google'; .\install.ps1` | $env:MODULES value applied | P2 |
| TC-INS-WIN-005 | Admin privilege detection | Non-admin account | Run with Node.js not installed | UAC prompt requesting admin privileges | P0 |
| TC-INS-WIN-006 | Conditional elevation | All base tools installed | Run `-modules "notion" -skipBase` | Runs without requesting admin privileges | P1 |
| TC-INS-WIN-007 | Remote execution admin elevation | Non-admin, remote execution | Run `irm .../install.ps1 \| iex` | Remote script re-executed via scriptblock | P1 |
| TC-INS-WIN-008 | Smart status detection | Clean environment | Run install.ps1 | Node.js, Git, VS Code, WSL, Docker, Claude, bkit status displayed | P0 |
| TC-INS-WIN-009 | WSL detection | WSL2 installed | Run install.ps1 | `wsl --version` succeeds, WSL: [OK] displayed | P1 |
| TC-INS-WIN-010 | Docker not running warning | Docker installed + not running | Select module requiring Docker | "Docker Desktop is not running!" warning, awaiting user input | P1 |
| TC-INS-WIN-011 | Module execution order | Multiple modules selected | Run `-modules "google,github"` | Sorted by order (github:2, google:6) | P1 |
| TC-INS-WIN-012 | Base auto-skip | All base tools installed | Run `-modules "google"` | "All base tools are already installed. Skipping base." | P1 |
| TC-INS-WIN-013 | MCP config path | Installation completed | Check MCP config | Uses `$env:USERPROFILE\.claude\mcp.json` path | P0 |
| TC-INS-WIN-014 | Remote MCP type display | Installation completed | Check completion summary | Remote MCP servers displayed with "(Remote MCP)" text | P2 |
| TC-INS-WIN-015 | Local/remote auto-detection | - | Check $MyInvocation.MyCommand.Path | Local: $UseLocal=$true, Remote: $UseLocal=$false | P1 |
| TC-INS-WIN-016 | -installDocker flag | Docker not installed | Run `.\install.ps1 -installDocker` | $script:needsDocker=$true, Docker installation proceeds | P1 |

#### 4.1.3 Linux Test Cases

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-INS-LNX-001 | apt-based installation | Ubuntu/Debian | Run install.sh | Node.js, Git installed via apt-get | P0 |
| TC-INS-LNX-002 | dnf-based installation | Fedora/RHEL | Run install.sh | Node.js, Git installed via dnf | P1 |
| TC-INS-LNX-003 | pacman-based installation | Arch Linux | Run install.sh | Node.js, Git installed via pacman | P2 |
| TC-INS-LNX-004 | Docker group addition | Linux, Docker installed | Base module Docker installation | `sudo usermod -aG docker $USER` executed | P1 |
| TC-INS-LNX-005 | SHA-256: sha256sum | sha256sum available, shasum unavailable | Call download_and_verify | Hash computed via sha256sum | P1 |
| TC-INS-LNX-006 | SHA-256: shasum | shasum available, sha256sum unavailable | Call download_and_verify | Hash computed via shasum -a 256 | P2 |
| TC-INS-LNX-007 | VS Code snap installation | Ubuntu, snap available | Run base module | `sudo snap install code --classic` | P2 |
| TC-INS-LNX-008 | WSL2 browser open | WSL2 environment | Call browser_open() | `cmd.exe /c start` or `powershell.exe Start-Process` | P1 |
| TC-INS-LNX-009 | xdg-open fallback | Regular Linux (non-WSL) | Call browser_open() | `xdg-open` command used | P1 |
| TC-INS-LNX-010 | Unsupported package manager | zypper-only system | Run install.sh | "Unsupported package manager" warning, manual installation instructions | P3 |

### 4.2 Google Workspace MCP Functional Tests

#### 4.2.1 Authentication (OAuth 2.0)

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-AUT-ALL-001 | Initial authentication flow | client_secret.json exists, token.json absent | Call getAuthenticatedClient() | Browser OAuth flow starts, token.json created (mode 0600) | P0 |
| TC-AUT-ALL-002 | Token reuse | Valid token.json exists | Call getAuthenticatedClient() | Cached token used without browser | P0 |
| TC-AUT-ALL-003 | Token expiry refresh | token.json expiry_date < now + 5 min | Call getAuthenticatedClient() | refreshAccessToken() auto-called, new token saved | P0 |
| TC-AUT-ALL-004 | Re-authentication on refresh failure | refresh_token invalidated | Call getAuthenticatedClient() | refreshAccessToken fails -> getTokenFromBrowser executed | P0 |
| TC-AUT-ALL-005 | refresh_token missing validation | token.json has no refresh_token | Call loadToken() | Returns null, "[SECURITY] Missing refresh_token" logged | P1 |
| TC-AUT-ALL-006 | CSRF prevention: state parameter | OAuth flow in progress | Send incorrect state value to callback | 403 response, "State mismatch -- possible CSRF attack" logged | P0 |
| TC-AUT-ALL-007 | CSRF prevention: state match | OAuth flow in progress | Send correct state value to callback | 200 response, token issued | P0 |
| TC-AUT-ALL-008 | Authorization code not received | OAuth callback | Callback without code parameter | 400 response, "No authorization code" error | P1 |
| TC-AUT-ALL-009 | Login timeout | OAuth flow started | Login not completed within 5 minutes | "Login timeout (5 minutes)" error | P1 |
| TC-AUT-ALL-010 | Mutex: concurrent auth prevention | - | Call getAuthenticatedClient() 2 times concurrently | Second call reuses first Promise (authInProgress) | P0 |
| TC-AUT-ALL-011 | Service caching | Authentication completed | Call getGoogleServices() twice within 50 min | Second call returns cached service instance | P1 |
| TC-AUT-ALL-012 | Service cache expiry | Authentication completed, 50 min elapsed | Call getGoogleServices() | New service instance created, cache refreshed | P1 |
| TC-AUT-ALL-013 | clearServiceCache | Cache exists | Call clearServiceCache() then getGoogleServices() | New service instance created | P2 |
| TC-AUT-ALL-014 | Config directory creation | CONFIG_DIR absent | Call ensureConfigDir() | Directory created (mode 0700) | P0 |
| TC-AUT-ALL-015 | Config directory permission fix | CONFIG_DIR permissions 0755 | Call ensureConfigDir() | Changed to 0700, security event logged | P1 |
| TC-AUT-ALL-016 | Dynamic OAuth scopes | GOOGLE_SCOPES="gmail,drive" | Call resolveScopes() | Only gmail.modify + drive scopes included | P1 |
| TC-AUT-ALL-017 | Default full scopes | GOOGLE_SCOPES not set | Call resolveScopes() | All 6 service scopes returned | P1 |
| TC-AUT-ALL-018 | Dynamic OAuth port | OAUTH_PORT=8080 | Call getTokenFromBrowser() | Callback server starts on localhost:8080 | P2 |
| TC-AUT-ALL-019 | client_secret.json missing | File absent in CONFIG_DIR | Call loadClientSecret() | Error message includes installation guide | P0 |
| TC-AUT-ALL-020 | installed type client | client_secret.json has "installed" key | Call createOAuth2Client() | Client created with installed credentials | P1 |
| TC-AUT-ALL-021 | web type client | client_secret.json has "web" key | Call createOAuth2Client() | Client created with web credentials | P2 |
| TC-AUT-ALL-022 | Security event logging | - | Trigger each security event | JSON format log on stderr (timestamp, event_type, result, detail) | P1 |

#### 4.2.2 Gmail Tools

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-GML-ALL-001 | gmail_search: basic search | Authentication completed | query="from:test@example.com", maxResults=5 | messages array returned with id/from/subject/date/snippet | P0 |
| TC-GML-ALL-002 | gmail_search: empty results | Authentication completed | Non-existent search query | total=0, messages=[] | P1 |
| TC-GML-ALL-003 | gmail_read: full read | Authentication completed, message ID obtained | Call with messageId | Returns id, from, to, cc, subject, date, body, attachments, labels | P0 |
| TC-GML-ALL-004 | gmail_read: MIME parsing | Multipart email exists | Call with messageId | text/plain extracted via extractTextBody(), text/html fallback | P1 |
| TC-GML-ALL-005 | gmail_read: attachment list | Email with attachments | Call with messageId | Returns filename, mimeType, attachmentId, size via extractAttachments() | P1 |
| TC-GML-ALL-006 | gmail_read: body 5000 char limit | Long body email | Call with messageId | body truncated to 5000 characters | P2 |
| TC-GML-ALL-007 | gmail_send: send email | Authentication completed | Set to, subject, body | success=true, messageId returned | P0 |
| TC-GML-ALL-008 | gmail_send: CC/BCC | Authentication completed | Send with cc, bcc included | Email sent with CC/BCC headers | P1 |
| TC-GML-ALL-009 | gmail_send: UTF-8 subject | Authentication completed | Send with Korean subject | Subject: =?UTF-8?B?...?= Base64 encoded | P1 |
| TC-GML-ALL-010 | gmail_send: header injection prevention | Authentication completed | to="victim@test.com\r\nBcc: spy@evil.com" | CRLF removed via sanitizeEmailHeader(), spy@evil.com not sent | P0 |
| TC-GML-ALL-011 | gmail_draft_create | Authentication completed | Set to, subject, body | draftId returned, "Draft saved" message | P1 |
| TC-GML-ALL-012 | gmail_draft_list | Drafts exist in draft folder | Call with maxResults=5 | total, drafts array (draftId, to, subject, snippet) | P1 |
| TC-GML-ALL-013 | gmail_draft_send | Draft exists | Call with draftId | success=true, messageId returned | P1 |
| TC-GML-ALL-014 | gmail_draft_delete | Draft exists | Call with draftId | success=true, "Draft deleted" message | P2 |
| TC-GML-ALL-015 | gmail_labels_list | Authentication completed | Call | labels array (id, name, type) | P1 |
| TC-GML-ALL-016 | gmail_labels_add | Message and label exist | Set messageId, labelIds | "Label added" message | P2 |
| TC-GML-ALL-017 | gmail_labels_remove | Message with label applied | Set messageId, labelIds | "Label removed" message | P2 |
| TC-GML-ALL-018 | gmail_attachment_get | Message with attachments | Set messageId, attachmentId | Returns size, data (base64) | P1 |
| TC-GML-ALL-019 | gmail_trash | Message exists | Call with messageId | "Email moved to trash" message | P1 |
| TC-GML-ALL-020 | gmail_untrash | Trashed message exists | Call with messageId | "Email restored from trash" message | P2 |
| TC-GML-ALL-021 | gmail_mark_read | Unread message | Call with messageId | UNREAD label removed | P1 |
| TC-GML-ALL-022 | gmail_mark_unread | Read message | Call with messageId | UNREAD label added | P2 |

#### 4.2.3 Drive Tools

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-DRV-ALL-001 | drive_search: basic search | Authentication completed | query="test", maxResults=10 | files array, supportsAllDrives=true used | P0 |
| TC-DRV-ALL-002 | drive_search: MIME filter | Authentication completed | mimeType="application/pdf" | Only PDFs returned | P1 |
| TC-DRV-ALL-003 | drive_search: query escape | Authentication completed | query="test's file" | `'` escaped via escapeDriveQuery() | P0 |
| TC-DRV-ALL-004 | drive_list: root listing | Authentication completed | folderId="root" | Root folder file list with isFolder field | P0 |
| TC-DRV-ALL-005 | drive_list: ID validation | Authentication completed | folderId="invalid!@#" | validateDriveId() error: "Invalid folderId format" | P0 |
| TC-DRV-ALL-006 | drive_get_file | File exists | Call with fileId | Detailed info (id, name, type, owners, shared, etc.) | P1 |
| TC-DRV-ALL-007 | drive_create_folder | Authentication completed | name="Test Folder" | Returns folderId, name, link | P1 |
| TC-DRV-ALL-008 | drive_create_folder: parent specified | Parent folder exists | Set name, parentId | Created within specified folder | P2 |
| TC-DRV-ALL-009 | drive_copy | File exists | Set fileId, newName | Copy created, new fileId returned | P1 |
| TC-DRV-ALL-010 | drive_move | File and target folder exist | Set fileId, newParentId | previousParents removed, newParentId added | P1 |
| TC-DRV-ALL-011 | drive_rename | File exists | Set fileId, newName | Name change confirmed | P2 |
| TC-DRV-ALL-012 | drive_delete | File exists | Call with fileId | trashed=true set, "File moved to trash" | P1 |
| TC-DRV-ALL-013 | drive_restore | Trashed file exists | Call with fileId | trashed=false set, "File restored" | P2 |
| TC-DRV-ALL-014 | drive_share | File exists | Set fileId, email, role="writer" | Permission created, "Shared with email as editor" | P1 |
| TC-DRV-ALL-015 | drive_share_link | File exists | Set fileId, type="anyone" | Link sharing enabled, webViewLink returned | P1 |
| TC-DRV-ALL-016 | drive_unshare | Shared file | Set fileId, email | Permission removed, "Sharing removed" | P2 |
| TC-DRV-ALL-017 | drive_unshare: permission not found | Unshared file | Non-existent email | success=false, "No sharing permission found" | P2 |
| TC-DRV-ALL-018 | drive_list_permissions | Shared file | Call with fileId | permissions array (id, type, role, email, name) | P2 |
| TC-DRV-ALL-019 | drive_get_storage_quota | Authentication completed | Call | limit, usage, usageInDrive, usageInDriveTrash (in GB) | P2 |
| TC-DRV-ALL-020 | Shared Drive support | Shared Drive exists | corpora="allDrives" in all Drive tools | Shared Drive files included | P1 |

#### 4.2.4 Calendar Tools

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-CAL-ALL-001 | calendar_list_calendars | Authentication completed | Call | calendars array (id, name, primary, accessRole) | P0 |
| TC-CAL-ALL-002 | calendar_list_events: basic | Authentication completed | calendarId="primary" | Event list from now to 30 days ahead | P0 |
| TC-CAL-ALL-003 | calendar_list_events: range specified | Authentication completed | Set timeMin, timeMax | Only events within specified range returned | P1 |
| TC-CAL-ALL-004 | calendar_get_event | Event exists | Call with eventId | Detailed info (recurrence, reminders, conferenceData included) | P1 |
| TC-CAL-ALL-005 | calendar_create_event | Authentication completed | Set title, startTime, endTime | Returns eventId, link, dynamic timezone applied | P0 |
| TC-CAL-ALL-006 | calendar_create_event: attendees | Authentication completed | Include attendees array | Notifications sent to attendees (sendUpdates="all") | P1 |
| TC-CAL-ALL-007 | calendar_create_event: time parsing | Authentication completed | startTime="2026-03-01 10:00" | Converted to ISO 8601 + UTC offset via parseTime() | P1 |
| TC-CAL-ALL-008 | calendar_create_all_day_event | Authentication completed | date="2026-03-01" | All-day event created, date field used | P1 |
| TC-CAL-ALL-009 | calendar_update_event | Event exists | Set eventId, fields to modify | Existing values preserved + modified values applied | P1 |
| TC-CAL-ALL-010 | calendar_delete_event | Event exists | Set eventId, sendNotifications=true | Event deleted, attendees notified | P1 |
| TC-CAL-ALL-011 | calendar_quick_add | Authentication completed | text="Meeting tomorrow at 3pm" | Event created via natural language parsing | P2 |
| TC-CAL-ALL-012 | calendar_find_free_time | Authentication completed | Set timeMin, timeMax | freebusy info returned | P2 |
| TC-CAL-ALL-013 | calendar_respond_to_event | Invited event exists | response="accepted" | Own responseStatus changed | P2 |
| TC-CAL-ALL-014 | Dynamic timezone: env variable | TIMEZONE="America/New_York" | Call calendar_create_event | America/New_York timezone applied | P1 |
| TC-CAL-ALL-015 | Dynamic timezone: auto-detect | TIMEZONE not set | Call getTimezone() | Returns Intl.DateTimeFormat().resolvedOptions().timeZone | P1 |

#### 4.2.5 Docs Tools

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-DOC-ALL-001 | docs_create: empty document | Authentication completed | Set title only | Returns documentId, title, link | P0 |
| TC-DOC-ALL-002 | docs_create: with content | Authentication completed | Set title, content | Document created then text inserted via batchUpdate | P1 |
| TC-DOC-ALL-003 | docs_create: folder specified | Target folder exists | Set folderId | Moved to specified folder | P2 |
| TC-DOC-ALL-004 | docs_read | Document exists | Call with documentId | Returns content (10000 char limit), title, revisionId | P0 |
| TC-DOC-ALL-005 | docs_read: with table | Document with table | Call with documentId | Table displayed as "[table]" text | P2 |
| TC-DOC-ALL-006 | docs_append | Document exists | Set documentId, content | "\n" + content inserted at end of document | P1 |
| TC-DOC-ALL-007 | docs_prepend | Document exists | Set documentId, content | content + "\n" inserted at document start (index 1) | P1 |
| TC-DOC-ALL-008 | docs_replace_text | Document exists | Set searchText, replaceText | Returns occurrencesChanged | P1 |
| TC-DOC-ALL-009 | docs_replace_text: case sensitive | Document exists | matchCase=true | Case-sensitive search | P2 |
| TC-DOC-ALL-010 | docs_insert_heading | Document exists | Set text, level=2 | HEADING_2 style applied | P2 |
| TC-DOC-ALL-011 | docs_insert_table | Document exists | Set rows=3, columns=4 | 3x4 table inserted | P2 |
| TC-DOC-ALL-012 | docs_get_comments | Document exists | Call with documentId | comments array (id, content, author, resolved, replies) | P2 |
| TC-DOC-ALL-013 | docs_add_comment | Document exists | Set content | Returns commentId | P2 |

#### 4.2.6 Sheets Tools

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-SHT-ALL-001 | sheets_create | Authentication completed | Set title | Returns spreadsheetId, link, sheets | P0 |
| TC-SHT-ALL-002 | sheets_create: sheet names specified | Authentication completed | sheetNames=["Data","Summary"] | Spreadsheet created with 2 sheets | P1 |
| TC-SHT-ALL-003 | sheets_get_info | Spreadsheet exists | Call with spreadsheetId | title, sheets (sheetId, title, rowCount, columnCount) | P1 |
| TC-SHT-ALL-004 | sheets_read | Data exists | spreadsheetId, range="Sheet1!A1:D10" | values 2D array, rowCount, columnCount | P0 |
| TC-SHT-ALL-005 | sheets_read_multiple | Data exists | ranges=["A1:B5","C1:D5"] | valueRanges array | P2 |
| TC-SHT-ALL-006 | sheets_write | Spreadsheet exists | Set range, values | Returns updatedCells, updatedRows | P0 |
| TC-SHT-ALL-007 | sheets_append | Data exists | range="Sheet1", set values | Rows added via INSERT_ROWS, returns updatedRows | P1 |
| TC-SHT-ALL-008 | sheets_clear | Data exists | Set range | Range data deleted | P1 |
| TC-SHT-ALL-009 | sheets_add_sheet | Spreadsheet exists | Set title | Returns sheetId, title | P1 |
| TC-SHT-ALL-010 | sheets_delete_sheet | 2+ sheets exist | Set sheetId | Sheet deletion completed | P2 |
| TC-SHT-ALL-011 | sheets_rename_sheet | Sheet exists | Set sheetId, newTitle | Rename completed | P2 |
| TC-SHT-ALL-012 | sheets_format_cells: bold | Sheet exists | Set bold=true, range | textFormat.bold applied | P2 |
| TC-SHT-ALL-013 | sheets_format_cells: background color | Sheet exists | backgroundColor="#FF0000" | RGB conversion (1,0,0) applied | P2 |
| TC-SHT-ALL-014 | sheets_auto_resize | Sheet exists | Set sheetId | COLUMNS dimension auto-resized | P3 |

#### 4.2.7 Slides Tools

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-SLD-ALL-001 | slides_create | Authentication completed | Set title | Returns presentationId, link, slideCount | P0 |
| TC-SLD-ALL-002 | slides_create: folder specified | Target folder exists | Set folderId | Moved to specified folder | P2 |
| TC-SLD-ALL-003 | slides_get_info | Presentation exists | Call with presentationId | title, slideCount, pageSize, slides array | P1 |
| TC-SLD-ALL-004 | slides_read | Presentation exists | Call with presentationId | Text extracted per slide (1000 char limit) | P0 |
| TC-SLD-ALL-005 | slides_add_slide: title+body | Presentation exists | title, body, layout="TITLE_AND_BODY" | Slide created + text inserted in TITLE/BODY placeholders | P1 |
| TC-SLD-ALL-006 | slides_add_slide: blank slide | Presentation exists | layout="BLANK" | Blank slide created | P2 |
| TC-SLD-ALL-007 | slides_delete_slide | Slide exists | Set slideId | Slide deleted | P2 |
| TC-SLD-ALL-008 | slides_duplicate_slide | Slide exists | Set slideId | Duplicate created, newSlideId returned | P2 |
| TC-SLD-ALL-009 | slides_move_slide | 2+ slides exist | Set slideId, insertionIndex=0 | Slide position changed | P2 |
| TC-SLD-ALL-010 | slides_add_text | Slide exists | Set slideId, text, coordinates | Text box created + text inserted | P1 |
| TC-SLD-ALL-011 | slides_replace_text | Presentation with text | Set searchText, replaceText | Returns occurrencesChanged | P2 |

### 4.3 Per-Module Functional Tests

#### 4.3.1 Atlassian MCP

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-ATL-ALL-001 | Docker mode selection | Docker installed + running | Select 1 (Local install) in role selection | Docker image pull + MCP config registration | P0 |
| TC-ATL-ALL-002 | Rovo mode selection | Docker not installed | Select 1 (Simple install) in role selection | `claude mcp add --transport sse` executed | P0 |
| TC-ATL-ALL-003 | Docker mode: credential storage | Docker installed | Enter URL, email, apiToken | `~/.atlassian-mcp/credentials.env` created (permissions 600) | P0 |
| TC-ATL-ALL-004 | Docker mode: directory permissions | Docker installed | credentials.env saved | `~/.atlassian-mcp/` directory permissions 700 | P1 |
| TC-ATL-ALL-005 | Docker mode: MCP config | Docker mode completed | Check MCP config file | Credentials passed via --env-file, no inline env vars | P0 |
| TC-ATL-ALL-006 | URL normalization | Docker mode | Enter URL with trailing "/" | Trailing "/" removed | P2 |
| TC-ATL-ALL-007 | Docker mode without Docker | Docker not installed | Force select Docker mode | "Docker is not installed!" error, installation guide URL | P1 |

#### 4.3.2 Figma MCP

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-FIG-ALL-001 | Claude CLI check | claude not installed | Run figma module | "Claude CLI is required" error, exit 1 | P0 |
| TC-FIG-ALL-002 | Python3 check | python3 not installed | Run figma module | "Python 3 is required for OAuth" error, exit 1 | P0 |
| TC-FIG-ALL-003 | Remote MCP registration | claude, python3 installed | Run figma module | `claude mcp add --transport http figma https://mcp.figma.com/mcp` executed | P0 |
| TC-FIG-ALL-004 | OAuth PKCE flow | MCP registration completed | Run mcp_oauth_flow | PKCE code_verifier/code_challenge generated, browser OAuth | P1 |
| TC-FIG-ALL-005 | OAuth metadata acquisition | Internet connected | Call well-known URL | authorization_endpoint, token_endpoint parsed | P1 |
| TC-FIG-ALL-006 | Token storage | OAuth completed | Call _save_tokens | mcpOAuth entry saved in `~/.claude/.credentials.json` | P1 |
| TC-FIG-ALL-007 | Existing auth reuse | Valid token exists | Re-run figma module | "Already authenticated with figma!" message, OAuth skipped | P2 |
| TC-FIG-ALL-008 | OAuth state mismatch | OAuth in progress | Callback with incorrect state | "State mismatch" error | P1 |

#### 4.3.3 Notion MCP

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-NOT-ALL-001 | Claude CLI check | claude not installed | Run notion module | "Claude CLI is required" error | P0 |
| TC-NOT-ALL-002 | Python3 check | python3 not installed | Run notion module | "Python 3 is required" error | P0 |
| TC-NOT-ALL-003 | Remote MCP registration | Preconditions met | Run notion module | `claude mcp add --transport http notion https://mcp.notion.com/mcp` | P0 |
| TC-NOT-ALL-004 | OAuth PKCE flow | MCP registration completed | Run mcp_oauth_flow | Notion OAuth completed, token saved | P1 |

#### 4.3.4 GitHub CLI

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-GIT-MAC-001 | gh install (macOS) | Homebrew exists, gh not installed | Run github module | `brew install gh` | P0 |
| TC-GIT-LNX-001 | gh install (Ubuntu) | apt available, gh not installed | Run github module | GPG key added + apt install | P0 |
| TC-GIT-LNX-002 | gh install (Fedora) | dnf available, gh not installed | Run github module | `sudo dnf install gh -y` | P1 |
| TC-GIT-ALL-001 | gh authentication | gh installed, not authenticated | Run github module | `gh auth login --hostname github.com --git-protocol https --web` | P0 |
| TC-GIT-ALL-002 | gh already authenticated | gh auth status succeeds | Run github module | "Already logged in." message, auth skipped | P1 |
| TC-GIT-ALL-003 | gh auth failure | Auth cancelled | Run github module | "Authentication failed" error, exit 1 | P1 |
| TC-GIT-ALL-004 | No MCP config verification | Installation completed | Check MCP config | No MCP config (gh used directly via Bash tool) | P2 |

#### 4.3.5 Pencil

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-PEN-ALL-001 | IDE not detected | VS Code/Cursor both not installed | Run pencil module | "VS Code or Cursor is required" error, exit 1 | P0 |
| TC-PEN-ALL-002 | VS Code extension install | VS Code installed | Run pencil module | `code --install-extension highagency.pencildev` | P0 |
| TC-PEN-ALL-003 | Cursor extension install | Cursor installed | Run pencil module | `cursor --install-extension highagency.pencildev` | P1 |
| TC-PEN-ALL-004 | Both IDEs installed | VS Code + Cursor | Run pencil module | Extension installed in both | P2 |
| TC-PEN-MAC-001 | Desktop app instructions | macOS | Run pencil module | "Download from: https://www.pencil.dev/downloads" instructions | P3 |

---

## 5. User Scenario Tests

### 5.1 Fresh Installation Scenarios

| ID | Scenario | Preconditions | Test Procedure | Expected Result | Priority |
|----|----------|---------------|----------------|-----------------|----------|
| TC-E2E-MAC-001 | macOS clean install (full) | macOS Sonoma, no dev tools | 1. Run `curl -sSL .../install.sh \| bash -s -- --all` 2. Respond to each module prompt 3. Complete Google OAuth 4. Enter Atlassian credentials | Homebrew -> Node.js -> Git -> VS Code -> Docker -> Claude -> bkit -> all modules installed in order, servers registered in ~/.claude/mcp.json | P0 |
| TC-E2E-WIN-001 | Windows clean install (full) | Windows 11, no dev tools | 1. Run install.ps1 remotely in PowerShell (Step 1: -installDocker) 2. Start Docker Desktop 3. Re-run install.ps1 (Step 2: -modules "google" -skipBase) | UAC prompt -> Node.js, Git, VS Code, WSL2, Docker installed -> Google MCP installed after Docker starts | P0 |
| TC-E2E-LNX-001 | Ubuntu clean install (full) | Ubuntu 24.04, minimal install | 1. Run `curl -sSL .../install.sh \| bash -s -- --all` 2. Enter sudo password 3. Respond to each module prompt | NodeSource -> Node.js -> Git -> VS Code(snap) -> Docker -> Claude -> bkit -> module installation | P0 |
| TC-E2E-WSL-001 | WSL2 clean install | WSL2 Ubuntu, minimal install | 1. Run install.sh locally 2. Verify Windows browser is used when opening browser | Opens browser via cmd.exe/powershell.exe, Docker uses Windows host Docker | P1 |

### 5.2 Update/Additional Installation Scenarios

| ID | Scenario | Preconditions | Test Procedure | Expected Result | Priority |
|----|---------|---------|------------|-----------|---------|
| TC-E2E-ALL-010 | Additional module install | Base + Google installed | `./install.sh --modules "atlassian,github" --skip-base` | Base skipped, only Atlassian and GitHub installed, existing MCP config preserved | P0 |
| TC-E2E-ALL-011 | Reinstall already installed module | Google module installed | `./install.sh --modules "google" --skip-base` | Docker image re-pulled, MCP config overwritten, OAuth re-authentication | P1 |
| TC-E2E-ALL-012 | Base tools update | Previous Node.js version | `./install.sh --modules "google"` (Base not auto-skipped) | Node.js version updated, no impact on existing modules | P2 |

### 5.3 Migration Scenarios

| ID | Scenario | Preconditions | Test Procedure | Expected Result | Priority |
|----|---------|---------|------------|-----------|---------|
| TC-E2E-ALL-020 | Legacy MCP config migration | ~/.mcp.json exists, ~/.claude/mcp.json absent | Run module installation | ~/.mcp.json copied to ~/.claude/mcp.json, new path used thereafter | P0 |
| TC-E2E-ALL-021 | Both config files exist | Both ~/.mcp.json and ~/.claude/mcp.json exist | Run module installation | Only ~/.claude/mcp.json used, legacy file ignored | P1 |
| TC-E2E-WIN-020 | Windows MCP path migration | %USERPROFILE%\.mcp.json exists | Run install.ps1 | Migrated to %USERPROFILE%\.claude\mcp.json | P1 |

### 5.4 Error Recovery Scenarios

| ID | Scenario | Preconditions | Test Procedure | Expected Result | Priority |
|----|---------|---------|------------|-----------|---------|
| TC-E2E-ALL-030 | Installation during network disconnection | Internet disconnected | Attempt remote execution of install.sh | curl failure, appropriate error message | P1 |
| TC-E2E-ALL-031 | Docker image pull failure | Docker running, ghcr.io inaccessible | Run Google module | docker pull failure error, installation aborted | P1 |
| TC-E2E-ALL-032 | OAuth timeout | Google module running, login not completed | Wait 5 minutes | "Auth timed out after 300s" message, container cleanup | P1 |
| TC-E2E-ALL-033 | Retry after module failure | Google module failed in previous installation | Re-run same command | MCP config restored from backup, reinstallation succeeds | P0 |
| TC-E2E-ALL-034 | Partial installation state recovery | Failed at 2nd of 3 modules | Retry from 3rd module | Can continue with `--skip-base --modules "third_module"` | P1 |
| TC-E2E-ALL-035 | client_secret.json not provided | Google module running, file absent | Press Enter at client_secret.json prompt | "client_secret.json not found" error, exit 1 | P1 |
| TC-E2E-ALL-036 | Port conflict | OAuth port (3000) in use | Run Google module OAuth | Conflict avoided via dynamic port allocation (python3 socket.bind) | P1 |

### 5.5 Daily Work Scenarios

| ID | Scenario | Preconditions | Test Procedure | Expected Result | Priority |
|----|---------|---------|------------|-----------|---------|
| TC-E2E-ALL-040 | Email search and read | MCP server running | 1. gmail_search "from:boss" 2. gmail_read (first result ID) | Email list displayed -> body content displayed | P0 |
| TC-E2E-ALL-041 | Email compose and send | MCP server running | 1. gmail_send (to, subject, body) 2. Verify with gmail_search | Email sent successfully, confirmed in sent folder | P0 |
| TC-E2E-ALL-042 | Event creation and listing | MCP server running | 1. calendar_create_event (title, time) 2. calendar_list_events | Event created -> confirmed in list | P0 |
| TC-E2E-ALL-043 | File search and share | MCP server running, Drive files exist | 1. drive_search "report" 2. drive_share (email, role) | File found -> sharing configured | P0 |
| TC-E2E-ALL-044 | Document creation and editing | MCP server running | 1. docs_create (title, content) 2. docs_append 3. docs_read | Document created -> content appended -> full content verified | P1 |
| TC-E2E-ALL-045 | Spreadsheet data entry | MCP server running | 1. sheets_create 2. sheets_write 3. sheets_read | Sheet created -> data entered -> read verified | P1 |
| TC-E2E-ALL-046 | Presentation creation | MCP server running | 1. slides_create 2. slides_add_slide (x3) 3. slides_read | Presentation created -> slides added -> content verified | P1 |
| TC-E2E-ALL-047 | Composite workflow | MCP server running | 1. gmail_search 2. docs_create (based on email content) 3. drive_share | Email -> documentation -> sharing pipeline | P2 |

### 5.6 Advanced Usage Scenarios

| ID | Scenario | Preconditions | Test Procedure | Expected Result | Priority |
|----|---------|---------|------------|-----------|---------|
| TC-E2E-ALL-050 | Restricted scope usage | GOOGLE_SCOPES="gmail,calendar" set | Call drive_search after starting MCP server | Drive API insufficient permissions error | P2 |
| TC-E2E-ALL-051 | Timezone change usage | TIMEZONE="UTC" set | Call calendar_create_event | Event created with UTC-based time | P2 |
| TC-E2E-ALL-052 | Docker volume persistence | Container restart | 1. OAuth authentication 2. Stop/restart container 3. API call | token.json persisted in volume, no re-authentication needed | P1 |
| TC-E2E-ALL-053 | Concurrent MCP sessions | 2 Claude sessions | Call Gmail API simultaneously | Mutex prevents auth conflicts, both sessions respond normally | P2 |

---

## 6. Cross-Platform Compatibility Tests

### 6.1 OS Version Compatibility Matrix

#### 6.1.1 Installer Compatibility

| Feature | macOS 13 | macOS 14 | macOS 15 | Win10 21H2 | Win10 22H2 | Win11 23H2 | Ubuntu 22.04 | Ubuntu 24.04 | Fedora 39 | Arch |
|------|:--------:|:--------:|:--------:|:----------:|:----------:|:----------:|:------------:|:------------:|:---------:|:----:|
| Base module | O | O | O | O | O | O | O | O | O | O |
| Google module | O* | O | O | O | O | O | O | O | O | O |
| Atlassian (Docker) | O* | O | O | O | O | O | O | O | O | O |
| Atlassian (Rovo) | O | O | O | O | O | O | O | O | O | O |
| Figma module | O | O | O | - | - | - | O | O | O | O |
| Notion module | O | O | O | - | - | - | O | O | O | O |
| GitHub module | O | O | O | - | - | - | O | O | O | - |
| Pencil module | O | O | O | - | - | - | O | O | - | - |

*O = Supported, O* = Docker Desktop version caveat (4.41 or lower recommended), - = No Windows PowerShell version (Bash only)*

#### 6.1.2 MCP Server Compatibility (Docker-based)

| Feature | Docker Desktop macOS | Docker Desktop Win (WSL2) | Docker Engine Linux |
|------|:-------------------:|:------------------------:|:------------------:|
| Image build | O | O | O |
| Container execution | O | O | O |
| Volume mount | O | O | O |
| Port mapping | O | O | O |
| HEALTHCHECK | O | O | O |
| Non-root user | O | O | O |
| stdio communication | O | O | O |

### 6.2 Package Manager Tests

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-------------|---------|------------|-----------|---------|
| TC-SHR-ALL-001 | pkg_detect_manager: brew | macOS | Call pkg_detect_manager() | Returns "brew" | P1 |
| TC-SHR-ALL-002 | pkg_detect_manager: apt | Ubuntu/Debian | Call pkg_detect_manager() | Returns "apt" | P1 |
| TC-SHR-ALL-003 | pkg_detect_manager: dnf | Fedora/RHEL | Call pkg_detect_manager() | Returns "dnf" | P1 |
| TC-SHR-ALL-004 | pkg_detect_manager: yum | CentOS | Call pkg_detect_manager() | Returns "yum" | P2 |
| TC-SHR-ALL-005 | pkg_detect_manager: pacman | Arch | Call pkg_detect_manager() | Returns "pacman" | P2 |
| TC-SHR-ALL-006 | pkg_detect_manager: none | Unsupported OS | Call pkg_detect_manager() | Returns "none" | P3 |
| TC-SHR-ALL-007 | pkg_install: brew | macOS | pkg_install "jq" | `brew install jq` executed | P1 |
| TC-SHR-ALL-008 | pkg_install: apt | Ubuntu | pkg_install "jq" | `sudo apt-get install -y jq` executed | P1 |
| TC-SHR-ALL-009 | pkg_ensure_installed: already installed | jq installed | pkg_ensure_installed "jq" | "jq is already installed" message | P2 |
| TC-SHR-ALL-010 | pkg_install_cask: macOS | macOS | pkg_install_cask "docker" | `brew install --cask docker` | P2 |

### 6.3 Shell Environment Tests

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-------------|---------|------------|-----------|---------|
| TC-SHR-ALL-020 | Bash 4.x compatibility | Bash 4.x | Run install.sh | declare -a arrays work correctly | P1 |
| TC-SHR-ALL-021 | Bash 5.x compatibility | Bash 5.x | Run install.sh | All features work correctly | P0 |
| TC-SHR-ALL-022 | Zsh compatibility | macOS default Zsh | source install.sh | Note: install.sh specifies #!/bin/bash, uses bash when run directly | P2 |
| TC-SHR-WIN-001 | PowerShell 5.1 compatibility | Windows 10 default | Run install.ps1 | ConvertFrom-Json, irm work correctly | P0 |
| TC-SHR-WIN-002 | PowerShell 7.x compatibility | PS7 installed | Run install.ps1 | All features work correctly | P1 |
| TC-SHR-WIN-003 | ExecutionPolicy Restricted | Default policy | Attempt to run install.ps1 | Execution blocked, Bypass instructions needed | P1 |

### 6.4 Docker Desktop Compatibility

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-------------|---------|------------|-----------|---------|
| TC-DOK-ALL-001 | Docker Desktop 4.41 + macOS 13 | Ventura + DD 4.41 | Call docker_check_compatibility() | Passes without warnings | P1 |
| TC-DOK-ALL-002 | Docker Desktop 4.42+ + macOS 13 | Ventura + DD 4.42+ | Call docker_check_compatibility() | "Docker Desktop may not support macOS" warning | P1 |
| TC-DOK-ALL-003 | Docker Desktop 4.42+ + macOS 14+ | Sonoma + DD 4.42+ | Call docker_check_compatibility() | Passes without warnings | P0 |
| TC-DOK-ALL-004 | Docker not installed diagnosis | Docker absent | Call docker_get_status() | Returns "not_installed" | P1 |
| TC-DOK-ALL-005 | Docker not running diagnosis | Docker present + not running | Call docker_get_status() | Returns "not_running" | P1 |
| TC-DOK-ALL-006 | Docker startup wait | Docker starting up | docker_wait_for_start 60 | Returns 0 if docker info succeeds within 60 seconds | P2 |
| TC-DOK-ALL-007 | Container cleanup | Previous Google MCP container running | Call docker_cleanup_container | Existing container stopped + removed | P2 |

---

## 7. Security Tests

### 7.1 OWASP Top 10 Verification

#### 7.1.1 A01: Broken Access Control

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-------------|---------|------------|-----------|---------|
| TC-SEC-ALL-001 | Token file permissions | token.json exists | `stat -c %a token.json` (Linux) or `stat -f %Lp` (macOS) | File permissions 0600 (owner read/write only) | P0 |
| TC-SEC-ALL-002 | Config directory permissions | .google-workspace/ exists | Check directory permissions | Directory permissions 0700 (owner access only) | P0 |
| TC-SEC-ALL-003 | MCP config file permissions | ~/.claude/mcp.json exists | Check file permissions | File permissions 0600 | P0 |
| TC-SEC-ALL-004 | Atlassian credentials file permissions | ~/.atlassian-mcp/ exists | Check file/directory permissions | Directory 700, credentials.env 600 | P0 |
| TC-SEC-ALL-005 | Docker non-root execution | Google MCP container | `docker exec <id> id -u` | UID != 0 (non-root mcp user) | P0 |
| TC-SEC-ALL-006 | Automatic permission recovery | token.json permissions changed to 0644 | Call saveToken() | Restored to 0600 via chmodSync, security event logged | P1 |

#### 7.1.2 A02: Cryptographic Failures

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-------------|---------|------------|-----------|---------|
| TC-SEC-ALL-010 | OAuth state entropy | - | Repeat state generation (100 times) | 32 bytes (64 hex chars) random, no collisions | P0 |
| TC-SEC-ALL-011 | PKCE code_verifier entropy | - | Generate code_verifier | openssl rand -base64 32, base64url encoded | P1 |
| TC-SEC-ALL-012 | PKCE code_challenge | code_verifier exists | Verify SHA-256 hash | S256 method correctly implemented | P1 |
| TC-SEC-ALL-013 | SHA-256 checksum integrity | Remote installation | Download valid file and verify | shasum/sha256sum match | P0 |
| TC-SEC-ALL-014 | SHA-256 tamper detection | Remote installation | Tamper 1 byte in file | "[SECURITY] Integrity verification failed!" | P0 |

#### 7.1.3 A03: Injection

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-------------|---------|------------|-----------|---------|
| TC-SEC-ALL-020 | Drive query injection prevention | Authentication completed | drive_search query="' OR 1=1 --" | `'` escaped via escapeDriveQuery(), query injection fails | P0 |
| TC-SEC-ALL-021 | Drive query backslash escaping | Authentication completed | drive_search query="test\\injection" | Backslash double-escaped | P1 |
| TC-SEC-ALL-022 | Drive ID injection prevention | Authentication completed | drive_list folderId="1234' OR name='hack" | validateDriveId() pattern [a-zA-Z0-9_-] mismatch, error | P0 |
| TC-SEC-ALL-023 | Gmail header injection prevention | Authentication completed | gmail_send to="a@b.com\r\nBcc: spy@c.com" | CR/LF removed via sanitizeEmailHeader() | P0 |
| TC-SEC-ALL-024 | JSON parsing injection prevention | Remote installation | module.json contains shell metacharacters | stdin-based parsing prevents shell interpolation | P0 |
| TC-SEC-ALL-025 | Atlassian credential injection prevention | Docker mode | API token contains shell special characters | Passed via --env-file without shell expansion | P0 |

#### 7.1.4 A04: Insecure Design (Not Applicable - Design-Level Verification)

This item has been verified during the design document review phase and is not covered in code-level testing.

#### 7.1.5 A05: Security Misconfiguration

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-------------|---------|------------|-----------|---------|
| TC-SEC-ALL-030 | npm ci (deterministic build) | Dockerfile | Docker build | Uses `npm ci` (not npm install) | P1 |
| TC-SEC-ALL-031 | Production dependencies only | Dockerfile production stage | Inspect image | `npm ci --omit=dev`, devDependencies not included | P1 |
| TC-SEC-ALL-032 | NODE_ENV=production | Production image | Check environment variable | NODE_ENV=production is set | P1 |

#### 7.1.6 A06: Vulnerable Components

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-------------|---------|------------|-----------|---------|
| TC-SEC-ALL-040 | npm audit | google-workspace-mcp/ | `npm audit --audit-level=high` | 0 high/critical vulnerabilities | P0 |
| TC-SEC-ALL-041 | Node.js 22 usage | Verify Dockerfile | Verify `FROM node:22-slim` | Migration completed before Node.js 20 EOL (2026-04-30) | P1 |
| TC-SEC-ALL-042 | Dependency version pinning | package.json | Verify major dependencies | @modelcontextprotocol/sdk ^1.0, googleapis ^140.0, zod ^3.22 | P2 |

#### 7.1.7 A07: Authentication Failures

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-------------|---------|------------|-----------|---------|
| TC-SEC-ALL-050 | refresh_token required validation | token.json has no refresh_token | Call loadToken() | Returns null, triggers re-authentication | P0 |
| TC-SEC-ALL-051 | Token expiry buffer | expiry_date is now + 3 minutes | getAuthenticatedClient() | Pre-emptive refresh with 5-minute buffer | P1 |
| TC-SEC-ALL-052 | access_type=offline | Generate OAuth URL | Verify authUrl | Includes access_type=offline, prompt=consent | P1 |

#### 7.1.8 A08: Software and Data Integrity

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-------------|---------|------------|-----------|---------|
| TC-SEC-ALL-060 | checksums.json integrity | CI environment | Re-run `generate-checksums.sh` and diff | Matches checksums.json | P0 |
| TC-SEC-ALL-061 | Remote script verification | Remote installation | Verify all files via download_and_verify | All files match SHA-256 | P0 |

### 7.2 Authentication/Authorization Tests

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-------------|---------|------------|-----------|---------|
| TC-SEC-ALL-070 | OAuth CSRF prevention | OAuth flow in progress | Callback with incorrect state | 403 response, "CSRF attack" logged | P0 |
| TC-SEC-ALL-071 | PKCE code exchange | OAuth flow in progress | Token exchange without code_verifier | Token exchange fails | P1 |
| TC-SEC-ALL-072 | Concurrent authentication mutex | - | Call getAuthenticatedClient() 3 times concurrently | Only the first actually executes, rest wait | P1 |
| TC-SEC-ALL-073 | Security event log format | Authentication event triggered | Check stderr output | `[SECURITY] {"timestamp":"...","event_type":"...","result":"..."}` | P2 |

### 7.3 Input Validation Tests

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-------------|---------|------------|-----------|---------|
| TC-SEC-ALL-080 | escapeDriveQuery: single quote | - | escapeDriveQuery("test's") | Returns "test\\'s" | P0 |
| TC-SEC-ALL-081 | escapeDriveQuery: backslash | - | escapeDriveQuery("test\\path") | Returns "test\\\\path" | P0 |
| TC-SEC-ALL-082 | validateDriveId: valid ID | - | validateDriveId("abc123_-XYZ") | No error | P0 |
| TC-SEC-ALL-083 | validateDriveId: "root" allowed | - | validateDriveId("root") | No error | P1 |
| TC-SEC-ALL-084 | validateDriveId: special characters | - | validateDriveId("id!@#$%") | Error raised | P0 |
| TC-SEC-ALL-085 | sanitizeEmailHeader: CRLF | - | sanitizeEmailHeader("a@b.com\r\nBcc: spy") | "a@b.comBcc: spy" (newlines removed) | P0 |
| TC-SEC-ALL-086 | validateEmail: valid | - | validateEmail("user@example.com") | true | P1 |
| TC-SEC-ALL-087 | validateEmail: length exceeded | - | validateEmail("a".repeat(255) + "@b.com") | false (exceeds 254 characters) | P2 |
| TC-SEC-ALL-088 | sanitizeFilename: path traversal | - | sanitizeFilename("../../../etc/passwd") | "_.._.._.._etc_passwd" (dangerous characters replaced) | P1 |
| TC-SEC-ALL-089 | sanitizeFilename: null byte | - | sanitizeFilename("file\x00.txt") | "file_.txt" (control characters replaced) | P1 |
| TC-SEC-ALL-090 | sanitizeRange: valid A1 notation | - | sanitizeRange("Sheet1!A1:B10") | Returns "Sheet1!A1:B10" | P1 |
| TC-SEC-ALL-091 | sanitizeRange: invalid input | - | sanitizeRange("DROP TABLE users;") | Returns null | P1 |
| TC-SEC-ALL-092 | validateMaxLength | - | validateMaxLength("a".repeat(1000), 500) | Truncated to 500 characters | P2 |

### 7.4 File System Security Tests

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-------------|---------|------------|-----------|---------|
| TC-SEC-ALL-100 | Config directory auto-creation | CONFIG_DIR absent | ensureConfigDir() | Created with 0700 permissions | P0 |
| TC-SEC-ALL-101 | Config directory permission auto-recovery | CONFIG_DIR permissions 0755 | ensureConfigDir() | Restored to 0700 + security event | P0 |
| TC-SEC-ALL-102 | Token file save permissions | - | saveToken() | Saved with 0600 permissions + defensive chmodSync | P0 |
| TC-SEC-ALL-103 | Windows permission handling | Windows environment | ensureConfigDir() / saveToken() | Handles chmodSync failure gracefully (try-catch, relies on Windows ACL) | P1 |
| TC-SEC-ALL-104 | Temporary file cleanup | Remote installation | EXIT trap triggered | SHARED_TMP and all download temp files deleted | P1 |
| TC-SEC-ALL-105 | Temp file deletion on checksum failure | Remote installation | SHA-256 mismatch | tmpfile immediately deleted (`rm -f "$tmpfile"`) | P0 |

### 7.5 Network Security Tests

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-SEC-ALL-110 | HTTPS-only communication | Internet connection | Monitor all external API calls | Only HTTPS used for googleapis.com, github.com, etc. | P0 |
| TC-SEC-ALL-111 | OAuth callback local only | During OAuth flow | Check callback server binding | Listens only on localhost (127.0.0.1) | P0 |
| TC-SEC-ALL-112 | Docker network isolation | Container running | `docker run -i --rm` options | Auto-deleted on exit via --rm, no unnecessary ports exposed | P1 |
| TC-SEC-ALL-113 | curl integrity | Remote installation | Check curl options | Uses -sSL (silent, SSL required, follow redirects) | P1 |

---

## 8. Performance/Stability Tests

### 8.1 Rate Limiting Tests

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-PER-ALL-001 | withRetry: 429 retry | - | Mock function returning 429 | Retry up to 3 times, exponential backoff (1s -> 2s -> 4s) | P0 |
| TC-PER-ALL-002 | withRetry: 500 retry | - | Mock function returning 500 | Retry up to 3 times | P0 |
| TC-PER-ALL-003 | withRetry: 502/503/504 retry | - | Mock each status code | All are retry targets | P1 |
| TC-PER-ALL-004 | withRetry: 400 no retry | - | 400 response | Immediately throw error (no retry) | P1 |
| TC-PER-ALL-005 | withRetry: 403 no retry | - | 403 response | Immediately throw error (no retry) | P1 |
| TC-PER-ALL-006 | withRetry: network error | - | ECONNRESET error | Retry executed | P1 |
| TC-PER-ALL-007 | withRetry: ETIMEDOUT | - | ETIMEDOUT error | Retry executed | P1 |
| TC-PER-ALL-008 | withRetry: ECONNREFUSED | - | ECONNREFUSED error | Retry executed | P2 |
| TC-PER-ALL-009 | withRetry: max delay limit | - | maxDelay=10000 setting | Delay does not exceed 10000ms | P2 |
| TC-PER-ALL-010 | withRetry: custom options | - | maxAttempts=5, initialDelay=500 | 5 retries, starting at 500ms | P2 |
| TC-PER-ALL-011 | withRetry: first attempt success | - | Normal response | Immediately returned without retry | P0 |

### 8.2 Large Data Processing Tests

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-PER-ALL-020 | gmail_search: large results | Hundreds of emails | maxResults=100 search | Only top 10 detailed queries (Promise.all), stable memory | P1 |
| TC-PER-ALL-021 | drive_search: large files | Thousands of files | maxResults=50 search | pageSize limit works correctly | P1 |
| TC-PER-ALL-022 | gmail_read: large attachment | 10MB+ attachment email | Read by messageId | body truncated to 5000 chars, only attachment metadata returned | P2 |
| TC-PER-ALL-023 | gmail_attachment_get: large | 25MB attachment | Download by attachmentId | base64 encoded data returned normally | P2 |
| TC-PER-ALL-024 | docs_read: long document | 10000+ char document | Read by documentId | content truncated to 10000 chars | P2 |
| TC-PER-ALL-025 | sheets_write: large cells | 1000 rows x 26 columns | Send values array | All cells updated in USER_ENTERED mode | P2 |

### 8.3 Concurrency Tests

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-PER-ALL-030 | Concurrent auth mutex | Auth not completed | Call getAuthenticatedClient() 3 times concurrently | authInProgress Promise shared, auth executed only once | P0 |
| TC-PER-ALL-031 | Mutex release | Auth completed | Check authInProgress | Reset to null, new auth possible on next call | P1 |
| TC-PER-ALL-032 | Service cache concurrent access | Cache about to expire | Call getGoogleServices() concurrently | Only one creates service, others use cache | P2 |
| TC-PER-ALL-033 | Concurrent API calls | Auth completed | gmail_search + drive_search concurrently | Each operates withRetry independently, no interference | P1 |

### 8.4 Long-running Operation Tests

| ID | Test Case | Preconditions | Test Procedure | Expected Result | Priority |
|----|-----------|---------------|----------------|-----------------|----------|
| TC-PER-ALL-040 | 50-minute cache refresh | Service cache active | API call after 50 minutes | Cache expired -> new service instance created -> normal response | P1 |
| TC-PER-ALL-041 | Token auto-refresh | access_token about to expire | API call after long time | Auto refresh with 5-min buffer, no service interruption | P0 |
| TC-PER-ALL-042 | refresh_token expiry | refresh_token invalidated | API call after long time | Auto re-authentication flow (browser OAuth) | P1 |
| TC-PER-ALL-043 | Memory leak verification | MCP server long-running | Periodic API calls over 24 hours | RSS memory stable (under 500MB) | P2 |
| TC-PER-ALL-044 | Docker container stability | Docker-based execution | 24-hour operation | Container HEALTHCHECK passes, no OOM | P2 |

---

## 9. Regression Tests

### 9.1 Automated Tests (CI)

#### 9.1.1 Current CI Pipeline (`ci.yml`)

| CI Job | Environment | Test Content | Corresponding Test Case |
|--------|-------------|-------------|------------------------|
| `lint` | ubuntu-latest, Node.js 22 | ESLint + Prettier validation | TC-REG-ALL-001 |
| `build` | ubuntu-latest, Node.js 22 | TypeScript compilation | TC-REG-ALL-002 |
| `test` | ubuntu-latest, Node.js 22 | vitest full run + coverage | TC-REG-ALL-003 |
| `smoke-tests` | ubuntu-latest, macos-latest | module.json validation + install.sh syntax | TC-REG-ALL-004 |
| `security-audit` | ubuntu-latest, Node.js 22 | npm audit --audit-level=high | TC-REG-ALL-005 |
| `shellcheck` | ubuntu-latest | ShellCheck -S warning all files | TC-REG-ALL-006 |
| `docker-build` | ubuntu-latest | Docker image build + non-root check | TC-REG-ALL-007 |
| `verify-checksums` | ubuntu-latest | checksums.json up-to-date check | TC-REG-ALL-008 |

#### 9.1.2 CI Regression Test Cases

| ID | Test Case | Automation | Trigger | Expected Result | Priority |
|----|-----------|------------|---------|-----------------|----------|
| TC-REG-ALL-001 | No ESLint rule violations | CI auto | push/PR | 0 lint errors | P0 |
| TC-REG-ALL-002 | TypeScript compilation success | CI auto | push/PR | 0 tsc errors, dist/ generated | P0 |
| TC-REG-ALL-003 | vitest all pass | CI auto | push/PR | All 6 test files pass | P0 |
| TC-REG-ALL-004 | module.json validity | CI auto | push/PR | 7 module JSON parsing success, required fields present | P0 |
| TC-REG-ALL-005 | npm security audit pass | CI auto | push/PR | 0 high/critical vulnerabilities | P0 |
| TC-REG-ALL-006 | No ShellCheck warnings | CI auto | push/PR | No warnings in all .sh files under installer/ | P1 |
| TC-REG-ALL-007 | Docker image build success | CI auto | push/PR | Image build + `node -e "console.log('OK')"` success + UID 1001 verified | P0 |
| TC-REG-ALL-008 | checksums.json up-to-date | CI auto | push/PR | Matches generate-checksums.sh re-run result | P0 |
| TC-REG-ALL-009 | install.sh syntax validation | CI auto | push/PR | bash -n passes (macOS + Ubuntu) | P1 |
| TC-REG-ALL-010 | Module execution order validation | CI auto | push/PR | Sorted by order field confirmed | P2 |

#### 9.1.3 Manual CI Workflow (`test-installer.yml`)

| Trigger | Input | Execution Content |
|---------|-------|-------------------|
| workflow_dispatch | os: all/windows/macos | Windows/macOS actual installation test |
| workflow_dispatch | module: base/github/notion/figma | Specific module installation test |

### 9.2 Manual Regression Checklist

Items that must be manually verified before release.

#### 9.2.1 Installer Regression

- [ ] macOS (Sonoma): `./install.sh --all` full installation succeeds
- [ ] macOS: `./install.sh --list` displays 7 modules
- [ ] macOS: `./install.sh --modules "google" --skip-base` standalone execution succeeds
- [ ] macOS: Warning + wait behavior when Docker not running
- [ ] macOS: MCP config rollback on module failure
- [ ] Windows: `.\install.ps1 -all` full installation succeeds
- [ ] Windows: UAC admin privilege elevation works
- [ ] Windows: `-list` displays list (no admin required)
- [ ] Linux (Ubuntu): Full module clean installation succeeds
- [ ] Linux (Fedora): dnf-based installation succeeds

#### 9.2.2 MCP Server Regression

- [ ] OAuth initial auth flow (browser -> callback -> token saved)
- [ ] Token auto-refresh (5 minutes before expiry)
- [ ] gmail_search + gmail_read chained call
- [ ] gmail_send email send (UTF-8 subject)
- [ ] drive_search + drive_share chained call
- [ ] calendar_create_event (dynamic timezone)
- [ ] docs_create + docs_append + docs_read
- [ ] sheets_create + sheets_write + sheets_read
- [ ] slides_create + slides_add_slide

#### 9.2.3 Security Regression

- [ ] token.json file permissions 0600
- [ ] .google-workspace/ directory permissions 0700
- [ ] MCP config file permissions 0600
- [ ] Atlassian credentials.env permissions 600
- [ ] Docker container non-root execution
- [ ] Drive query escaping works
- [ ] Gmail header injection prevention works

---

## 10. Test Execution Plan

### 10.1 Execution Order by Priority

#### Phase 1: P0 Critical (Release Blockers)

**Goal**: Verify core functionality, 0 security vulnerabilities

| Order | Area | Test Count | Estimated Duration |
|-------|------|-----------|-------------------|
| 1 | CI Automation (REG) | 8 | Auto (10 min) |
| 2 | OAuth Authentication (AUT) | 11 | 30 min |
| 3 | Security Core (SEC) | 22 | 1 hour |
| 4 | Installer Core (INS) | 14 | 1 hour |
| 5 | Gmail/Drive/Calendar Core (GML,DRV,CAL) | 10 | 1 hour |
| 6 | E2E Clean Installation (E2E) | 4 | 2 hours |

**Subtotal**: 69 tests, approximately 5.5 hours

#### Phase 2: P1 High (Recommended Before Release)

**Goal**: Verify major feature stability, cross-platform verification

| Order | Area | Test Count | Estimated Duration |
|-------|------|-----------|-------------------|
| 1 | Installer Supplementary (INS) | 20 | 1 hour |
| 2 | MCP Tools Major (GML,DRV,CAL,DOC,SHT,SLD) | 35 | 2 hours |
| 3 | Module Features (ATL,FIG,NOT,GIT,PEN) | 15 | 1 hour |
| 4 | Performance/Concurrency (PER) | 10 | 1 hour |
| 5 | Cross-Platform (SHR,DOK) | 12 | 1 hour |
| 6 | E2E Scenarios (E2E) | 8 | 2 hours |

**Subtotal**: 100 tests, approximately 8 hours

#### Phase 3: P2-P3 Medium/Low (Acceptable Until Next Release)

| Order | Area | Test Count | Estimated Duration |
|-------|------|-----------|-------------------|
| 1 | MCP Tools Supplementary | 30 | 2 hours |
| 2 | Edge Cases | 15 | 1 hour |
| 3 | Performance Stress | 8 | 3 hours |
| 4 | Long-Running Operation | 4 | 24 hours |

**Subtotal**: 57 tests, approximately 30 hours

### 10.2 Test Environment Preparation Checklist

#### 10.2.1 Common Preparation

- [ ] Google Cloud project created (for testing)
- [ ] OAuth Client ID issued (Desktop type)
- [ ] client_secret.json prepared
- [ ] Test Google account (with Gmail, Drive, Calendar data)
- [ ] Atlassian test instance + API token
- [ ] GitHub test account + PAT
- [ ] Figma test account
- [ ] Notion test workspace

#### 10.2.2 macOS Environment Preparation

- [ ] macOS Sonoma 14.x + Apple Silicon VM/physical machine
- [ ] Clean user account with Homebrew not installed
- [ ] Docker Desktop installed + not running state snapshot
- [ ] Network access verified (ghcr.io, raw.githubusercontent.com, googleapis.com)

#### 10.2.3 Windows Environment Preparation

- [ ] Windows 11 23H2 VM/physical machine
- [ ] Clean state snapshot with WSL2 not installed
- [ ] Standard user account + admin account
- [ ] PowerShell 5.1 environment + PowerShell 7 environment

#### 10.2.4 Linux Environment Preparation

- [ ] Ubuntu 24.04 LTS VM (apt testing)
- [ ] Fedora 39+ VM (dnf testing)
- [ ] WSL2 Ubuntu 22.04 (Windows integration testing)
- [ ] User account with sudo access

#### 10.2.5 Docker Environment Preparation

- [ ] Docker Desktop/Engine latest version
- [ ] ghcr.io accessible (image pull test)
- [ ] Sufficient disk space (10GB+)
- [ ] docker group membership confirmed (Linux)

### 10.3 Result Recording Templates

#### 10.3.1 Test Execution Record

```markdown
## Test Execution Record

- Execution Date: YYYY-MM-DD
- Executor:
- Environment: (Env ID)
- Build Version: (git commit hash)

| TC ID | Result | Notes |
|-------|--------|-------|
| TC-XXX-YYY-NNN | PASS / FAIL / SKIP / BLOCK | Details |
```

#### 10.3.2 Defect Report

```markdown
## Defect Report

- Defect ID: BUG-YYYY-NNNN
- Related TC: TC-XXX-YYY-NNN
- Severity: Critical / Major / Minor / Trivial
- Environment: (Env ID)
- Discovery Date: YYYY-MM-DD

### Reproduction Steps
1. ...
2. ...

### Expected Result
...

### Actual Result
...

### Screenshots/Logs
...
```

---

## Appendix

### A. Complete Test Case List

#### A.1 Test Case Statistics

| Area | P0 | P1 | P2 | P3 | Total |
|------|:--:|:--:|:--:|:--:|:-----:|
| INS (Installer) | 14 | 22 | 6 | 2 | 44 |
| AUT (OAuth Authentication) | 11 | 9 | 2 | 0 | 22 |
| GML (Gmail) | 3 | 10 | 9 | 0 | 22 |
| DRV (Drive) | 4 | 8 | 8 | 0 | 20 |
| CAL (Calendar) | 3 | 6 | 6 | 0 | 15 |
| DOC (Docs) | 2 | 4 | 7 | 0 | 13 |
| SHT (Sheets) | 3 | 4 | 6 | 1 | 14 |
| SLD (Slides) | 2 | 3 | 6 | 0 | 11 |
| ATL (Atlassian) | 3 | 2 | 2 | 0 | 7 |
| FIG (Figma) | 3 | 3 | 2 | 0 | 8 |
| NOT (Notion) | 3 | 1 | 0 | 0 | 4 |
| GIT (GitHub) | 2 | 3 | 1 | 0 | 6 |
| PEN (Pencil) | 2 | 1 | 1 | 1 | 5 |
| SHR (Shared Utilities) | 1 | 11 | 6 | 2 | 20 |
| DOK (Docker) | 1 | 4 | 2 | 0 | 7 |
| SEC (Security) | 22 | 12 | 4 | 0 | 38 |
| PER (Performance) | 4 | 10 | 11 | 0 | 25 |
| E2E (Scenarios) | 5 | 8 | 6 | 0 | 19 |
| REG (Regression) | 6 | 3 | 1 | 0 | 10 |
| **Total** | **94** | **124** | **84** | **6** | **310** |

#### A.2 Complete Test Case ID Index

```
TC-INS-MAC-001 ~ TC-INS-MAC-026  (26 cases)
TC-INS-WIN-001 ~ TC-INS-WIN-016  (16 cases)
TC-INS-LNX-001 ~ TC-INS-LNX-010  (10 cases)
TC-AUT-ALL-001 ~ TC-AUT-ALL-022  (22 cases)
TC-GML-ALL-001 ~ TC-GML-ALL-022  (22 cases)
TC-DRV-ALL-001 ~ TC-DRV-ALL-020  (20 cases)
TC-CAL-ALL-001 ~ TC-CAL-ALL-015  (15 cases)
TC-DOC-ALL-001 ~ TC-DOC-ALL-013  (13 cases)
TC-SHT-ALL-001 ~ TC-SHT-ALL-014  (14 cases)
TC-SLD-ALL-001 ~ TC-SLD-ALL-011  (11 cases)
TC-ATL-ALL-001 ~ TC-ATL-ALL-007  (7 cases)
TC-FIG-ALL-001 ~ TC-FIG-ALL-008  (8 cases)
TC-NOT-ALL-001 ~ TC-NOT-ALL-004  (4 cases)
TC-GIT-MAC-001, TC-GIT-LNX-001 ~ 002, TC-GIT-ALL-001 ~ 004  (6 cases)
TC-PEN-ALL-001 ~ TC-PEN-ALL-004, TC-PEN-MAC-001  (5 cases)
TC-SHR-ALL-001 ~ TC-SHR-ALL-010  (10 cases)
TC-SHR-ALL-020 ~ TC-SHR-ALL-022  (3 cases)
TC-SHR-WIN-001 ~ TC-SHR-WIN-003  (3 cases)
TC-DOK-ALL-001 ~ TC-DOK-ALL-007  (7 cases)
TC-SEC-ALL-001 ~ TC-SEC-ALL-113  (38 cases)
TC-PER-ALL-001 ~ TC-PER-ALL-044  (25 cases)
TC-E2E-MAC-001, TC-E2E-WIN-001, TC-E2E-LNX-001, TC-E2E-WSL-001  (4 cases)
TC-E2E-ALL-010 ~ TC-E2E-ALL-053  (15 cases)
TC-REG-ALL-001 ~ TC-REG-ALL-010  (10 cases)
```

### B. Detailed OS Compatibility Matrix

#### B.1 Per-MCP Tool OS Compatibility

All MCP tools run inside Docker containers and are therefore OS-independent. The following summarizes the per-OS path differences for installer modules.

| Item | macOS | Windows | Linux | WSL2 |
|------|-------|---------|-------|------|
| MCP Config Path | `~/.claude/mcp.json` | `%USERPROFILE%\.claude\mcp.json` | `~/.claude/mcp.json` | `~/.claude/mcp.json` |
| Legacy MCP Path | `~/.mcp.json` | `%USERPROFILE%\.mcp.json` | `~/.mcp.json` | `~/.mcp.json` |
| Google Config | `~/.google-workspace/` | `%USERPROFILE%\.google-workspace\` | `~/.google-workspace/` | `~/.google-workspace/` |
| Atlassian Config | `~/.atlassian-mcp/` | - (Docker mode not supported*) | `~/.atlassian-mcp/` | `~/.atlassian-mcp/` |
| Claude Credentials | `~/.claude/.credentials.json` | `%USERPROFILE%\.claude\.credentials.json` | `~/.claude/.credentials.json` | `~/.claude/.credentials.json` |
| Node.js Install Method | Homebrew | winget/direct install | NodeSource | apt (WSL) |
| Docker Execution Method | Docker Desktop | Docker Desktop (WSL2 backend) | Docker Engine | Windows Docker shared |
| Browser Open | `open` | `Start-Process` | `xdg-open` | `cmd.exe /c start` |
| Package Manager | brew | winget/choco | apt/dnf/pacman | apt |
| Shell | bash (Zsh is default but bash specified) | PowerShell | bash | bash |

*Windows Atlassian Docker mode requires separate implementation in install.ps1

#### B.2 File Permissions Matrix

| File/Directory | Unix Permissions | Windows Behavior | Code Location |
|---------------|-----------|-------------|-----------|
| `~/.google-workspace/` | 0700 | ACL inherited | `oauth.ts:117` |
| `token.json` | 0600 | ACL inherited | `oauth.ts:202-209` |
| `~/.claude/mcp.json` | 0600 | - | `mcp-config.sh:75` |
| `~/.atlassian-mcp/` | 0700 | - | `atlassian/install.sh:141` |
| `credentials.env` | 0600 | - | `atlassian/install.sh:152` |

### C. Test Tools List

| Tool | Purpose | Installation Command |
|------|---------|---------------------|
| **vitest** | TypeScript unit tests (MCP server) | `cd google-workspace-mcp && npm ci` |
| **@vitest/coverage-v8** | Code coverage measurement | Same as above |
| **@vitest/ui** | Test UI dashboard | Same as above |
| **ESLint** | TypeScript static analysis | Same as above |
| **Prettier** | Code format verification | Same as above |
| **ShellCheck** | Shell script static analysis | `sudo apt-get install shellcheck` / `brew install shellcheck` |
| **Docker** | Container build/execution testing | Docker Desktop / Docker Engine |
| **curl** | HTTP request testing | Pre-installed |
| **jq** | JSON parsing (for result verification) | `brew install jq` / `apt install jq` |
| **bash -n** | Shell script syntax verification | Pre-installed |
| **npm audit** | Dependency security audit | Included with Node.js |
| **openssl** | SHA-256 hashing, PKCE random generation | Pre-installed |
| **python3** | OAuth PKCE callback server, JSON parsing | Pre-installed / `brew install python3` |
| **gh** | GitHub Actions manual trigger | `brew install gh` |
| **VM/Container** | Cross-platform test environments | UTM (macOS), Hyper-V (Windows), Docker |

---

*End of document*
