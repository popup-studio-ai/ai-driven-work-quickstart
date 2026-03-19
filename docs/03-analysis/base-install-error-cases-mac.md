# Base Module Installation Error Cases Comprehensive Report (macOS)

> **Date**: 2026-02-23
> **Scope**: Installing Homebrew, Node.js, Git, VS Code, Docker Desktop, Antigravity on macOS
> **Purpose**: Documenting all possible error cases when installing base modules across various macOS environments

---

## Table of Contents

1. [Overview](#1-overview)
2. [Homebrew (Prerequisite)](#2-homebrew-prerequisite)
   - 2.1 [macOS Version Compatibility](#21-macos-version-compatibility)
   - 2.2 [Apple Silicon vs Intel Mac Differences](#22-apple-silicon-vs-intel-mac-differences)
   - 2.3 [Xcode Command Line Tools](#23-xcode-command-line-tools)
   - 2.4 [Permission Errors](#24-permission-errors)
   - 2.5 [Enterprise Environment (MDM)](#25-enterprise-environment-mdm)
   - 2.6 [Network Issues (Proxy/Firewall/VPN)](#26-network-issues-proxyfirewallvpn)
   - 2.7 [Disk Space Issues](#27-disk-space-issues)
   - 2.8 [SIP (System Integrity Protection)](#28-sip-system-integrity-protection)
   - 2.9 [PATH Configuration Issues](#29-path-configuration-issues)
   - 2.10 [Rosetta 2 Related Issues](#210-rosetta-2-related-issues)
   - 2.11 [Shell Configuration Issues (zsh/bash)](#211-shell-configuration-issues-zshbash)
   - 2.12 [FileVault Encryption Related](#212-filevault-encryption-related)
   - 2.13 [Multi-User Account Issues](#213-multi-user-account-issues)
   - 2.14 [Existing Homebrew Corruption/Outdated Version](#214-existing-homebrew-corruptionoutdated-version)
   - 2.15 [curl/git Failures](#215-curlgit-failures)
3. [Node.js Error Cases](#3-nodejs-error-cases)
   - 3.1 [Homebrew Node.js vs nvm/fnm/volta Conflicts](#31-homebrew-nodejs-vs-nvmfnmvolta-conflicts)
   - 3.2 [npm Global Install Permission Error (EACCES)](#32-npm-global-install-permission-error-eacces)
   - 3.3 [Apple Silicon native vs Rosetta Node.js](#33-apple-silicon-native-vs-rosetta-nodejs)
   - 3.4 [node-gyp / Native Module Compilation Errors](#34-node-gyp--native-module-compilation-errors)
   - 3.5 [Xcode Command Line Tools Requirements](#35-xcode-command-line-tools-requirements)
   - 3.6 [Python Dependency Issues (node-gyp)](#36-python-dependency-issues-node-gyp)
   - 3.7 [PATH Conflicts (Multiple Node.js Installations)](#37-path-conflicts-multiple-nodejs-installations)
   - 3.8 [npm Registry Access Issues (Corporate Proxy/VPN)](#38-npm-registry-access-issues-corporate-proxyvpn)
   - 3.9 [npm Cache Corruption](#39-npm-cache-corruption)
   - 3.10 [brew link Errors](#310-brew-link-errors)
4. [Git Error Cases](#4-git-error-cases)
   - 4.1 [Apple Default Git vs Homebrew Git Conflict](#41-apple-default-git-vs-homebrew-git-conflict)
   - 4.2 [Xcode Git vs Standalone Git](#42-xcode-git-vs-standalone-git)
   - 4.3 [Git Credential Helper Issues (Keychain)](#43-git-credential-helper-issues-keychain)
   - 4.4 [SSH Key Issues (macOS Keychain Integration)](#44-ssh-key-issues-macos-keychain-integration)
   - 4.5 [Git LFS Issues](#45-git-lfs-issues)
   - 4.6 [Corporate Proxy/SSL Certificate Issues](#46-corporate-proxyssl-certificate-issues)
   - 4.7 [Case-Insensitive Filesystem (APFS)](#47-case-insensitive-filesystem-apfs)
   - 4.8 [.gitconfig Location Issues](#48-gitconfig-location-issues)
   - 4.9 [Outdated Git Version Issues](#49-outdated-git-version-issues)
5. [VS Code Installation Errors](#5-vs-code-installation-errors)
   - 5.1 [Homebrew Cask Installation Failure](#51-homebrew-cask-installation-failure)
   - 5.2 [`code` Command PATH Issues](#52-code-command-path-issues)
   - 5.3 [Gatekeeper / Quarantine Issues](#53-gatekeeper--quarantine-issues)
   - 5.4 [Extension Installation Failure](#54-extension-installation-failure)
   - 5.5 [VS Code Insiders vs Stable Conflict](#55-vs-code-insiders-vs-stable-conflict)
   - 5.6 [Enterprise MDM Blocking](#56-enterprise-mdm-blocking)
   - 5.7 [Apple Silicon (Rosetta 2) Issues](#57-apple-silicon-rosetta-2-issues)
   - 5.8 [Remote SSH Extension Issues](#58-remote-ssh-extension-issues)
   - 5.9 [Terminal Integration (Shell Detection) Issues](#59-terminal-integration-shell-detection-issues)
   - 5.10 [Extension Directory Permission Issues](#510-extension-directory-permission-issues)
6. [Docker Desktop Installation Errors](#6-docker-desktop-installation-errors)
   - 6.1 [Apple Silicon (M1/M2/M3/M4) Compatibility Issues](#61-apple-silicon-m1m2m3m4-compatibility-issues)
   - 6.2 [Rosetta 2 Requirements](#62-rosetta-2-requirements)
   - 6.3 [Docker Desktop License](#63-docker-desktop-license)
   - 6.4 [Virtualization Framework / QEMU Backend](#64-virtualization-framework--qemu-backend)
   - 6.5 [Docker Daemon Not Started](#65-docker-daemon-not-started)
   - 6.6 [Memory/CPU Allocation Issues](#66-memorycpu-allocation-issues)
   - 6.7 [File Sharing / Bind Mount Performance](#67-file-sharing--bind-mount-performance)
   - 6.8 [Network (VPN Conflicts)](#68-network-vpn-conflicts)
   - 6.9 [Docker Desktop Update Failure](#69-docker-desktop-update-failure)
   - 6.10 [macOS Version Compatibility](#610-macos-version-compatibility)
   - 6.11 [`docker` Command Not Registered](#611-docker-command-not-registered)
   - 6.12 [Disk Space Issues](#612-disk-space-issues)
   - 6.13 [Corporate Proxy Settings](#613-corporate-proxy-settings)
7. [Antigravity (Google) Installation Errors](#7-antigravity-google-installation-errors)
   - 7.1 [Homebrew Cask Installation](#71-homebrew-cask-installation)
   - 7.2 [Gatekeeper / Quarantine Blocking](#72-gatekeeper--quarantine-blocking)
   - 7.3 [`agy` CLI PATH Issues](#73-agy-cli-path-issues)
   - 7.4 [Google Account Requirements/Restrictions](#74-google-account-requirementsrestrictions)
   - 7.5 [Copilot Extension Conflicts](#75-copilot-extension-conflicts)
   - 7.6 [OpenVSX vs VS Code Marketplace Differences](#76-openvsx-vs-vs-code-marketplace-differences)
8. [Claude Code CLI Installation](#8-claude-code-cli-installation)
   - 8.1 [Native Installation (curl installer)](#81-native-installation-curl-installer)
   - 8.2 [npm Installation (deprecated)](#82-npm-installation-deprecated)
   - 8.3 [Network/Proxy Issues](#83-networkproxy-issues)
   - 8.4 [Shell/PATH Issues](#84-shellpath-issues)
   - 8.5 [macOS Platform-Specific Issues](#85-macos-platform-specific-issues)
   - 8.6 [Authentication Issues](#86-authentication-issues)
   - 8.7 [VS Code Extension Issues (Claude Code)](#87-vs-code-extension-issues-claude-code)
9. [Gemini CLI Installation](#9-gemini-cli-installation)
   - 9.1 [npm Installation](#91-npm-installation)
   - 9.2 [Homebrew Installation](#92-homebrew-installation)
   - 9.3 [Network/Proxy Issues](#93-networkproxy-issues)
   - 9.4 [Authentication Issues](#94-authentication-issues)
   - 9.5 [Quota and Regional Restrictions](#95-quota-and-regional-restrictions)
10. [bkit Plugin](#10-bkit-plugin)
    - 10.1 [Claude Code Plugin (MCP Server)](#101-claude-code-plugin-mcp-server)
    - 10.2 [Gemini CLI Extensions](#102-gemini-cli-extensions)
11. [Risk Matrix by Environment (Comprehensive)](#11-risk-matrix-by-environment-comprehensive)
12. [Top 15 Most Frequent Errors (Comprehensive)](#12-top-15-most-frequent-errors-comprehensive)

---

## 1. Overview

### Target Programs for Installation

| Step | Program | Installation Method | Required |
|------|---------|----------|----------|
| 0 | Homebrew | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` | **Required** |
| 1 | Node.js LTS | `brew install node` | **Required** |
| 2 | Git | `brew install git` | **Required** |
| 3 | VS Code / Antigravity | `brew install --cask visual-studio-code` | **Required** |
| 4 | Docker Desktop | `brew install --cask docker` | When module needed |
| 5 | Claude Code CLI | `curl -fsSL https://claude.ai/install.sh \| bash` (native, recommended) | **Required** |
| 6 | Gemini CLI | `npm install -g @google/gemini-cli` or `brew install gemini-cli` | **Required** |
| 7 | bkit Plugin | `claude mcp add` / Gemini extensions | **Required** |

### Target Environment Types

- **General Mac users**: macOS Sonoma/Sequoia, default settings
- **Apple Silicon (M1/M2/M3/M4)**: ARM64 native
- **Intel Mac**: x86_64 architecture
- **Enterprise environment (MDM managed)**: Jamf/Mosyle, proxy, firewall
- **Educational institutions**: Limited user permissions
- **Developer environment**: Existing nvm/fnm/volta, multiple Node.js versions

---

## 2. Homebrew (Prerequisite)

> Current code: If Homebrew is missing, run `curl` install script -> add to PATH -> verify

### Installation Path (by Architecture)

| Platform | Default Path | Notes |
|--------|----------|------|
| Apple Silicon (M1/M2/M3/M4) | `/opt/homebrew` | macOS 11+ only |
| Intel x86_64 | `/usr/local` | macOS 10.15+ |

### Homebrew Support Tiers (as of November 2025)

| Tier | Apple Silicon | Intel x86_64 | Description |
|------|-------------|-------------|------|
| Tier 1 | Sequoia 15, Sonoma 14 | Sequoia 15, Sonoma 14 | Full support, CI builds |
| Tier 3 | Ventura 13 and below | Ventura 13 and below | Unsupported, may require source build |

### 2.1 macOS Version Compatibility

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| V1 | macOS Mojave 10.14 and below | `Homebrew is not supported on this macOS version` | Homebrew 4.x+ requires Catalina 10.15 or higher | macOS upgrade required |
| V2 | macOS Catalina 10.15 | `Warning: You are using macOS 10.15. We (and Apple) do not provide support for this old version.` | Tier 3 support. Full deprecation planned after September 2026 | macOS upgrade recommended |
| V3 | macOS Big Sur 11 | Warning about some formula bottles not available | Tier 3. No CI builds | Source build fallback. Keep Xcode CLT up to date |
| V4 | macOS Monterey 12 | `Warning: You are using macOS 12. We do not provide support for this old version.` | Demoted to Tier 3 since 2024 | Upgrade to Sonoma 14 or higher |
| V5 | macOS Ventura 13 | Some latest formulas without bottle support | Tier 3 since November 2025 | Upgrade to Sonoma 14 or higher recommended |
| V6 | macOS beta/pre-release | `We do not provide support for this pre-release version` | Homebrew does not recognize beta macOS | Wait for official release or retry after `brew update` |
| V7 | macOS version recognition failure | `unknown or unsupported macOS version: :dunno` | Not in Homebrew's internal version mapping table | Run `brew update-reset` |
| V8 | Right after macOS upgrade | `dyld: Library not loaded: /opt/homebrew/opt/icu4c/lib/libicui18n.76.dylib` | Existing builds broken due to system library changes | Run `xcode-select --install` then `brew upgrade` |
| V9 | Right after macOS upgrade | `configure: error: Cannot find libz` | Xcode CLT in incompatible state | Reinstall `xcode-select --install` then `brew upgrade` |
| V10 | macOS Sequoia 15 (early) | `Error: Homebrew does not provide support for this macOS version` | Not supported before Homebrew 4.4.0 | Update to 4.4.0+ via `brew update` |

#### Upcoming Support Deprecation

| Timeline | Changes |
|------|----------|
| After September 2026 | Full deprecation of Catalina 10.15 and below. All Intel x86_64 demoted to Tier 3 |
| After September 2027 | Big Sur 11 unsupported (Apple Silicon). All Intel x86_64 fully unsupported |

### 2.2 Apple Silicon vs Intel Mac Differences

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| A1 | Attempting to install in `/usr/local` on Apple Silicon | `Cannot install in Homebrew on ARM processor in Intel default prefix (/usr/local)` | Attempting to install in Intel-only path on ARM Mac | Fresh install in `/opt/homebrew` |
| A2 | Migrated from Intel Mac via Migration Assistant | Two Homebrew installations coexist at `/usr/local` and `/opt/homebrew` | MA copied Intel Mac's `/usr/local` as-is | Remove Intel installation, keep ARM only |
| A3 | Using x86_64 terminal on Apple Silicon | brew uses `/usr/local` path | iTerm2 etc. running in Rosetta mode | Uncheck "Open using Rosetta". Verify `arm64` with `arch` command |
| A4 | brew not found after installation on Apple Silicon | `zsh: command not found: brew` | `/opt/homebrew/bin` not in PATH | Add `eval "$(/opt/homebrew/bin/brew shellenv)"` to `~/.zprofile` |
| A5 | Attempting to install in `/opt/homebrew` on Intel Mac | `Homebrew is not (yet) supported on this hardware` | Intel Mac only supports `/usr/local` | Use default install script |
| A6 | Universal binary conflict | Certain formulas do not provide arm64 bottles | Some formulas do not support arm64 | `brew install --build-from-source <formula>` or use Rosetta |

### 2.3 Xcode Command Line Tools

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| X1 | CLT not installed | `xcode-select: note: No developer tools were found` | Xcode CLT required for Homebrew | `xcode-select --install` |
| X2 | CLT installation UI failure | `Can't install the software because it is not currently available from the Software Update server` | Apple server issue or macOS too old | Manual download from developer.apple.com/download/all/ |
| X3 | Outdated CLT version | `Your Command Line Tools are too outdated` | CLT version mismatch after macOS upgrade | `sudo rm -rf /Library/Developer/CommandLineTools && xcode-select --install` |
| X4 | Xcode and CLT conflict | `Your CLT does not support macOS <version>` | Version conflict between full Xcode and standalone CLT | `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` |
| X5 | Partial CLT installation | `Xcode alone is not sufficient on <macOS version>` | CLT installation incomplete | `sudo rm -rf /Library/Developer/CommandLineTools && sudo xcode-select --install` |
| X6 | Xcode license not accepted | `You have not agreed to the Xcode license` | License agreement required after Xcode installation | `sudo xcodebuild -license accept` |
| X7 | Headless installation failure | `xcode-select --install` requires GUI popup but in SSH session | GUI popup not available in remote session | `softwareupdate --install "Command Line Tools for Xcode-<version>"` |
| X8 | CLT update detection failure | `brew doctor` shows warning but not in Software Update | macOS software update cache issue | Download directly from Apple Developer site |

### 2.4 Permission Errors

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| P1 | Intel Mac - `/usr/local` ownership | `Permission denied @ dir_s_mkdir - /usr/local/Frameworks` | Another program changed ownership | `sudo chown -R $(whoami):admin /usr/local/*` |
| P2 | Intel Mac - zsh compinit | `zsh compinit: insecure directories` | Permission mismatch on `/usr/local/share/zsh/site-functions` | `chmod go-w /usr/local/share` |
| P3 | Apple Silicon - `/opt/homebrew` ownership | `Permission denied - /opt/homebrew/Cellar` | Installed by another user or installed with sudo | `sudo chown -R $(whoami):admin /opt/homebrew` |
| P4 | Cask install - `/Applications` not writable | `Operation not permitted` | MDM or TCC blocking Applications access | `brew install --cask <app> --appdir=~/Applications` |
| P5 | Attempting `sudo brew` | `Running Homebrew as root is extremely dangerous and no longer supported.` | Attempting to run Homebrew as root | Run as regular user without sudo |
| P6 | Cannot create `/opt/homebrew` | `Failed to create /opt/homebrew` | No write permission to `/opt` | User must belong to admin group |
| P7 | macOS Sequoia TCC restriction | `Operation not permitted` | TCC blocking terminal's folder access | Add Terminal.app to Privacy & Security > Full Disk Access |
| P8 | Homebrew Caskroom ownership | `Permission denied @ dir_s_mkdir - /opt/homebrew/Caskroom/<app>` | Caskroom permission mismatch | `sudo chown -R $(whoami):admin $(brew --caskroom)` |

### 2.5 Enterprise Environment (MDM)

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| M1 | MDM blocks software installation | `Operation not permitted` | Jamf/Kandji etc. restrict unauthorized software | Request IT to allow Homebrew. Consider Workbrew |
| M2 | MDM Mac - no admin privileges | Cannot use sudo | Regular user has no admin privileges | Request admin privileges from IT or request MDM PKG deployment |
| M3 | Configuration Profile restricts terminal | Cannot execute certain commands | MDM Profile restricts terminal functionality | Request developer Profile exception from IT |
| M4 | MDM blocks `/opt` access | `mkdir: /opt/homebrew: Operation not permitted` | Enhanced SIP or MDM filesystem restriction | Request IT to allow directory creation |
| M5 | MDM installed as root account | Cannot use as regular user | MDM script runs as root | Install under user account: `sudo -u $loggedInUser brew install ...` |
| M6 | Corporate certificate store conflict | `curl: (60) SSL certificate problem` | Corporate proxy SSL interception | Add corporate CA certificate to Keychain |
| M7 | Homebrew refuses root execution | `Don't run this as root!` | Homebrew designed to not run as root | Use Homebrew PKG Installer |

### 2.6 Network Issues (Proxy/Firewall/VPN)

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| N1 | Corporate proxy | `curl: (7) Failed to connect to raw.githubusercontent.com` | Proxy blocks GitHub | `export http_proxy=http://proxy:port && export https_proxy=http://proxy:port` |
| N2 | Firewall blocks GitHub | `curl: (28) Connection timed out` | Firewall blocks GitHub domains | Request allowlisting of `github.com`, `raw.githubusercontent.com`, `ghcr.io` |
| N3 | VPN active | `error: RPC failed; curl 92 HTTP/2 stream was not closed cleanly` | VPN interferes with HTTP/2 | Disconnect VPN before installing or `git config --global http.version HTTP/1.1` |
| N4 | SSL intercept proxy | `curl failed to verify the legitimacy of the server` | Corporate proxy SSL MitM | Add corporate CA certificate to Keychain. `export HOMEBREW_FORCE_BREWED_CURL=1` |
| N5 | `.curlrc` interference | Various curl errors | `~/.curlrc` modifies curl behavior | Rename `mv ~/.curlrc ~/.curlrc.bak` and retry |
| N6 | DNS resolution failure | `curl: (6) Could not resolve host` | DNS server issue | Change DNS to `8.8.8.8` or `1.1.1.1` |
| N7 | Git clone connection drop | `fatal: early EOF` | Unstable network | Use wired connection. `git config --global http.postBuffer 524288000` |
| N8 | Homebrew API download failure | `Error: Failure while executing; /usr/bin/curl ... exit status 56` | JSON API download failed | Retry with `brew update --force` |
| N9 | Bottle download failure | `curl: (18) transfer closed with outstanding read data remaining` | Connection closed during bottle download | Retry. Source build fallback |

### 2.7 Disk Space Issues

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| D1 | Insufficient disk space | `No space left on device` | Homebrew + formulae require several GB | Clean cache with `brew cleanup` |
| D2 | Cache bloat | Continuous disk space decrease | Bottles stored in `~/Library/Caches/Homebrew` | `brew cleanup --prune=all` |
| D3 | APFS container confusion | `No space left on device` but overall space available | APFS volume space sharing issue | Check volumes in Disk Utility. Delete Time Machine snapshots |
| D4 | During Xcode CLT installation | `Not enough free disk space` | CLT requires approximately 1.5-3GB | Delete unnecessary files before installation |
| D5 | During source build | `make: *** [all] Error 1` + space shortage log | Source build requires several GB of temporary space | Ensure at least 10GB free space |

### 2.8 SIP (System Integrity Protection)

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| S1 | Accessing `/usr/local` with SIP enabled | `Operation not permitted` | SIP protects system directories | Use Homebrew default script (no SIP bypass needed) |
| S2 | SIP disabled state | `brew doctor` warning: `Your system has SIP disabled` | Increased security risk | Re-enable SIP: Recovery > Terminal > `csrutil enable` |
| S3 | macOS upgrade + SIP disabled | System instability, boot failure | Issues when upgrading with SIP disabled | Must re-enable SIP before upgrading |
| S4 | `/usr/local/bin` symlink failure | `Error: Could not symlink ... is not writable` | SIP or another program changed permissions | `sudo chown -R $(whoami):admin /usr/local/bin` |

### 2.9 PATH Configuration Issues

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| PA1 | Right after Apple Silicon installation | `zsh: command not found: brew` | `/opt/homebrew/bin` not in PATH | `echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile` |
| PA2 | Terminal not restarted | `command not found: brew` | Not applied to current session | Restart terminal or `source ~/.zprofile` |
| PA3 | Intel PATH takes priority over ARM | Wrong brew version executed | PATH order issue after Migration | Ensure `brew shellenv` is at the top in `~/.zprofile` |
| PA4 | `path_helper` interference | PATH order differs from expected | `/usr/libexec/path_helper` reorders PATH | Set `brew shellenv` after `path_helper` |
| PA5 | Formula not in PATH | `command not found: <installed-program>` | keg-only or `brew link` not done | `brew link <formula>` or manually add to PATH |
| PA6 | bash user | `bash: brew: command not found` | Must be set in `~/.bash_profile` | `echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile` |

### 2.10 Rosetta 2 Related Issues

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| R1 | Attempting Intel Homebrew install on ARM | `Cannot install in Homebrew on ARM processor in Intel default prefix` | Attempting to install in `/usr/local` on ARM Mac | Use default script -> automatically installs to `/opt/homebrew` |
| R2 | Rosetta not installed | `Bad CPU type in executable` | Running x86_64 binary without Rosetta 2 | `softwareupdate --install-rosetta --agree-to-license` |
| R3 | Installing Homebrew in Rosetta terminal | Installed in `/usr/local` (unintended) | Rosetta mode terminal is recognized as x86_64 | Uncheck "Open using Rosetta" and reinstall |
| R4 | ARM + x86_64 Homebrew coexistence | Package conflicts | Dual installation | Remove Intel version, keep ARM only |
| R5 | Formula does not support arm64 | `<formula> is not available for the arm64 architecture` | arm64 build not supported | `arch -x86_64 /usr/local/bin/brew install <formula>` |

### 2.11 Shell Configuration Issues (zsh/bash)

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| SH1 | zsh PATH not configured | `zsh: command not found: brew` | `brew shellenv` not added to `~/.zprofile` | `echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile` |
| SH2 | Set in `.zshrc` but not working in login shell | Not found in non-interactive shell | `.zshrc` only loads in interactive shells | Place environment variables in `~/.zprofile` |
| SH3 | zsh settings ignored in bash | `bash: brew: command not found` | bash uses `~/.bash_profile` | Use the appropriate config file for the shell |
| SH4 | fish shell | `fish: Unknown command 'brew'` | fish is not POSIX compatible | `echo 'eval (/opt/homebrew/bin/brew shellenv)' >> ~/.config/fish/config.fish` |
| SH5 | oh-my-zsh PATH reordering | System version is executed | oh-my-zsh changes PATH | Ensure `brew shellenv` is set before oh-my-zsh loads |
| SH6 | When using `~/.zshenv` | PATH order reversed | `path_helper` overrides `.zshenv` settings | Use `~/.zprofile` instead of `~/.zshenv` |

#### Homebrew `shellenv` Configuration Guide

| Shell | Config File | Command |
|----|----------|--------|
| zsh (default) | `~/.zprofile` | `echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile` |
| bash | `~/.bash_profile` | `echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile` |
| fish | `~/.config/fish/config.fish` | `echo 'eval (/opt/homebrew/bin/brew shellenv)' >> ~/.config/fish/config.fish` |

> **Note**: On Intel Mac, replace `/opt/homebrew/bin/brew` with `/usr/local/bin/brew`

### 2.12 FileVault Encryption Related

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| F1 | Installing during FileVault encryption | Installation extremely slow | FileVault initial encryption occupies I/O | Install after encryption completes |
| F2 | FileVault + low disk space | `No space left on device` | Encryption uses additional space | Ensure at least 15% free space |
| F3 | Disk locked after boot | Homebrew path inaccessible | Script accesses before unlock | Configure to run after user login |

### 2.13 Multi-User Account Issues

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| MU1 | Homebrew installed by another user | Multiple `Permission denied` | Homebrew designed for single user | Install Homebrew independently per user |
| MU2 | Shared installation - permission conflict | `Error: Permission denied` | Multiple users accessing same prefix | Independent installation per user recommended |
| MU3 | After `su`/`sudo -u` switch | Permission errors | Environment variable/PATH mismatch | Log in directly to each user account |
| MU4 | Guest account | Installation fails | Data deleted on logout | Install from a regular user account |

### 2.14 Existing Homebrew Corruption/Outdated Version

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| B1 | `brew update` fails | `fatal: Could not resolve HEAD to a revision` | git repository corrupted | `brew update-reset` |
| B2 | git conflict | `error: Your local changes would be overwritten` | Homebrew files manually modified | `cd "$(brew --repository)" && git reset --hard FETCH_HEAD` |
| B3 | Tap corrupted | `Error: Tap <name> already tapped` | tap repository corrupted | `brew tap --repair` or `brew untap && brew tap` |
| B4 | Extremely old Homebrew | `Error: undefined method` Ruby error | Current formula format mismatch | Full reinstall: `brew bundle dump`, uninstall, reinstall |
| B5 | Homebrew 1.x to 4.x+ upgrade | API change errors | JSON API transition in 4.x | Full reinstall recommended |
| B6 | Multiple `brew doctor` warnings | Various warnings | Accumulated configuration mismatches | Resolve `brew doctor` output sequentially |
| B7 | Cellar/Caskroom corrupted | `Error: No such keg` | Package files partially deleted | `brew reinstall <formula>` |
| B8 | Everything broken after macOS upgrade | Most brew commands fail | System library changes | `xcode-select --install && brew update && brew upgrade` |

### 2.15 curl/git Failures

| # | Environment/Condition | Error Message | Cause | Solution |
|---|----------|-----------|------|----------|
| C1 | Install script download failure | `curl: (7) Failed to connect to raw.githubusercontent.com` | Network blocked | Try mobile hotspot. Change DNS |
| C2 | Git clone timeout | `fatal: early EOF` | Unstable network | `git config --global http.postBuffer 524288000`. Use wired connection |
| C3 | SSL certificate verification failure | `curl: (60) SSL certificate problem: certificate has expired` | System time incorrect | Enable automatic system time sync |
| C4 | GitHub rate limit | `curl: (22) The requested URL returned error: 403` | API call limit exceeded | `export HOMEBREW_GITHUB_API_TOKEN=<token>` |
| C5 | HTTP/2 protocol issue | `error: RPC failed; curl 92 HTTP/2 stream was not closed cleanly` | Network equipment does not support HTTP/2 | `git config --global http.version HTTP/1.1` |
| C6 | Git shallow clone failure | `fatal: error processing shallow info: 4` | Shallow clone network issue | Set `HOMEBREW_NO_AUTO_UPDATE=1` then manually update |

### Current Code Coverage Level

```
Current:
  Mac: If brew missing, curl install -> add PATH -> verify
  On failure: Manual install guide (URL + PATH commands)

Improvements needed:
  - Apple Silicon vs Intel auto-detection + correct PATH guidance
  - Xcode CLT pre-check + auto-installation
  - Rosetta mode terminal detection + warning
  - Enterprise MDM/proxy environment detection
  - Existing Homebrew corruption check (brew doctor)
```

---

## 3. Node.js Error Cases

### 3.1 Homebrew Node.js vs nvm/fnm/volta Conflicts

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| NV1 | nvm + brew node simultaneously installed | `node` command runs unexpected version | nvm overwrites PATH during shell initialization. `~/.nvm/versions/node/` path takes priority | **Use only one**: `brew uninstall node` or `nvm deactivate && nvm unload` |
| NV2 | fnm + brew node simultaneously installed | `which node` shows fnm path, `node -v` shows different version | fnm's shim is ahead of Homebrew in PATH | When using fnm: `brew uninstall node`. When using Homebrew: remove fnm initialization from shell rc |
| NV3 | volta + brew node simultaneously installed | `npm install -g` packages won't run | volta uses its own shim system (`~/.volta/bin`), conflicts with npm global | When using volta: `brew uninstall node`. Use volta's `volta install` |
| NV4 | asdf + brew node | `No version is set for command node` | asdf manages node but shim shadows Homebrew node | When using asdf: remove brew node, or remove node plugin from asdf |
| NV5 | nvm + nvm installed via brew | nvm behavior unstable, `nvm is not compatible with the npm config "prefix"` | **nvm official docs do not support installing nvm via Homebrew** | `brew uninstall nvm` then use official install script: `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh \| bash` |

**Detection Logic Recommendations**:
```bash
# Detect existing Node.js version managers
if command -v nvm &>/dev/null || [ -d "$HOME/.nvm" ]; then
  echo "Warning: nvm detected. May conflict with brew install node."
fi
if command -v fnm &>/dev/null; then
  echo "Warning: fnm detected."
fi
if command -v volta &>/dev/null || [ -d "$HOME/.volta" ]; then
  echo "Warning: volta detected."
fi
```

---

### 3.2 npm Global Install Permission Error (EACCES)

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| NP1 | Running `npm install -g` | `EACCES: permission denied, access '/usr/local/lib/node_modules'` | npm global directory owned by root. Ownership changed due to past `sudo npm install` usage | `sudo chown -R $(whoami) $(npm config get prefix)/{lib/node_modules,bin,share}` |
| NP2 | npm cache directory permission | `EACCES: permission denied, mkdir '/Users/<user>/.npm/_cacache'` | `~/.npm` directory owned by root (past sudo usage) | `sudo chown -R $(whoami) ~/.npm` |
| NP3 | Apple Silicon + Homebrew | `EACCES: permission denied, access '/opt/homebrew/lib/node_modules'` | `/opt/homebrew` directory ownership issue | `sudo chown -R $(whoami) /opt/homebrew` |
| NP4 | Multi-user Mac | Cannot access npm global packages installed by another user | node_modules directory owned by another user | Set per-user npm prefix: `npm config set prefix '~/.npm-global'` then add `~/.npm-global/bin` to PATH |

**Recommended Resolution Strategy** (based on npm official docs):
```bash
# Method 1: Change npm global directory to user directory
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
# Add to ~/.zshrc:
export PATH="$HOME/.npm-global/bin:$PATH"

# Method 2: Fix Homebrew Node.js directory ownership
sudo chown -R $(whoami) $(brew --prefix)/lib/node_modules
sudo chown -R $(whoami) $(brew --prefix)/bin
```

---

### 3.3 Apple Silicon native vs Rosetta Node.js

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| AS1 | brew install node in Rosetta terminal | x86_64 Node.js installed (`/usr/local/bin/node`) | Terminal running in Rosetta mode, using Intel Homebrew | Terminal.app Info > Uncheck "Open using Rosetta". Verify with `arch` command |
| AS2 | ARM64 Node.js + x86_64 npm packages | `Error: Unsupported platform: darwin-arm64` or `mach-o file, but is an incompatible architecture (have 'x86_64', need 'arm64')` | npm packages installed in Rosetta environment, containing only x86_64 binaries | `rm -rf node_modules && npm install` (in ARM64 terminal) |
| AS3 | esbuild/swc architecture mismatch | `Error: The package "esbuild-darwin-arm64" could not be found` | package-lock.json generated in a different architecture environment | `rm package-lock.json node_modules && npm install` |
| AS4 | Two Homebrew installations simultaneously | Confusing behavior, duplicate packages | Both `/usr/local` (Intel) and `/opt/homebrew` (ARM64) exist | Remove Intel Homebrew: delete `/usr/local/bin/brew` and use ARM64 only |
| AS5 | Legacy packages like node-sass | `Unsupported architecture (arm64)` | Legacy packages do not provide ARM64 binaries | Use alternative packages (e.g., `node-sass` -> `sass`) |

**Architecture Check Commands**:
```bash
# Check current architecture
arch                          # arm64 or i386
uname -m                      # arm64 or x86_64

# Check Node.js architecture
node -p "process.arch"        # arm64 or x64

# Check Homebrew architecture
file $(which brew)            # Mach-O 64-bit executable arm64
```

---

### 3.4 node-gyp / Native Module Compilation Errors

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| NG1 | Xcode CLT not installed | `gyp: No Xcode or CLT version detected!` | node-gyp requires C++ compiler (clang) | `xcode-select --install` |
| NG2 | After macOS upgrade | `gyp ERR! stack Error: Could not find any Python installation to use` or `xcrun: error: invalid active developer path` | macOS upgrade invalidated CLT | `sudo xcode-select --reset` or re-run `xcode-select --install` |
| NG3 | Apple Silicon + old native modules | `ld: warning: ignoring file, building for macOS-x86_64 but attempting to link with file built for macOS-arm64` | Native module does not support ARM64 or mixed architectures | Update module or `npm rebuild` |
| NG4 | node-gyp + Python 3.12+ | `ModuleNotFoundError: No module named 'distutils'` | distutils module removed in Python 3.12 (PEP 632) | **Update to node-gyp v10+**: `npm install -g node-gyp@latest` or `pip3 install setuptools` |
| NG5 | macOS Sonoma + CLT only (Xcode not installed) | `xcode-select: error: tool 'xcodebuild' requires Xcode` | Some node-gyp versions require full Xcode | `sudo xcode-select -s /Library/Developer/CommandLineTools` or update node-gyp to latest version |
| NG6 | `-march=native` compiler flag | `error: the clang compiler does not support '-march=native'` | Apple Silicon's clang does not support certain x86 compiler flags | Remove flag from the module's binding.gyp or update the module |

---

### 3.5 Xcode Command Line Tools Requirements

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| XC1 | CLT completely not installed | `xcode-select: note: no developer tools were found at '/Applications/Xcode.app'` | No development tools on clean macOS | `xcode-select --install` (approximately 1.2GB download) |
| XC2 | After macOS major upgrade | `xcrun: error: invalid active developer path (/Library/Developer/CommandLineTools)` | OS upgrade invalidated CLT. Installation record remains but binaries invalid | `sudo rm -rf /Library/Developer/CommandLineTools && xcode-select --install` |
| XC3 | Xcode installed + CLT not installed | Xcode present but CLI build fails | CLT may need to be installed separately even with Xcode | `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` or install CLT separately |
| XC4 | CLT version mismatch | `Agreeing to the Xcode/iOS license requires admin privileges` | License agreement needed after Xcode update | `sudo xcodebuild -license accept` |
| XC5 | CLT update not available via `softwareupdate` | CLT update not in software update list | Apple software update catalog issue | Download directly from Apple Developer site: https://developer.apple.com/download/all/ |

**CLT Status Check**:
```bash
# Check CLT installation
xcode-select -p                    # Display installation path
xcode-select --version             # Check version
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables  # Detailed info

# Check tools included in CLT
gcc --version     # Apple clang version
make --version    # GNU Make
```

---

### 3.6 Python Dependency Issues (node-gyp)

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| PY1 | Python 3.12+ (Homebrew) | `ModuleNotFoundError: No module named 'distutils'` | `distutils` removed in Python 3.12. node-gyp depends on it | `npm install -g node-gyp@latest` (v10+ does not need distutils) or `pip3 install setuptools` |
| PY2 | Python not installed | `gyp ERR! find Python - Python is not set` | No Python on macOS (recent macOS removed Python 2) | `brew install python@3.11` or install Xcode CLT (includes Python 3) |
| PY3 | Multiple Python versions | node-gyp uses wrong Python version | Multiple Python in PATH, node-gyp selects incompatible version | `npm config set python /usr/bin/python3` or `export npm_config_python=$(which python3)` |
| PY4 | Python 2 / Python 3 mixed | `gyp ERR! stack Error: Could not find any Python installation to use` | node-gyp v5+ requires Python 3.6+. Fails if only Python 2 available | Install Python 3: `brew install python` |
| PY5 | macOS system Python removed | `/usr/bin/python: No such file or directory` | Python 2 (`/usr/bin/python`) removed in macOS 12.3+ | `brew install python` then `npm config set python $(which python3)` |

---

### 3.7 PATH Conflicts (Multiple Node.js Installations)

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| PA1 | nvm + Homebrew node | `node -v` result differs from expected | `~/.nvm` path precedes Homebrew in PATH | Use only one. `brew uninstall node` recommended (when using nvm) |
| PA2 | Intel Homebrew + ARM Homebrew | Two `node` binaries exist | `/usr/local/bin/node` (Intel) and `/opt/homebrew/bin/node` (ARM) conflict | Remove Intel Homebrew: delete `/usr/local/Homebrew` |
| PA3 | Manual install + Homebrew | `env: node: No such file or directory` (in scripts) | PATH differs in non-interactive shell, cannot find node | Add PATH settings to `~/.zshenv` (instead of `.zshrc`) |
| PA4 | npm global bin and PATH | Commands installed via `npm install -g` won't run | npm global bin path not in PATH | Add `export PATH="$(npm config get prefix)/bin:$PATH"` to shell rc |
| PA5 | volta shim conflict | Packages installed via `volta` not visible from Homebrew node | volta uses its own shim directory (`~/.volta/bin`) | Use only one of volta or Homebrew node |

**PATH Debugging Commands**:
```bash
# Check current node location and version
which -a node          # Show all node paths
node -v                # Current active version
npm config get prefix  # npm global install path

# Check PATH order
echo $PATH | tr ':' '\n'

# Check which shell config files modify PATH
grep -n 'PATH\|nvm\|fnm\|volta' ~/.zshrc ~/.zprofile ~/.zshenv ~/.bash_profile 2>/dev/null
```

---

### 3.8 npm Registry Access Issues (Corporate Proxy/VPN)

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| NR1 | Corporate proxy | `npm ERR! network request to https://registry.npmjs.org failed, reason: connect ETIMEDOUT` | HTTP/HTTPS proxy blocks direct connection | `npm config set proxy http://proxy.company.com:8080` and `npm config set https-proxy http://proxy.company.com:8080` |
| NR2 | SSL inspection proxy (MITM) | `npm ERR! code UNABLE_TO_VERIFY_LEAF_SIGNATURE` | Corporate security solution intercepts SSL traffic and replaces certificates | **Recommended**: `npm config set cafile /path/to/corporate-ca.pem`. **Temporary workaround**: `npm config set strict-ssl false` (security risk) |
| NR3 | VPN + split tunneling | `npm ERR! code ECONNREFUSED` or very slow installation | VPN misroutes npm registry traffic | Request `registry.npmjs.org` exclusion in VPN split tunneling settings |
| NR4 | DNS resolution failure | `npm ERR! code EAI_AGAIN` or `getaddrinfo ENOTFOUND registry.npmjs.org` | DNS server not responding | Check DNS: `nslookup registry.npmjs.org`. Change DNS server (8.8.8.8 etc.) |
| NR5 | Firewall blocks port 443 | `npm ERR! network socket hang up` | Corporate firewall blocks specific domain/port | Request IT admin to allow `registry.npmjs.org:443` |
| NR6 | Internal npm registry | Public packages not found | `.npmrc` only configured with internal registry | `npm config set registry https://registry.npmjs.org/` or verify public package mirroring on internal registry |

**Proxy Settings Check and Resolution**:
```bash
# Check current npm settings
npm config list
npm config get proxy
npm config get https-proxy
npm config get registry

# Corporate CA certificate configuration
npm config set cafile /etc/ssl/certs/corporate-ca-bundle.crt

# Proxy settings
npm config set proxy http://proxy.company.com:8080
npm config set https-proxy http://proxy.company.com:8080
```

---

### 3.9 npm Cache Corruption

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| NC1 | Network disconnected during install | `npm ERR! code EINTEGRITY` `sha512-... integrity checksum failed` | Download incomplete, cached package hash mismatch | `npm cache clean --force && npm install` |
| NC2 | After npm version upgrade | `npm ERR! Unexpected end of JSON input` | Old npm cache format incompatible with new version | `npm cache verify` or `npm cache clean --force` |
| NC3 | Cache corrupted due to disk space shortage | `ENOSPC: no space left on device` repeated | npm cache (`~/.npm/_cacache`) exhausted disk space | Free disk space then `npm cache clean --force` |
| NC4 | `package-lock.json` mismatch | `EINTEGRITY` error only on specific packages | package-lock.json integrity hash mismatches current registry version | `rm package-lock.json && npm install` |
| NC5 | Cache write failed due to permissions | `EACCES: permission denied, open '/Users/<user>/.npm/_cacache/...'` | Parts of `~/.npm` directory owned by root | `sudo chown -R $(whoami) ~/.npm` |

**Cache Management Commands**:
```bash
# Check cache status
npm cache verify

# Force clean cache
npm cache clean --force

# Check cache location
npm config get cache    # Default: ~/.npm

# Complete clean install
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

---

### 3.10 brew link Errors

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| BL1 | Previous Node.js installation remains | `Error: Could not symlink bin/node. Target /opt/homebrew/bin/node already exists.` | Files remain from previous manual or alternative installation | `brew link --overwrite node` |
| BL2 | keg-only formula | `Warning: node is keg-only and must be linked with --force` | Specific version of node installed as keg-only (e.g., `node@18`) | `brew link --force node@18` then add to PATH: `export PATH="$(brew --prefix node@18)/bin:$PATH"` |
| BL3 | Directory permission issue | `Error: Could not symlink share/man/man1/node.1. /opt/homebrew/share/man/man1 is not writable.` | Homebrew directory not owned by current user | `sudo chown -R $(whoami) $(brew --prefix)/share/man` |
| BL4 | Another node version already linked | `Error: node conflicts with node@20` | Multiple node versions installed, causing conflict | `brew unlink node@20 && brew link node` |
| BL5 | Homebrew prefix mismatch | `Error: Could not symlink` repeated failure | ARM/Intel Homebrew coexistence causing prefix path conflict | Run `brew doctor` to diagnose, then use only one Homebrew |

**brew link Diagnosis and Resolution**:
```bash
# Diagnose Homebrew status
brew doctor

# Check current link status
brew list --versions node
brew info node

# Force link
brew link --overwrite --force node

# Unlink all then re-link
brew unlink node && brew link node
```

---

## 4. Git Error Cases

### 4.1 Apple Default Git vs Homebrew Git Conflict

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| AG1 | After brew install git | `which git` still shows `/usr/bin/git` | macOS default `/usr/bin/git` precedes Homebrew in PATH | Restart shell or verify `eval "$(/opt/homebrew/bin/brew shellenv)"`. Homebrew must precede `/usr/bin` in PATH |
| AG2 | On Apple Silicon | `git --version` shows Apple Git (e.g., `git version 2.39.5 (Apple Git-154)`) | `/opt/homebrew/bin` not in PATH | Add `eval "$(/opt/homebrew/bin/brew shellenv)"` to `~/.zprofile` |
| AG3 | Mixed use of two Git versions | Git settings/hooks behave unexpectedly | Apple Git and Homebrew Git may reference different config paths | Check all git paths with `which -a git` then keep only desired one in PATH |
| AG4 | IDE/editor uses different Git | VS Code etc. use system Git (`/usr/bin/git`) | IDE uses separate PATH or hardcoded path | VS Code: set `"git.path": "/opt/homebrew/bin/git"` |

---

### 4.2 Xcode Git vs Standalone Git

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| XG1 | Xcode installed | `/usr/bin/git` is Xcode's Git shim | `/usr/bin/git` is not the actual binary but a shim to Xcode CLT | Verify PATH priority when using Homebrew Git |
| XG2 | After Xcode update | `xcrun: error: invalid active developer path` | Xcode update changed the developer path | `sudo xcode-select --reset` |
| XG3 | After Xcode deletion | Running `git` command shows Xcode installation dialog | `/usr/bin/git` shim requires Xcode/CLT | `xcode-select --install` or `brew install git` |
| XG4 | Xcode CLT version < Git minimum requirement | Certain Git features not working | Git version included in Apple's CLT may not be latest (usually 3-6 months behind) | Install latest version with `brew install git` |

---

### 4.3 Git Credential Helper Issues (Keychain)

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| GC1 | After password change | `remote: Invalid username or password. fatal: Authentication failed` | Previous credentials stored in macOS Keychain expired/changed | Delete `github.com` entry in Keychain Access.app or `git credential-osxkeychain erase` |
| GC2 | After enabling GitHub 2FA | `remote: Support for password authentication was removed` | Personal Access Token (PAT) or SSH key required instead of password | Set up SSH key or install Git Credential Manager (GCM): `brew install --cask git-credential-manager` |
| GC3 | credential.helper not set | Password prompt every time | Git not configured to use macOS Keychain | `git config --global credential.helper osxkeychain` or use GCM |
| GC4 | Homebrew Git + osxkeychain | `git: 'credential-osxkeychain' is not a git command` | Homebrew Git does not include osxkeychain helper or path mismatch | `brew install git` (latest version includes it) or install GCM |
| GC5 | Keychain locked during remote access | `error: unable to read askpass response` | macOS Keychain locked in SSH/remote session | `security unlock-keychain ~/Library/Keychains/login.keychain` or use SSH key-based authentication |

**Credential Configuration Recommendations**:
```bash
# Method 1: Git Credential Manager (recommended, 2FA/OAuth support)
brew install --cask git-credential-manager
git config --global credential.helper manager

# Method 2: macOS Keychain (default)
git config --global credential.helper osxkeychain

# Reset credentials
echo -e "protocol=https\nhost=github.com" | git credential-osxkeychain erase
```

---

### 4.4 SSH Key Issues (macOS Keychain Integration)

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| SK1 | SSH key lost after macOS restart | `Permission denied (publickey)` (occurs after reboot) | ssh-agent forgets keys on restart | Add `AddKeysToAgent yes` and `UseKeychain yes` to `~/.ssh/config` |
| SK2 | `ssh-add --apple-use-keychain` not working | `ssh-add: illegal option -- apple-use-keychain` | OpenSSH installed via Homebrew does not support Apple extension options | Use Apple default `/usr/bin/ssh-add`: `/usr/bin/ssh-add --apple-use-keychain ~/.ssh/id_ed25519` |
| SK3 | `-K` / `-A` flags deprecated | `WARNING: -K and -A flags are deprecated` | Flag names changed in macOS Monterey+ | Use `-K` -> `--apple-use-keychain`, `-A` -> `--apple-load-keychain` |
| SK4 | SSH config not configured | Passphrase prompt every time | Keychain integration not configured in SSH config | Add SSH config below |
| SK5 | Incorrect key algorithm | `no mutual signature algorithm` | Old RSA key (1024bit) not supported | Generate ED25519 key: `ssh-keygen -t ed25519 -C "email@example.com"` |
| SK6 | `~/.ssh` directory permissions | `Permissions 0777 for '/Users/<user>/.ssh/id_ed25519' are too open.` | SSH key file permissions are too open | `chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_* && chmod 644 ~/.ssh/*.pub` |

**Recommended SSH config** (`~/.ssh/config`):
```
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
```

**SSH Key Generation and Registration**:
```bash
# Generate ED25519 key (recommended)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to macOS Keychain (must use Apple SSH)
/usr/bin/ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Test connection
ssh -T git@github.com
```

---

### 4.5 Git LFS Issues

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| LF1 | Git LFS not installed | `git: 'lfs' is not a git command. See 'git --help'.` | git-lfs is not installed | `brew install git-lfs && git lfs install` |
| LF2 | Homebrew Git + Xcode Git path mismatch | `git lfs` works in terminal but not in scripts/IDE | Scripts use `/usr/bin/git` but git-lfs only exists in Homebrew path | Create symlink: `sudo ln -s "$(which git-lfs)" "$(git --exec-path)/git-lfs"` |
| LF3 | `git lfs install` not executed | LFS files downloaded as pointer files only (few bytes of text) | Hooks not registered via `git lfs install` | `git lfs install && git lfs pull` |
| LF4 | LFS bandwidth/storage limit exceeded | `batch response: This repository is over its data quota` | GitHub LFS free limit (1GB storage, 1GB/month bandwidth) exceeded | Purchase LFS data pack or clean up unnecessary LFS files |
| LF5 | LFS + corporate proxy | `LFS: client error 407` | Proxy authentication required | `git config --global http.proxy http://user:pass@proxy:8080` |

---

### 4.6 Corporate Proxy/SSL Certificate Issues

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| GS1 | SSL inspection proxy | `SSL certificate problem: unable to get local issuer certificate` | Corporate proxy intercepts SSL traffic and replaces with its own certificate | `git config --global http.sslCAInfo /path/to/corporate-ca.pem` |
| GS2 | Self-signed certificate | `SSL certificate problem: self-signed certificate in certificate chain` | Internal Git server uses self-signed certificate | Add corporate CA certificate to system Keychain or set `git config --global http.sslCAInfo` |
| GS3 | Corporate proxy authentication | `Proxy Authentication Required (407)` | Proxy requires NTLM/Basic authentication | `git config --global http.proxy http://user:password@proxy.company.com:8080` |
| GS4 | Disable SSL (not recommended) | Ignore security warning | SSL verification disabled | `git config --global http.sslVerify false` (**Security risk! Use only for temporary debugging**) |
| GS5 | macOS Keychain + corporate CA | `SecTrustEvaluateWithError: The certificate chain is not trusted` | Corporate CA not in macOS system trust store | Keychain Access.app > Add corporate CA certificate to system Keychain and set to "Always Trust" |

**Corporate Environment SSL Configuration**:
```bash
# Export corporate CA certificate (from browser)
# 1. Access Git server via browser
# 2. Lock icon > View certificate > Export root CA (PEM format)

# Register CA certificate with Git
git config --global http.sslCAInfo /usr/local/share/ca-certificates/corporate-ca.pem

# Apply to specific host only
git config --global http.https://git.company.com/.sslCAInfo /path/to/corporate-ca.pem
```

---

### 4.7 Case-Insensitive Filesystem (APFS)

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| CF1 | Changing only filename case | `git mv README.md Readme.md` not detected as a change | macOS APFS is case-insensitive by default | Rename in two steps: `git mv README.md temp.md && git mv temp.md Readme.md` |
| CF2 | Cloning repo created on Linux | Files with same name but different case (e.g., `File.js` and `file.js`) only one visible | APFS does not distinguish case, causing file overwrite | Set `git config --global core.ignorecase false` (can detect but cannot resolve filesystem limitation) |
| CF3 | Failure in CI/CD (Linux) | Build succeeds on macOS but import path error on Linux CI | `import './Component'` vs `'./component'` are the same on macOS but different on Linux | Match import path case exactly with filename. Enable ESLint `import/no-unresolved` rule |
| CF4 | Directories with different case | `src/Components/` and `src/components/` conflict | Treated as the same directory in APFS | Unify directory names. Create case-sensitive volume (Disk Utility > APFS Case-sensitive volume) |

**Preventive Measures**:
```bash
# Enable Git case detection
git config --global core.ignorecase false

# Create case-sensitive volume (for development only)
# Disk Utility > Add Volume > APFS (Case-sensitive)
# Or via CLI:
diskutil apfs addVolume disk1 "APFS (Case-sensitive)" DevCode
```

---

### 4.8 .gitconfig Location Issues

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| GF1 | Using XDG_CONFIG_HOME setting | `~/.gitconfig` settings ignored | `$XDG_CONFIG_HOME/git/config` takes priority over `~/.gitconfig` if it exists | Use only one location. Check which file is applied with `git config --list --show-origin` |
| GF2 | `~/.config/git/config` exists | Settings applied differently than expected | If XDG_CONFIG_HOME is not set, `~/.config` is the default. This file is used if `~/.gitconfig` does not exist | Check setting source with `git config --list --show-origin --show-scope` |
| GF3 | System gitconfig conflict | `includeIf` etc. not working as expected | `/etc/gitconfig` or Homebrew's `$(brew --prefix)/etc/gitconfig` exists | Check all config file locations with `git config --list --show-origin` |
| GF4 | Corporate MDM deploys gitconfig | User settings overwritten | MDM manages `/etc/gitconfig` or system-level settings | Use per-project settings with `--local` flag: `git config --local user.email "email@example.com"` |

**gitconfig Location Priority** (low priority -> high priority):
```
1. $(brew --prefix)/etc/gitconfig          # Homebrew system
2. /etc/gitconfig                           # System
3. ~/.gitconfig or $XDG_CONFIG_HOME/git/config  # Global
4. .git/config                              # Local (project)
5. .git/config.worktree                     # Worktree
6. Command line option (-c)                  # One-time
```

```bash
# Check all settings and their sources
git config --list --show-origin --show-scope

# Check source of specific setting
git config --show-origin --show-scope user.email
```

---

### 4.9 Outdated Git Version Issues

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| GV1 | Using Apple default Git | Latest Git features (e.g., early support for `git switch`, `git restore`) not working | Git provided by Apple can be 3-6 months behind latest release | Install latest version with `brew install git` |
| GV2 | Installation popup on first `git` run | "The git command requires the command line developer tools. Would you like to install them?" | Git not installed (clean macOS). `/usr/bin/git` is a CLT shim | Click "Install" to install Xcode CLT or `brew install git` |
| GV3 | After macOS major upgrade | `xcrun: error: invalid active developer path` | OS upgrade invalidated CLT, breaking git shim | Re-run `xcode-select --install` |
| GV4 | CLT update not available | CLT update not shown in `softwareupdate -l` | Apple software update catalog issue | Download directly from Apple Developer site: https://developer.apple.com/download/all/ |
| GV5 | Relatively new options like `git -C` not supported | `unknown option: -C` | Apple Git version is too old | `brew install git` |

**Git Version Check and Update**:
```bash
# Check Apple Git version
/usr/bin/git --version          # git version 2.x.x (Apple Git-xxx)

# Check Homebrew Git version
/opt/homebrew/bin/git --version  # git version 2.x.x (Homebrew latest)
# Or Intel Mac:
/usr/local/bin/git --version

# Install latest Git via Homebrew
brew install git

# Check currently active Git
which git && git --version
```

---

## 5. VS Code Installation Errors

### 5.1 Homebrew Cask Installation Failure

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| VC1 | Homebrew not installed | `zsh: command not found: brew` | Homebrew is not installed on macOS | Run `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`. For Apple Silicon, add `eval "$(/opt/homebrew/bin/brew shellenv)"` to `~/.zprofile` after installation |
| VC2 | Outdated Homebrew version | `Error: Cask 'visual-studio-code' is unreadable` or download URL 404 | Local Homebrew metadata does not match latest cask information | Run `brew update` then retry |
| VC3 | SHA256 mismatch | `Error: SHA256 mismatch. Expected: ... Actual: ...` | File updated on source server but Homebrew cache references old hash | Retry after `brew update-reset && brew update`. Or `brew install --cask visual-studio-code --force` |
| VC4 | Existing VS Code present | `Error: It seems there is already an App at '/Applications/Visual Studio Code.app'` | VS Code already exists from manual installation | `brew install --cask visual-studio-code --force` or delete existing app then retry |
| VC5 | Conflict with VSCodium | `Error: Cask 'vscodium' conflicts with 'visual-studio-code'` | VSCodium and VS Code cask defined as mutually conflicting | Uninstall one then install the desired one |
| VC6 | Xcode CLT not installed | `Error: No developer tools installed. Install the Command Line Tools` | Xcode Command Line Tools required for Homebrew not present | Run `xcode-select --install` |
| VC7 | Insufficient disk space | `Error: No space left on device` | VS Code ~500MB, more needed with extensions | Free up disk space then retry |
| VC8 | macOS Catalina (10.15) or below | Installation succeeds but cannot run, or installation fails | VS Code 1.97+ dropped macOS 10.15 support | Upgrade macOS or manually install VS Code 1.97 or below |
| VC9 | Apple Silicon + wrong architecture | Rosetta emulation warning, slow performance | Running Intel (x64) version on Apple Silicon | `brew install --cask visual-studio-code` automatically installs ARM64 version. For manual installation, verify "Apple Silicon" build download |
| VC10 | Corporate proxy/firewall | `curl: (35) SSL connect error` or download timeout | CDN blocked by corporate network | Set `export HOMEBREW_PROXY=http://proxy:port`. Or set `ALL_PROXY` environment variable |

---

### 5.2 `code` Command PATH Issues

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| VP1 | Right after installation | `zsh: command not found: code` | VS Code does not automatically create `code` symlink (macOS-specific behavior) | In VS Code, run `Cmd+Shift+P` > "Shell Command: Install 'code' command in PATH" |
| VP2 | Running outside Applications folder | `code` command stops working after reboot | macOS App Translocation runs app from temporary path, breaking symlink path | Move VS Code to `/Applications/` folder then reinstall Shell Command |
| VP3 | Manual PATH configuration | `code` stops working after terminal restart | PATH not added to `~/.zshrc` or incorrect path used | Add `export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"` to `~/.zshrc` |
| VP4 | Using multiple shells | Works in bash but not in zsh | Different profile files used per shell | Add PATH to each: zsh: `~/.zshrc`, bash: `~/.bash_profile`, fish: `~/.config/fish/config.fish` |
| VP5 | Persistent symlink creation | `code` disappears after every reboot/update | VS Code internal path may change during updates | Create persistent symlink: `sudo ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code` |

---

### 5.3 Gatekeeper / Quarantine Issues

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| VG1 | Direct download (non-Homebrew) | `"Visual Studio Code" is damaged and can't be opened` | macOS assigns quarantine attribute to downloaded .app | `sudo xattr -r -d com.apple.quarantine "/Applications/Visual Studio Code.app"` |
| VG2 | Gatekeeper blocking | `"Visual Studio Code" can't be opened because Apple cannot check it for malicious software` | Gatekeeper signature verification failed | System Preferences > Security & Privacy > Click "Open Anyway". Or Control+click > Open |
| VG3 | macOS Sequoia enhanced security | Previous bypass methods no longer work | On Sequoia, confirmation still required in System Settings even after `spctl --master-disable` | Allow directly in System Settings > Privacy & Security. Use Homebrew `--no-quarantine` flag: `brew install --cask visual-studio-code --no-quarantine` |
| VG4 | Full Disk Access required | `Operation not permitted` (when removing xattr) | Terminal does not have Full Disk Access permission on latest macOS | System Settings > Privacy & Security > Full Disk Access > Add Terminal.app |

---

### 5.4 Extension Installation Failure

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| VE1 | `code` command not registered | Cannot install extensions after `code: command not found` | `code` command must be in PATH to install extensions from CLI | Resolve VP1 above then retry |
| VE2 | Network error | `Error: connect ENOENT` or `Failed to fetch extension` | Cannot connect to marketplace server (proxy, DNS) | Set `http.proxy` in VS Code settings. Or allow `marketplace.visualstudio.com` in corporate firewall |
| VE3 | Permission issue | `EACCES: permission denied, open '.../.vscode/extensions/extensions.json'` | `~/.vscode/extensions` directory ownership issue (history of running VS Code with sudo, etc.) | `sudo chown -R $USER:staff ~/.vscode && chmod -R u+rwX ~/.vscode` |
| VE4 | Corrupted VSIX file | `End of central directory record signature not found` | Bundled extension VSIX file is corrupted | Re-download VSIX file then `code --install-extension <path>.vsix` |
| VE5 | Unsigned marketplace extension | `Extension is not signed by the marketplace` | Extension not signed by publisher | Change `extensions.verifySignature` to `false` in VS Code settings (be aware of security risk) |
| VE6 | Corporate extension restriction policy | Extension installation blocked message | MDM policy blocks extensions not included in `extensions.allowed` | Request IT admin to allow the extension |
| VE7 | Compatibility issue | `Incompatible: requires VS Code ^x.y.z` | Extension requires higher VS Code version than installed | Update VS Code then retry |

---

### 5.5 VS Code Insiders vs Stable Conflict

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| VI1 | CLI conflict with both installed | `code` command always runs Stable | Insiders uses `code-insiders`, Stable uses `code` command | Add `code-insiders` command to checks for Insiders users |
| VI2 | Settings Sync conflict | Settings sync data compatibility issue | Insiders and Stable use different Sync services | Disable simultaneous Sync or use Sync on only one |
| VI3 | Extension compatibility | Extension works in Insiders but fails in Stable (or vice versa) | Insiders uses newer API, causing extension compatibility differences | Use only one or test on both |

---

### 5.6 Enterprise MDM Blocking

| # | Environment/Condition | Error Message/Symptom | Cause | Solution |
|---|----------|----------------|------|----------|
| VM1 | MDM blocks app installation | Installation itself impossible | JAMF/Intune etc. block unauthorized app installation | Request IT admin to approve VS Code app |
| VM2 | No PKG installer provided | Cannot mass deploy via JAMF/Intune | Microsoft provides macOS VS Code only as .app (no PKG) | Wrap ZIP file for MDM deployment, or wrap Homebrew cask in a script for deployment |
| VM3 | "Managed by Organization" displayed | Certain settings are locked | MDM profile sets VS Code policies (`com.microsoft.VSCode` plist) | Request IT admin to unlock required settings |
| VM4 | Update blocked | VS Code auto-update fails | MDM blocks app modification | Only the version deployed by IT admin can be used |

---

### 5.7 Apple Silicon (Rosetta 2) 문제

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| VA1 | Intel 버전을 Apple Silicon에서 실행 | 에뮬레이션 경고 배너, 현저히 느린 성능 | x86_64 빌드가 Rosetta 2 번역을 거쳐 실행됨 | Apple Silicon(ARM64) 빌드 재설치. `file /Applications/Visual\ Studio\ Code.app/Contents/MacOS/Electron` 명령으로 아키텍처 확인 |
| VA2 | Universal Binary 혼란 | 성능이 기대보다 낮음 | Universal Binary가 때때로 Intel 바이너리를 우선 로드 | Activity Monitor에서 VS Code 프로세스의 "Kind" 열 확인. "Intel"이면 ARM64 전용 빌드 재설치 |
| VA3 | 확장 네이티브 모듈 | 확장이 로드 실패 또는 느림 | 확장의 네이티브 바이너리가 x86_64 전용으로 빌드됨 | 확장 업데이트 확인 |

---

### 5.8 Remote SSH 확장 문제

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| VR1 | 원격 서버 연결 실패 | `Could not establish connection. The VS Code Server failed to start` | 원격 서버에서 VS Code Server 설치/시작 실패 | 원격 서버의 `~/.vscode-server/` 삭제 후 재시도 |
| VR2 | Server 설치 중 멈춤 | `Waiting for server log...` 반복 | wget/curl 다운로드 실패 또는 서버 방화벽 차단 | 원격 서버에서 `https://update.code.visualstudio.com` 접근 가능 여부 확인 |
| VR3 | 확장 버전 호환성 | 특정 Remote-SSH 버전에서 연결 실패 | Remote-SSH 확장의 특정 버전에 버그 (예: v0.109.0) | 이전 안정 버전으로 다운그레이드 (예: v0.107.1) |
| VR4 | 메모리 부족 (원격) | 서버 연결 후 바로 끊김 | VS Code Server + Node.js가 원격 서버에서 과도한 메모리 사용 | 원격 서버 메모리 확인 (최소 1GB 여유 권장) |
| VR5 | SSH 키 인증 실패 | `Permission denied (publickey)` | macOS Keychain과 VS Code의 SSH agent 포워딩 차이 | `~/.ssh/config` 에 `AddKeysToAgent yes` 및 `UseKeychain yes` 추가 |

---

### 5.9 터미널 통합 (Shell Detection) 문제

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| VT1 | 쉘 변경 미감지 | VS Code가 이전 쉘(bash)을 계속 사용 | `chsh` 로 기본 쉘을 변경했으나 VS Code가 캐시 | `terminal.integrated.defaultProfile.osx` 를 명시적으로 설정 |
| VT2 | Shell Integration 비활성 | 명령 데코레이션, Sticky Scroll 등 미동작 | Shell Integration 자동 주입 실패 | `~/.zshrc`에 `. "$(code --locate-shell-integration-path zsh)"` 수동 추가 |
| VT3 | Powerlevel10k 충돌 | Shell Integration 관련 경고 또는 프롬프트 깨짐 | Powerlevel10k 테마가 Shell Integration과 충돌 | Powerlevel10k 최신 버전 업데이트 |
| VT4 | fish shell 미지원 (구버전) | Shell Integration 자동 주입 실패 | fish 구버전이 `$XDG_DATA_DIRS` 미지원 | fish 3.6.0 이상으로 업데이트 |

---

### 5.10 확장 디렉토리 권한 문제

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| VD1 | sudo로 VS Code 실행 이력 | `EACCES: permission denied` (확장 설치/업데이트 시) | `sudo code` 로 실행하면 `~/.vscode/extensions` 소유권이 root로 변경됨 | `sudo chown -R $USER:staff ~/.vscode` 실행. 절대 `sudo code` 사용 금지 |
| VD2 | 마이그레이션 후 권한 | 확장 로드 실패 | Time Machine 복원 또는 Migration Assistant 사용 후 권한 불일치 | `sudo chown -R $USER:staff ~/.vscode && chmod -R u+rwX ~/.vscode` |
| VD3 | 여러 사용자 계정 | 다른 사용자의 확장과 충돌 | macOS 멀티 유저 환경에서 `~/.vscode` 디렉토리 공유 불가 | 각 사용자 홈 디렉토리의 `~/.vscode` 확인. `--extensions-dir` 로 경로 지정 |

---

## 6. Docker Desktop 설치 에러

### 6.1 Apple Silicon (M1/M2/M3/M4) 호환성 문제

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| DA1 | x86 이미지 실행 실패 | `exec format error` 또는 `no matching manifest for linux/arm64` | ARM64 Mac에서 x86_64 전용 이미지 실행 시도 | `--platform linux/amd64` 플래그 사용. 또는 "Use Rosetta for x86_64/amd64 emulation" 활성화 |
| DA2 | Rosetta 에뮬레이션 느림 | 빌드/실행이 현저히 느림 | QEMU 기반 x86 에뮬레이션 (네이티브 대비 10-20x 느림) | Rosetta 활성화 (QEMU 대비 4-5x 빠름). 가능하면 ARM64 네이티브 이미지 사용 |
| DA3 | pip/npm 패키지 설치 실패 (빌드 중) | `no matching distribution found` 또는 `platform mismatch` | Dockerfile에서 x86 전용 패키지를 ARM 환경에서 빌드 시도 | `FROM --platform=linux/amd64` 지정. 또는 ARM 호환 패키지 사용 |
| DA4 | M3/M4 칩 특정 문제 | 컨테이너 빌드/실행 중 크래시 | 최신 Apple Silicon 칩과 Docker Desktop 특정 버전 간 호환성 문제 | Docker Desktop 최신 버전 업데이트. 또는 안정 버전(예: 4.32.0)으로 다운그레이드 |
| DA5 | Rosetta 2 에뮬레이션 100% CPU | 컨테이너가 응답 없음, CPU 100% 고정 | Rosetta 에뮬레이션 하에서 특정 Node.js/amd64 워크로드가 무한 루프에 빠짐 | Rosetta 비활성화 후 QEMU로 전환. 또는 해당 워크로드를 ARM64 네이티브로 전환 |

---

### 6.2 Rosetta 2 요구사항

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| DR1 | Rosetta 2 미설치 | Docker Desktop 설치 실패 또는 일부 CLI 도구 오류 | 일부 Docker Desktop 컴포넌트가 여전히 Rosetta 2 필요 | `softwareupdate --install-rosetta --agree-to-license` 실행 |
| DR2 | Rosetta 설정 오류 메시지 | `Rosetta is only intended to run on Apple Silicon` | macOS Sequoia에서 Rosetta 관련 설정 충돌 | Docker Desktop 최신 버전 업데이트. "Use Rosetta" 토글 해제 후 재활성화 |
| DR3 | x86 컨테이너 성능 경고 | `WARNING: The requested image's platform (linux/amd64) does not match the detected host platform` | ARM Mac에서 x86 이미지를 에뮬레이션하지만 성능 저하 | ARM64 네이티브 이미지 사용. `docker buildx build --platform linux/arm64` |

---

### 6.3 Docker Desktop 라이선스

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| DL1 | 250인+ 기업 | Docker Desktop 사용 시 라이선스 위반 | 250명 이상 또는 연매출 $10M 이상 기업은 유료 구독 필수 | Docker Business ($24/월/사용자) 또는 Docker Pro ($5/월) 구독. 또는 Colima/Lima 사용 |
| DL2 | 인증 요구 | Docker Desktop 로그인 프롬프트 | 2024년 12월 이후 유료 플랜 가격 변경, 기업 사용자 인증 강화 | Docker Hub 계정으로 로그인. 기업은 SSO/SCIM 설정 |
| DL3 | 오프라인 환경 | 라이선스 검증 실패 | Docker Desktop이 라이선스 서버에 주기적으로 접속 필요 | 오프라인 라이선스 토큰 설정 |

---

### 6.4 Virtualization Framework / QEMU 백엔드

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| DV1 | QEMU 지원 종료 | Docker Desktop 기동 경고 | QEMU 가상화 옵션이 2025년 7월 14일부로 완전 deprecated | "Use Virtualization Framework" 활성화. Apple Virtualization Framework 또는 Docker VMM으로 전환 |
| DV2 | Apple Virtualization Framework 오류 | VM 시작 실패 | 하이퍼바이저 권한 문제 | `sysctl kern.hv_support` 로 확인. 시스템 설정 > 보안에서 가상화 허용 |
| DV3 | Docker VMM (Beta) 불안정 | 간헐적 크래시 또는 성능 저하 | Docker VMM이 아직 Beta 상태 | 안정적인 Apple Virtualization Framework 사용 |
| DV4 | 가상화 미지원 (구형 Mac) | `HV support: 0` | Intel Mac 중 하이퍼바이저 미지원 모델 | `sysctl kern.hv_support` 로 확인 |

---

### 6.5 Docker 데몬 미시작

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| DD1 | 데몬 연결 실패 | `Cannot connect to the Docker daemon at unix:///var/run/docker.sock` | Docker Desktop 앱이 실행되지 않았거나 데몬 시작 실패 | Docker Desktop 앱 실행 확인. 메뉴바 아이콘에서 상태 확인 |
| DD2 | 디스크 마운트 오류 | `mounting read write disk: invalid argument` | VM 디스크 이미지 손상 | Troubleshoot > "Clean / Purge data" 실행 |
| DD3 | macOS Sequoia 방화벽 간섭 | 데몬 시작 후 DNS 해석 실패 | macOS Sequoia의 향상된 방화벽이 Docker 네트워킹 간섭 | Docker Desktop 4.37.2 이상으로 업데이트 |
| DD4 | 리소스 부족 | Docker Desktop 앱은 열리지만 데몬 무응답 | 할당된 메모리/CPU 부족으로 VM 시작 실패 | Settings > Resources > Memory를 최소 4GB 이상으로 증가 |
| DD5 | "Docker.app will damage your computer" | macOS가 Docker 실행 차단 | 2024년 Docker 인증서 만료 사건으로 인한 false positive | Docker Desktop 4.37.2 이상으로 업데이트. 또는 `sudo xattr -r -d com.apple.quarantine /Applications/Docker.app` |

---

### 6.6 메모리/CPU 할당 문제

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| DM1 | OOM (Out of Memory) | 컨테이너 크래시, `Killed` 메시지 | Docker VM에 할당된 메모리 부족 (기본 2GB) | Memory 증가 (권장: 물리 RAM의 50%). Apple Silicon은 Unified Memory라 호스트 영향 적음 |
| DM2 | 빌드 느림 | `docker build` 가 매우 느림 | CPU 코어 할당 부족 | Settings > Resources > CPUs 증가 |
| DM3 | 호스트 Mac 느려짐 | macOS 전체 성능 저하 | Docker에 과도한 리소스 할당 | Settings > Resources에서 할당 감소. Resource Saver 모드 활성화 |
| DM4 | 8+ CPU 코어 할당 시 불안정 | Docker Desktop 크래시 (M1 Max 등) | Apple Silicon에서 높은 코어 수 할당 시 VM 불안정 | CPU 할당을 8 이하로 제한 |
| DM5 | Swap 과다 사용 | 디스크 I/O 급증, 느린 성능 | 컨테이너가 할당 메모리 초과하여 swap 사용 | 물리 메모리 할당 증가. `docker stats` 로 모니터링 |

---

### 6.7 파일 공유 / Bind Mount 성능

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| DF1 | node_modules 포함 bind mount | `npm install` 이 10x+ 느림 | 수만 개의 작은 파일이 호스트/VM 경계를 넘어 각각 I/O 발생 | `.dockerignore` 에 `node_modules` 추가. Named volume 사용 |
| DF2 | gRPC FUSE (레거시) | 파일 I/O가 네이티브 대비 10x 느림 | gRPC FUSE 성능 불량 | "VirtioFS" 활성화 (macOS 12.5+ 필요) |
| DF3 | VirtioFS 대용량 파일 | 2GB+ 파일이 잘림 (truncated) | VirtioFS 초기 버전의 대용량 파일 버그 | Docker Desktop 최신 버전 업데이트 |
| DF4 | 파일 감시 (inotify) | Hot reload 미동작, 파일 변경 감지 안 됨 | macOS FSEvents가 VM 내 Linux inotify로 전파 안 됨 | VirtioFS 사용. 또는 `CHOKIDAR_USEPOLLING=true` 환경변수 설정 |
| DF5 | Synchronized File Shares | 설정 후에도 느림 | Docker Desktop 유료 기능 (Pro+) | Settings > Resources > File Sharing에서 Synchronized File Shares 설정 |

---

### 6.8 네트워크 (VPN 충돌)

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| DN1 | VPN 연결 시 DNS 실패 | 컨테이너에서 `Could not resolve host` | Docker 컨테이너가 호스트 DNS를 상속하지만 VPN이 DNS를 변경 | Docker Desktop 4.42+ 사용. 또는 `docker run --dns 8.8.8.8` |
| DN2 | VPN + Docker 동시 사용 시 크래시 | Docker Desktop이 VPN 연결 시 종료됨 | Docker 네트워킹과 VPN (Cisco AnyConnect, AWS VPN)의 서브넷 충돌 | Docker 네트워크 서브넷 변경: `docker network create --subnet=172.28.0.0/16 custom_net` |
| DN3 | 사내 레지스트리 접근 불가 | `dial tcp: lookup registry.internal.corp: no such host` | VPN을 통한 사내 레지스트리가 컨테이너에서 접근 불가 | `daemon.json` 에 `"dns": ["10.0.0.2", "8.8.8.8"]` 추가 |
| DN4 | 포트 충돌 | `Bind for 0.0.0.0:xxxx failed: port is already allocated` | 호스트에서 해당 포트를 이미 사용 중 | `lsof -i :포트번호` 로 확인. 다른 포트로 매핑 |

---

### 6.9 Docker Desktop 업데이트 실패

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| DU1 | 업데이트 다운로드 멈춤 | "Updating..." 상태에서 진행 없음 | 다운로드 서버 문제 또는 네트워크 불안정 | `brew upgrade --cask docker` 로 Homebrew 경유 업데이트 |
| DU2 | 업데이트 후 시작 불가 | Docker Desktop이 열리지 않음 | 업데이트 중 파일 손상 | 완전 삭제 후 재설치: `brew uninstall --cask docker` + 관련 Library 폴더 삭제 |
| DU3 | In-app 업데이트가 최신 버전 미반영 | 알림은 뜨지만 실제 최신 버전이 아님 | In-app updater 버그 | 공식 사이트에서 DMG 수동 다운로드. 또는 `brew upgrade --cask docker` |
| DU4 | 업데이트 후 데이터 손실 | 컨테이너/이미지/볼륨 사라짐 | 메이저 업데이트 시 VM 재생성 | `docker compose` 로 재현 가능한 환경 유지 |

---

### 6.10 macOS 버전별 호환성

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| DO1 | macOS Ventura (13) 이하 | Docker Desktop 최신 버전 설치/실행 불가 | Docker Desktop 4.53+ 은 macOS Sonoma (14) 이상만 지원 | macOS 업그레이드. 또는 Docker Desktop 4.36 사용 |
| DO2 | macOS Sequoia (15) DNS 버그 | 컨테이너 내부에서 DNS 해석 실패 | macOS Sequoia 방화벽의 DNS 관련 버그 | Docker Desktop 4.37.2+ 으로 업데이트 |
| DO3 | macOS Sequoia (15.3) GUI 문제 | Docker Desktop 앱이 열리지 않지만 데몬은 동작 | Sequoia 15.3의 윈도우 관리 변경 | Docker Desktop 최신 버전 업데이트. CLI는 정상 동작 |
| DO4 | macOS Sonoma (14) GUI 무응답 | Docker Desktop 창이 반응 없음 | Docker Desktop 4.28-4.33 버전의 Sonoma GUI 버그 | Docker Desktop 4.34 이상으로 업데이트 |
| DO5 | macOS 업그레이드 후 Docker 깨짐 | Docker Desktop 시작 불가 | macOS를 Docker Desktop보다 먼저 업그레이드 | 항상 Docker Desktop을 먼저 업데이트한 후 macOS 업그레이드 |

---

### 6.11 `docker` 명령어 미등록

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| DC1 | 설치 직후 | `zsh: command not found: docker` | Docker Desktop이 CLI를 `$HOME/.docker/bin` 에 설치 (USER 모드 기본값) | Settings > Advanced > "System" 선택. 또는 `~/.zshrc` 에 PATH 추가 |
| DC2 | symlink 깨짐 | `docker` 명령이 갑자기 동작 안 함 | Docker Desktop 업데이트 시 symlink 재생성 실패 | Settings > Advanced > "System" 재설정 |
| DC3 | Homebrew 설치 후 | `docker: command not found` | `brew install --cask docker` 후 Docker Desktop 앱을 실행하지 않음 | Docker Desktop 앱을 한 번 실행하여 CLI 도구 설치 완료 |
| DC4 | docker-compose vs docker compose | `docker-compose: command not found` | Docker Compose V2는 `docker compose` (하이픈 없음)으로 변경됨 | `docker compose` 사용 |

---

### 6.12 디스크 공간 문제

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| DS1 | 이미지 누적 | Mac 저장 공간 경고, Docker 빌드 실패 | 미사용 Docker 이미지/레이어 누적 (20-50GB+) | `docker system prune -a`. `docker system df` 로 확인 |
| DS2 | Docker.raw 파일 비대 | `~/Library/Containers/com.docker.docker/Data/vms/` 에 수십 GB | VM 디스크 이미지가 삭제 후에도 축소되지 않음 (sparse file) | "Clean / Purge Data" 로 VM 재생성 |
| DS3 | 빌드 캐시 누적 | `docker build` 캐시가 수 GB 차지 | BuildKit 캐시가 자동 정리되지 않음 | `docker builder prune` |
| DS4 | 볼륨 고아화 | `docker volume ls` 에 미사용 볼륨 다수 | 컨테이너 삭제 시 볼륨은 자동 삭제되지 않음 | `docker volume prune` (데이터 손실 주의) |
| DS5 | Disk image size 제한 | `no space left on device` (컨테이너 내부) | Docker VM 디스크 이미지 최대 크기 초과 | Settings > Resources > Disk image size 증가 |

---

### 6.13 기업 프록시 설정

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| DP1 | Docker pull 실패 | `proxyconnect tcp: dial tcp: connect: connection refused` | 기업 프록시가 Docker Hub 접근 차단 | Settings > Resources > Proxies에서 HTTP/HTTPS 프록시 설정 |
| DP2 | NTLM/Kerberos 인증 프록시 | 프록시 인증 실패 | 기업 프록시가 NTLM/Kerberos 인증 요구 | Docker Desktop 4.30+ 사용 (NTLM/Kerberos 자동 지원) |
| DP3 | SOCKS5 프록시 | 연결 실패 | SOCKS5 프록시 미지원 (구버전) | Docker Desktop 4.30+ 사용 (SOCKS5 지원 추가) |
| DP4 | SSL 인증서 (MITM) | `x509: certificate signed by unknown authority` | 기업 보안 솔루션이 SSL 트래픽 가로채기 | 기업 CA 인증서를 Docker에 추가. 또는 `"insecure-registries"` 설정 |
| DP5 | Docker build 중 프록시 | `Dockerfile`의 `RUN apt-get update` 등이 실패 | 빌드 타임 프록시 미설정 | `docker build --build-arg HTTP_PROXY=http://proxy:port` 사용 |

---

## 7. Antigravity (Google) 설치 에러

### 7.1 Homebrew Cask 설치

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| AGY1 | Cask 미발견 | `Error: Cask 'google-antigravity' is unavailable` | Homebrew 메타데이터가 오래됨 또는 cask 이름 변경 | `brew update` 후 `brew search antigravity` 로 확인 |
| AGY2 | 다운로드 실패 (404) | `Error: Download failed on Cask 'google-antigravity'` | 특정 버전의 릴리즈 파일이 GitHub에서 누락됨 | `brew update` 후 재시도. 또는 `curl -O https://dl.google.com/antigravity/latest/Antigravity-mac.dmg` |
| AGY3 | SHA256 불일치 | `Error: SHA256 mismatch` | Homebrew 해시와 실제 파일 해시 불일치 | `brew update-reset && brew update` 후 재시도 |
| AGY4 | 기존 설치와 충돌 | `Error: It seems there is already an App at '/Applications/Antigravity Tools.app'` | 수동 설치 Antigravity가 이미 존재 | `brew install --cask google-antigravity --force` |
| AGY5 | Apple Silicon 호환성 | 설치는 되지만 Rosetta 에뮬레이션으로 실행 | ARM64 네이티브 빌드가 아닌 빌드 설치 | Activity Monitor에서 "Kind" 열 확인 |

---

### 7.2 Gatekeeper / Quarantine 차단

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| AQ1 | "앱이 손상됨" 오류 | `"Antigravity Tools" is damaged and can't be opened` | macOS quarantine 속성 부착 | `sudo xattr -rd com.apple.quarantine "/Applications/Antigravity Tools.app"` |
| AQ2 | 미확인 개발자 차단 | `"Antigravity Tools" can't be opened because it is from an unidentified developer` | Gatekeeper 서명 검증 실패 | `--no-quarantine` 플래그 사용. 또는 시스템 설정에서 허용 |
| AQ3 | macOS Sequoia 강화 보안 | 이전 우회 방법이 동작하지 않음 | Sequoia에서 Gatekeeper 우회가 더 어려워짐 | 시스템 설정 > 개인정보 및 보안에서 직접 앱 허용 |
| AQ4 | 보안 소프트웨어 간섭 | Antigravity 확장 파일이 격리됨 | Norton, Kaspersky 등이 확장 파일을 의심 | 보안 소프트웨어 예외 목록에 Antigravity 추가 |

---

### 7.3 `agy` CLI PATH 문제

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| AP1 | CLI 명령 미등록 | `zsh: command not found: agy` | Antigravity가 `agy` symlink를 자동 생성하지 않음 | Command Palette > "Install 'agy' command in PATH" 실행. 또는 수동 symlink 생성 |
| AP2 | 바이너리명 불일치 | `agy: command not found` 이지만 `antigravity` 는 동작 | 패키지 관리자가 바이너리를 `antigravity` 로 설치 | `sudo ln -s /usr/bin/antigravity /usr/local/bin/agy` |
| AP3 | PATH 미적용 | 터미널 재시작 후에도 `agy` 없음 | `~/.zshrc` 에 PATH 미추가 | `~/.zshrc` 에 PATH 추가 후 `source ~/.zshrc` |
| AP4 | Gemini CLI와의 연동 실패 | `error: agy not found. Please ensure it is in your system's PATH.` | Gemini CLI가 `agy`를 PATH에서 못 찾음 | 위 AP1-AP3 해결 후 재시도 |

---

### 7.4 Google 계정 요구사항/제한

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| AA1 | 미인증 상태 | AI 기능 미동작, Gemini 모델 접근 불가 | Google 계정 로그인 필수 | Google 계정으로 로그인. 개인 Gmail 계정 권장 |
| AA2 | 미지원 지역 | `Your current account is not eligible for Antigravity` | Google 계정 등록 지역이 지원 지역 외 | 계정 지역을 지원 지역 (미국, 일본, 대만 등)으로 변경 |
| AA3 | 연령 제한 | 계정 부적격 메시지 | 18세 미만 Google 계정 | 18세 이상의 계정 사용 |
| AA4 | Workspace 계정 | 로그인 실패 또는 기능 제한 | 프리뷰 기간 중 Workspace 계정 미지원 가능 | 개인 Gmail 계정으로 로그인 |
| AA5 | OAuth 리다이렉트 실패 | 로그인 후 빈 페이지 또는 오류 | OAuth 콜백 URL 차단 (방화벽, VPN, 브라우저 확장) | `antigravity.google` 도메인 접근 확인. 광고 차단기 일시 비활성화 |

---

### 7.5 Copilot 확장 충돌

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| AC1 | 이중 자동 완성 | 두 개의 자동 완성 제안이 동시에 표시 | GitHub Copilot 확장과 Antigravity 내장 AI 동시 동작 | Antigravity 내에서 Copilot 확장 비활성화 |
| AC2 | 키바인딩 충돌 | AI 관련 단축키가 예상과 다르게 동작 | 두 AI 확장의 키바인딩 충돌 | Keyboard Shortcuts에서 충돌 키바인딩 조정 |
| AC3 | 성능 저하 | 에디터 반응 느림, 높은 CPU 사용 | 두 AI 확장이 동시에 동작 | 하나의 AI 어시스턴트만 활성화 |

---

### 7.6 OpenVSX vs VS Code Marketplace 차이

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| AO1 | 확장 미발견 | 특정 확장이 검색되지 않음 | OpenVSX 레지스트리에 Microsoft 독점 확장 없음 (C#, Remote-SSH 등) | `.vsix` 파일을 직접 다운로드하여 수동 설치 |
| AO2 | 확장 버전 차이 | VS Code에서보다 오래된 버전 | OpenVSX에 최신 버전 미게시 | GitHub 릴리즈에서 `.vsix` 다운로드 후 수동 설치 |
| AO3 | 악성 확장 위험 | `Extension 'xyz' is not verified` 경고 | OpenVSX에 사칭 확장 등록 사례 (2025년 12월 발견) | 확장 설치 전 발행자 확인. Antigravity 최신 버전 업데이트 |
| AO4 | VS Code 확장 수동 설치 | `.vsix` 설치 시 호환성 문제 | VS Code 독점 API 미지원 가능 | 확장의 API 호환성 확인 |

---

## 8. Claude Code CLI 설치

> **네이티브 설치 (권장)**: `curl -fsSL https://claude.ai/install.sh | bash`
> **npm 설치 (deprecated)**: `npm install -g @anthropic-ai/claude-code`
> **진단 명령**: `claude doctor`

### 8.1 네이티브 설치 (curl installer)

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| CC1 | curl 미설치 | `zsh: command not found: curl` | 극히 드물지만 커스텀 macOS에서 발생 가능 | `brew install curl` 또는 Xcode CLT 설치 |
| CC2 | SSL 인증서 오류 | `curl: (60) SSL certificate problem: unable to get local issuer certificate` | 기업 프록시의 TLS 인터셉션 또는 시스템 인증서 스토어 문제 | `export NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem` 설정, IT에서 CA 인증서 획득 |
| CC3 | 프록시/방화벽 차단 | `curl: (7) Failed to connect to claude.ai port 443` | 기업 방화벽이 claude.ai 도메인 차단 | IT에 `claude.ai`, `api.anthropic.com` 화이트리스트 요청 |
| CC4 | DNS 해석 실패 | `curl: (6) Could not resolve host: claude.ai` | DNS 설정 문제 또는 네트워크 미연결 | DNS 서버 확인 (8.8.8.8 등), 네트워크 연결 확인 |
| CC5 | 프록시 인증 필요 | `curl: (407) Proxy Authentication Required` | 기업 프록시 사용 시 인증 미설정 | `export HTTPS_PROXY=http://user:pass@proxy:port` 설정 |
| CC6 | 다운로드 타임아웃 | `curl: (28) Connection timed out` | 느린 네트워크 또는 방화벽 간섭 | VPN 해제 시도, 다른 네트워크 시도 |
| CC7 | bash 실행 문제 (zsh 기본) | 스크립트가 bash로 실행되나 PATH를 zsh에 반영 못함 | macOS Catalina+ 기본 셸이 zsh이나 스크립트가 bash로 실행 | 설치 후 `~/.zshrc`에 PATH 수동 추가 |
| CC8 | install.sh 다운로드 불완전 | 스크립트 실행 중 구문 오류 | 네트워크 중단으로 스크립트 일부만 다운로드 | `curl -fsSL` 의 `-f` 플래그가 처리하지만, 재시도 필요 |
| CC9 | ~/.local/bin 디렉토리 생성 실패 | `Permission denied: mkdir ~/.local/bin` | 디스크 권한 문제 (극히 드묾) | `mkdir -p ~/.local/bin && chmod 755 ~/.local/bin` |
| CC10 | 아키텍처 감지 오류 | x86_64 바이너리가 ARM64 Mac에 설치됨 | install.sh가 아키텍처를 잘못 감지 (Rosetta 환경 등) | `arch -arm64 bash -c "curl -fsSL https://claude.ai/install.sh \| bash"` |

**소스**: [Claude Code Troubleshooting](https://code.claude.com/docs/en/troubleshooting), [ARM64 binary issue #13617](https://github.com/anthropics/claude-code/issues/13617), [Architecture Mismatch #4749](https://github.com/anthropics/claude-code/issues/4749)

---

### 8.2 npm 설치 (deprecated)

> **주의**: Anthropic은 네이티브 설치를 권장하며 npm 설치는 deprecated입니다.

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| CN1 | npm EACCES 권한 오류 | `EACCES: permission denied, access '/usr/local/lib/node_modules'` | npm 글로벌 디렉토리에 쓰기 권한 없음 | `npm config set prefix '~/.npm-global'` + PATH 추가, 또는 nvm 사용 |
| CN2 | Node.js 버전 부족 | `Claude Code requires Node.js version 18 or higher` | Node.js 16 이하 설치됨 | `brew install node@20` 또는 `nvm install 20` |
| CN3 | Node.js 미설치 | `npm: command not found` | Node.js/npm 미설치 | Homebrew로 Node.js 설치: `brew install node` |
| CN4 | Homebrew Node.js 심링크 오류 | `claude: command not found` (설치 성공 후) | Homebrew Node.js로 설치 시 심링크가 JS 파일을 가리킴 (실행 스크립트 아님) | 심링크 수동 수정: `ln -sf $(npm prefix -g)/lib/node_modules/@anthropic-ai/claude-code/cli.js $(brew --prefix)/bin/claude` |
| CN5 | 네이티브 설치와 npm 설치 충돌 | `segmentation fault` 또는 버전 혼란 | 두 가지 설치 방식이 동시에 존재 | npm 글로벌 설치 제거 후 네이티브 설치: `npm uninstall -g @anthropic-ai/claude-code && curl -fsSL https://claude.ai/install.sh \| bash` |
| CN6 | nvm/asdf 버전 관리자 충돌 | PATH 우선순위 문제로 잘못된 claude 바이너리 실행 | nvm/asdf shim이 npm-global 경로를 가림 | `which claude`로 경로 확인, shim 재설정 |
| CN7 | npm 캐시 오염 | 업데이트 시 npm-local 모드로 잘못 전환 | 이전 npm 설치의 캐시가 남아있음 | `npm cache clean --force` 후 재설치 |
| CN8 | sudo npm install | 향후 권한 문제 연쇄 발생 | root로 설치된 파일이 일반 사용자 접근 차단 | **절대 sudo로 npm install하지 말 것**. `sudo chown -R $(whoami) ~/.npm` 후 재설치 |

**소스**: [npm/native conflict #7734](https://github.com/anthropics/claude-code/issues/7734), [Homebrew symlink #3172](https://github.com/anthropics/claude-code/issues/3172), [Auto-updater npm-global #22415](https://github.com/anthropics/claude-code/issues/22415)

**혼합 설치 완전 제거 절차**:
```bash
# 1. npm 글로벌 설치 제거
npm uninstall -g @anthropic-ai/claude-code 2>/dev/null

# 2. npm-global 유령 바이너리 제거
rm -f ~/.npm-global/bin/claude 2>/dev/null

# 3. npm 캐시에서 이전 패키지 제거
npm cache clean --force

# 4. 네이티브 설치 제거 (필요 시)
rm -f ~/.local/bin/claude

# 5. 네이티브 재설치 (권장)
curl -fsSL https://claude.ai/install.sh | bash
```

---

### 8.3 네트워크/프록시 문제

> 기업 환경에서 Claude Code 사용 시 추가 네트워크 설정 필요

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| CP1 | 기업 프록시 | `ECONNREFUSED` 또는 API 호출 실패 | 프록시 미설정 | `export HTTPS_PROXY=https://proxy.example.com:8080` |
| CP2 | TLS 인터셉션 (SSL MITM) | `Self-signed certificate detected` / `UNABLE_TO_VERIFY_LEAF_SIGNATURE` | 기업 보안 솔루션이 SSL 인증서 교체 | `export NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.pem` |
| CP3 | 방화벽 URL 차단 | API 호출 타임아웃 | 필수 URL이 화이트리스트에 없음 | `api.anthropic.com`, `claude.ai`, `platform.claude.com` 허용 |
| CP4 | mTLS 인증 필요 | 클라이언트 인증서 오류 | 기업 환경에서 상호 TLS 인증 요구 | `CLAUDE_CODE_CLIENT_CERT`, `CLAUDE_CODE_CLIENT_KEY` 환경변수 설정 |
| CP5 | SOCKS 프록시 사용 | 연결 실패 | Claude Code는 SOCKS 프록시 미지원 | HTTP/HTTPS 프록시로 변경 또는 LLM Gateway 사용 |
| CP6 | VPN 충돌 | 간헐적 연결 실패 | VPN split tunneling 설정 문제 | VPN 설정에서 `api.anthropic.com` 제외 또는 포함 확인 |
| CP7 | NO_PROXY 미설정 | MCP 로컬 서버 연결 시 프록시 경유 | localhost 요청이 프록시를 통해 라우팅 | `export NO_PROXY="localhost 127.0.0.1"` |

**소스**: [Enterprise network config](https://code.claude.com/docs/en/network-config), [Self-signed cert #24470](https://github.com/anthropics/claude-code/issues/24470)

**기업 환경 설정 예시** (`~/.zshrc`에 추가):
```bash
# Claude Code 프록시 설정
export HTTPS_PROXY=https://proxy.company.com:8080
export NO_PROXY="localhost 127.0.0.1"
export NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/corporate-ca.pem

# mTLS 인증 (필요 시)
export CLAUDE_CODE_CLIENT_CERT=/path/to/client-cert.pem
export CLAUDE_CODE_CLIENT_KEY=/path/to/client-key.pem
```

---

### 8.4 Shell/PATH 문제

> macOS Catalina (10.15)부터 기본 셸이 zsh로 변경됨

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| CS1 | 설치 후 command not found | `zsh: command not found: claude` | `~/.local/bin`이 PATH에 없음 | `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc` |
| CS2 | 틸드(~) 확장 버그 | PATH에 리터럴 `~` 문자가 들어감 | install.sh가 `export PATH="~/.local/bin:$PATH"` 형태로 안내 → 따옴표 안 틸드 미확장 | `$HOME` 사용: `export PATH="$HOME/.local/bin:$PATH"` |
| CS3 | .zshrc 미존재 | PATH 추가가 반영되지 않음 | 새 Mac에서 `.zshrc` 파일이 없을 수 있음 | `touch ~/.zshrc` 후 PATH export 추가 |
| CS4 | .zprofile vs .zshrc 혼돈 | 로그인 셸에서만 작동 또는 그 반대 | macOS Terminal은 로그인 셸로 실행 (`.zprofile` 읽음) | 양쪽 모두에 추가하거나 `.zprofile`에서 `.zshrc` source |
| CS5 | bash 사용자 (비기본) | `.bash_profile` 또는 `.bashrc`에 PATH 없음 | 수동으로 bash로 변경한 사용자 | `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bash_profile` |
| CS6 | source 미실행 | 설치 직후 `claude` 인식 안됨 | 셸 설정 파일 변경 후 source 미실행 | `source ~/.zshrc` 또는 새 터미널 탭 열기 |
| CS7 | install 명령이 PATH에 추가 안함 | `claude install` 성공 메시지 후 command not found | `claude install`이 `~/.local/bin/claude`에 설치하지만 셸 설정 파일에 PATH 미추가 | 수동으로 `~/.zshrc`에 PATH 추가 |
| CS8 | 네이티브 설치 후 npm-global 유령 바이너리 | 이전 npm 버전이 실행됨 | 자동 업데이터가 `~/.npm-global/bin/claude` 재생성하여 PATH 우선순위 문제 | `rm ~/.npm-global/bin/claude` 후 `which claude`로 확인 |

**소스**: [PATH expansion bug #6090](https://github.com/anthropics/claude-code/issues/6090), [Incorrect PATH syntax for zsh #5177](https://github.com/anthropics/claude-code/issues/5177), [PATH Fails with Quoted Tilde #4453](https://github.com/anthropics/claude-code/issues/4453), [claude install doesn't persist PATH #21069](https://github.com/anthropics/claude-code/issues/21069)

**Shell 설정 파일 로딩 순서** (macOS zsh):
```
로그인 셸 (Terminal.app 기본):
  1. /etc/zshenv → 2. ~/.zshenv → 3. /etc/zprofile → 4. ~/.zprofile
  → 5. /etc/zshrc → 6. ~/.zshrc → 7. /etc/zlogin → 8. ~/.zlogin

비로그인 셸 (tmux, 스크립트):
  1. /etc/zshenv → 2. ~/.zshenv → 3. /etc/zshrc → 4. ~/.zshrc
```

---

### 8.5 macOS 플랫폼 고유 문제

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| CM1 | Gatekeeper 경고 | `"claude" Not Opened: Apple could not verify "claude" is free of malware` | 바이너리가 Apple 공증(notarization) 안됨 | 시스템 설정 > 개인 정보 보호 및 보안 > "확인 없이 열기" 또는 `xattr -d com.apple.quarantine ~/.local/bin/claude` |
| CM2 | .node 파일 Gatekeeper 경고 | `.7fd3dfffbffbbd2f-00000000.node Not Opened` 반복 팝업 | Bun 런타임이 추출하는 네이티브 .node 모듈이 코드 서명 미상속 | `xattr -cr ~/.local/share/claude-code/` 또는 시스템 설정에서 허용 |
| CM3 | Apple Silicon에서 x86_64 바이너리 설치 | 성능 저하, Rosetta 의존 | install 명령이 아키텍처 잘못 감지하여 x86_64 바이너리 설치 | `file ~/.local/bin/claude`로 확인 후 ARM64 바이너리 재설치 |
| CM4 | Intel Mac에서 Apple Silicon 필요 오류 | `Apple Silicon required` 에러 (잘못된 감지) | cowork 기능이 아키텍처를 잘못 감지 | CLI 업데이트로 해결: `claude update` |
| CM5 | Segmentation Fault | `Segmentation fault: 11` | 혼합 설치 (npm + 네이티브, Bun + Node.js 충돌) | 모든 기존 설치 제거 후 네이티브 재설치 (8.2 혼합 설치 제거 절차 참고) |
| CM6 | macOS Tahoe (26) 비호환 | 기능 오류 또는 실행 안됨 | 최신 macOS 베타와 호환성 문제 | 안정 릴리즈 macOS 사용 또는 Claude Code 업데이트 대기 |
| CM7 | Bun 런타임 크래시 | `Bun has crashed` | 네이티브 바이너리의 Bun 런타임 내부 오류 | Claude Code 최신 버전으로 업데이트: `claude update` |
| CM8 | CPU AVX 지원 없음 (VM 환경) | `CPU lacks AVX support` | 가상 머신에서 AVX 미지원 CPU 에뮬레이션 | Node.js 기반 npm 설치 사용 (Bun 대신) |

**소스**: [Gatekeeper .node warning #14911](https://github.com/anthropics/claude-code/issues/14911), [Homebrew blocked by Gatekeeper #19897](https://github.com/anthropics/claude-code/issues/19897), [Segfault on macOS Silicon #15925](https://github.com/anthropics/claude-code/issues/15925), [Wrong architecture install #15571](https://github.com/anthropics/claude-code/issues/15571)

**아키텍처 확인 및 Gatekeeper 해결**:
```bash
# 바이너리 아키텍처 확인
file ~/.local/bin/claude
# 기대 결과 (Apple Silicon): Mach-O 64-bit executable arm64

# Gatekeeper quarantine 속성 제거
xattr -d com.apple.quarantine ~/.local/bin/claude
xattr -cr ~/.local/share/claude-code/

# 현재 아키텍처 확인
arch    # arm64 (Apple Silicon) 또는 i386 (Rosetta/Intel)
```

---

### 8.6 인증 문제

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| CA1 | API 키 오류 | `Invalid API key · Please run /login` | API 키 만료 또는 잘못된 키 | `/logout` 후 `/login`으로 재인증, 또는 Anthropic Console에서 키 확인 |
| CA2 | macOS 키체인 문제 | 로그인 성공 후 즉시 `Missing API key` 반복 | OAuth 토큰이 macOS 키체인에 저장되지 않음 | `security unlock-keychain ~/Library/Keychains/login.keychain-db` 후 재시도 |
| CA3 | 인증 무한 루프 | `/login` → 성공 → 즉시 `Missing API key` → `/login` 반복 | 키체인 접근 권한 문제 또는 auth.json 손상 | `rm -rf ~/.config/claude-code/auth.json` 후 `claude` 재실행 |
| CA4 | 브라우저가 열리지 않음 | OAuth URL 열기 실패 | 기본 브라우저 설정 문제 또는 헤드리스 환경 | `c` 키를 눌러 OAuth URL을 클립보드에 복사 후 수동으로 브라우저에 붙여넣기 |
| CA5 | SSH 세션에서 인증 | 토큰 미저장 | SSH 환경에서 키체인에 접근 불가 | `ANTHROPIC_API_KEY` 환경변수로 API 키 직접 설정 |
| CA6 | 기업/개인 계정 혼재 | 기업 설정이 개인 설정 덮어쓰기 | employer API 키 설정이 개인 설정을 오염 | `~/.claude.json`에서 잘못된 설정 수동 삭제 |

**소스**: [Auth loop macOS #8280](https://github.com/anthropics/claude-code/issues/8280), [Invalid API key #5167](https://github.com/anthropics/claude-code/issues/5167), [Login not persisting Mac SSH #5225](https://github.com/anthropics/claude-code/issues/5225)

**인증 완전 초기화**:
```bash
# 1. 로그아웃
claude /logout 2>/dev/null

# 2. 인증 정보 삭제
rm -rf ~/.config/claude-code/auth.json

# 3. 키체인 잠금 해제 (SSH 세션)
security unlock-keychain ~/Library/Keychains/login.keychain-db

# 4. 재로그인
claude
# 또는 API 키 직접 설정
export ANTHROPIC_API_KEY=sk-ant-xxxxx
```

---

### 8.7 VS Code 확장 문제 (Claude Code)

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| CV1 | 확장 설치 ENOENT | `Error installing VS Code extension: 1: ENOENT` | 번들된 .vsix 파일 손상 (0 바이트) | VS Code Marketplace에서 직접 설치 |
| CV2 | Node.js 18 필요 에러 | `Claude Code requires Node.js version 18 or higher to be installed` | VS Code가 잘못된 Node.js 경로 참조 | VS Code 설정에서 node 경로 지정, 또는 시스템 Node.js 업데이트 |
| CV3 | 확장 호스트 크래시 | `Extension host terminated unexpectedly` 반복 | 메모리 한도 초과 (2-3GB) | VS Code 재시작, `--max-memory` 설정, 또는 CLI 사용 |
| CV4 | 메모리 누수 | 프로세스당 6-11GB RAM 사용 | 특정 확장 버전의 메모리 누수 버그 | 확장 업데이트 또는 다운그레이드, VS Code 주기적 재시작 |
| CV5 | ARM64 SIGABRT (Remote SSH) | `SIGABRT (exit code 134)` | ARM64 64KB 페이지 사이즈와 비호환 | CLI 사용 또는 확장 업데이트 대기 |
| CV6 | macOS Tahoe 비호환 | 확장 아이콘 미표시, UI 로드 안됨 | macOS 26 Tahoe 베타와 비호환 | 안정 macOS 버전 사용 |
| CV7 | CPU 99% 사용 | Code Helper (Renderer) 프로세스 CPU 과다 사용 | VS Code 렌더러 프로세스 과부하 | VS Code 재시작, 다른 확장 비활성화 시도 |

**소스**: [VS Code crash ARM64 #10496](https://github.com/anthropics/claude-code/issues/10496), [Memory Leak 11.6GB #21182](https://github.com/anthropics/claude-code/issues/21182), [Extension host terminated #12229](https://github.com/anthropics/claude-code/issues/12229), [Not compatible macOS Tahoe #2270](https://github.com/anthropics/claude-code/issues/2270)

---

## 9. Gemini CLI 설치

> **npm 설치**: `npm install -g @google/gemini-cli`
> **Homebrew 설치**: `brew install gemini-cli`
> **Node.js 필수 요구사항**: Node.js 20.0.0+

### 9.1 npm 설치

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| GN1 | npm EACCES 권한 오류 | `EACCES: permission denied, access '/usr/local/lib/node_modules'` | npm 글로벌 디렉토리에 쓰기 권한 없음 | `mkdir ~/.npm-global && npm config set prefix '~/.npm-global'` + PATH 추가. 또는 nvm 사용 |
| GN2 | Node.js 버전 부족 | `EBADENGINE Unsupported engine { required: { node: '>=20' } }` | Node.js 20 미만 설치됨 (Gemini CLI는 **Node.js 20+ 필수**) | `brew install node@20` 또는 `nvm install 20 && nvm use 20` |
| GN3 | Node.js 미설치 | `npm: command not found` | Node.js/npm 미설치 | `brew install node` 또는 [nodejs.org](https://nodejs.org) 에서 설치 |
| GN4 | npm 레지스트리 접근 불가 | `npm ERR! network request to https://registry.npmjs.org failed` | 프록시/방화벽이 npm 레지스트리 차단 | `npm config set proxy http://proxy:port` 또는 미러 사용 |
| GN5 | 의존성 deprecated 경고 (다수) | 다수의 deprecated 패키지 경고 | 내부 의존성이 deprecated 패키지 사용 | **무시 가능** - 경고일 뿐 설치는 진행됨 |
| GN6 | ripgrep 다운로드 타임아웃 | `RequestError: connect ETIMEDOUT` (GitHub releases 서버) | Gemini CLI가 GitHub에서 ripgrep 바이너리 다운로드 시 타임아웃 | `~/.gemini/settings.json`에 `"useRipgrep": false` 추가 |
| GN7 | npx GitHub 설치 실패 | `npx https://github.com/google-gemini/gemini-cli` 후 무반응 | GitHub repo에는 빌드된 `bundle/` 디렉토리 없음 | **올바른 방법**: `npx @google/gemini-cli` (npm 패키지에서 직접) |
| GN8 | 설치 후 command not found | `zsh: command not found: gemini` | npm 글로벌 bin 디렉토리가 PATH에 없음 | `echo 'export PATH="$(npm config get prefix)/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc` |
| GN9 | ERR_REQUIRE_ESM | `ERR_REQUIRE_ESM` 모듈 로딩 오류 | Node.js 버전과 ESM 모듈 비호환 | Node.js 20+로 업그레이드 |
| GN10 | sudo npm install 후유증 | 향후 권한 문제 연쇄 | root 소유 파일이 일반 사용자 접근 차단 | `sudo chown -R $(whoami) $(npm config get prefix)/{lib/node_modules,bin,share}` |
| GN11 | npm 업데이트 실패 | `Automatic update failed. Please try updating manually` | PATH 충돌 또는 권한 문제로 자동 업데이트 실패 | `npm install -g @google/gemini-cli@latest` |
| GN12 | npm/Homebrew 설치 충돌 | 버전 불일치 경고 반복, 업데이트 루프 | 두 패키지 매니저로 동시 설치됨 | 하나로 통일: `brew uninstall gemini-cli` 또는 `npm uninstall -g @google/gemini-cli` |
| GN13 | EOVERRIDE 크래시 | CLI가 시작 시 크래시 | `npm list` 실패가 초기화를 중단 | npm 설정 확인, `npm config delete overrides` |

**소스**: [npm install fails #2264](https://github.com/google-gemini/gemini-cli/issues/2264), [Installation impossible #7795](https://github.com/google-gemini/gemini-cli/issues/7795), [EBADENGINE Node.js v20 #2870](https://github.com/google-gemini/gemini-cli/issues/2870), [command not found #8397](https://github.com/google-gemini/gemini-cli/issues/8397), [npx GitHub fails #2077](https://github.com/google-gemini/gemini-cli/issues/2077)

---

### 9.2 Homebrew 설치

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| GH1 | 첫 실행 EACCES | `Error: EACCES: permission denied, mkdir '/Library/Application Support/GeminiCli'` | 코드가 `/Library/Application Support/` (시스템 레벨) 사용, sudo 필요 | `sudo mkdir -p '/Library/Application Support/GeminiCli' && sudo chown $(whoami) '/Library/Application Support/GeminiCli'` |
| GH2 | Homebrew 미설치 | `brew: command not found` | Homebrew 미설치 | [brew.sh](https://brew.sh) 에서 Homebrew 설치 |
| GH3 | Homebrew 업데이트 불일치 | `outdated version` 경고가 반복 표시 | Homebrew 설치와 npm 설치 버전 충돌 | 하나의 패키지 매니저로 통일 |
| GH4 | macOS 15.7 temp 폴더 권한 | `Permission Denied to Temp folder` (`/var/folders/.../T/gemini-cli-warnings.txt`) | macOS Sequoia 업그레이드 후 임시 폴더 rootless 권한 변경 | macOS 재시작 또는 `chmod 755 /var/folders/...` (특정 temp 경로) |
| GH5 | 업데이트 후 command not found | 업데이트 후 `gemini` 실행 안됨 | 업데이트 시 실행 파일 경로가 변경됨 | `brew unlink gemini-cli && brew link gemini-cli` |

**소스**: [EACCES Homebrew first run #13547](https://github.com/google-gemini/gemini-cli/issues/13547), [Temp folder permission macOS 15.7 #8690](https://github.com/google-gemini/gemini-cli/issues/8690), [Homebrew/npm version mismatch #5939](https://github.com/google-gemini/gemini-cli/issues/5939)

---

### 9.3 네트워크/프록시 문제

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| GP1 | 기업 프록시 차단 | 연결 오류, API 호출 실패 | 기업 방화벽이 Google API 서버 차단 | settings.json에 proxy 설정 또는 환경변수 사용 |
| GP2 | 프록시 인증 중 미작동 | OAuth 인증 시 프록시 불통 | settings.json의 proxy 설정이 인증 과정에서 적용 안됨 | API 키 인증으로 전환 (OAuth 우회): `export GEMINI_API_KEY=your_key` |
| GP3 | ripgrep 다운로드 프록시 미경유 | 초기화 시 2.5분 지연 | ripgrep 다운로드가 프록시 설정 무시 | `~/.gemini/settings.json`에 `"useRipgrep": false` 설정 |
| GP4 | npm 레지스트리 프록시 설정 | npm install 시 타임아웃 | npm이 프록시 설정 미반영 | `npm config set proxy http://proxy:port && npm config set https-proxy http://proxy:port` |
| GP5 | MCP 로컬 서버 프록시 충돌 | localhost MCP 서버 연결 실패 | 프록시가 localhost 요청도 가로챔 | `NO_PROXY` 환경변수에 localhost 추가 |
| GP6 | --proxy 플래그 미지원 (최신 버전) | `--proxy` 옵션 인식 안됨 | Gemini CLI 0.11.x+ 에서 `--proxy` 인수 제거됨 | settings.json에서 proxy 설정 또는 환경변수 사용 |

**소스**: [Corporate Network issue #4581](https://github.com/google-gemini/gemini-cli/issues/4581), [--proxy removed 0.11.x #12392](https://github.com/google-gemini/gemini-cli/issues/12392), [proxy not working during auth #8616](https://github.com/google-gemini/gemini-cli/issues/8616), [ripgrep hang behind proxy #13611](https://github.com/google-gemini/gemini-cli/issues/13611)

---

### 9.4 인증 문제

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| GA1 | 브라우저 리다이렉트 루프 | 로그인 후 브라우저가 리다이렉트 반복, CLI 대기 중 | OAuth 콜백 URL (`localhost:[port]/oauth2callback`) 접근 실패 | **API 키 인증으로 전환**: `export GEMINI_API_KEY=your_key` |
| GA2 | Safari 연결 불가 | `Safari cannot connect to server` (localhost URL) | Safari가 로컬 OAuth 콜백 서버에 연결 못함 | 다른 브라우저(Chrome)를 기본 브라우저로 설정 후 재시도 |
| GA3 | 인증 미완료 | `The authentication did not complete successfully` | OAuth 흐름 중 타임아웃 또는 취소 | 재시도하거나 API 키 방식 사용 |
| GA4 | 인증 코드 입력 루프 | 인증 코드 요청 → URL 방문 → 다시 인증 요청 반복 | OAuth 콜백 처리 버그 | `npm install -g @google/gemini-cli@latest` 로 최신 버전 업데이트 |
| GA5 | Google Workspace 계정 제한 | 로그인 거부 또는 권한 오류 | 조직 관리자가 Gemini CLI 접근 차단 | Google Workspace 관리자에게 Gemini CLI 활성화 요청 |
| GA6 | 개인 계정 로그인 불가 | `Unable to login with Personal Account` | Google 계정 설정 문제 | Gemini API 키를 직접 생성하여 사용: [aistudio.google.com](https://aistudio.google.com) |

**소스**: [Login redirect loop macOS #2547](https://github.com/google-gemini/gemini-cli/issues/2547), [Auth consistently fails #5580](https://github.com/google-gemini/gemini-cli/issues/5580), [Auth issue #13133](https://github.com/google-gemini/gemini-cli/issues/13133)

**인증 방법 비교**:
```bash
# 방법 1: Google 로그인 (기본, 문제 발생 가능)
gemini    # 자동으로 브라우저 열림

# 방법 2: API 키 (안정적, 권장 대안)
# https://aistudio.google.com 에서 키 생성
export GEMINI_API_KEY=AIzaSy...
gemini

# 방법 3: 서비스 계정 (기업 환경)
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
gemini
```

---

### 9.5 할당량 및 지역 제한

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| GQ1 | 무료 티어 한도 초과 | `429 Too Many Requests` / `RESOURCE_EXHAUSTED` | 무료 티어 RPM/RPD 한도 초과 (5-15 RPM, 모델별 상이) | 잠시 대기 후 재시도, 또는 유료 플랜 업그레이드 |
| GQ2 | 2025.12 무료 티어 대폭 축소 | 갑작스런 429 오류 급증 | 2025년 12월 무료 티어 할당량 50-92% 감소 (Flash: 250→20 RPD) | 유료 플랜 전환 (Google AI Pro/Ultra) 또는 요청 빈도 감소 |
| GQ3 | Gemini 2.5 Pro 무료 제거 | 모델 사용 불가 | 많은 계정에서 Gemini 2.5 Pro가 무료 티어에서 제거됨 | 다른 모델 사용 (Flash 등) 또는 유료 플랜 |
| GQ4 | 지역 제한 | API 접근 불가 또는 특정 기능 차단 | GDPR 규제 (유럽 일부), 제재 국가 (이란, 러시아), 정부 차단 (중국) | VPN 사용 (약관 위반 가능성 있음) 또는 지원 지역에서 사용 |
| GQ5 | Gemini Code Assist 지역 확인 | 특정 국가에서 서비스 미제공 | Google이 해당 국가에서 Gemini Code Assist 미활성화 | [공식 지역 목록](https://developers.google.com/gemini-code-assist/resources/available-locations) 확인 |
| GQ6 | 토큰 한도 초과 | 긴 대화에서 응답 중단 | TPM (tokens per minute) 한도 초과 | 대화 분할 또는 컨텍스트 축소 |

**소스**: [Gemini API Rate Limits](https://ai.google.dev/gemini-api/docs/rate-limits), [Gemini Code Assist Quotas](https://developers.google.com/gemini-code-assist/resources/quotas), [Rate-Limited Free Tier Discussion #2436](https://github.com/google-gemini/gemini-cli/discussions/2436), [Available Regions](https://ai.google.dev/gemini-api/docs/available-regions)

---

## 10. bkit Plugin

### 10.1 Claude Code Plugin (MCP 서버)

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| BP1 | MCP 서버 연결 실패 | `MCP server failed to connect` | MCP 서버 설정 오류 또는 의존성 미설치 | `claude doctor`로 MCP 설정 진단, `.mcp.json` 확인 |
| BP2 | claude mcp add 실패 | `Invalid input` 오류 | JSON 형식 오류 또는 transport 타입 미지원 | `claude mcp add --transport http` 형식 사용 |
| BP3 | GitHub MCP 서버 OAuth 실패 | GitHub 원격 MCP 서버 연결 안됨 | OAuth 인증 흐름 문제 | 토큰 기반 인증으로 전환 또는 로컬 MCP 서버 사용 |
| BP4 | 플러그인 로딩 오류 | `plugin loading error` (claude doctor 출력) | 플러그인 설정 파일 손상 또는 의존성 누락 | 플러그인 재설치, `.claude/settings.json` 확인 |
| BP5 | GitHub 네트워크 접근 불가 | 플러그인 다운로드/설치 타임아웃 | 방화벽/프록시가 github.com 차단 | `github.com`, `raw.githubusercontent.com` 화이트리스트 추가 |
| BP6 | npx 실행 실패 | MCP 서버 npx 실행 오류 | Node.js 미설치 또는 PATH 문제 | Node.js 설치 확인, `which npx` 경로 확인 |
| BP7 | MCP 서버 토큰 사용량 과다 | 컨텍스트 창 소진 경고 | MCP 서버가 너무 많은 토큰 사용 | `claude doctor`에서 MCP 토큰 사용량 확인, 불필요한 MCP 서버 제거 |

**소스**: [MCP servers fail to connect #1611](https://github.com/anthropics/claude-code/issues/1611), [GitHub remote MCP #3433](https://github.com/anthropics/claude-code/issues/3433), [Claude Code Plugins](https://data-wise.github.io/claude-plugins/installation/)

**MCP 진단 및 설정**:
```bash
# MCP 서버 상태 진단
claude doctor

# MCP 서버 추가 (HTTP transport)
claude mcp add --transport http my-server https://example.com/mcp

# MCP 서버 목록 확인
claude mcp list

# MCP 디버그 모드
claude --mcp-debug
```

---

### 10.2 Gemini CLI Extensions

| # | 환경/조건 | 에러 메시지/증상 | 원인 | 해결 방법 |
|---|----------|----------------|------|----------|
| GE1 | extensions install 실패 | 확장 설치 오류 | npm 레지스트리 접근 불가 또는 권한 문제 | npm 프록시 설정 확인, 권한 확인 |
| GE2 | MCP 서버 호환성 | MCP 서버 프로토콜 불일치 | Gemini CLI MCP 구현과 서버 버전 불일치 | 호환 가능한 MCP 서버 버전 사용 |
| GE3 | GitHub 접근 차단 | 확장 소스 다운로드 실패 | 기업 방화벽이 GitHub 차단 | GitHub 도메인 화이트리스트 추가 |
| GE4 | 인증 필요 확장 | 확장이 추가 인증 요구 | 확장이 별도 API 키/토큰 필요 | 각 확장 문서에 따라 인증 설정 |

---

## 11. 환경별 위험도 매트릭스 (종합)

> Homebrew/Node.js/Git/VS Code/Docker Desktop/Antigravity + Claude Code CLI + Gemini CLI + bkit Plugin 전체 통합

| 에러 카테고리 | 일반 사용자 | Apple Silicon | Intel Mac | 기업 환경 | 개발자 환경 |
|-------------|-----------|--------------|----------|----------|-----------|
| **Xcode CLT 문제** | **높음** | **높음** | **높음** | **높음** | 중간 |
| **nvm/fnm/volta 충돌** | 낮음 | 낮음 | 낮음 | 중간 | **높음** |
| **npm EACCES** | 중간 | 중간 | 중간 | 중간 | 중간 |
| **아키텍처 불일치 (Node/CLI)** | 낮음 | **높음** | 해당없음 | **높음** | **높음** |
| **node-gyp 에러** | 낮음 | **높음** | 중간 | **높음** | **높음** |
| **프록시/VPN/방화벽** | 낮음 | 낮음 | 낮음 | **높음** | 중간 |
| **VS Code Homebrew Cask 실패** | 중간 | 중간 | 중간 | **높음** | 낮음 |
| **VS Code `code` PATH 문제** | **높음** | **높음** | **높음** | 중간 | 중간 |
| **VS Code Gatekeeper 차단** | 중간 | 중간 | 중간 | **높음** | 낮음 |
| **VS Code Extension 설치 실패** | 중간 | 중간 | 중간 | **높음** | 중간 |
| **VS Code Insiders/Stable 충돌** | 낮음 | 낮음 | 낮음 | 낮음 | **높음** |
| **VS Code 기업 MDM 차단** | 낮음 | 낮음 | 낮음 | **높음** | 낮음 |
| **VS Code Rosetta 2 호환성** | 낮음 | **높음** | 해당없음 | 중간 | 중간 |
| **VS Code Remote SSH 문제** | 낮음 | 중간 | 중간 | **높음** | **높음** |
| **Docker Desktop Apple Silicon 호환** | 낮음 | **높음** | 해당없음 | **높음** | **높음** |
| **Docker Desktop Rosetta 2 요구** | 낮음 | **높음** | 해당없음 | 중간 | 중간 |
| **Docker Desktop 라이선스 위반** | 낮음 | 낮음 | 낮음 | **높음** | 낮음 |
| **Docker QEMU→VF 마이그레이션** | 중간 | **높음** | 해당없음 | **높음** | **높음** |
| **Docker 데몬 미시작** | **높음** | **높음** | **높음** | 중간 | 중간 |
| **Docker 메모리/CPU 부족** | 중간 | 중간 | **높음** | 중간 | **높음** |
| **Docker Bind Mount 성능** | 낮음 | 중간 | 중간 | 중간 | **높음** |
| **Docker VPN 네트워크 충돌** | 낮음 | 낮음 | 낮음 | **높음** | 중간 |
| **Docker macOS 버전 호환성** | 중간 | 중간 | 중간 | **높음** | 중간 |
| **Docker `docker` 명령어 미등록** | **높음** | **높음** | **높음** | 중간 | 낮음 |
| **Docker 디스크 공간 부족** | 중간 | 중간 | 중간 | 중간 | **높음** |
| **Docker 기업 프록시** | 낮음 | 낮음 | 낮음 | **높음** | 중간 |
| **Antigravity Cask 설치 실패** | **높음** | **높음** | **높음** | **높음** | 중간 |
| **Antigravity Gatekeeper 차단** | 중간 | 중간 | 중간 | **높음** | 낮음 |
| **Antigravity `agy` PATH 문제** | **높음** | **높음** | **높음** | 중간 | 중간 |
| **Antigravity Google 계정 제한** | **높음** | **높음** | **높음** | **높음** | 중간 |
| **Antigravity Copilot 충돌** | 낮음 | 낮음 | 낮음 | 중간 | **높음** |
| **Antigravity OpenVSX 제한** | 중간 | 중간 | 중간 | **높음** | **높음** |
| **Claude Code PATH 문제** | **높음** | **높음** | **높음** | 중간 | 중간 |
| **Claude Code Gatekeeper** | 중간 | 중간 | 중간 | **높음** | 낮음 |
| **Claude Code 인증 루프** | 중간 | 중간 | 중간 | **높음** | 중간 |
| **Claude Code 혼합 설치 충돌** | 낮음 | 낮음 | 낮음 | 낮음 | **높음** |
| **Claude Code VS Code 확장 메모리** | 중간 | 중간 | 중간 | 중간 | 중간 |
| **Gemini CLI Node.js 20+ 요구** | **높음** | **높음** | **높음** | **높음** | 낮음 |
| **Gemini CLI command not found** | **높음** | **높음** | **높음** | 중간 | 중간 |
| **Gemini CLI OAuth 리다이렉트 루프** | 중간 | 중간 | 중간 | **높음** | 중간 |
| **Gemini CLI 할당량 한도** | 중간 | 중간 | 중간 | 낮음 | **높음** |
| **Gemini CLI Homebrew EACCES** | 중간 | 중간 | 중간 | **높음** | 중간 |
| **bkit MCP 연결 실패** | 중간 | 중간 | 중간 | **높음** | 중간 |
| **SSL 인증서 (전체)** | 낮음 | 낮음 | 낮음 | **높음** | 낮음 |
| **Git Credential/SSH** | 중간 | 중간 | 중간 | **높음** | **높음** |
| **brew link 에러** | 중간 | 중간 | 중간 | 중간 | **높음** |

---

## 12. Top 15 빈출 에러 (종합)

발생 빈도와 사용자 영향도를 기준으로 정렬 (Homebrew/Node.js/Git/VS Code/Docker Desktop/Antigravity + Claude Code + Gemini CLI + bkit Plugin 전체 통합):

| 순위 | 에러 | 관련 코드 | 발생 빈도 | 영향도 | 주 대상 환경 |
|------|------|----------|----------|--------|------------|
| 1 | **`claude: command not found` (PATH 미설정)** | CS1, CS2, CS7 | **매우 높음** | **높음** (설치 완전 차단) | 모든 환경 |
| 2 | **Xcode CLT 미설치/무효화** | XC1, XC2 | **매우 높음** | **높음** | 모든 환경 (macOS 업그레이드 후) |
| 3 | **Docker Desktop 데몬 미시작 (`Cannot connect to the Docker daemon`)** | DD1-DD5 | **매우 높음** | **높음** (Docker 사용 불가) | 모든 환경 |
| 4 | **VS Code `code: command not found` (PATH 미등록)** | VP1-VP5 | **높음** | **높음** (터미널 워크플로 차단) | 모든 환경 |
| 5 | **`gemini: command not found` (PATH/Node.js)** | GN2, GN8 | **높음** | **높음** (설치 차단) | 모든 환경 |
| 6 | **Docker `docker: command not found` (심볼릭 링크 미생성)** | DC1-DC4 | **높음** | **높음** (Docker CLI 사용 불가) | 모든 환경 |
| 7 | **npm EACCES 권한 에러** | NP1, CN1, GN1 | **높음** | 중간 | 모든 환경 |
| 8 | **Antigravity Google 계정 인증/지역 제한** | AA1-AA5 | **높음** | **높음** (사용 완전 차단) | 미지원 국가, 기업 환경 |
| 9 | **VS Code / Antigravity Gatekeeper 차단** | VG1-VG4, AQ1-AQ4 | **높음** | 중간 (우회 가능) | 일반 사용자, 기업 환경 |
| 10 | **Claude Code Gatekeeper 경고** | CM1, CM2 | **높음** | 중간 (우회 가능) | 일반 사용자, 기업 환경 |
| 11 | **Docker Desktop QEMU 지원 종료 (2025.07)** | DV1-DV4 | 중간 | **높음** (VM 실행 불가) | Apple Silicon 환경 |
| 12 | **Docker Desktop 라이선스 위반 (250+ 직원)** | DL1-DL3 | 중간 (기업 한정) | **높음** (법적 리스크) | 기업 환경 |
| 13 | **Claude Code 인증 무한 루프 (키체인)** | CA2, CA3 | 중간 | **높음** (사용 차단) | macOS SSH 사용자, 기업 환경 |
| 14 | **기업 프록시/SSL 인터셉션 (Docker/VS Code/CLI 전체)** | CP1, CP2, GP1, NR2, GS1, DP1-DP5 | 중간 (기업 한정) | **높음** (완전 차단) | 기업 환경 |
| 15 | **Antigravity OpenVSX 확장 부족/보안 이슈** | AO1-AO4 | 중간 | 중간 (워크플로 제한) | 개발자 환경 |

---

## 참고 자료

### Node.js 관련
- [npm 공식 문서 - EACCES 권한 에러 해결](https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally/)
- [node-gyp GitHub - macOS 설치 가이드](https://github.com/nodejs/node-gyp)
- [node-gyp Python 3.12 distutils 이슈](https://github.com/nodejs/node-gyp/issues/2869)
- [node-gyp macOS Sonoma CLT 이슈](https://github.com/nodejs/node-gyp/issues/2992)
- [npm 공식 문서 - 일반 에러](https://docs.npmjs.com/common-errors/)

### Git 관련
- [GitHub Docs - macOS Keychain 자격 증명 업데이트](https://docs.github.com/en/get-started/getting-started-with-git/updating-credentials-from-the-macos-keychain)
- [GitHub Docs - SSH 키 생성 및 ssh-agent 등록](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- [GitHub Docs - ssh-add illegal option 에러](https://docs.github.com/en/authentication/troubleshooting-ssh/error-ssh-add-illegal-option----apple-use-keychain)
- [Git 공식 문서 - Credential Storage](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)
- [기업 환경 Git SSL 인증서 이슈 해결](https://konkretor.com/2024/11/01/understanding-and-fixing-git-ssl-certificate-issues-in-corporate-environments/)

### VS Code 관련
- [VS Code macOS Setup 공식 가이드](https://code.visualstudio.com/docs/setup/mac)
- [VS Code Command Line Interface (code 명령어)](https://code.visualstudio.com/docs/editor/command-line)
- [VS Code Network Connections (프록시 설정)](https://code.visualstudio.com/docs/setup/network)
- [VS Code Remote SSH 문서](https://code.visualstudio.com/docs/remote/ssh)
- [VS Code Extension Marketplace](https://code.visualstudio.com/docs/editor/extension-marketplace)
- [VS Code macOS Catalina EOL (1.97 릴리스)](https://code.visualstudio.com/updates/v1_97)
- [VS Code GitHub - SHA256 mismatch cask issue](https://github.com/Homebrew/homebrew-cask/issues?q=visual-studio-code+sha256)
- [VS Code MDM 배포 가이드](https://code.visualstudio.com/docs/setup/enterprise)
- [VS Code Apple Silicon (Universal Build)](https://code.visualstudio.com/docs/supporting/faq#_apple-silicon)

### Docker Desktop 관련
- [Docker Desktop macOS 설치 가이드](https://docs.docker.com/desktop/setup/install/mac-install/)
- [Docker Desktop 릴리스 노트](https://docs.docker.com/desktop/release-notes/)
- [Docker Desktop 라이선스 FAQ](https://www.docker.com/pricing/faq/)
- [Docker Desktop Virtualization Framework 설정](https://docs.docker.com/desktop/settings-and-maintenance/settings/#general)
- [Docker Desktop 파일 공유 백엔드 (VirtioFS)](https://docs.docker.com/desktop/settings-and-maintenance/settings/#file-sharing)
- [Docker Desktop 네트워크 설정](https://docs.docker.com/desktop/networking/)
- [Docker Desktop 프록시 설정](https://docs.docker.com/desktop/settings-and-maintenance/settings/#proxies)
- [Docker Desktop Troubleshooting (macOS)](https://docs.docker.com/desktop/troubleshoot-and-support/troubleshoot/topics/)
- [Docker QEMU 지원 종료 공지 (2025년 7월)](https://docs.docker.com/desktop/release-notes/#4410)
- [Docker Desktop Synchronized File Shares](https://docs.docker.com/desktop/features/synchronized-file-sharing/)
- [Docker Desktop 시스템 요구사항](https://docs.docker.com/desktop/setup/install/mac-install/#system-requirements)

### Antigravity (Google) 관련
- [Google Antigravity 공식 사이트](https://idx.google.com/antigravity)
- [Antigravity 설치 가이드 (macOS)](https://developers.google.com/idx/guides/antigravity-install)
- [OpenVSX Registry](https://open-vsx.org/)
- [OpenVSX 보안 취약점 보고 (2025년 12월)](https://www.bleepingcomputer.com/news/security/malicious-vscode-extensions-found-on-open-vsx-registry/)
- [Google 계정 연령 제한 정책](https://support.google.com/accounts/answer/1350409)
- [Antigravity GitHub Copilot 호환성 이슈](https://github.com/nicolo-ribaudo/tc39-proposal-seeded-random/issues)

### macOS / Homebrew 관련
- [Homebrew FAQ](https://docs.brew.sh/FAQ)
- [Homebrew Discussion - keg-only 설명](https://github.com/orgs/Homebrew/discussions/239)
- [Apple Silicon Homebrew 아키텍처 에러 수정](https://osxdaily.com/2024/07/06/fix-brew-error-the-arm64-architecture-is-required-for-this-software-on-apple-silicon-mac/)

### Claude Code 공식 문서
- [Claude Code Troubleshooting](https://code.claude.com/docs/en/troubleshooting)
- [Claude Code Setup](https://code.claude.com/docs/en/setup)
- [Enterprise Network Configuration](https://code.claude.com/docs/en/network-config)
- [Claude Code VS Code Extension](https://code.claude.com/docs/en/vs-code)

### Claude Code GitHub Issues (주요)
- [Homebrew symlink issue #3172](https://github.com/anthropics/claude-code/issues/3172)
- [PATH expansion bug #6090](https://github.com/anthropics/claude-code/issues/6090)
- [Incorrect PATH syntax for zsh #5177](https://github.com/anthropics/claude-code/issues/5177)
- [PATH Fails with Quoted Tilde #4453](https://github.com/anthropics/claude-code/issues/4453)
- [claude install doesn't persist PATH #21069](https://github.com/anthropics/claude-code/issues/21069)
- [npm/native conflict #7734](https://github.com/anthropics/claude-code/issues/7734)
- [Native installer deletes working npm #26173](https://github.com/anthropics/claude-code/issues/26173)
- [Auto-updater reinstalls npm-global #22415](https://github.com/anthropics/claude-code/issues/22415)
- [Gatekeeper .node warning #14911](https://github.com/anthropics/claude-code/issues/14911)
- [Homebrew blocked by Gatekeeper #19897](https://github.com/anthropics/claude-code/issues/19897)
- [ARM64 binary replaced #13617](https://github.com/anthropics/claude-code/issues/13617)
- [Architecture Mismatch Apple Silicon #4749](https://github.com/anthropics/claude-code/issues/4749)
- [Wrong architecture install #15571](https://github.com/anthropics/claude-code/issues/15571)
- [Segfault on macOS Silicon #15925](https://github.com/anthropics/claude-code/issues/15925)
- [Bun crash #7848](https://github.com/anthropics/claude-code/issues/7848)
- [Auth loop macOS #8280](https://github.com/anthropics/claude-code/issues/8280)
- [Invalid API key #5167](https://github.com/anthropics/claude-code/issues/5167)
- [Login not persisting Mac SSH #5225](https://github.com/anthropics/claude-code/issues/5225)
- [VS Code crash ARM64 #10496](https://github.com/anthropics/claude-code/issues/10496)
- [Memory Leak 11.6GB #21182](https://github.com/anthropics/claude-code/issues/21182)
- [Extension host terminated #12229](https://github.com/anthropics/claude-code/issues/12229)
- [Not compatible macOS Tahoe #2270](https://github.com/anthropics/claude-code/issues/2270)
- [Self-signed certificate #24470](https://github.com/anthropics/claude-code/issues/24470)
- [Connection Refused #17541](https://github.com/anthropics/claude-code/issues/17541)
- [MCP servers fail #1611](https://github.com/anthropics/claude-code/issues/1611)
- [GitHub remote MCP #3433](https://github.com/anthropics/claude-code/issues/3433)

### Gemini CLI 공식 문서
- [Gemini CLI Troubleshooting Guide](https://google-gemini.github.io/gemini-cli/docs/troubleshooting.html)
- [Gemini CLI Installation](https://geminicli.com/docs/get-started/installation/)
- [Gemini CLI Authentication](https://google-gemini.github.io/gemini-cli/docs/get-started/authentication.html)
- [Gemini CLI FAQ](https://google-gemini.github.io/gemini-cli/docs/faq.html)
- [Gemini CLI Enterprise](https://geminicli.com/docs/cli/enterprise/)
- [Gemini API Rate Limits](https://ai.google.dev/gemini-api/docs/rate-limits)
- [Gemini Code Assist Quotas](https://developers.google.com/gemini-code-assist/resources/quotas)
- [Available Regions](https://ai.google.dev/gemini-api/docs/available-regions)
- [Available Locations - Code Assist](https://developers.google.com/gemini-code-assist/resources/available-locations)

### Gemini CLI GitHub Issues (주요)
- [npm install fails #2264](https://github.com/google-gemini/gemini-cli/issues/2264)
- [Installation impossible #7795](https://github.com/google-gemini/gemini-cli/issues/7795)
- [Installing/running fails #14173](https://github.com/google-gemini/gemini-cli/issues/14173)
- [EBADENGINE Node.js v20 #2870](https://github.com/google-gemini/gemini-cli/issues/2870)
- [command not found #8397](https://github.com/google-gemini/gemini-cli/issues/8397)
- [command not found #2225](https://github.com/google-gemini/gemini-cli/issues/2225)
- [PATH issue after update #13248](https://github.com/google-gemini/gemini-cli/issues/13248)
- [npx GitHub fails #2077](https://github.com/google-gemini/gemini-cli/issues/2077)
- [Updates do not apply #4076](https://github.com/google-gemini/gemini-cli/issues/4076)
- [npm PATH conflict #5886](https://github.com/google-gemini/gemini-cli/issues/5886)
- [Homebrew/npm version mismatch #5939](https://github.com/google-gemini/gemini-cli/issues/5939)
- [EOVERRIDE crash #15627](https://github.com/google-gemini/gemini-cli/issues/15627)
- [EACCES Homebrew first run #13547](https://github.com/google-gemini/gemini-cli/issues/13547)
- [Temp folder permission macOS 15.7 #8690](https://github.com/google-gemini/gemini-cli/issues/8690)
- [OAuth redirect loop macOS #2547](https://github.com/google-gemini/gemini-cli/issues/2547)
- [Auth consistently fails #5580](https://github.com/google-gemini/gemini-cli/issues/5580)
- [Auth issue #13133](https://github.com/google-gemini/gemini-cli/issues/13133)
- [Auth Error #4546](https://github.com/google-gemini/gemini-cli/issues/4546)
- [Corporate Network #4581](https://github.com/google-gemini/gemini-cli/issues/4581)
- [--proxy removed 0.11.x #12392](https://github.com/google-gemini/gemini-cli/issues/12392)
- [proxy not working during auth #8616](https://github.com/google-gemini/gemini-cli/issues/8616)
- [ripgrep hang behind proxy #13611](https://github.com/google-gemini/gemini-cli/issues/13611)
- [ripgrep download timeout #18045](https://github.com/google-gemini/gemini-cli/issues/18045)
- [Rate-Limited Free Tier Discussion #2436](https://github.com/google-gemini/gemini-cli/discussions/2436)
