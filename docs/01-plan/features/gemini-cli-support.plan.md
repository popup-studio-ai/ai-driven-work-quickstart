# Gemini CLI Support Plan

> **Summary**: Add Claude / Gemini selection option to ADW installer -- when the user selects one, IDE, CLI, plugins, and MCP configuration are all installed for that platform
>
> **Project**: popup-claude (AI-Driven Work Installer)
> **Feature**: gemini-cli-support
> **Author**: Claude (PDCA Plan)
> **Date**: 2026-02-22
> **Status**: Draft (v2 -- compatibility research reflected)

---

## 1. Overview

### 1.1 Purpose

The current ADW installer is hardcoded for Claude only. When a user **selects either Claude or Gemini**, IDE, CLI, plugins, and MCP configuration should **all be installed for that platform**.

### 1.2 Compatibility Research Results

#### Claude vs Gemini -- Installation Item Comparison

| Item | Claude | Gemini |
|------|--------|--------|
| **IDE** | VS Code | VS Code |
| **IDE Installation** | `winget install Microsoft.VisualStudioCode` / `brew install --cask visual-studio-code` | Same |
| **VS Code Extension** | `anthropic.claude-code` | `Google.gemini-cli-vscode-ide-companion` |
| **CLI Installation** | `curl claude.ai/install.sh \| bash` / `irm claude.ai/install.ps1 \| iex` | `npm install -g @google/gemini-cli` |
| **Plugin** | `claude plugin install bkit@bkit-marketplace` | `gemini extensions install https://github.com/popup-studio-ai/bkit-gemini.git` |
| **MCP Config File** | `~/.claude/mcp.json` | `~/.gemini/settings.json` |
| **MCP Registration Command** | `claude mcp add` | `gemini mcp add` |
| **MCP JSON Structure** | `{ "mcpServers": { ... } }` | `{ "mcpServers": { ... } }` (same) |
| **CLI Existence Check** | `command -v claude` | `command -v gemini` |
| **Authentication** | Anthropic account/API key | Google account (free) |

#### Per-MCP Module Change Requirements

| Module | CLI Check | MCP Registration Command | MCP Config File Path | Changes Needed |
|------|:--------:|:--------------:|:----------------:|:---------:|
| **Notion** | `claude` -> `gemini` | `claude mcp add` -> `gemini mcp add` | -- | 2 locations |
| **Figma** | `claude` -> `gemini` | `claude mcp add` -> `gemini mcp add` | -- | 2 locations |
| **Atlassian** | -- | `claude mcp add` -> `gemini mcp add` | `~/.claude/` -> `~/.gemini/` | 2 locations |
| **Google** | -- | -- | `~/.claude/` -> `~/.gemini/` | 1 location |
| **GitHub** | -- | -- | -- | None |
| **Pencil** | -- | -- | VS Code extension | TBD |
| **OAuth Helper** | -- | `claude mcp list` -> `gemini mcp list` | -- | 1 location |

### 1.3 Branch Point Summary

All changes come down to these **4 branch points**:

1. **VS Code Extension**: `anthropic.claude-code` vs `Google.gemini-cli-vscode-ide-companion`
2. **CLI Installation + Check**: `claude` vs `gemini` command
3. **Plugin Installation**: bkit (claude) vs bkit-gemini
4. **MCP Configuration**: `~/.claude/mcp.json` vs `~/.gemini/settings.json`

---

## 2. Scope

### 2.1 In Scope

- [ ] **Main installer**: `--cli claude|gemini` parameter + `CLI_TYPE` environment variable
- [ ] **base module**: IDE, CLI, plugin, VS Code extension branching
- [ ] **Notion module**: CLI check + MCP registration command branching
- [ ] **Figma module**: CLI check + MCP registration command branching
- [ ] **Atlassian module**: MCP registration command + config file path branching
- [ ] **Google module**: MCP config file path branching
- [ ] **Shared utility (mcp-config.sh)**: Config file path branching
- [ ] **Shared utility (oauth-helper.sh)**: `claude mcp list` -> per-CLI branching
- [ ] **README update**

### 2.2 Out of Scope

- Simultaneous Gemini + Claude installation (only one selectable)
- Landing page UI changes (separate task)
- Pencil module Gemini support (separate task after confirmation)

---

## 3. Requirements

### 3.1 Functional Requirements

#### Main Installer (install.sh / install.ps1)

| ID | Requirement | Priority | Target File |
|----|-------------|:--------:|----------|
| FR-01 | **Add `--cli claude\|gemini` parameter** -- Default `claude` when unspecified | **High** | `install.sh`, `install.ps1` |
| FR-02 | **`CLI_TYPE` environment variable support** -- `CLI_TYPE=gemini bash` for remote execution | **High** | `install.sh`, `install.ps1` |
| FR-03 | **Export `$CLI_TYPE` to all child modules** | **High** | `install.sh`, `install.ps1` |

#### base module (base/install.sh / install.ps1)

