# Manual Test Checklist — ADW Improvement

> **Version**: 1.1
> **Date**: 2026-02-20
> **Target**: installer (macOS / Windows / Linux)
> **Automated Tests**: 226 unit tests (97.46% coverage) — This document covers only manual tests that cannot be automated
> **Note**: Google Workspace MCP related tests are covered by automated tests (excluded from manual testing)

---

## How to Use

- [ ] Execute each scenario in order
- [ ] Check Pass/Fail and record issues in the notes column
- [ ] Create a GitHub Issue on failure

**Legend**: P0 = Must pass, P1 = Important, P2 = Recommended

---

## 1. Installer — macOS

### TC-INS-MAC-01: Clean Install (P0)

**Prerequisites**: macOS 12+, internet connection, terminal

| Step | Action | Expected Result | Pass/Fail |
|------|--------|----------------|-----------|
| 1 | `curl -fsSL https://raw.githubusercontent.com/popup-jacob/popup-claude/master/installer/install.sh \| bash` | Script download and execution starts | |
| 2 | Verify system requirements check output | RAM >= 8GB, CPU >= 4, Disk >= 10GB displayed | |
| 3 | Verify module list display | List of 7 modules (base + 6 optional) displayed | |
| 4 | Select and install base module only | Node.js, Git, VS Code, Docker, Claude CLI, bkit installation complete | |
| 5 | `node --version` | v18+ output | |
| 6 | `git --version` | Version output | |
| 7 | `docker --version` | Version output | |
| 8 | `claude --version` | Claude CLI version output | |

**Notes**: _______________________________________________

### TC-INS-MAC-02: Full Module Install (P1)

| Step | Action | Expected Result | Pass/Fail |
|------|--------|----------------|-----------|
| 1 | `./install.sh --all` | Sequential installation of 7 modules starts | |
| 2 | Notion module install | Verify notion server added to MCP config | |
| 3 | GitHub module install | `gh --version` outputs normally | |
| 4 | Figma module install | Figma token input prompt displayed | |
| 5 | Pencil module install | VS Code extension installation message | |
| 6 | Atlassian module install | Jira/Confluence URL + API token input prompt | |
| 7 | Check Claude Code MCP config | Verify server registration in `~/.claude/claude_desktop_config.json` | |

**Notes**: _______________________________________________

### TC-INS-MAC-03: Environment Without Homebrew (P1)

| Step | Action | Expected Result | Pass/Fail |
|------|--------|----------------|-----------|
| 1 | Run install.sh without Homebrew installed | Automatic Homebrew installation attempt | |
| 2 | sudo password prompt | Password input dialog displayed (even in curl\|bash mode) | |
| 3 | Continue after Homebrew installation completes | Base module installation proceeds normally | |

**Notes**: _______________________________________________

---

## 2. Installer — Windows

### TC-INS-WIN-01: PowerShell Clean Install (P0)

**Prerequisites**: Windows 10/11, PowerShell 5.1+, administrator privileges

| Step | Action | Expected Result | Pass/Fail |
|------|--------|----------------|-----------|
| 1 | In PowerShell (Administrator): `irm https://raw.githubusercontent.com/popup-jacob/popup-claude/master/installer/install.ps1 \| iex` | Script download and execution | |
| 2 | System requirements check | RAM, CPU, Disk check results displayed | |
| 3 | Base module install | Node.js, Git, VS Code, Docker Desktop installation | |
| 4 | `node --version` (new terminal) | v18+ output | |
| 5 | `docker --version` | Docker Desktop version output | |
| 6 | `claude --version` | Claude CLI version output | |

**Notes**: _______________________________________________

### TC-INS-WIN-02: Per-Module Selective Install (P1)

| Step | Action | Expected Result | Pass/Fail |
|------|--------|----------------|-----------|
| 1 | `.\install.ps1 -Modules "github,notion"` | Only github + notion modules installed | |
| 2 | GitHub CLI check | `gh auth status` normal | |
| 3 | Notion MCP check | Notion server registered in MCP config | |

**Notes**: _______________________________________________

---

## 3. Installer — Linux

### TC-INS-LNX-01: Ubuntu/Debian Install (P1)

**Prerequisites**: Ubuntu 22.04+, sudo privileges

| Step | Action | Expected Result | Pass/Fail |
|------|--------|----------------|-----------|
| 1 | `curl -fsSL .../install.sh \| bash` | apt package manager auto-detected | |
| 2 | Base module install | Node.js, Git, Docker installed via `apt install` | |
| 3 | Verify installation complete | All CLI tool versions can be confirmed | |

### TC-INS-LNX-02: Fedora/RHEL Install (P2)

| Step | Action | Expected Result | Pass/Fail |
|------|--------|----------------|-----------|
| 1 | `curl -fsSL .../install.sh \| bash` | dnf package manager auto-detected | |
| 2 | Base module install | Installation proceeds via `dnf install` | |

**Notes**: _______________________________________________

---

## 4. Security Verification

### TC-SEC-01: Checksum Verification (P1)

| Step | Action | Expected Result | Pass/Fail |
|------|--------|----------------|-----------|
| 1 | checksums.json download during remote install | Checksum file downloads successfully | |
| 2 | Module file integrity verification | SHA-256 hash match confirmed | |
| 3 | Attempt install after tampering with module file | Checksum mismatch warning + installation aborted | |

**Notes**: _______________________________________________

---

## Test Execution Summary

| Category | Total TCs | P0 | P1 | P2 | Pass | Fail |
|----------|:---------:|:--:|:--:|:--:|:----:|:----:|
| Installer macOS | 3 | 1 | 2 | 0 | | |
| Installer Windows | 2 | 1 | 1 | 0 | | |
| Installer Linux | 2 | 0 | 1 | 1 | | |
| Security | 1 | 0 | 1 | 0 | | |
| **Total** | **8** | **2** | **5** | **1** | | |

**Tested By**: _______________
**Date**: _______________
**Environment**: _______________
**Overall Result**: Pass / Fail
