# Base Module Installation Error Cases Comprehensive Report

> **Date**: 2026-02-23
> **Target**: `installer/modules/base/install.ps1`
> **Purpose**: Comprehensive listing of all possible error cases when installing the base module across various Windows environments

---

## Table of Contents

1. [Overview](#1-overview)
2. [winget (Step 1)](#2-winget-step-1)
3. [Node.js (Step 2)](#3-nodejs-step-2)
4. [Git (Step 3)](#4-git-step-3)
5. [VS Code / Antigravity (Step 4)](#5-vs-code--antigravity-step-4)
6. [**VS Code Extension Installation (Step 4 Sub-step)**](#6-vs-code-extension-installation-step-4-sub-step)
7. [WSL (Step 5)](#7-wsl-step-5)
8. [Docker Desktop (Step 6)](#8-docker-desktop-step-6)
9. [Claude Code CLI / Gemini CLI (Step 7)](#9-claude-code-cli--gemini-cli-step-7)
10. [bkit Plugin (Step 8)](#10-bkit-plugin-step-8)
11. [Common Errors (Cross-cutting)](#11-common-errors-cross-cutting)
12. [Top 10 Most Frequent Errors](#12-top-10-most-frequent-errors)
13. [Risk Matrix by Environment](#13-risk-matrix-by-environment)

---

## 1. Overview

### Programs to Install

| Step | Program | Installation Method | Required |
|------|---------|----------|----------|
| 1 | winget | Prerequisite (validation only) | **Required** |
| 2 | Node.js LTS | `winget install OpenJS.NodeJS.LTS` | **Required** |
| 3 | Git | `winget install Git.Git` | **Required** |
| 4 | VS Code / Antigravity | `winget install Microsoft.VisualStudioCode` | **Required** |
| 5 | WSL | `wsl --install --no-distribution` | When Docker is needed |
| 6 | Docker Desktop | `winget install Docker.DockerDesktop` | When module is needed |
| 7 | Claude Code CLI | `irm https://claude.ai/install.ps1 \| iex` | **Required** |
| 8 | bkit Plugin | `claude plugin marketplace add ...` | **Required** |

### Target Test Environment Types

- **General Home PC**: Windows 11 Home, default security settings
- **Enterprise Environment (AD-managed)**: Group Policy, proxy, firewall
- **Educational Institution**: Restricted user permissions, filtering
- **Older Windows**: Windows 10 1809~21H2
- **Special Editions**: Windows 11 S Mode, LTSC, Server

---

## 2. winget (Step 1)

> Current code: If winget is not found, throw error and exit

### Error Cases

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| W1 | Windows 10 1709 or below | `winget not found` | winget requires 1809+ | Windows update or manual installation guide |
| W2 | Windows LTSC (2019/2021) | `winget not found` | LTSC does not include Microsoft Store → App Installer not included | Manual installation of `.msixbundle` from GitHub |
| W3 | Windows Server 2019/2022 | `winget not found` | Not included by default on Server | Included by default from Server 2025. Manual installation for earlier versions |
| W4 | Windows 11 S Mode | `winget not found` or installation blocked | S Mode only allows Store apps | S Mode must be disabled (Settings > Activation) |
| W5 | Enterprise environment (MSIX sideload blocked) | Cannot install App Installer | Sideload blocked by Group Policy | Request from IT administrator |
| W6 | Corrupted App Installer | `winget` command exists but fails to run | App Installer package corrupted | Re-register with `Add-AppxPackage -Register` or reinstall from Store |
| W7 | winget source agreements not accepted | `agreements not accepted` | Source agreements required on first run | `--accept-source-agreements` flag (already applied) |

### Current Code Response Level

```
Current: If winget missing, throw → installation aborted
Improvements needed:
  - Display manual installation guide when LTSC/Server detected
  - Provide App Installer Store link (already implemented)
  - Consider adding GitHub releases direct download fallback
```

---

## 3. Node.js (Step 2)

> Current code: `winget install OpenJS.NodeJS.LTS` → `Refresh-Path` → verify

### Error Cases

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| N1 | No administrator privileges | `Access denied` / installation failure | winget may require administrator privileges | Allow UAC prompt or use `--scope user` |
| N2 | Existing Node.js (nvm installation) | Conflict or PATH priority issue | nvm-windows manages PATH, causing conflict | Skip winget installation if nvm exists |
| N3 | Existing Node.js (direct installation) | `A newer version already installed` | winget version < existing installed version | Can be ignored (already installed) |
| N4 | PATH not updated | `node not found` (after installation) | PATH not refreshed after winget installation | `Refresh-Path` (already implemented) → if still fails, restart terminal |
| N5 | Proxy/firewall | winget download failure | Enterprise proxy blocking CDN | Configure proxy in `winget settings` or offline installation |
| N6 | SSL certificate inspection (MITM) | `certificate verify failed` | Enterprise security solution intercepting SSL | Add enterprise certificate to trust store |
| N7 | Insufficient disk space | Installation failure | Insufficient free space on C: drive | Free up space and retry |
| N8 | Antivirus blocking | Installation file quarantined | Norton, Kaspersky, etc. flagging msi as suspicious | Temporarily disable AV or add exception |
| N9 | ARM64 Windows | Possible compatibility issue | Need to verify Node.js ARM64 build | ARM64 Node.js is supported (v18+) |

### Current Code Response Level

```
Current: Install → refresh PATH → verify → guide to "restart terminal" on failure
Improvements needed:
  - Add nvm existence check
  - `--scope user` fallback (when no administrator privileges)
  - Strengthen skip logic when existing installation detected
```

---

## 4. Git (Step 3)

> Current code: `winget install Git.Git` → `Refresh-Path` → verify

### Error Cases

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| G1 | PATH not updated | `git not found` (after installation) | Git installed to `C:\Program Files\Git\cmd` but PATH not registered | `Refresh-Path` + manual PATH addition |
| G2 | Existing Git (installed via different method) | Version conflict | Conflict with Git installed via Chocolatey/Scoop/manual | Detect existing installation and skip |
| G3 | Enterprise proxy | Git clone/fetch failure (installation OK) | `https_proxy` not set | Guide to set `git config --global http.proxy` |
| G4 | SSL certificate (enterprise) | `SSL certificate problem: unable to get local issuer certificate` | Enterprise MITM proxy | `git config --global http.sslCAInfo <cert-path>` |
| G5 | No administrator privileges | Installation failure | No write permission to Program Files | Use `--scope user` or portable Git |
| G6 | Long path (exceeding 260 characters) | `Filename too long` | Windows default MAX_PATH=260 | `git config --global core.longpaths true` |
| G7 | Korean filenames | `UTF-8 encoding error` or garbled text | Git default settings may not be UTF-8 | `git config --global core.quotepath false` |
| G8 | Execution policy (post-installation scripts) | Git Bash related scripts blocked | PowerShell execution policy | `Set-ExecutionPolicy` already handled at parent level |

### Current Code Response Level

```
Current: Install → refresh PATH → verify → guide to "restart terminal" on failure
Improvements needed:
  - Enterprise environment proxy/SSL check guidance message
  - Consider automatic longpaths configuration
  - Consider automatic UTF-8 settings application
```

---

## 5. VS Code / Antigravity (Step 4)

> Current code: Direct path check → install via winget if missing → install Claude extension

### Error Cases

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| V1 | VS Code Insiders installed | Detection failure (different path) | Insiders version installs to a different path | Add Insiders path to detection checks |
| V2 | VS Code Portable version | Detection failure | Extracted to arbitrary path for use | Also check via `code` command |
| V3 | System install vs User install | Path mismatch | winget does User install, existing is System install | Check both paths (already implemented) |
| V4 | Extension installation failure (offline) | `code --install-extension` failure | Extension marketplace inaccessible | Guide for offline `.vsix` installation |
| V5 | Enterprise extension restriction | Extension installation blocked | Enterprise policy blocks specific extensions | Request permission from IT administrator |
| V6 | `code` command not registered | `code not found` (cannot install extensions) | VS Code not registered in PATH | VS Code settings > "Add to PATH" or manual registration |
| V7 | Insufficient disk space | Installation failure | VS Code + extensions need ~500MB | Free up space and retry |
| V8 | Antigravity winget ID not registered | `No package found` | Antigravity may not be in winget catalog | Add direct download fallback |

### 5-2. Antigravity IDE (When Gemini is selected)

> Current code: `winget install Google.Antigravity` + direct path check
> **winget ID**: `Google.Antigravity` (confirmed)
> **CLI command**: `agy` (equivalent to VS Code's `code`)
> **Extension marketplace**: OpenVSX (not VS Code Marketplace)

#### 🚨 Script Bug Found: Installation Path Error

| Current Path in Script (incorrect) | Actual Installation Path |
|---------------------------|--------------|
| `$env:LOCALAPPDATA\Programs\Antigravity\Antigravity.exe` | **Does not exist** |
| `$env:ProgramFiles\Antigravity\Antigravity.exe` | **Does not exist** |
| (none) | `$env:ProgramFiles\Google\Antigravity\Antigravity.exe` (**actual path**) |

→ **Result**: Fails to detect already-installed Antigravity and attempts reinstallation every time

#### Error Cases

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| AG1 | Path detection bug | (No error - repeated reinstallation) | `Google\` missing from script path | Fix path to `$env:ProgramFiles\Google\Antigravity\Antigravity.exe` |
| AG2 | No administrator privileges | `The installer failed with exit code: 1` | Inno Setup installs to `C:\Program Files\` → requires administrator | Run as administrator |
| AG3 | winget source not updated | `No applicable installer found` | winget source is outdated | Run `winget source update` |
| AG4 | `agy` not in PATH | `'agy' is not recognized` | PATH not refreshed after installation | Restart terminal or `Refresh-Path` |
| AG5 | SmartScreen blocking | `Windows Defender SmartScreen prevented an unrecognized app` | Warning for new executable file | Popup may be blocked when using `-h` flag |
| AG6 | Google Workspace account blocked | `Your current account is not eligible for Antigravity` | Administrator disabled "Experimental AI" | Use personal @gmail.com or administrator enables it |
| AG7 | Unsupported country (China, Russia, etc.) | `Your current account is not eligible` | Account country is in unsupported region | Change Google country association (takes 24-48 hours) |
| AG8 | Account under 18 years old | `not eligible` | Google AI features require 18+ | Use an account aged 18 or older |
| AG9 | GitHub Copilot extension conflict | Freeze on Antigravity loading screen | Copilot extension imported from VS Code causes conflict | Disable Copilot extension |
| AG10 | Forced version update | `This version is no longer supported. Please update` | Old version hard deprecated | Clean reinstall of latest version |
| AG11 | Extension marketplace access | VS Code extensions not found in search | Uses OpenVSX, not VS Code Marketplace | Use `agy --install-extension` or manual .vsix installation |
| AG12 | ARM64 architecture mismatch | `No applicable installer found for the machine architecture` | Auto-detection failure | `winget install Google.Antigravity --architecture arm64` |
| AG13 | Free quota exceeded | `Model quota limit exceeded` | Free tier limit exceeded | Wait for quota reset (5 hours) or subscribe to AI Pro |
| AG14 | Auth token corrupted | Repeated login failures | Local auth token corrupted | Delete `%APPDATA%\Antigravity\auth-tokens` and restart |

#### Gemini CLI Integration Errors

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| GM-AG1 | Gemini CLI does not detect Antigravity | `No installer is available for IDE` | `agy` binary not in PATH | Add Antigravity bin directory to PATH |
| GM-AG2 | IDE Companion extension connection failure | `Failed to connect to IDE companion extension` | Environment variables not set | Run `/ide install` in Antigravity |
| GM-AG3 | GEMINI.md configuration conflict | Antigravity + Gemini CLI overwrite same file | Both tools share `~/.gemini/GEMINI.md` | Manual merge management |

### Current Code Response Level

```
Current:
  VS Code: Direct path check → winget install → install extensions via code command
  Antigravity: Direct path check → winget install (path bug!)

VS Code improvements needed:
  - Check whether `code` command is registered in PATH
  - Add Insiders version path
  - Error handling for extension installation failure (currently suppressed with 2>$null)

Antigravity improvements needed (Critical):
  - Installation path fix required: Google\ subfolder
  - Add `agy` CLI PATH verification
  - Use `agy --install-extension` for extensions (different from code)
  - Pre-installation guidance for Google account/region restrictions
  - Copilot conflict warning
```

---

## 6. VS Code Extension Installation (Step 4 Sub-step)

> Current code:
> - base: `code --install-extension anthropic.claude-code 2>$null`
> - pencil module: `code --install-extension highagency.pencildev 2>$null`

### 6-1. `code` Command Issues

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| EX1 | "Add to PATH" unchecked during VS Code installation | `'code' is not recognized` (CMD) / `The term 'code' is not recognized` (PS) | VS Code `bin` directory not in PATH | Manually add to PATH: `%LOCALAPPDATA%\Programs\Microsoft VS Code\bin` |
| EX2 | VS Code installed from Microsoft Store | `code` command not registered | Store version has no PATH registration option | Reinstall with official installer (check PATH) |
| EX3 | Only VS Code Insiders installed | `code` missing, only `code-insiders` available | Insiders uses a separate command | Use `code-insiders --install-extension` |
| EX4 | Portable VS Code (ZIP extraction) | `code` command missing | Portable mode does not register with system | Run with full path: `<install-path>\bin\code.cmd` |
| EX5 | System install + User install coexisting | Extensions installed to wrong VS Code version | Different `code` executed based on PATH priority | Remove one or use full path |
| EX6 | Cursor IDE in use | `code` command unrelated to Cursor | Cursor uses separate extension directory (`~/.cursor/extensions/`) | Use `cursor --install-extension` or install manually within Cursor |

### 6-2. Network/Download Issues

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| EX7 | Enterprise proxy | `XHR failed` / CLI timeout | Proxy blocking `marketplace.visualstudio.com` | Configure `"http.proxy"` + domain whitelist |
| EX8 | SSL MITM inspection (zScaler, etc.) | `UNABLE_TO_GET_ISSUER_CERT_LOCALLY` / `SELF_SIGNED_CERT_IN_CHAIN` | VS Code uses its own Node.js certificate store → enterprise CA not recognized | Set `NODE_EXTRA_CA_CERTS` environment variable or `"http.proxyStrictSSL": false` |
| EX9 | Firewall blocking | `net::ERR_CONNECTION_TIMED_OUT` | Required domains inaccessible | Whitelist domains listed below |
| EX10 | Slow network | `XHR timeout` / installation stalls | Large extension download timeout | Retry or manually download VSIX |
| EX11 | DNS error | `getaddrinfo ENOTFOUND` | DNS cannot resolve marketplace domains | Change DNS (8.8.8.8, etc.) |

**Extension Marketplace Required Domains:**

| Domain | Purpose |
|--------|------|
| `marketplace.visualstudio.com` | Marketplace API |
| `*.gallery.vsassets.io` | Extension downloads |
| `*.gallerycdn.vsassets.io` | Extension CDN |
| `*.vscode-unpkg.net` | Web extension loading |
| `*.vscode-cdn.net` | VS Code CDN |
| `raw.githubusercontent.com` | Some extensions access GitHub |

### 6-3. Extension-Specific Issues

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| EX12 | Incorrect extension ID | `Extension 'xxx' not found` → `Failed Installing Extensions` | Typo or extension has been removed | Verify exact ID on marketplace |
| EX13 | VS Code version compatibility | `Extension is not compatible with the current version` | Extension requires newer VS Code API version | Update VS Code or install older extension version: `code --install-extension <id>@<version>` |
| EX14 | Signature verification failure | `Cannot verify extension signature` / `PackageIntegrityCheckFailed` | Download corruption, proxy tampering, OSS VS Code build | Retry or set `"extensions.verifySignature": false` |
| EX15 | Platform-specific extension not supported | Installation failure or no response | Extension only supports specific platform (win32-x64), ARM64 not available | Check for universal VSIX or request from publisher |
| EX16 | Deprecated extension | Installation blocked (Install button disabled) | Marked as deprecated on marketplace | Install alternative extension |
| EX17 | Already installed | `already installed. Use '--force' to update.` | Normal behavior but may not be latest | Force install latest with `--force` flag |

### 6-4. Permission/Policy Issues

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| EX18 | Enterprise Group Policy extension restriction | Installation blocked or auto-disabled | Whitelist managed via `AllowedExtensions` policy | Request extension permission from IT administrator |
| EX19 | Extension directory permissions | `EPERM: operation not permitted` | No write permission to `~/.vscode/extensions/` (AV lock, OneDrive sync) | Add AV exception, exclude from OneDrive sync |
| EX20 | Antivirus quarantining extension files | `EPERM` or missing files | AV quarantines extension DLLs/binaries as suspicious | Add `~/.vscode/extensions/` to AV exceptions |
| EX21 | OneDrive sync conflict | `EPERM` / conflict copies created | OneDrive syncing extension files and locking them | Exclude `.vscode/extensions/` from OneDrive settings |
| EX22 | AppLocker policy | VS Code itself blocked from running | Electron app blocked or unapproved path | Set `"disable-chromium-sandbox": true` or add to whitelist |

### 6-5. Silent Failures

> **Very Important**: These cases are particularly dangerous because the current code hides errors with `2>$null`

| # | Environment/Condition | Symptom | Cause | Solution |
|---|----------|------|------|----------|
| EX23 | Installation fails but returns exit code 0 | Script treats it as success | VS Code CLI bug — sometimes returns exit code 0 even on failure | Parse stdout/stderr text instead of exit code (check for "Failed" string) |
| EX24 | `2>$null` swallows error messages | Cannot determine what error occurred | Error output to stderr is suppressed | Capture with `$output = code --install-extension <id> 2>&1` and parse |
| EX25 | Installed but not activated | Extension in list but disabled | Reload needed, installed to wrong profile, policy disabled, workspace trust not granted | Restart VS Code, check profile |
| EX26 | Old version installed from cache | Older version installed instead of latest | CDN propagation delay or local cache | Use `--force` flag |

### 6-6. `anthropic.claude-code` Extension-Specific Errors

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| CC1 | Claude CLI auto-installs VSIX | `ENOENT. Please restart your IDE` | Claude CLI v1.0.x fails to resolve bundled VSIX path | Manual install: `code --install-extension ~/.local/lib/.../claude-code.vsix` |
| CC2 | `code` not registered + Claude CLI infinite retry | `The command "code" is either misspelled or could not be found` (infinite loop) | Claude CLI loops trying to auto-install VS Code extension | Add `code` to PATH or install manually from marketplace |
| CC3 | VS Code profile issue | Installed only to Default profile, not in active profile | CLI installation only applies to default profile when using non-default profile | Install manually from Extensions view in active profile |
| CC4 | Windows ARM64 | Extension stuck at v2.0.46, cannot update | ARM64 build not available or distribution delayed | Wait for ARM64 support or use x64 emulation |
| CC5 | Windows 11 crash | VS Code extension UI fails to load, crashes on CLI edit action | Windows version-specific compatibility issue | Update both VS Code and extension to latest |
| CC6 | git-bash error | Extension spawn fails due to git-bash related error | VS Code incorrectly resolves git-bash path even when bash is installed | Check shell path in VS Code terminal settings |

### 6-7. `highagency.pencildev` Extension-Specific Errors

| # | Environment/Condition | Error | Cause | Solution |
|---|----------|------|------|----------|
| PC1 | Claude Code not authenticated | Pencil extension functionality limited | Pencil depends on Claude Code authentication | Log in to Claude Code first |
| PC2 | Installing on Cursor IDE | VS Code marketplace access may be restricted | Cursor uses Open VSX, MS marketplace ToS restrictions | Install from Open VSX (registered there) |

### Current Code Response Level

```
Current:
  - `code --install-extension anthropic.claude-code 2>$null`
  - Errors completely suppressed, only success message displayed
  - Only pre-checks whether `code` command exists (Test-CommandExists "code")

Serious issues:
  1. 2>$null hides all errors → user cannot know about failures
  2. Combined with exit code 0 return bug, results in complete silent failure
  3. No handling when code command exists but fails due to network/policy issues
  4. Does not verify if already-installed version is up to date

Improvements needed:
  - Capture output and check for "Failed" string
  - Provide specific cause guidance on failure
  - Use --force to always ensure latest version
  - Pre-check marketplace accessibility when enterprise environment detected
  - Handle Cursor/Insiders users
```

---

## 7. WSL (Step 5)

> Current code: Only when Docker is needed → `wsl --install --no-distribution`

### Error Cases

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| L1 | No administrator privileges | `wsl --install` failure | WSL installation requires administrator privileges | Run script as administrator |
| L2 | Virtualization disabled (BIOS) | `Please enable Virtual Machine Platform` | Intel VT-x / AMD-V is turned off | Enable virtualization in BIOS |
| L3 | Hyper-V disabled | Cannot run WSL2 | Windows Home does not have Hyper-V (WSL2 is separate) | Enable `Virtual Machine Platform` feature |
| L4 | Windows 10 before 1903 | `wsl --install` command not supported | WSL2 requires 1903+, `--install` requires 2004+ | Windows update required |
| L5 | Windows 10 Home (old version) | Only WSL1 supported | WSL2 feature not included | Windows update or use WSL1 |
| L6 | Enterprise Hyper-V disabled by GPO | Virtualization feature blocked | Hyper-V related features blocked by Group Policy | Request from IT administrator |
| L7 | Reboot not performed | Cannot use WSL | Reboot required after installation | Reboot guidance (already implemented) |
| L8 | Existing WSL1 → WSL2 conversion | Conversion failure | Kernel update required | Run `wsl --update` (already implemented) |
| L9 | VPN software conflict | WSL network error | Cisco AnyConnect, GlobalProtect, etc. | Update VPN client or change WSL network settings |
| L10 | Antivirus blocking | WSL process blocked | Symantec, McAfee, etc. blocking WSL processes | Add AV exception |
| L11 | ARM64 device | Compatibility issue | Surface Pro X and other ARM devices | WSL2 supports ARM64, some distributions not supported |
| L12 | Windows Sandbox/hypervisor conflict | Virtualization resource conflict | Conflict with older VMware/VirtualBox | Use VMware 15.5.5+, VirtualBox 6+ |

### Current Code Response Level

```
Current: Check wsl --version → install/update → reboot guidance
Improvements needed:
  - Pre-check virtualization enablement (required)
  - Administrator privileges verification
  - VPN/AV conflict guidance messages
  - Pre-check Windows version
```

---

## 8. Docker Desktop (Step 6)

> Current code: Only when Docker is needed → `winget install Docker.DockerDesktop`

### Error Cases

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| D1 | BIOS virtualization not enabled | `Hardware assisted virtualization and data execution protection must be enabled` | VT-x/AMD-V disabled | Enable in BIOS |
| D2 | WSL2 not installed/not working | `WSL 2 installation is incomplete` | WSL2 required when using Docker WSL2 backend | Install WSL2 first (depends on Step 5) |
| D3 | Hyper-V conflict | Docker + VMware/VirtualBox cannot run simultaneously | Hyper-V conflicts with other virtualization | Recommend using Docker WSL2 backend |
| D4 | Windows Home (old version) | Hyper-V backend unavailable | Home does not have Hyper-V | Use WSL2 backend (default) |
| D5 | License (enterprise 250+ employees) | Docker Desktop paid | Enterprises with 250+ employees require paid subscription | Verify Docker Desktop license or use alternative |
| D6 | No administrator privileges | Installation failure | Docker Desktop installation requires administrator privileges | Run as administrator |
| D7 | Reboot not performed | Cannot run Docker | Reboot required after first installation | Reboot guidance (already implemented) |
| D8 | Docker daemon not started | `Cannot connect to the Docker daemon` | Docker Desktop not running | Start Docker Desktop and wait |
| D9 | Network mode conflict | `docker network` error | VPN/firewall blocking Docker network | Change Docker network settings |
| D10 | Insufficient disk space | Installation failure | Docker Desktop installation needs ~2GB, images need additional space | Free up space |
| D11 | Existing Docker conflict | `docker already installed` | Docker Toolbox or another Docker version exists | Remove existing version and reinstall |
| D12 | Firewall blocking Docker Hub | `docker pull` failure | Enterprise firewall blocking Docker Hub | Configure mirror registry or firewall exception |
| D13 | Group Policy blocking | Cannot install service | Service installation blocked by GPO | Request from IT administrator |

### Current Code Response Level

```
Current: Check docker command → install via winget if missing → reboot guidance
Improvements needed:
  - BIOS virtualization pre-check (shared with WSL)
  - Docker Desktop license warning (enterprise environment)
  - Detect existing Docker Toolbox
  - Docker daemon startup wait logic
```

---

## 9. Claude Code CLI / Gemini CLI (Step 7)

### 9-1. Claude Code CLI

> Current code: `irm https://claude.ai/install.ps1 | iex` → manual PATH addition

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| C1 | PowerShell execution policy | `scripts is disabled on this system` | `Restricted` execution policy | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| C2 | Internet blocked | `irm` download failure | Firewall/proxy blocking `claude.ai` | Configure proxy or offline installation |
| C3 | SSL inspection (enterprise) | `certificate error` | MITM proxy intercepting SSL | Add enterprise certificate |
| C4 | PATH not registered | `claude not found` | `~/.local/bin` not in PATH | Manual PATH addition (already implemented) |
| C5 | Previous version conflict | Installation failure or version confusion | Conflict with npm globally installed Claude CLI | Remove existing npm global version |
| C6 | `~/.local/bin` permission issue | File write failure | Located within OneDrive sync folder | Exclude from OneDrive sync or change installation path |
| C7 | Node.js not installed | npm related error (inside installation script) | Claude CLI installation script may use npm internally | Install Node.js first (depends on Step 2) |
| C8 | Proxy authentication required | 407 Proxy Authentication Required | Enterprise proxy requires authentication | Configure proxy authentication |

### 9-2. Gemini CLI

> Current code: `npm install -g @google/gemini-cli`

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| GM1 | npm permission issue | `EACCES` / `permission denied` | Insufficient permissions for global installation | Set `npm config set prefix` to user directory |
| GM2 | Node.js not installed | `npm not found` | When Step 2 failed | Install Node.js first |
| GM3 | npm registry blocked | `ETIMEDOUT` / `ECONNREFUSED` | Enterprise firewall blocking `registry.npmjs.org` | Configure npm proxy or use internal registry |
| GM4 | Existing installation conflict | Version issue | Previous global installation exists | `npm update -g @google/gemini-cli` |
| GM5 | Node.js version compatibility | Installation failure | Node.js version too old | Update Node.js LTS |

### Current Code Response Level

```
Current:
  - Claude: irm install → manual PATH addition → verify
  - Gemini: npm -g install → refresh PATH → verify
Improvements needed:
  - Pre-check execution policy
  - Detect existing npm global Claude CLI
  - Detect proxy environment and provide guidance
  - Verify Node.js dependency (reference Step 2 result)
```

---

## 10. bkit Plugin (Step 8)

> Current code: `claude plugin marketplace add` → `claude plugin install` → verify

### Error Cases

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| B1 | Claude CLI not installed | `claude not found` | When Step 7 failed | Install Claude CLI first |
| B2 | Claude CLI not logged in | Authentication error | Plugin installation may require login | Run `claude login` first |
| B3 | Network blocked | Marketplace inaccessible | Firewall blocking GitHub/marketplace | Add network exception |
| B4 | Plugin API changed | Command syntax changed | Plugin commands changed due to Claude CLI update | Check CLI documentation and update commands |
| B5 | Gemini extension installation failure | `extensions install` failure | Gemini CLI extension system immature | Retry after updating Gemini CLI |

### Current Code Response Level

```
Current: Suppress errors (SilentlyContinue) → verify installation → "verify" guidance
Improvements needed:
  - Pre-check Claude CLI existence
  - Specific guidance on installation failure (login required, etc.)
```

---

## 11. Common Errors (Cross-cutting)

Common issues that affect all installation steps:

### 11-1. PowerShell Related

| # | Issue | Impact | Solution |
|---|------|------|------|
| PS1 | Execution policy `Restricted` | Cannot run scripts at all | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| PS2 | PowerShell 5.1 (old version) | Some cmdlet behavior differences | Recommend using PowerShell 7+ |
| PS3 | Constrained Language Mode | `Add-Member` etc. restricted | Enterprise AppLocker policy must be removed |
| PS4 | `$ErrorActionPreference` | Unexpected error propagation | Isolate error handling per section |

### 11-2. Network Related

| # | Issue | Impact | Solution |
|---|------|------|------|
| NET1 | Enterprise proxy | All downloads fail | Auto-detect system proxy or manual configuration |
| NET2 | SSL/TLS MITM inspection | Certificate errors | Install enterprise root certificate |
| NET3 | Firewall port blocking | HTTPS(443) blocked | Add firewall exception |
| NET4 | DNS blocking | Specific domains inaccessible | Change DNS settings or use hosts file |
| NET5 | Offline environment | All online installations impossible | Pre-prepare offline installation packages |

### 11-3. Permission Related

| # | Issue | Impact | Solution |
|---|------|------|------|
| AUTH1 | Non-administrator account | Cannot install WSL, Docker | Guide to run as administrator |
| AUTH2 | UAC prompt blocked | Automated installation interrupted | Guide that UAC approval is needed |
| AUTH3 | Group Policy restriction | Software installation blocked | IT administrator approval needed |
| AUTH4 | AppLocker policy | Execution blocked | Request whitelist addition |

### 11-4. PATH Related

| # | Issue | Impact | Solution |
|---|------|------|------|
| PATH1 | Not applied even after Refresh-Path | Command not found | Guide to restart terminal |
| PATH2 | PATH length exceeded (Windows limit) | Cannot add new entries | Clean up unnecessary PATH entries |
| PATH3 | User PATH vs System PATH conflict | Wrong version executed | Check and adjust PATH order |

---

## 12. Top 10 Most Frequent Errors

Ranked by most frequently encountered errors when testing across multiple computers:

| Rank | Error | Frequency | Impact Scope | Current Response |
|------|------|------|----------|----------|
| **1** | PATH not applied (`Refresh-Path` insufficient) | ★★★★★ | Node, Git, `code` command, Claude CLI, Gemini | Partially addressed (Refresh-Path) |
| **2** | Enterprise proxy/firewall blocking | ★★★★☆ | All download steps + extension marketplace | **Not addressed** |
| **3** | SSL MITM inspection (enterprise security) | ★★★★☆ | winget, npm, irm, git, VS Code extensions | **Not addressed** |
| **4** | Non-administrator privileges | ★★★★☆ | WSL, Docker, some winget | **Not addressed** |
| **5** | VS Code extension silent failure | ★★★★☆ | Claude extension, Pencil extension | **Not addressed** (errors hidden with `2>$null`) |
| **6** | Conflict with existing installations | ★★★☆☆ | Node(nvm), Git, Docker | **Not addressed** |
| **7** | BIOS virtualization not enabled | ★★★☆☆ | WSL, Docker | **Not addressed** |
| **8** | Reboot required (WSL/Docker) | ★★★☆☆ | WSL, Docker | Addressed (guidance) |
| **9** | Antivirus blocking | ★★☆☆☆ | Installation files, WSL processes, extension files | **Not addressed** |
| **10** | Windows S Mode / LTSC | ★★☆☆☆ | Cannot use winget at all | Partially addressed (Store link) |

---

## 13. Risk Matrix by Environment

Probability of errors by environment type:

| Environment | winget | Node.js | Git | VS Code | Antigravity | **Extensions** | WSL | Docker | Claude CLI | bkit |
|------|--------|---------|-----|---------|-------------|---------|-----|--------|-----------|------|
| **General Home PC** | ✅ | ✅ | ✅ | ✅ | ⚠️ Account/region | ✅ | ⚠️ BIOS | ⚠️ BIOS | ✅ | ✅ |
| **Enterprise (AD)** | ⚠️ GPO | ⚠️ Proxy | ⚠️ SSL | ⚠️ Policy | ❌ Workspace blocked | ❌ Policy+SSL | ❌ GPO | ❌ License+GPO | ⚠️ Proxy | ⚠️ Network |
| **Educational Institution** | ⚠️ Restricted | ⚠️ Permissions | ⚠️ Permissions | ✅ | ⚠️ 18+ restriction | ⚠️ Network | ❌ Permissions | ❌ Permissions | ⚠️ Permissions | ⚠️ |
| **Windows 10 (old)** | ⚠️ Version | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ Version | ⚠️ | ✅ | ✅ |
| **LTSC/Server** | ❌ Not included | ❌ | ❌ | ❌ | ❌ | ❌ | ⚠️ | ⚠️ | ⚠️ | ⚠️ |
| **S Mode** | ❌ Blocked | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **ARM64 Device** | ✅ | ✅ | ✅ | ✅ | ✅ (supported) | ⚠️ Build not available | ✅ | ⚠️ | ✅ | ✅ |

> ✅ = Expected to work normally | ⚠️ = Possible issues | ❌ = High probability of failure

---

## Appendix: Required Network Access List

The following domains must be accessible via HTTPS(443) for the script to function properly:

| Domain | Purpose | Step |
|--------|------|------|
| `cdn.winget.microsoft.com` | winget package source | All |
| `winget.azureedge.net` | winget CDN | All |
| `nodejs.org` / CDN | Node.js download | Step 2 |
| `github.com` | Git, gh CLI, bkit | Step 3, 8 |
| `objects.githubusercontent.com` | GitHub releases | Multiple |
| `update.code.visualstudio.com` | VS Code download | Step 4 |
| `marketplace.visualstudio.com` | VS Code extensions | Step 4 |
| `desktop.docker.com` | Docker Desktop | Step 6 |
| `registry.npmjs.org` | npm packages | Step 7 (Gemini) |
| `claude.ai` | Claude CLI installation script | Step 7 |

---

## 14. Implementation Plan

### 14-1. File Structure

```
installer/modules/
├── shared/
│   ├── preflight.ps1     ← New: Environment pre-check (pre-installation diagnostics)
│   ├── preflight.sh      ← New: Mac/Linux environment pre-check
│   └── oauth-helper.ps1  (existing)
├── base/
│   ├── install.ps1       ← Modified: Enhanced error handling
│   ├── install.sh        ← Modified: Enhanced error handling
│   └── module.json       (unchanged)
```

### 14-2. preflight.ps1 — Environment Pre-check (14 checks)

> Purpose: Diagnose the environment before starting installation, and pre-warn/abort if issues are found
> Invocation: Called from `install.ps1` before running the base module via `. .\modules\shared\preflight.ps1`
> Return: Each check result stored in `$preflight` object → referenced by base/install.ps1

#### Check 1: Windows Version/Edition

```powershell
# Detection method:
$osInfo = Get-CimInstance Win32_OperatingSystem
$buildNumber = [int]$osInfo.BuildNumber
$productType = $osInfo.ProductType  # 1=Workstation, 2=DC, 3=Server
$edition = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID

# S Mode detection:
$ciPolicy = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -ErrorAction SilentlyContinue
$isSMode = $ciPolicy -and $ciPolicy.SkuPolicyRequired -eq 1

# LTSC detection:
$isLTSC = $edition -like "*LTSC*" -or $edition -like "*Server*"

# Result:
# - S Mode → Abort: "Installation not possible in Windows S Mode. Disable S Mode and retry"
# - LTSC/Server → Warning: "winget is not included by default on LTSC/Server. Manual installation may be required"
# - Build < 17763 (below 1809) → Abort: "Windows 10 1809 or higher required"
```

#### Check 2: Administrator Privileges

```powershell
# Detection method:
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

# Result:
# - Non-admin + Docker needed → Warning: "Administrator privileges required for WSL/Docker installation. Recommend re-running as administrator"
# - Non-admin + Docker not needed → Info: "Not administrator. Some programs will be installed with --scope user"
```

#### Check 3: PowerShell Execution Policy

```powershell
# Detection method:
$policy = Get-ExecutionPolicy -Scope CurrentUser

# Result:
# - Restricted → Attempt auto-fix: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
# - Auto-fix failed → Warning: "Execution policy change required. Run in administrator PowerShell"
# - Constrained Language Mode detection:
$isConstrained = $ExecutionContext.SessionState.LanguageMode -eq "ConstrainedLanguage"
# → Abort: "Script cannot run in Constrained Language Mode. Contact IT administrator"
```

#### Check 4: Internet Connection (Offline Detection)

```powershell
# Detection method:
$testUrls = @(
    "cdn.winget.microsoft.com",      # winget
    "marketplace.visualstudio.com",  # VS Code extensions
    "claude.ai"                       # Claude CLI
)
$online = $false
foreach ($url in $testUrls) {
    $result = Test-NetConnection -ComputerName $url -Port 443 -WarningAction SilentlyContinue
    if ($result.TcpTestSucceeded) { $online = $true; break }
}

# Result:
# - All failed → Abort: "No internet connection. Run in an online environment"
# - Some failed → Warning: "Some servers inaccessible. Check firewall settings" + display list of failed domains
```

#### Check 5: Proxy/Firewall Detection

```powershell
# Detection method:
# 1. Check system proxy settings
$proxySettings = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$hasProxy = $proxySettings.ProxyEnable -eq 1
$proxyServer = $proxySettings.ProxyServer

# 2. Check environment variable proxy
$envProxy = $env:HTTP_PROXY -or $env:HTTPS_PROXY

# Result:
# - Proxy detected → Warning: "Proxy detected ($proxyServer). Check proxy settings if downloads fail during installation"
# - winget proxy guidance: "Proxy settings in winget settings may be required"
# - npm proxy guidance: "npm config set proxy http://... may be required"
```

#### Check 6: SSL MITM Detection

```powershell
# Detection method:
# Detect enterprise MITM proxy by checking certificate issuer of known domains
try {
    $request = [System.Net.HttpWebRequest]::Create("https://claude.ai")
    $request.Timeout = 5000
    $response = $request.GetResponse()
    $cert = $request.ServicePoint.Certificate
    $issuer = $cert.Issuer
    $response.Close()

    # If not a well-known CA, possible MITM
    $knownCAs = @("DigiCert", "Let's Encrypt", "Cloudflare", "Amazon", "Google Trust")
    $isMITM = -not ($knownCAs | Where-Object { $issuer -like "*$_*" })
} catch {
    $isMITM = $false  # If connection itself fails, handled in Check 4
}

# Result:
# - MITM detected → Warning:
#   "Enterprise SSL inspection detected (issuer: $issuer)"
#   "If certificate errors occur during installation:"
#   "  - git: git config --global http.sslVerify false (temporary)"
#   "  - npm: npm config set strict-ssl false (temporary)"
#   "  - VS Code: Set NODE_EXTRA_CA_CERTS environment variable"
#   "  Or request enterprise certificate installation from IT administrator"
```

#### Check 7: BIOS Virtualization Enablement

```powershell
# Detection method:
# Only check when WSL/Docker is needed
if ($script:needsDocker) {
    $vmEnabled = $false

    # Method 1: Check Hyper-V virtualization
    $computerInfo = Get-CimInstance Win32_ComputerSystem
    $vmEnabled = $computerInfo.HypervisorPresent

    # Method 2: Check processor capabilities (fallback)
    if (-not $vmEnabled) {
        $proc = Get-CimInstance Win32_Processor
        $vmEnabled = $proc.VirtualizationFirmwareEnabled
    }
}

# Result:
# - Disabled → Warning:
#   "Virtualization (VT-x/AMD-V) is disabled in BIOS"
#   "Required for WSL and Docker Desktop"
#   "Enter BIOS settings and enable it:"
#   "  Intel: VT-x or Intel Virtualization Technology"
#   "  AMD: AMD-V or SVM Mode"
```

#### Check 8: Disk Space

```powershell
# Detection method:
$drive = (Get-Item $env:SystemDrive)
$freeGB = [math]::Round((Get-PSDrive C).Free / 1GB, 1)

# Estimated required space:
# Node.js ~100MB, Git ~300MB, VS Code ~500MB, Docker ~2GB, other ~500MB
$requiredGB = 1.5
if ($script:needsDocker) { $requiredGB = 4.0 }

# Result:
# - Insufficient → Warning: "C: drive free space ${freeGB}GB. Minimum ${requiredGB}GB recommended. Free up space before proceeding"
```

#### Check 9: OneDrive Sync Path Conflict

```powershell
# Detection method:
$userProfile = $env:USERPROFILE
$oneDrivePath = $env:OneDrive -or $env:OneDriveConsumer -or $env:OneDriveCommercial
$vscodeExtDir = "$userProfile\.vscode\extensions"

$isOneDriveSynced = $false
if ($oneDrivePath -and $userProfile -like "*OneDrive*") {
    $isOneDriveSynced = $true
}
# Or check if .vscode is within the OneDrive path
if ($oneDrivePath -and (Test-Path $vscodeExtDir)) {
    $resolvedPath = (Resolve-Path $vscodeExtDir).Path
    if ($resolvedPath -like "*OneDrive*") { $isOneDriveSynced = $true }
}

# Result:
# - Detected → Warning:
#   "VS Code extensions folder is within the OneDrive sync path"
#   "EPERM errors may occur when installing extensions"
#   "Exclude the .vscode folder from OneDrive sync settings"
```

#### Check 10: Existing Installation Conflict Detection

```powershell
# nvm detection:
$hasNvm = Test-Path "$env:APPDATA\nvm\nvm.exe" -or (Test-CommandExists "nvm")

# Docker Toolbox detection:
$hasDockerToolbox = Test-Path "$env:ProgramFiles\Docker Toolbox\docker.exe"

# Existing npm global Claude CLI detection:
$hasNpmClaude = $false
if (Test-CommandExists "npm") {
    $npmGlobal = npm list -g @anthropic-ai/claude-code 2>$null
    if ($npmGlobal -and $npmGlobal -notlike "*empty*") { $hasNpmClaude = $true }
}

# VS Code Insiders detection (when only code-insiders exists, not code):
$hasInsiders = Test-CommandExists "code-insiders"
$hasCode = Test-CommandExists "code"

# Result:
# - nvm found → Info: "nvm detected. Skipping Node.js winget installation (managed by nvm)"
# - Docker Toolbox → Warning: "Docker Toolbox detected. May conflict with Docker Desktop. Recommend removing it first"
# - npm Claude CLI → Warning: "npm global Claude CLI detected. May conflict with native installation. Recommend npm uninstall -g ..."
# - Insiders only → Info: "VS Code Insiders detected. Extensions will be installed via code-insiders"
```

#### Check 11: AV Software Detection

```powershell
# Detection method:
$avProducts = Get-CimInstance -Namespace "root\SecurityCenter2" -ClassName AntivirusProduct -ErrorAction SilentlyContinue
$avNames = $avProducts | Select-Object -ExpandProperty displayName

# List of AV products known to cause issues:
$problematicAVs = @("Norton", "Kaspersky", "McAfee", "Symantec", "Bitdefender", "Avast", "AVG")
$detectedProblematic = $avNames | Where-Object { $name = $_; $problematicAVs | Where-Object { $name -like "*$_*" } }

# Result:
# - Detected → Warning:
#   "Antivirus detected: $($avNames -join ', ')"
#   "If file quarantine/blocking occurs during installation:"
#   "  - Temporarily disable real-time protection"
#   "  - Or add installation paths to AV exceptions:"
#   "    %LOCALAPPDATA%\Programs\"
#   "    %USERPROFILE%\.vscode\extensions\"
#   "    %USERPROFILE%\.local\bin\"
```

#### Check 12: Group Policy / AppLocker Restriction Detection

```powershell
# Detection method:
# 1. Check software installation restriction policy
$gpRestriction = Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -ErrorAction SilentlyContinue
$installRestricted = $gpRestriction -and $gpRestriction.DisableMSI

# 2. Check AppLocker policy
$appLockerPolicy = Get-AppLockerPolicy -Effective -ErrorAction SilentlyContinue
$hasAppLocker = $null -ne $appLockerPolicy -and ($appLockerPolicy.RuleCollections.Count -gt 0)

# 3. Check VS Code extension policy
$vscodePolicies = Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Visual Studio Code" -ErrorAction SilentlyContinue
$extensionRestricted = $vscodePolicies -and $vscodePolicies.AllowedExtensions

# Result:
# - Installation restricted → Warning: "Software installation is restricted by Group Policy. Contact IT administrator"
# - AppLocker → Warning: "AppLocker policy detected. Some program execution may be blocked"
# - Extension restricted → Warning: "VS Code extension installation policy detected. Request Claude/Pencil extension permission from IT administrator"
```

#### Check 13: Docker License Warning

```powershell
# Detection method (enterprise size estimation):
# - Determine enterprise environment by domain join status
$isDomainJoined = (Get-CimInstance Win32_ComputerSystem).PartOfDomain

# Result:
# - Docker needed + domain joined → Warning:
#   "Enterprise environment detected (domain: $((Get-CimInstance Win32_ComputerSystem).Domain))"
#   "Docker Desktop requires paid subscription for enterprises with 250+ employees (Docker Business)"
#   "Check license: https://www.docker.com/pricing/"
```

#### Check 14: Google Account/Region Restriction Notice (Antigravity)

```powershell
# Only displayed when Gemini (Antigravity) is selected
if ($env:CLI_TYPE -eq "gemini") {
    # Detection method: Estimate from system locale/region
    $region = (Get-WinSystemLocale).Name  # e.g.: "ko-KR", "zh-CN"
    $restrictedRegions = @("zh-CN", "ru-RU", "fa-IR", "cu-*", "kp-*", "sy-*")
    $isRestricted = $restrictedRegions | Where-Object { $region -like $_ }

    # Result: (always display notice)
    # Info:
    #   "Google account required to use Antigravity:"
    #   "  - Personal @gmail.com account recommended (Workspace accounts may be blocked)"
    #   "  - 18세 이상 계정만 가능"
    #   "  - 일부 국가에서 접근 제한 (중국, 러시아, 이란 등)"
    # + 제한 지역 감지 시 추가 경고
}
```

#### preflight 실행 흐름 요약

```
preflight.ps1 실행
│
├─ [FATAL] S Mode / Build 미달 / 오프라인 / Constrained Language
│   └─ 즉시 중단 + 명확한 에러 메시지
│
├─ [WARNING] 경고 수집 (중단하지 않음)
│   ├─ 관리자 아님
│   ├─ 프록시 감지
│   ├─ SSL MITM 감지
│   ├─ 가상화 미활성
│   ├─ 디스크 부족
│   ├─ OneDrive 충돌
│   ├─ 기존 설치 충돌
│   ├─ AV 감지
│   ├─ GPO/AppLocker
│   ├─ Docker 라이선스
│   └─ Google 계정 제한
│
├─ 경고 요약 출력
│   "⚠️ N개 경고 감지됨:"
│   "  1. 프록시 감지됨 (proxy.company.com:8080)"
│   "  2. 바이러스 백신: Norton 감지됨"
│   "  ..."
│
└─ 사용자 확인 (경고 있을 때)
    "경고가 있지만 계속 진행하시겠습니까? (Y/N)"
    └─ Y → $preflight 객체 반환 (base/install.ps1에서 참조)
    └─ N → 중단
```

#### $preflight 객체 구조

```powershell
$preflight = @{
    isAdmin          = $true/$false
    isSMode          = $true/$false
    isLTSC           = $true/$false
    isOnline         = $true/$false
    hasProxy         = $true/$false
    proxyServer      = "proxy:8080"
    isMITM           = $true/$false
    isVirtualization = $true/$false
    freeSpaceGB      = 15.2
    isOneDriveSynced = $true/$false
    hasNvm           = $true/$false
    hasDockerToolbox = $true/$false
    hasNpmClaude     = $true/$false
    hasCodeInsiders  = $true/$false
    hasCode          = $true/$false
    hasAgy           = $true/$false
    isDomainJoined   = $true/$false
    avProducts       = @("Norton", "Windows Defender")
    hasGPRestriction = $true/$false
    hasAppLocker     = $true/$false
    warnings         = @("경고1", "경고2", ...)
    fatal            = $null  # null이면 계속 진행 가능
}
```

---

### 14-3. base/install.ps1 — 에러 핸들링 강화 (8개 수정)

> 목적: 기존 설치 로직 유지하면서, preflight 결과를 활용한 스마트한 에러 처리
> $preflight 객체를 참조하여 각 단계별 분기 처리

#### 수정 1: 🚨 Antigravity 경로 수정 (Critical Bug Fix)

```powershell
# 현재 (잘못됨):
$antigravityPaths = @(
    "$env:LOCALAPPDATA\Programs\Antigravity\Antigravity.exe",
    "$env:ProgramFiles\Antigravity\Antigravity.exe"
)

# 수정:
$antigravityPaths = @(
    "$env:ProgramFiles\Google\Antigravity\Antigravity.exe",
    "$env:LOCALAPPDATA\Programs\Google\Antigravity\Antigravity.exe",
    "$env:LOCALAPPDATA\Programs\Antigravity\Antigravity.exe"   # 레거시 호환
)
```

#### 수정 2: Antigravity `agy` CLI + OpenVSX 대응

```powershell
# 현재: Antigravity 선택 시 확장 설치 없음 (VS Code만 확장 설치)
# 수정: Antigravity에서도 Gemini Companion 확장 설치 + agy CLI 활용

# Antigravity 선택 시 추가:
if (Test-CommandExists "agy") {
    Write-Host "  Installing Gemini CLI companion extension..." -ForegroundColor Gray
    $extOutput = agy --install-extension google.gemini-cli-companion 2>&1
    if ($extOutput -like "*Failed*") {
        Write-Host "  Extension install failed. Install manually from Antigravity marketplace." -ForegroundColor Yellow
    } else {
        Write-Host "  Gemini companion extension installed" -ForegroundColor Green
    }
}
```

#### 수정 3: PATH 강화

```powershell
# 현재:
function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

# 수정: 특정 경로 직접 추가하는 헬퍼 추가
function Ensure-InPath {
    param([string]$Dir)
    if ((Test-Path $Dir) -and ($env:PATH -notlike "*$Dir*")) {
        $env:PATH = "$Dir;$env:PATH"
    }
}

# 각 설치 후:
Refresh-Path
# Git 수동 PATH (Refresh-Path로 안잡힐 때 fallback)
Ensure-InPath "$env:ProgramFiles\Git\cmd"
# Node.js 수동 PATH
Ensure-InPath "$env:ProgramFiles\nodejs"
# Antigravity 수동 PATH
Ensure-InPath "$env:ProgramFiles\Google\Antigravity\bin"
# Claude CLI 수동 PATH
Ensure-InPath "$env:USERPROFILE\.local\bin"
```

#### 수정 4: VS Code 확장 사일런트 실패 수정

```powershell
# 현재 (에러 숨김):
code --install-extension anthropic.claude-code 2>$null
Write-Host "  Claude extension installed" -ForegroundColor Green

# 수정 (출력 캡처 + 파싱):
function Install-VSCodeExtension {
    param(
        [string]$ExtensionId,
        [string]$DisplayName,
        [string]$Command = "code"  # "code" 또는 "code-insiders" 또는 "agy"
    )

    if (-not (Test-CommandExists $Command)) {
        Write-Host "  $Command not found in PATH. Skip $DisplayName extension." -ForegroundColor Yellow
        return $false
    }

    Write-Host "  Installing $DisplayName extension..." -ForegroundColor Gray
    $output = & $Command --install-extension $ExtensionId --force 2>&1 | Out-String

    if ($output -like "*Failed*" -or $output -like "*not found*" -or $output -like "*not compatible*") {
        Write-Host "  ⚠ $DisplayName extension install failed:" -ForegroundColor Yellow
        # 원인별 안내
        if ($output -like "*not found*") {
            Write-Host "    Extension ID '$ExtensionId' not found in marketplace." -ForegroundColor Yellow
        } elseif ($output -like "*not compatible*") {
            Write-Host "    Extension requires newer $Command version. Update your IDE." -ForegroundColor Yellow
        } elseif ($output -like "*signature*") {
            Write-Host "    Signature verification failed. Corporate proxy may be modifying downloads." -ForegroundColor Yellow
        } else {
            Write-Host "    $($output.Trim())" -ForegroundColor Gray
        }
        return $false
    } else {
        Write-Host "  $DisplayName extension OK" -ForegroundColor Green
        return $true
    }
}

# 사용:
$codeCmd = if ($preflight.hasCodeInsiders -and -not $preflight.hasCode) { "code-insiders" } else { "code" }
Install-VSCodeExtension -ExtensionId "anthropic.claude-code" -DisplayName "Claude Code" -Command $codeCmd
```

#### 수정 5: 확장 `--force` 사용

```powershell
# 수정 4의 Install-VSCodeExtension에 이미 --force 포함됨
# 항상 최신 버전 설치 보장
```

#### 수정 6: 각 단계별 try-catch + 구체적 에러 안내

```powershell
# 현재: 전체 스크립트에 try-catch 없음 (상위 install.ps1에만 있음)
# 수정: 각 설치 단계별 try-catch 래핑

# 예시 - Node.js 설치:
Write-Host "[2/8] Checking Node.js..." -ForegroundColor Yellow
try {
    if ($preflight.hasNvm) {
        Write-Host "  nvm detected. Skipping winget Node.js install (managed by nvm)." -ForegroundColor Gray
        Write-Host "  OK (via nvm)" -ForegroundColor Green
    } elseif (-not (Test-CommandExists "node")) {
        Write-Host "  Installing Node.js LTS..." -ForegroundColor Gray
        $installArgs = "install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements -h"
        if (-not $preflight.isAdmin) { $installArgs += " --scope user" }
        $result = Start-Process winget -ArgumentList $installArgs -Wait -PassThru
        Refresh-Path
        Ensure-InPath "$env:ProgramFiles\nodejs"

        if (-not (Test-CommandExists "node")) {
            Write-Host "  Installed (restart terminal to use)" -ForegroundColor Yellow
        } else {
            Write-Host "  OK - $(node --version)" -ForegroundColor Green
        }
    } else {
        Write-Host "  OK - $(node --version)" -ForegroundColor Green
    }
} catch {
    Write-Host "  Node.js install failed: $_" -ForegroundColor Red
    if ($preflight.hasProxy) {
        Write-Host "  Proxy detected. Check proxy settings for winget." -ForegroundColor Yellow
    }
    Write-Host "  Manual install: https://nodejs.org/" -ForegroundColor Cyan
}
```

#### 수정 7: 기존 설치 스킵 로직 개선

```powershell
# preflight 결과 활용:
# - $preflight.hasNvm → Node.js winget 스킵
# - $preflight.hasDockerToolbox → Docker 설치 전 경고 + 제거 안내
# - $preflight.hasNpmClaude → Claude CLI 설치 전 기존 npm 버전 제거 안내
# - $preflight.hasCodeInsiders → code-insiders 명령 사용

# Docker Toolbox 감지 시:
if ($preflight.hasDockerToolbox) {
    Write-Host "  ⚠ Docker Toolbox detected. May conflict with Docker Desktop." -ForegroundColor Yellow
    Write-Host "  Recommend: Uninstall Docker Toolbox first." -ForegroundColor Yellow
    Write-Host "  Continue anyway? (Y/N)" -ForegroundColor White
    $continue = Read-Host
    if ($continue -ne "Y") { throw "Cancelled by user" }
}

# npm Claude CLI 감지 시:
if ($preflight.hasNpmClaude) {
    Write-Host "  ⚠ npm global Claude CLI detected. Removing to avoid conflict..." -ForegroundColor Yellow
    npm uninstall -g @anthropic-ai/claude-code 2>$null
}
```

#### 수정 8: winget `--scope user` fallback

```powershell
# 관리자 아닐 때 user scope로 재시도하는 헬퍼:
function Install-WithWinget {
    param(
        [string]$PackageId,
        [string]$DisplayName
    )

    $baseArgs = "install $PackageId --accept-source-agreements --accept-package-agreements -h"

    # 첫 시도
    winget $baseArgs.Split(' ')
    Refresh-Path

    # 실패 + 비관리자면 --scope user로 재시도
    if ($LASTEXITCODE -ne 0 -and -not $preflight.isAdmin) {
        Write-Host "  Retrying with --scope user..." -ForegroundColor Gray
        winget ($baseArgs + " --scope user").Split(' ')
        Refresh-Path
    }
}
```

---

### 14-4. base/install.sh — Mac/Linux 동일 적용

> PS1과 동일한 로직을 bash로 구현
> preflight.sh + install.sh 에러 핸들링 강화

주요 차이점:

| 항목 | PowerShell | Bash |
|------|-----------|------|
| 관리자 검사 | `WindowsPrincipal` | `[ "$EUID" -eq 0 ]` |
| 프록시 검사 | 레지스트리 | `$HTTP_PROXY`, `$HTTPS_PROXY` 환경변수 |
| AV 검사 | `SecurityCenter2` WMI | 해당 없음 (Mac: `xprotect` 정도) |
| GPO 검사 | 레지스트리 | 해당 없음 |
| 디스크 검사 | `Get-PSDrive` | `df -h /` |
| S Mode/LTSC | 레지스트리 | 해당 없음 (macOS/Linux는 해당 없음) |
| OneDrive | 경로 확인 | 해당 없음 (Mac: iCloud Drive 유사 문제 가능) |
| 가상화 | `Win32_ComputerSystem` | Mac: `sysctl kern.hv_support`, Linux: `/proc/cpuinfo` |

---

### 14-5. 구현 우선순위

| 우선순위 | 항목 | 난이도 | 영향도 |
|---------|------|--------|--------|
| **P0** | Antigravity 경로 버그 수정 | 쉬움 | 높음 — 현재 버그 |
| **P0** | VS Code 확장 사일런트 실패 수정 | 보통 | 높음 — 에러 숨김 |
| **P1** | preflight 환경 검사 전체 | 보통 | 높음 — 사전 진단 |
| **P1** | PATH 강화 (Ensure-InPath) | 쉬움 | 높음 — 최빈출 에러 |
| **P1** | 각 단계 try-catch 에러 핸들링 | 보통 | 높음 — 에러 안내 개선 |
| **P2** | 기존 설치 충돌 스킵 로직 | 보통 | 중간 |
| **P2** | winget --scope user fallback | 쉬움 | 중간 |
| **P2** | Antigravity agy CLI 대응 | 보통 | 중간 |
| **P3** | install.sh 동일 적용 | 보통 | 낮음 (Windows 중심) |

### 14-6. 예상 작업 분량

| 파일 | 현재 줄수 | 예상 줄수 | 비고 |
|------|----------|----------|------|
| `shared/preflight.ps1` | 0 (신규) | ~250줄 | 14개 검사 + 요약 출력 |
| `shared/preflight.sh` | 0 (신규) | ~150줄 | Windows 전용 검사 제외 |
| `base/install.ps1` | 245줄 | ~350줄 | 에러 핸들링 + 헬퍼 함수 추가 |
| `base/install.sh` | ~270줄 | ~330줄 | 동일 패턴 적용 |