| ID | Requirement | Priority | Target File |
|----|-------------|:--------:|----------|
| FR-04 | **IDE installation** -- Both Claude/Gemini install VS Code (common) | **High** | `base/install.sh`, `base/install.ps1` |
| FR-05 | **CLI installation branching** -- `claude` -> claude.ai install, `gemini` -> `npm install -g @google/gemini-cli` | **High** | `base/install.sh`, `base/install.ps1` |
| FR-06 | **Plugin branching** -- `claude` -> bkit, `gemini` -> bkit-gemini | **High** | `base/install.sh`, `base/install.ps1` |
| FR-07 | **VS Code extension branching** -- `claude` -> `anthropic.claude-code`, `gemini` -> `Google.gemini-cli-vscode-ide-companion` | **High** | `base/install.sh`, `base/install.ps1` |

#### MCP Modules (each module install.sh / install.ps1)

| ID | Requirement | Priority | Target File |
|----|-------------|:--------:|----------|
| FR-08 | **Notion: CLI check + MCP registration branching** | **High** | `notion/install.sh`, `notion/install.ps1` |
| FR-09 | **Figma: CLI check + MCP registration branching** | **High** | `figma/install.sh`, `figma/install.ps1` |
| FR-10 | **Atlassian: MCP registration + config path branching** | **High** | `atlassian/install.sh`, `atlassian/install.ps1` |
| FR-11 | **Google: MCP config path branching** | **High** | `google/install.sh`, `google/install.ps1` |

#### Shared Utilities

| ID | Requirement | Priority | Target File |
|----|-------------|:--------:|----------|
| FR-12 | **mcp-config.sh path branching** -- `~/.claude/mcp.json` or `~/.gemini/settings.json` based on `CLI_TYPE` | **High** | `shared/mcp-config.sh` |
| FR-13 | **oauth-helper.sh command branching** -- `claude mcp list` -> `gemini mcp list` | **High** | `shared/oauth-helper.sh`, `shared/oauth-helper.ps1` |

#### Other

| ID | Requirement | Priority | Target File |
|----|-------------|:--------:|----------|
| FR-14 | **README.md update** -- Add Gemini installation command examples | **Low** | `README.md` |

### 3.2 Non-Functional Requirements

| ID | Requirement | Priority |
|----|-------------|:--------:|
| NFR-01 | Default `claude` when `--cli` unspecified -- 100% existing behavior preserved | **Critical** |
| NFR-02 | Clear error message + manual installation guide on installation failure | **High** |
| NFR-03 | Existing tests do not break | **High** |

---

## 4. Implementation Strategy

### 4.1 Change Flow

```
User input: --cli gemini (or CLI_TYPE=gemini)
        |
        v
    install.sh / install.ps1
        |  Set CLI_TYPE variable + export
        v
    +---------------------------------------------+
    |  base module                                 |
    |  +-- [common] Node.js, Git, WSL, Docker      |
    |  +-- [branch] IDE: VS Code vs Antigravity    |
    |  +-- [branch] CLI: Claude vs Gemini CLI      |
    |  +-- [branch] Plugin: bkit vs bkit-gemini    |
    +---------------------------------------------+
        |  CLI_TYPE continues to pass
        v
    +---------------------------------------------+
    |  MCP modules (notion, figma, atlassian, etc.)|
    |  +-- [branch] CLI check: claude vs gemini    |
    |  +-- [branch] MCP register: claude mcp vs    |
    |  |   gemini mcp                              |
    |  +-- [branch] Config path: ~/.claude vs      |
    |      ~/.gemini                               |
    +---------------------------------------------+
```

### 4.2 Files to Modify (16 total)

| File | Changes |
|------|----------|
| `installer/install.sh` | `--cli` parameter + `CLI_TYPE` export |
| `installer/install.ps1` | `-cli` parameter + `$env:CLI_TYPE` |
| `modules/base/install.sh` | IDE + CLI + plugin + extension branching |
| `modules/base/install.ps1` | IDE + CLI + plugin + extension branching |
| `modules/notion/install.sh` | CLI check + MCP registration branching |
| `modules/notion/install.ps1` | CLI check + MCP registration branching |
| `modules/figma/install.sh` | CLI check + MCP registration branching |
| `modules/figma/install.ps1` | CLI check + MCP registration branching |
| `modules/atlassian/install.sh` | MCP registration + config path branching |
| `modules/atlassian/install.ps1` | MCP registration + config path branching |
| `modules/google/install.sh` | MCP config path branching |
| `modules/google/install.ps1` | MCP config path branching |
| `modules/shared/mcp-config.sh` | Config file path branching |
| `modules/shared/oauth-helper.sh` | `claude mcp list` branching |
| `modules/shared/oauth-helper.ps1` | `claude mcp list` branching |
| `README.md` | Gemini option documentation |

---

## 5. Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Gemini CLI is rapidly evolving | Installation command may change | npm package name is stable |
| `gemini mcp add` syntax may differ from `claude mcp add` | MCP registration failure | Verify exact syntax during Design phase |
| Gemini CLI Companion Extension ID change | Extension installation failure | Include manual installation guide message on failure |

---

## 6. Success Criteria

- [ ] `./install.sh --cli gemini` -> VS Code + Gemini CLI Companion extension + Gemini CLI + bkit-gemini installed
- [ ] `.\install.ps1 -cli gemini` -> Same
- [ ] `--cli` unspecified -> Existing Claude installation (100% backward compatible)
- [ ] MCP modules (notion, figma, atlassian, google) registered in Gemini settings
- [ ] Pencil module installs normally in Gemini mode
- [ ] Existing tests pass
