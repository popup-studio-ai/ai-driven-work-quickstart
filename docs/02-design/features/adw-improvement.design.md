# ADW Comprehensive Improvement — Design Document

> **Summary**: Based on 65.5% Match Rate analysis, detailed design for comprehensive security, quality, and compatibility improvements across 5 Sprints / 48 requirements (44 base + 4 new)
>
> **Feature**: adw-improvement
> **Version**: 1.2
> **Date**: 2026-02-13
> **Author**: CTO Team (8 specialized agents, parallel design)
> **Plan Reference**: `docs/01-plan/features/adw-improvement.plan.md` (v2.2)
> **Security Spec**: `docs/02-design/security-spec.md` (v1.2, includes FR-S1-11 + Security Logging)
> **Analysis References**:
> - `docs/03-analysis/adw-comprehensive.analysis.md` (Comprehensive analysis, Match Rate 65.5%)
> - `docs/03-analysis/security-verification-report.md` (12 security issues, manual verification)
> - `docs/03-analysis/shared-utilities-design.md` (10 shared utilities, detailed design)
> - `docs/03-analysis/adw-requirements-traceability-matrix.md` (44 FR, 89.6% coverage)
> **Gap Analysis**:
> - `docs/03-analysis/gap-security-verification.md` (Security gap 6P + 4D)
> - `docs/03-analysis/gap-shared-utilities.md` (Shared utilities gap 15P + 20D)
> - `docs/03-analysis/gap-requirements-traceability.md` (Traceability gap 19 items)
> **Status**: Draft (v1.2 -- reflects full cross-verification of 7 analysis documents)

---

## 1. Overview

### 1.1 Design Goals

This design document provides **concrete implementation designs** for 44 requirements to resolve 48 issues (Security 3 Critical / 8 High, Quality 9 items, OS 10 items) derived from the ADW Comprehensive Analysis Report (Match Rate 65.5%).

**Design Principles**:
1. **Security First** — OWASP Top 10 mapping, validate all inputs
2. **Backward Compatibility** — Maintain existing macOS user environment, gradual migration
3. **Testability** — Specify verification methods for all changes
4. **Minimal Changes** — Only make necessary changes, avoid excessive abstraction

### 1.2 CTO Team Agent Composition

| Agent | Role | Sprint Coverage | Output |
|-------|------|----------------|--------|
| Security Architect | Security design | Sprint 1 (10 FRs) | `docs/02-design/security-spec.md` |
| Enterprise Expert | Installer design | Sprint 2 (10 FRs) | Inline (this doc) |
| Code Analyzer | TypeScript refactoring | Sprint 3-4 (12 FRs) | Inline (this doc) |
| Infra Architect | CI/CD, Docker | Sprint 3-4 (8 files) | Inline (this doc) |
| Frontend Architect | Shared utilities | Sprint 3 (FR-S3-05) | `docs/03-analysis/shared-utilities-design.md` |
| QA Strategist | Test strategy | Sprint 3 (FR-S3-01~04) | `docs/03-analysis/test-strategy.md` |
| Product Manager | UX improvements | Sprint 5 (6 FRs) | `docs/02-design/features/sprint-5-ux-improvements.design.md` |
| Gap Detector | Requirements tracing | All Sprints | `docs/03-analysis/adw-requirements-traceability-matrix.md` |

### 1.3 Requirements Traceability Summary

- **Total Requirements**: 48 (12 + 11 + 10 + 10 + 6) -- per v2.2 plan
- **Analysis Issues Addressed**: 45 of 48 (93.8%)
- **Out of Scope Issues**: 3 items (SEC-11 third-party images, QA-05 structured logging, QA-09 CHANGELOG)
- **Cross-cutting Files**: `oauth.ts` (7 requirements), `install.sh` (6 requirements)
- **Gap Analysis Coverage**: Security gaps 10 items, shared utilities gaps 35 items, requirements traceability gaps 19 items -- all fully reflected

---

## 2. Architecture

### 2.1 System Architecture (Before → After)

```
BEFORE (65.5%):                           AFTER (95%+):
┌─────────────────────┐                   ┌──────────────────────────┐
│ installer/           │                   │ installer/                │
│  install.sh          │                   │  install.sh              │
│  (macOS only,        │                   │  (cross-platform,        │
│   osascript JSON)    │                   │   node/python3 JSON)     │
│  modules/            │                   │  modules/                │
│   base/              │                   │   base/ (apt+dnf+pacman) │
│   google/            │                   │   google/ (timeout+path) │
│   atlassian/         │                   │   atlassian/ (.env)      │
│   notion/            │                   │   shared/                │
│   figma/             │                   │    colors.sh             │
│   pencil/            │                   │    docker-utils.sh       │
│                      │                   │    mcp-config.sh         │
│                      │                   │    browser-utils.sh      │
│                      │                   │    package-manager.sh    │
│  (no tests)          │                   │  tests/                  │
│                      │                   │   test_module_json.sh    │
│                      │                   │   test_install_syntax.sh │
└─────────────────────┘                   └──────────────────────────┘

┌─────────────────────┐                   ┌──────────────────────────┐
│ google-workspace-mcp │                   │ google-workspace-mcp     │
│  src/                │                   │  src/                    │
│   auth/oauth.ts      │                   │   auth/oauth.ts          │
│   (no state, no      │                   │   (CSRF state, cached    │
│    cache, root user) │                   │    services, non-root)   │
│   tools/             │                   │   utils/                 │
│    gmail.ts (inject)  │                   │    retry.ts              │
│    drive.ts (inject)  │                   │    sanitize.ts           │
│    calendar.ts       │                   │    time.ts               │
│    (Seoul hardcode)  │                   │    mime.ts               │
│   index.ts (any)     │                   │    messages.ts           │
│                      │                   │   tools/                 │
│                      │                   │    (sanitized, typed,    │
│  (no tests, no CI)   │                   │     retry-wrapped)       │
│  Dockerfile          │                   │  Dockerfile (node:22,    │
│  (node:20, root)     │                   │   non-root, .dockerignore│
└─────────────────────┘                   └──────────────────────────┘

                                          ┌──────────────────────────┐
                                          │ .github/workflows/       │
                                          │  ci.yml (auto PR/push)   │
                                          │  lint→build→test+docker  │
                                          └──────────────────────────┘
```

### 2.2 Key Architectural Decisions

| Decision | Selected | Rationale |
|----------|----------|-----------|
| JSON Parser | `node -e` primary, `python3` fallback, `osascript` fallback | Node.js is always available as a base install dependency |
| Test Framework | Vitest 3.x | Native TypeScript ESM, fast execution |
| CI Pipeline | GitHub Actions multi-job | lint → build → test + docker + smoke (parallel) |
| Token Storage | `.env` + environment variable references | Cross-platform, Docker-friendly |
| Rate Limiting | Custom exponential backoff (`withRetry()`) | Minimize external dependencies, specialized for 429/503 |
| Timezone | `Intl.DateTimeFormat()` default + `TIMEZONE` env var override | Auto-detection + explicit configuration |
| Service Caching | Module-level singleton with TTL inside `oauth.ts` | Service re-creation per 71 tools → single creation. Separate `google-client.ts` extraction deferred |
| Time Utilities | Consolidated into `src/utils/time.ts` (absorbing `timezone.ts`) | Single module for all time-related functions: `parseTime()`, `getTimezone()`, `getUtcOffsetString()`, etc. |
| Shell Helper Functions | `print_success()` / `print_error()` (per shared-utilities-design) | Adopted clearer naming instead of `print_ok()`/`print_fail()` |
| MCP Config Functions | `mcp_add_docker_server()` + `mcp_add_stdio_server()` separated by type | Improved parameter clarity compared to single `mcp_add_server()` |

---

## 3. Sprint 1 — Critical Security Design

> **Reference**: `docs/02-design/security-spec.md` (includes full code)
> **OWASP Mapping**: A01 (Broken Access Control), A03 (Injection), A07 (Auth Failures)

### 3.1 FR-S1-01: OAuth State Parameter (CSRF Prevention)

**File**: `google-workspace-mcp/src/auth/oauth.ts` (lines 113-118)

**Design**:
```typescript
import crypto from "crypto";

// In getTokenFromBrowser():
const state = crypto.randomBytes(16).toString("hex");

const authUrl = oauth2Client.generateAuthUrl({
  access_type: "offline",
  scope: SCOPES,
  prompt: "consent",
  state: state,  // CSRF protection
});

// In callback handler:
const receivedState = new URL(callbackUrl).searchParams.get("state");
if (receivedState !== state) {
  throw new Error("OAuth state mismatch - possible CSRF attack");
}
```

**Invariant**: Every OAuth authorization request MUST include a `state` parameter, and every callback MUST validate it matches.

### 3.2 FR-S1-02: Drive API Query Escaping

**File**: `google-workspace-mcp/src/tools/drive.ts` (lines 18, 59)

**Design** — New shared sanitizer in `src/utils/sanitize.ts`:
```typescript
export function escapeDriveQuery(input: string): string {
  return input.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
}
```

**Application**:
```typescript
// BEFORE: let q = `name contains '${query}' and trashed = false`;
// AFTER:
let q = `name contains '${escapeDriveQuery(query)}' and trashed = false`;
```

### 3.3 FR-S1-03: osascript Template Injection Prevention

**File**: `installer/install.sh` (lines 29-39)

**Design**: Replace backtick template literal with stdin pipe:
```bash
parse_json() {
    local json="$1"
    local key="$2"
    # Primary: node -e (always available after base install)
    if command -v node > /dev/null 2>&1; then
        echo "$json" | node -e "
            let d='';process.stdin.on('data',c=>d+=c);
            process.stdin.on('end',()=>{
                try{const o=JSON.parse(d);const v='$key'.split('.').reduce((a,k)=>a&&a[k],o);
                process.stdout.write(v===undefined?'':String(v))}
                catch{process.stdout.write('')}
            })"
        return
    fi
    # Fallback: python3
    if command -v python3 > /dev/null 2>&1; then
        echo "$json" | python3 -c "
import json,sys
try:
    d=json.load(sys.stdin);v=d
    for k in '$key'.split('.'):v=v.get(k,'') if isinstance(v,dict) else ''
    print(v if v else '',end='')
except:print('',end='')"
        return
    fi
    # Last fallback: osascript (macOS only, stdin-based)
    if command -v osascript > /dev/null 2>&1; then
        echo "$json" | osascript -l JavaScript -e "
            var input=$.NSFileHandle.fileHandleWithStandardInput;
            var data=input.readDataToEndOfFile;
            var str=$.NSString.alloc.initWithDataEncoding(data,$.NSUTF8StringEncoding).js;
            var obj=JSON.parse(str);var keys='$key'.split('.');
            var val=obj;for(var k of keys)val=val?val[k]:undefined;
            val===undefined?'':String(val);" 2>/dev/null || echo ""
        return
    fi
    echo ""
}
```

### 3.4 FR-S1-04: Atlassian API Token Secure Storage

**File**: `installer/modules/atlassian/install.sh` (lines 147-172)

**Design**: Store credentials in `.env` file instead of inline in `.mcp.json`:
```bash
# Create .env file with restricted permissions
ENV_FILE="$HOME/.atlassian-mcp/.env"
mkdir -p "$(dirname "$ENV_FILE")"
cat > "$ENV_FILE" << EOF
CONFLUENCE_URL=$confluenceUrl
CONFLUENCE_USERNAME=$email
CONFLUENCE_API_TOKEN=$apiToken
JIRA_URL=$jiraUrl
JIRA_USERNAME=$email
JIRA_API_TOKEN=$apiToken
EOF
chmod 600 "$ENV_FILE"

# MCP config references .env via --env-file
config.mcpServers['atlassian'] = {
    command: 'docker',
    args: ['run', '-i', '--rm', '--env-file', envFile, 'ghcr.io/sooperset/mcp-atlassian:latest']
};
```

### 3.5 FR-S1-05 ~ FR-S1-10: Summary

| FR | Change | Key Code |
|----|--------|----------|
| FR-S1-05 | Figma: Informational only (template placeholder, not actual secret) | No code change needed |
| FR-S1-06 | Docker non-root: `adduser --system --uid 1001 app` + `USER app` | See Section 8 (Dockerfile) |
| FR-S1-07 | Token file permissions: `fs.chmodSync(TOKEN_PATH, 0o600)` after save | `oauth.ts:108` |
| FR-S1-08 | Config dir permissions: `mkdirSync(dir, { recursive: true, mode: 0o700 })` | `oauth.ts:53` |
| FR-S1-09 | Atlassian variable escaping: Use `--env-file` instead of shell interpolation | See FR-S1-04 above |
| FR-S1-10 | Email header injection: `sanitizeEmailHeader()` strips `\r\n` | `gmail.ts` send handler |

**Full implementation details**: `docs/02-design/security-spec.md`

---

## 4. Sprint 2 — Platform & Stability Design

### 4.1 FR-S2-01: Cross-Platform JSON Parser

See Section 3.3 above. The same `parse_json()` function serves both FR-S1-03 (security) and FR-S2-01 (compatibility).

**Test verification**:
```bash
# Linux test (no osascript):
echo '{"name":"test","order":3}' | parse_json /dev/stdin "name"
# Expected: "test"
```

### 4.2 FR-S2-02: Remote Shared Script Download

**File**: `installer/install.sh` (module loading section)

**Design**: Before executing each module in remote mode, download shared scripts:
```bash
run_module() {
    local mod="$1"
    # In remote mode, download shared scripts to temp dir
    if [ "$USE_LOCAL" != true ]; then
        SHARED_TMP=$(mktemp -d)
        # Ensure temp file cleanup (handles both normal and abnormal termination)
        trap 'rm -rf "$SHARED_TMP"' EXIT INT TERM
        for shared_script in colors.sh docker-utils.sh mcp-config.sh \
                             browser-utils.sh package-manager.sh oauth-helper.sh; do
            curl -sSL "$BASE_URL/modules/shared/$shared_script" \
                -o "$SHARED_TMP/$shared_script" || true
        done
        export SHARED_DIR="$SHARED_TMP"
    else
        export SHARED_DIR="$SCRIPT_DIR/modules/shared"
    fi
    # Execute module
    # ...
}
```

> **Decision**: The `trap 'rm -rf "$SHARED_TMP"' EXIT INT TERM` pattern ensures temp file cleanup even on abnormal termination. (Reflects requirements traceability gap analysis item 3)

Module scripts reference via `$SHARED_DIR`:
```bash
# Local execution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../shared/colors.sh"

# Remote execution (linked to FR-S2-02)
source "${SHARED_DIR:-$SCRIPT_DIR/../shared}/colors.sh"
```

### 4.3 FR-S2-03: MCP Config Path Unification

**Files affected**: `install.sh:406`, `google/install.sh:328`, `atlassian/install.sh:145`

**Design**: Migrate from `~/.mcp.json` to `~/.claude/mcp.json` with backward compatibility:
```bash
MCP_CONFIG_PATH="$HOME/.claude/mcp.json"
MCP_LEGACY_PATH="$HOME/.mcp.json"

# Migration: merge legacy into new path
if [ -f "$MCP_LEGACY_PATH" ] && [ ! -f "$MCP_CONFIG_PATH" ]; then
    mkdir -p "$(dirname "$MCP_CONFIG_PATH")"
    cp "$MCP_LEGACY_PATH" "$MCP_CONFIG_PATH"
elif [ -f "$MCP_LEGACY_PATH" ] && [ -f "$MCP_CONFIG_PATH" ]; then
    # Merge: new file takes precedence
    node -e "
const fs=require('fs');
const legacy=JSON.parse(fs.readFileSync('$MCP_LEGACY_PATH','utf8'));
const current=JSON.parse(fs.readFileSync('$MCP_CONFIG_PATH','utf8'));
const merged={...legacy,...current,mcpServers:{...legacy.mcpServers,...current.mcpServers}};
fs.writeFileSync('$MCP_CONFIG_PATH',JSON.stringify(merged,null,2));
"
fi
```

### 4.4 FR-S2-04: Linux Package Manager Expansion

**File**: `installer/modules/base/install.sh`

**Design**: Detect and use the appropriate package manager:
```bash
detect_pkg_manager() {
    if command -v apt-get > /dev/null 2>&1; then echo "apt"
    elif command -v dnf > /dev/null 2>&1; then echo "dnf"
    elif command -v pacman > /dev/null 2>&1; then echo "pacman"
    else echo "unknown"; fi
}

pkg_install() {
    local package="$1"
    case "$PKG_MANAGER" in
        apt) sudo apt-get install -y "$package" ;;
        dnf) sudo dnf install -y "$package" ;;
        pacman) sudo pacman -S --noconfirm "$package" ;;
        *) echo "Please install $package manually" ;;
    esac
}
```

### 4.5 FR-S2-05 ~ FR-S2-09: Summary

| FR | Change | Impact |
|----|--------|--------|
| FR-S2-05 | Figma `module.json`: `type: "remote-mcp"`, `node: false`, `python3: true` | Metadata accuracy |
| FR-S2-06 | Atlassian `module.json`: Add `modes` array for Docker/Rovo dual mode | Informational metadata |
| FR-S2-07 | Module execution sorting by `MODULE_ORDERS` before loop | Dependency order guarantee |
| FR-S2-08 | Docker wait timeout (300s polling loop) in `google/install.sh` | Prevents infinite hang |
| FR-S2-09 | `python3: true` in Notion/Figma `module.json` | Dependency documentation |

### 4.6 FR-S2-10: Windows Admin Privileges Conditional Request

> **Gap analysis reflected**: `gap-security-verification.md` D-03 -- Detailed fix code for SEC-06 was not reflected in the design document

**File**: `installer/install.ps1` (lines 130-153)
**OWASP Mapping**: A04 -- Insecure Design
**Severity**: High

**Design**: Introduce `Test-AdminRequired` function to determine admin privilege requirements per module:

```powershell
function Test-AdminRequired {
    param([string]$ModuleName)
    # base module: Admin required for global Node.js/npm install
    # google, atlassian: Only required when Docker is not installed
    # figma, notion, github, pencil: No admin required
    $adminModules = @("base")
    $conditionalModules = @("google", "atlassian") # Only when Docker is not installed

    if ($ModuleName -in $adminModules) { return $true }
    if ($ModuleName -in $conditionalModules) {
        return -not (Get-Command docker -ErrorAction SilentlyContinue)
    }
    return $false
}

# In the main execution flow:
$needsAdmin = $SelectedModules | Where-Object { Test-AdminRequired $_ }
if ($needsAdmin) {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Administrator privileges needed for: $($needsAdmin -join ', ')"
        # Request UAC elevation
        Start-Process powershell -Verb RunAs -ArgumentList $PSCommandPath
        exit
    }
}
```

### 4.7 FR-S2-11: Docker Desktop Version Compatibility Check

> **Gap analysis reflected**: `gap-requirements-traceability.md` Section 2 #5 -- New FR to address OS-06

**Files**: `google/install.sh`, `atlassian/install.sh`, `installer/modules/shared/docker-utils.sh`

**Design**: Add Docker Desktop version + OS compatibility cross-validation to `docker_check()` function:

```bash
# Added to docker-utils.sh
docker_check_compatibility() {
    local docker_version
    docker_version=$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo "")

    if [[ "$OSTYPE" == "darwin"* ]]; then
        local os_version
        os_version=$(sw_vers -productVersion 2>/dev/null || echo "")
        local major_version="${os_version%%.*}"

        # Docker Desktop 4.42+ requires macOS Sonoma (14.x) or later
        if [[ -n "$docker_version" ]] && [[ "$docker_version" > "4.42" ]]; then
            if [[ "$major_version" -lt 14 ]]; then
                echo -e "  ${YELLOW}Warning: Docker Desktop $docker_version may not support macOS $os_version${NC}"
                echo -e "  ${YELLOW}Consider using Docker Desktop 4.41 or earlier for macOS Ventura${NC}"
                return 1
            fi
        fi
    fi
    return 0
}
```

**Full before/after code**: Enterprise Expert agent output (see traceability matrix)

---

## 5. Sprint 3 — Quality & Testing Design

### 5.1 FR-S3-01: Google MCP Unit Tests (Vitest)

**Framework Configuration** — `google-workspace-mcp/vitest.config.ts`:
```typescript
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    globals: true,
    environment: "node",
    include: ["src/**/__tests__/**/*.test.ts"],
    coverage: {
      provider: "v8",
      reporter: ["text", "html", "lcov"],
      include: ["src/**/*.ts"],
      exclude: ["src/**/__tests__/**", "src/**/*.d.ts"],
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

**Test Strategy** — Priority-ranked 78 test cases:

| Priority | Tests | Category | Gate |
|----------|------:|----------|------|
| P0 (Critical) | 10 | Security: header injection, query escaping, CSRF | Block deployment |
| P1 (Core) | 46 | API calls, MIME parsing, timezone, OAuth flow | Block release |
| P2 (Edge) | 21 | Empty results, large files, network errors | Document known issues |
| P3 (Polish) | 1 | Tool registration count | Informational |

**Mock Strategy**: Mock at `getGoogleServices()` boundary:
```typescript
vi.mock("../../auth/oauth.js", () => ({
  getGoogleServices: vi.fn(),
}));
```

**Full test strategy**: `docs/03-analysis/test-strategy.md`

### 5.2 FR-S3-02: Installer Smoke Tests

**Framework**: Bash test scripts in `installer/tests/`

| Test Suite | Tests | Purpose |
|------------|------:|---------|
| `test_module_json.sh` | 49 | JSON syntax, required fields, type validation |
| `test_install_syntax.sh` | 9 | Bash/PowerShell syntax check |
| `test_module_ordering.sh` | 3 | Installation sequence validation |
| **Total** | **73** | |

### 5.3 FR-S3-03: CI Auto-Trigger Pipeline

**File**: `.github/workflows/ci.yml`

```yaml
name: CI
on:
  push:
    branches: [master, develop]
  pull_request:
    branches: [master]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22 }
      - run: cd google-workspace-mcp && npm ci
      - run: cd google-workspace-mcp && npm run lint
      - run: cd google-workspace-mcp && npm run format:check

  build:
    needs: lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22 }
      - run: cd google-workspace-mcp && npm ci && npm run build

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22 }
      - run: cd google-workspace-mcp && npm ci && npm run test:coverage

  smoke-tests:
    needs: build
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - run: bash installer/tests/test_module_json.sh
      - run: bash installer/tests/test_install_syntax.sh

  security-audit:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22 }
      - run: cd google-workspace-mcp && npm ci && npm audit --audit-level=high

  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install ShellCheck
        run: sudo apt-get install -y shellcheck
      - name: Run ShellCheck on installer scripts
        run: |
          find installer/ -name "*.sh" -exec shellcheck -S warning {} +

  docker-build:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: cd google-workspace-mcp && docker build -t test .
      - run: |
          docker run --rm test node -e "console.log('OK')"
          docker run --rm test id -u | grep -q 1001
```

> **v1.2 addition**: `security-audit` job (FR-S3-09 npm audit CI integration), `shellcheck` job (reflects cross-cutting concern #8)

### 5.4 FR-S3-05: Shared Utilities (Detailed Design)

> **Gap analysis reflected**: Shared utilities gap analysis (gap-shared-utilities.md) items D-1 through D-20 reflected
> **Original detailed design**: `docs/03-analysis/shared-utilities-design.md`

#### 5.4.1 Installer Shared Utilities Detail

**Directory**: `installer/modules/shared/`

> **Decision**: Function names are unified per `shared-utilities-design.md`. Adopted `print_success()`/`print_error()` instead of `print_ok()`/`print_fail()`, `browser_open()` instead of `open_browser()`, `mcp_add_docker_server()`/`mcp_add_stdio_server()` instead of `mcp_add_server()`.

| File | Functions | Eliminates | Source Reference |
|------|-----------|------------|-----------------|
| `colors.sh` | `RED`, `GREEN`, `YELLOW`, `CYAN`, `GRAY`, `BLUE`, `MAGENTA`, `WHITE`, `NC`, `COLOR_SUCCESS`, `COLOR_ERROR`, `COLOR_WARNING`, `COLOR_INFO`, `COLOR_DEBUG`, `print_success()`, `print_error()`, `print_warning()`, `print_info()`, `print_debug()` | 42 lines of duplicate color definitions across 7 modules | shared-utilities-design Section 1.3.1 |
| `docker-utils.sh` | `docker_is_installed()`, `docker_is_running()`, `docker_get_status()`, `docker_check()`, `docker_wait_for_start()`, `docker_install()`, `docker_pull_image()`, `docker_cleanup_container()`, `docker_show_install_guide()` | 4x duplicate Docker checks + install/cleanup logic | shared-utilities-design Section 1.3.2 |
| `mcp-config.sh` | `mcp_get_config_path()`, `mcp_check_node()`, `mcp_add_docker_server()`, `mcp_add_stdio_server()`, `mcp_remove_server()`, `mcp_server_exists()` | 4x duplicate Node.js `-e` JSON manipulation blocks | shared-utilities-design Section 1.3.3 |
| `browser-utils.sh` | `browser_open()`, `browser_open_with_prompt()`, `browser_open_or_show()`, `browser_wait_for_completion()` | Cross-platform browser open duplication across 4 modules (including WSL detection) | shared-utilities-design Section 1.3.4 |
| `package-manager.sh` | `pkg_detect_manager()`, `pkg_install()`, `pkg_install_cask()`, `pkg_is_installed()`, `pkg_ensure_installed()` | brew/apt/dnf/yum/pacman package manager abstraction (linked to FR-S2-04) | shared-utilities-design Section 1.3.5 |

**Key function design -- docker-utils.sh**:
```bash
# Docker Desktop install (platform-specific branching)
docker_install() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - Homebrew with progress spinner
        brew install --cask docker > /dev/null 2>&1 &
        BREW_PID=$!
        # show spinner ...
        wait $BREW_PID
    else
        # Linux - official install script
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker $USER
    fi
    DOCKER_NEEDS_RESTART=true
}

# Docker image pull with progress
docker_pull_image() {
    local image_name="$1"
    echo -e "  ${YELLOW}Pulling Docker image: $image_name${NC}"
    docker pull "$image_name" 2>/dev/null
}

# Container cleanup (by image)
docker_cleanup_container() {
    local image_name="$1"
    local container_id
    container_id=$(docker ps -q --filter "ancestor=$image_name" 2>/dev/null)
    if [ -n "$container_id" ]; then
        docker stop "$container_id" > /dev/null 2>&1
        docker rm "$container_id" > /dev/null 2>&1
    fi
}
```

**Key function design -- package-manager.sh**:
```bash
# Package manager detection (brew/apt/dnf/yum/pacman)
pkg_detect_manager() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        command -v brew > /dev/null 2>&1 && echo "brew" || echo "none"
    elif command -v apt > /dev/null 2>&1; then echo "apt"
    elif command -v dnf > /dev/null 2>&1; then echo "dnf"
    elif command -v yum > /dev/null 2>&1; then echo "yum"
    elif command -v pacman > /dev/null 2>&1; then echo "pacman"
    else echo "none"; fi
}

# Package install (auto-branching by package manager)
pkg_install() {
    local package_name="$1"
    local manager=$(pkg_detect_manager)
    case "$manager" in
        brew) brew install "$package_name" ;;
        apt) sudo apt update && sudo apt install -y "$package_name" ;;
        dnf) sudo dnf install -y "$package_name" ;;
        yum) sudo yum install -y "$package_name" ;;
        pacman) sudo pacman -S --noconfirm "$package_name" ;;
        none) echo -e "${RED}No package manager detected${NC}"; return 1 ;;
    esac
}

# Auto-install if not already installed
pkg_ensure_installed() {
    local package_name="$1"
    local description="${2:-$package_name}"
    if command -v "$package_name" > /dev/null 2>&1; then
        echo -e "  ${GREEN}$description is already installed${NC}"
    else
        echo -e "  ${YELLOW}Installing $description...${NC}"
        pkg_install "$package_name"
    fi
}
```

**Key function design -- browser-utils.sh**:
```bash
# Cross-platform browser open
browser_open() {
    local url="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$url" 2>/dev/null
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        start "$url" 2>/dev/null
    elif command -v xdg-open > /dev/null 2>&1; then
        xdg-open "$url" 2>/dev/null
    else
        echo -e "  ${YELLOW}Could not auto-open browser. Please open manually:${NC}"
        echo "  $url"
        return 1
    fi
}

# Open after prompt
browser_open_with_prompt() {
    local description="$1" url="$2"
    read -p "Open $description in browser? (y/n): " response < /dev/tty
    [ "$response" = "y" ] || [ "$response" = "Y" ] && browser_open "$url"
}
```

**Source pattern**:
```bash
# Local execution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../shared/colors.sh"
source "$SCRIPT_DIR/../shared/docker-utils.sh"
source "$SCRIPT_DIR/../shared/mcp-config.sh"
source "$SCRIPT_DIR/../shared/browser-utils.sh"

# Remote execution (linked to FR-S2-02)
source "${SHARED_DIR:-$SCRIPT_DIR/../shared}/colors.sh"
```

**Target modules for modification** (7):
| Module | Key Changes |
|--------|----------|
| `base/install.sh` | colors.sh + package-manager.sh source |
| `google/install.sh` | colors.sh + docker-utils.sh + mcp-config.sh + browser-utils.sh source |
| `atlassian/install.sh` | colors.sh + docker-utils.sh + mcp-config.sh + browser-utils.sh source |
| `figma/install.sh` | colors.sh + browser-utils.sh source |
| `notion/install.sh` | colors.sh + browser-utils.sh source |
| `github/install.sh` | colors.sh source |
| `pencil/install.sh` | colors.sh source |

**Installer acceptance criteria**:
1. All 7 installer modules source `shared/colors.sh`
2. Zero inline color definitions (`RED=`, `GREEN=`, etc.)
3. Docker-related modules (google, atlassian) use `docker_check()`
4. MCP config modules (google, atlassian) use `mcp_add_docker_server()` / `mcp_add_stdio_server()`
5. Browser-opening modules (atlassian, google, figma, notion) use `browser_open()`

#### 5.4.2 Google MCP Shared Utilities Detail

> **Decision -- time.ts vs timezone.ts consolidation**: Unified into `src/utils/time.ts`. All of `parseTime()`, `getCurrentTime()`, `addDays()`, `formatDate()` + existing `timezone.ts`'s `getTimezone()`, `getUtcOffsetString()` are consolidated into `time.ts`.

> **Decision -- google-client.ts architecture**: Adopt the internal caching approach within `oauth.ts` (maintain current design). However, add `clearServiceCache()` function as an export for testing convenience.

> **Decision -- sanitize.ts function scope**: Finalized with 7 functions -- `escapeDriveQuery()`, `validateDriveId()`, `sanitizeEmailHeader()`, `validateEmail()`, `validateMaxLength()`, `sanitizeFilename()`, `sanitizeRange()`.

| File | Exports | Used By | Sprint |
|------|---------|---------|--------|
| `time.ts` | `parseTime()`, `getCurrentTime()`, `addDays()`, `formatDate()`, `getTimezone()`, `getUtcOffsetString()` | calendar.ts, other time-related tools | S3-05, S4-03 consolidated |
| `retry.ts` | `withRetry()`, `RetryOptions` | All 6 tool files (~80 API calls) | S4-01 |
| `sanitize.ts` | `escapeDriveQuery()`, `validateDriveId()`, `sanitizeEmailHeader()`, `validateEmail()`, `validateMaxLength()`, `sanitizeFilename()`, `sanitizeRange()` | drive.ts, gmail.ts, sheets.ts, etc. | S1-02, S1-10 |
| `mime.ts` | `extractTextBody()`, `extractAttachments()` | gmail.ts | S4-07 |
| `messages.ts` | 8-category messages + `msg()` helper | All tool files | S3-05, S5-05 concurrent implementation |

**sanitize.ts extended function design** (from 5 to 7 functions):
```typescript
// Existing (retained)
export function escapeDriveQuery(input: string): string { ... }
export function validateDriveId(id: string): boolean { ... }
export function sanitizeEmailHeader(header: string): string { ... }
export function validateEmail(email: string): boolean { ... }
export function validateMaxLength(input: string, max: number): string { ... }

// Newly added (reflects gap analysis D-10)
export function sanitizeFilename(filename: string): string {
  return filename
    .replace(/[<>:"/\\|?*\x00-\x1F]/g, "_")
    .replace(/\.+/g, ".")
    .replace(/^\./, "")
    .trim()
    .substring(0, 255);
}

export function sanitizeRange(range: string): string | null {
  // Google Sheets A1 notation validation
  const rangeRegex = /^([^!]+!)?[A-Z]+\d+:[A-Z]+\d+$|^([^!]+!)?[A-Z]+\d+$/i;
  return rangeRegex.test(range) ? range.trim() : null;
}
```

**messages.ts detailed design** (8 categories):
```typescript
export const messages = {
  common: {
    success: "Success",
    failed: "Failed",
    created: "Created successfully",
    updated: "Updated successfully",
    deleted: "Deleted successfully",
    notFound: "Not found",
  },
  calendar: {
    eventCreated: (title: string) => `Event "${title}" created successfully.`,
    eventUpdated: "Event updated successfully.",
    eventDeleted: "Event deleted successfully.",
    // ... 7 messages
  },
  gmail: {
    emailSent: (to: string) => `Email sent to ${to}.`,
    draftSaved: "Draft saved successfully.",
    // ... 11 messages
  },
  drive: { /* 10 messages */ },
  docs: { /* 7 messages */ },
  sheets: { /* 9 messages */ },
  slides: { /* 7 messages */ },
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

// Parameterized message helper function
export function msg(
  template: string | ((...args: any[]) => string),
  ...args: any[]
): string {
  return typeof template === "function" ? template(...args) : template;
}
```

> **Decision -- messages.ts implementation timing**: Implement concurrently with Sprint 5 FR-S5-05 (295 Korean strings to English conversion). In Sprint 3, only create the `messages.ts` file structure; in Sprint 5, perform the actual Korean-to-English migration.
>
> **Decision -- i18n direction** (gap analysis reflected: cross-cutting concern #7): Default to **English-only** at the current stage. However, preemptively apply `messages.ts`'s key-based structure so that when an i18n framework (e.g., `i18next`) is needed in the future, it can be adopted with minimal changes. Adopting the i18n framework itself is currently Out of Scope.

**time.ts consolidated design** (absorbing timezone.ts):
```typescript
// src/utils/time.ts -- consolidates timezone.ts functionality

export function getTimezone(): string {
  return process.env.TIMEZONE || Intl.DateTimeFormat().resolvedOptions().timeZone;
}

export function getUtcOffsetString(): string {
  const tz = getTimezone();
  const formatter = new Intl.DateTimeFormat("en-US", {
    timeZone: tz, timeZoneName: "longOffset",
  });
  const parts = formatter.formatToParts(new Date());
  const offset = parts.find(p => p.type === "timeZoneName")?.value || "+00:00";
  const match = offset.match(/GMT([+-]\d{2}:\d{2})/);
  return match ? match[1] : "+00:00";
}

export function parseTime(timeStr: string, timezone?: string): string {
  if (timeStr.includes("T")) return timeStr;
  const [date, time] = timeStr.split(" ");
  const offset = getUtcOffsetString();
  return `${date}T${time}:00${offset}`;
}

export function getCurrentTime(): string {
  return new Date().toISOString();
}

export function addDays(date: string | Date, days: number): string {
  const baseDate = typeof date === "string" ? new Date(date) : date;
  return new Date(baseDate.getTime() + days * 86400000).toISOString();
}

export function formatDate(isoString: string, locale: string = "en-US"): string {
  return new Date(isoString).toLocaleString(locale, {
    year: "numeric", month: "2-digit", day: "2-digit",
    hour: "2-digit", minute: "2-digit",
  });
}
```

**Service Cache test utility** (added to oauth.ts):
```typescript
// Test export added at the bottom of oauth.ts
export function clearServiceCache(): void {
  serviceCache = null;
}
```

**Google MCP acceptance criteria**:
1. Zero duplicate `parseTime()` functions in `calendar.ts`
2. All 69 handlers use cached `getGoogleServices()`
3. All Google API calls wrapped with `withRetry()`
4. User input passes through sanitize functions before reaching APIs
5. Zero hardcoded Korean messages (upon Sprint 5 completion)

**Full design**: `docs/03-analysis/shared-utilities-design.md`

### 5.5 FR-S3-06: ESLint + Prettier

**ESLint** — `google-workspace-mcp/eslint.config.js`:
```javascript
import eslint from "@eslint/js";
import tseslint from "typescript-eslint";
import prettierConfig from "eslint-config-prettier";

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  prettierConfig,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      "@typescript-eslint/no-explicit-any": "warn",
      "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
    },
  }
);
```

### 5.6 FR-S3-07: `any` Type Removal + strict Mode Preservation

> **Gap analysis reflected**: `gap-requirements-traceability.md` implicit requirement #6 -- Prevent strict:true regression when removing `any`

**Verification method**: Run `tsc --strict --noEmit` step before build in the CI pipeline to ensure strict compatibility.

| Location | Before | After |
|----------|--------|-------|
| `index.ts:32` | `async (params: any)` | `async (params: Record<string, unknown>)` |
| `sheets.ts:18` | `const requestBody: any` | `const requestBody: sheets_v4.Schema$Spreadsheet` |
| `sheets.ts:341` | `const cellFormat: any` | `const cellFormat: sheets_v4.Schema$CellFormat` |
| `slides.ts:135` | `const requests: any[]` | `const requests: slides_v1.Schema$Request[]` |
| `slides.ts:156` | `const textRequests: any[]` | `const textRequests: slides_v1.Schema$Request[]` |
| `calendar.ts:288` | `const updatedEvent: any` | `const updatedEvent: CalendarEventUpdate` |
| `docs.ts:236` | `as any` | `as NamedStyleType` (union type) |

### 5.7 FR-S3-08: Error Message English Unification

```typescript
// BEFORE (Korean)
console.error("오류:", error);
console.error("서버 시작 실패:", error);

// AFTER (English)
console.error("Error:", error);
console.error("Server startup failed:", error);
```

---

## 6. Sprint 4 — Google MCP Hardening Design

### 6.1 FR-S4-01: Rate Limiting with Exponential Backoff

**New file**: `google-workspace-mcp/src/utils/retry.ts`

```typescript
export interface RetryOptions {
  maxAttempts?: number;    // Default: 3
  initialDelay?: number;   // Default: 1000ms
  backoffFactor?: number;  // Default: 2
  maxDelay?: number;       // Default: 10000ms
  retryableErrors?: number[]; // Default: [429, 500, 502, 503, 504]
}

// Include network errors as retryable targets (reflects gap analysis D-9)
function isRetryableError(error: unknown, retryableStatuses: number[]): boolean {
  // HTTP status code based retry
  const status = (error as any)?.response?.status;
  if (status && retryableStatuses.includes(status)) return true;

  // Network error based retry (ECONNRESET, ETIMEDOUT, etc.)
  const code = (error as any)?.code;
  const networkErrors = ["ECONNRESET", "ETIMEDOUT", "ECONNREFUSED", "EPIPE", "EAI_AGAIN"];
  if (code && networkErrors.includes(code)) return true;

  return false;
}

export async function withRetry<T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> {
  const maxAttempts = options.maxAttempts ?? 3;
  const initialDelay = options.initialDelay ?? 1000;
  const backoffFactor = options.backoffFactor ?? 2;
  const retryableStatuses = options.retryableErrors ?? [429, 500, 502, 503, 504];
  let delay = initialDelay;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error: unknown) {
      if (!isRetryableError(error, retryableStatuses) || attempt === maxAttempts) throw error;

      const status = (error as any)?.response?.status || (error as any)?.code || "unknown";
      console.warn(`[Retry] Attempt ${attempt}/${maxAttempts} failed (${status}). Retrying in ${delay}ms...`);
      await new Promise(r => setTimeout(r, delay));
      delay = Math.min(delay * backoffFactor, options.maxDelay ?? 10000);
    }
  }
  throw new Error("Unreachable");
}
```

**Application**: Wrap every Google API call:
```typescript
const response = await withRetry(() =>
  gmail.users.messages.list({ userId: "me", q: query, maxResults })
);
```

### 6.2 FR-S4-02: Dynamic OAuth Scope

**File**: `google-workspace-mcp/src/auth/oauth.ts`

```typescript
const SCOPE_MAP: Record<string, string[]> = {
  gmail: ["https://www.googleapis.com/auth/gmail.modify"],
  calendar: ["https://www.googleapis.com/auth/calendar"],
  drive: ["https://www.googleapis.com/auth/drive"],
  docs: ["https://www.googleapis.com/auth/documents"],
  sheets: ["https://www.googleapis.com/auth/spreadsheets"],
  slides: ["https://www.googleapis.com/auth/presentations"],
};

function resolveScopes(): string[] {
  const envScopes = process.env.GOOGLE_SCOPES;
  if (!envScopes) return Object.values(SCOPE_MAP).flat();
  return envScopes.split(",")
    .map(s => s.trim().toLowerCase())
    .flatMap(s => SCOPE_MAP[s] || [s]);
}

const SCOPES = resolveScopes();
```

### 6.3 FR-S4-03: Dynamic Timezone

> **Decision**: Instead of creating `timezone.ts` as a separate file, consolidate into `src/utils/time.ts` (see Section 5.4.2). `getTimezone()` and `getUtcOffsetString()` functions are located in `time.ts` alongside `parseTime()`, etc.

**File**: `google-workspace-mcp/src/utils/time.ts` (see Section 5.4.2 consolidated design)

**Application in calendar.ts**:
```typescript
import { getTimezone, parseTime } from "../utils/time.js";

// BEFORE: timeZone: "Asia/Seoul"
// AFTER:
const timezone = getTimezone();
event.start = { dateTime: parseTime(startTime), timeZone: timezone };
```

### 6.4 FR-S4-04: Service Instance Caching

**File**: `google-workspace-mcp/src/auth/oauth.ts`

```typescript
interface GoogleServices {
  gmail: gmail_v1.Gmail;
  calendar: calendar_v3.Calendar;
  drive: drive_v3.Drive;
  docs: docs_v1.Docs;
  sheets: sheets_v4.Sheets;
  slides: slides_v1.Slides;
}

interface ServiceCache {
  services: GoogleServices;
  createdAt: number;
}

const CACHE_TTL_MS = 50 * 60 * 1000; // 50 minutes
let serviceCache: ServiceCache | null = null;

export async function getGoogleServices(): Promise<GoogleServices> {
  if (serviceCache && Date.now() - serviceCache.createdAt < CACHE_TTL_MS) {
    return serviceCache.services;
  }
  const auth = await getAuthenticatedClient();
  const services: GoogleServices = {
    gmail: google.gmail({ version: "v1", auth }),
    calendar: google.calendar({ version: "v3", auth }),
    drive: google.drive({ version: "v3", auth }),
    docs: google.docs({ version: "v1", auth }),
    sheets: google.sheets({ version: "v4", auth }),
    slides: google.slides({ version: "v1", auth }),
  };
  serviceCache = { services, createdAt: Date.now() };
  return services;
}

// Test utility: Clear service cache (used in unit tests)
export function clearServiceCache(): void {
  serviceCache = null;
}
```

### 6.5 Error Message Format Standard

> **Gap analysis reflected**: `gap-requirements-traceability.md` implicit requirement #2 -- Unify error handling patterns for Rate limiting + Token validation

All user-facing error messages follow this format:

```typescript
// Error message standard format
interface UserFacingError {
  code: string;        // e.g.: "AUTH_FAILED", "RATE_LIMITED", "INVALID_INPUT"
  message: string;     // User-friendly message (see messages.ts)
  detail?: string;     // Technical details (for developers, excluding sensitive info)
  retry?: boolean;     // Whether retry is possible
}

// Usage example (after retry.ts failure):
{
  code: "RATE_LIMITED",
  message: messages.errors.rateLimitExceeded,
  detail: "429 after 3 attempts (1s->2s->4s backoff)",
  retry: true
}

// Usage example (authentication failure):
{
  code: "AUTH_FAILED",
  message: messages.errors.authFailed,
  detail: "refresh_token expired or revoked",
  retry: false
}
```

**Rules**:
1. Never include sensitive information (API keys, tokens, user input, etc.) in the `detail` field
2. The `message` field must use centralized messages from `messages.ts`
3. Since MCP stdout is reserved for JSON-RPC, error logging must go to stderr

### 6.6 FR-S4-05 ~ FR-S4-10: Summary

| FR | Design | Key Code Change |
|----|--------|-----------------|
| FR-S4-05 | Token refresh validation: Check `refresh_token` exists, add 5-min expiry buffer | `oauth.ts: loadToken()` |
| FR-S4-06 | Auth mutex: Promise-based lock prevents concurrent auth requests | `let authInProgress: Promise \| null` |
| FR-S4-07 | Recursive MIME parsing: New `extractTextBody()` + `extractAttachments()` in `mime.ts` | `gmail.ts` import from `mime.ts` |
| FR-S4-08 | Attachment: Optional `maxSize` param, remove hardcoded `.slice(0, 1000)` | `gmail.ts` attachment handler |
| FR-S4-09 | Node.js 22: `node:22-slim` in Dockerfile, `@types/node: ^22.0.0` | Dockerfile + package.json |
| FR-S4-10 | `.dockerignore`: Exclude credentials, node_modules, .git, tests | New file |

### 6.7 oauth.ts Refactoring Roadmap

> **Decision**: Since 7 FRs (S1-01, S1-07, S1-08, S4-02, S4-04, S4-05, S4-06) modify the same file (`oauth.ts`), perform module separation after Sprint 1 completion and before Sprint 4 start. (Reflects requirements traceability gap analysis cross-cutting concern #1)

**Current structure**: `oauth.ts` (single file, ~240 lines)
- `generateAuthUrl()` + callback handler
- `loadToken()` + `saveToken()`
- `getGoogleServices()` + service cache
- config directory management

**Proposed separation structure**:
```
src/auth/
  config.ts          -- CONFIG_DIR, ensureConfigDir(), SCOPES
                        (handles FR-S1-08, FR-S4-02)
  token-manager.ts   -- loadToken(), saveToken(), validateRefreshToken()
                        (handles FR-S1-07, FR-S4-05)
  auth-flow.ts       -- generateAuthUrl(), callback, state validation, mutex
                        (handles FR-S1-01, FR-S4-06)
  service-cache.ts   -- getGoogleServices(), singleton cache with TTL,
                        clearServiceCache()
                        (handles FR-S4-04)
  index.ts           -- re-export public API (ensures backward compatibility)
```

**Application timing**: After Sprint 1 completion, before Sprint 4 start
**Risk mitigation**: Re-export all public APIs from `index.ts` to minimize import path changes

---

## 7. Sprint 5 — UX & Documentation Design

> **Full specification**: `docs/02-design/features/sprint-5-ux-improvements.design.md`

### 7.1 FR-S5-01: Post-Installation Verification

```bash
verify_module_installation() {
    local mod="$1"
    local type="${MODULE_TYPES[$idx]}"
    case "$type" in
        "mcp"|"docker-mcp")
            verify_mcp_server "$mod" 3  # 3 retry attempts
            ;;
        "remote-mcp")
            verify_remote_mcp "$mod"
            ;;
        "extension"|"cli")
            verify_cli_tool "$mod"
            ;;
    esac
}
```

### 7.2 FR-S5-02: Rollback Mechanism

- Backup `~/.claude/mcp.json` before installation
- On module failure: prompt user for rollback
- Rollback: restore config, remove Docker images
- On all success: cleanup backup files

### 7.3 FR-S5-03 ~ FR-S5-06: Summary

| FR | Change |
|----|--------|
| FR-S5-03 | `ARCHITECTURE.md`: Add Pencil module, shared/ directory, execution order section |
| FR-S5-04 | `package.json`: `0.1.0` → `1.0.0`, create `CHANGELOG.md` |
| FR-S5-05 | 295 Korean strings → English across 6 tool files |
| FR-S5-06 | `.gitignore`: Add `**/client_secret.json`, `**/token.json`, `.env*`, `*.pem`, `*.key` |

---

## 8. Docker & Infrastructure Design

### 8.1 Production Dockerfile

```dockerfile
FROM node:22-slim AS builder
WORKDIR /app
COPY package*.json tsconfig.json ./
RUN npm ci --ignore-scripts
COPY src ./src
RUN npm run build

FROM node:22-slim
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev --ignore-scripts && npm cache clean --force
COPY --from=builder /app/dist ./dist

# Non-root user (FR-S1-06)
RUN addgroup --system --gid 1001 app && \
    adduser --system --uid 1001 --ingroup app --home /app --no-create-home app
RUN mkdir -p /app/.google-workspace && chown -R app:app /app
VOLUME ["/app/.google-workspace"]
ENV GOOGLE_CONFIG_DIR=/app/.google-workspace NODE_ENV=production
USER app
CMD ["node", "dist/index.js"]
```

**Docker build cache optimization** (gap analysis reflected: implicit requirement #7):

Layer order is arranged from least to most frequently changed:
1. `node:22-slim` base image (rarely changes)
2. `package*.json` copy + `npm ci` (cache invalidated only on dependency changes)
3. `src/` copy + `tsc` build (cache invalidated on code changes)
4. Non-root user setup (only on Dockerfile modification)

The `USER app` directive is placed after `COPY --from=builder` to maximize build cache efficiency.

### 8.2 Updated package.json

```json
{
  "name": "google-workspace-mcp",
  "version": "1.0.0",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "vitest run",
    "test:coverage": "vitest run --coverage",
    "lint": "eslint src/",
    "format": "prettier --write \"src/**/*.ts\"",
    "format:check": "prettier --check \"src/**/*.ts\""
  },
  "devDependencies": {
    "@eslint/js": "^9.0.0",
    "@types/node": "^22.0.0",
    "@vitest/coverage-v8": "^3.0.0",
    "eslint": "^9.0.0",
    "eslint-config-prettier": "^10.0.0",
    "prettier": "^3.0.0",
    "typescript-eslint": "^8.0.0",
    "vitest": "^3.0.0"
  }
}
```

---

## 9. Security Design Summary

### 9.1 OWASP Mapping

| OWASP | ADW Issue | FR | Mitigation |
|-------|-----------|-----|------------|
| A01 Broken Access Control | Docker root user | FR-S1-06 | Non-root USER in Dockerfile |
| A03 Injection | Drive query injection | FR-S1-02 | `escapeDriveQuery()` |
| A03 Injection | Email header injection | FR-S1-10 | `sanitizeEmailHeader()` |
| A03 Injection | osascript template injection | FR-S1-03 | stdin pipe input |
| A03 Injection | Atlassian variable injection | FR-S1-09 | `--env-file` pattern |
| A04 Insecure Design | No rate limiting | FR-S4-01 | `withRetry()` exponential backoff |
| A05 Security Misconfiguration | Token file 644 permissions | FR-S1-07 | `chmod 0o600` |
| A07 Auth Failures | OAuth CSRF | FR-S1-01 | `state` parameter |
| A07 Auth Failures | Over-scoped OAuth | FR-S4-02 | Dynamic scope selection |
| A08 Data Integrity | Credentials in config | FR-S1-04 | `.env` file separation |
| A08 Data Integrity | curl\|bash no integrity check | FR-S1-11 | SHA-256 checksum + `download_and_verify()` |
| A09 Security Logging | No security event logging | FR-S3-10 | `logSecurityEvent()` to stderr |

### 9.2 Input Validation Layer

> **Gap analysis reflected**: Extended input validation from security verification gap analysis (D-02) -- previously covering only Drive/Gmail -- to include Calendar, Docs, Sheets, Slides

New `src/utils/sanitize.ts` provides centralized input sanitization (7 functions):

| Function | Purpose | Used In |
|----------|---------|---------|
| `escapeDriveQuery()` | Escape `'` in Drive API queries | `drive.ts` |
| `validateDriveId()` | Validate file/folder ID format | `drive.ts` |
| `sanitizeEmailHeader()` | Strip `\r\n` from email headers | `gmail.ts` |
| `validateEmail()` | RFC 5322 email format check | `gmail.ts` |
| `validateMaxLength()` | Input length limit | All tools |
| `sanitizeFilename()` | Remove/replace special characters in filenames | `drive.ts`, `docs.ts` |
| `sanitizeRange()` | Google Sheets A1 notation validation | `sheets.ts` |

**Per-tool input validation scope** (extended):

| Tool File | Parameters to Validate | Applied Functions |
|-----------|-------------------|-----------|
| `drive.ts` | query, fileId, folderId, name | `escapeDriveQuery()`, `validateDriveId()`, `sanitizeFilename()` |
| `gmail.ts` | to, subject, body headers | `sanitizeEmailHeader()`, `validateEmail()` |
| `calendar.ts` | startTime, endTime, title | `validateMaxLength()`, `time.ts` parsing validation |
| `docs.ts` | documentId, content, title | `validateDriveId()`, `validateMaxLength()` |
| `sheets.ts` | range, spreadsheetId, values | `sanitizeRange()`, `validateDriveId()` |
| `slides.ts` | presentationId, text, slideIndex | `validateDriveId()`, `validateMaxLength()` |

### 9.3 Environment Variable Management (.env.example)

> **Gap analysis reflected**: Requirements traceability gap analysis cross-cutting concern #3 -- 4+ new environment variables added but `.env.example` template not designed

**New file**: `google-workspace-mcp/.env.example`

```bash
# Google Workspace MCP Configuration
# Copy to .env and fill in values

# OAuth Scopes (comma-separated: gmail,calendar,drive,docs,sheets,slides)
# Default: all scopes enabled
# GOOGLE_SCOPES=gmail,calendar,drive

# Timezone (IANA format, e.g., America/New_York)
# Default: system timezone via Intl API
# TIMEZONE=Asia/Seoul

# Config directory (Docker volume mount point)
# Default: ~/.google-workspace-mcp
# GOOGLE_CONFIG_DIR=/app/.google-workspace
```

**New file**: `installer/.env.example`

```bash
# Atlassian Configuration (FR-S1-04)
# CONFLUENCE_URL=https://your-domain.atlassian.net/wiki
# CONFLUENCE_USERNAME=your@email.com
# CONFLUENCE_API_TOKEN=your-token
# JIRA_URL=https://your-domain.atlassian.net
# JIRA_USERNAME=your@email.com
# JIRA_API_TOKEN=your-token
```

### 9.4 module.json Schema Definition

> **Gap analysis reflected**: Requirements traceability gap analysis cross-cutting concern #4 -- 3 FRs modify module.json but no formal schema definition exists

**New file**: `installer/module-schema.json`

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": ["name", "order", "type"],
  "properties": {
    "name": { "type": "string", "description": "Module display name" },
    "order": { "type": "integer", "minimum": 1, "description": "Installation order" },
    "type": {
      "type": "string",
      "enum": ["mcp", "docker-mcp", "remote-mcp", "extension", "cli"],
      "description": "Module type"
    },
    "node": { "type": "boolean", "default": true, "description": "Node.js dependency required" },
    "python3": { "type": "boolean", "default": false, "description": "Python3 dependency required" },
    "docker": { "type": "boolean", "default": false, "description": "Docker dependency required" },
    "modes": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Supported mode list (e.g.: ['docker', 'rovo'])"
    },
    "description": { "type": "string" }
  }
}
```

**CI verification**: `installer/tests/test_module_json.sh` performs required field validation based on this schema

### 9.5 ShellCheck CI Integration

> **Gap analysis reflected**: Requirements traceability gap analysis cross-cutting concern #8 -- Shell scripts modified across 5 FRs but ShellCheck not included in CI

Job to add to the CI workflow (Section 5.3):

```yaml
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install ShellCheck
        run: sudo apt-get install -y shellcheck
      - name: Run ShellCheck on installer scripts
        run: |
          find installer/ -name "*.sh" -exec shellcheck -S warning {} +
```

### 9.6 Migration User Guide

> **Gap analysis reflected**: Requirements traceability gap analysis implicit requirement #5 -- User documentation missing for MCP path change (FR-S2-03)

Include the following migration guide section within FR-S5-03 (ARCHITECTURE.md) scope:

**MCP Config Path Migration Guide**:
1. **Auto migration**: Re-running the installer auto-merges `~/.mcp.json` → `~/.claude/mcp.json`
2. **Manual migration**: `cp ~/.mcp.json ~/.claude/mcp.json` then back up the original file
3. **Rollback method**: Restore original path with `cp ~/.claude/mcp.json.backup ~/.mcp.json`
4. **Verification**: `cat ~/.claude/mcp.json | node -e "process.stdin.on('data',d=>console.log(JSON.parse(d).mcpServers))"`

---

## 10. Test Plan

### 10.1 Test Coverage Targets

| Component | Metric | Target |
|-----------|--------|--------|
| Google MCP Unit Tests | Line coverage | 60%+ |
| Google MCP Unit Tests | P0 Security tests | 100% pass |
| Installer Smoke Tests | Module JSON validation | 100% pass |
| CI Pipeline | PR auto-trigger | Active |
| Docker Build | Non-root verification | Pass |

### 10.2 Test Case Summary

| Category | P0 | P1 | P2 | Total |
|----------|---:|---:|---:|------:|
| Gmail | 3 | 10 | 2 | 15 |
| Drive | 2 | 7 | 3 | 12 |
| Calendar | 0 | 7 | 3 | 10 |
| OAuth | 5 | 5 | 2 | 12 |
| Docs | 0 | 5 | 3 | 8 |
| Sheets | 0 | 7 | 3 | 10 |
| Slides | 0 | 3 | 2 | 5 |
| Index | 0 | 4 | 2 | 6 |
| **Total** | **10** | **46** | **21** | **78** |

**Full test strategy**: `docs/03-analysis/test-strategy.md`

### 10.3 Quantitative Expected Improvements

> **Gap analysis reflected**: Shared utilities gap analysis D-18, requirements traceability gap analysis Low #13

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Installer LOC | ~1,200 lines | ~850 lines | **-29%** |
| Google MCP LOC | ~1,800 lines | ~1,300 lines | **-28%** |
| Service instances (per execution) | 414 (69 handlers x 6 services) | 6 (per process) | **-99%** |
| Duplicate `parseTime()` | 2 copies | 1 (`time.ts`) | **-50%** |
| Hardcoded Korean messages | ~150 | 0 (centrally managed) | **-100%** |
| Inline color definitions | 42 lines (7 modules) | 0 lines (shared) | **-100%** |
| Match Rate target | 65.5% | 95%+ | **+29.5pp** |

### 10.4 Risk Analysis

> **Gap analysis reflected**: Shared utilities gap analysis D-19, requirements traceability gap analysis Low #14

| Risk | Probability | Impact | Mitigation |
|------|:-----------:|:------:|------------|
| Shared utilities refactoring breaks existing installer module behavior | Medium | High | Sequential per-module refactoring + smoke test after each module |
| Performance regression (service caching introduction) | Low | Medium | Before/after benchmark comparison, TTL 50-min auto-refresh |
| Shell compatibility issues (bash version differences) | Low | Medium | Test on macOS, Linux, WSL environments + ShellCheck CI |
| TypeScript compilation errors (any removal) | Low | Low | Gradual strict transition, CI blocks on build failure |
| oauth.ts module separation causes import path changes | Medium | Medium | Backward compatibility via `index.ts` re-export, gradual migration |

---

## 11. Implementation Guide

### 11.1 Sprint Execution Order

```
Sprint 1 (Critical Security) — Immediately, 22-33 hours
  Phase 1: FR-S1-03 (parse_json security) — blocks Sprint 2
  Phase 2: FR-S1-01, FR-S1-02, FR-S1-10 (injection prevention)
  Phase 3: FR-S1-04, FR-S1-07, FR-S1-08 (credential security)
  Phase 4: FR-S1-06, FR-S1-09 (Docker, Atlassian)

Sprint 2 (Platform & Stability) — Within 1 week
  Phase 1: FR-S2-01 (cross-platform JSON) — depends on FR-S1-03
  Phase 2: FR-S2-05, FR-S2-06, FR-S2-09 (metadata fixes)
  Phase 3: FR-S2-07, FR-S2-04, FR-S2-08 (sorting, Linux, timeout)
  Phase 4: FR-S2-03, FR-S2-02, FR-S2-10 (MCP path, remote, Windows)

Sprint 3 (Quality & Testing) — Within 2 weeks
  Phase 1: FR-S3-06 (ESLint/Prettier setup)
  Phase 2: FR-S3-01 (Vitest + P0 security tests)
  Phase 3: FR-S3-02, FR-S3-03, FR-S3-04 (smoke tests, CI)
  Phase 4: FR-S3-05, FR-S3-07, FR-S3-08 (shared utils, types, messages)

Sprint 4 (Google MCP Hardening) — Within 3 weeks
  Phase 1: FR-S4-01 (retry), FR-S4-03 (timezone)
  Phase 2: FR-S4-04 (caching), FR-S4-06 (mutex)
  Phase 3: FR-S4-02 (scopes), FR-S4-05 (refresh validation)
  Phase 4: FR-S4-07, FR-S4-08 (MIME, attachment)
  Phase 5: FR-S4-09, FR-S4-10 (Node 22, dockerignore)

Sprint 5 (UX & Documentation) — Within 1 month
  Phase 1: FR-S5-06, FR-S5-04 (security + version, 30min)
  Phase 2: FR-S5-05 (i18n, 3hrs)
  Phase 3: FR-S5-01, FR-S5-02 (verification, rollback, 6hrs)
  Phase 4: FR-S5-03 (ARCHITECTURE.md, 1hr)
```

### 11.2 Critical Path Dependencies

```
FR-S1-03 (osascript security)
    └── FR-S2-01 (cross-platform JSON) — same function
         └── FR-S2-02 (remote shared download)
         └── FR-S2-07 (module ordering)

FR-S1-01 (OAuth state)
    └── FR-S4-05 (token refresh)
         └── FR-S4-06 (auth mutex)
              └── FR-S4-04 (service caching)

FR-S3-06 (ESLint)
    └── FR-S3-01 (unit tests)
         └── FR-S3-03 (CI pipeline)
              └── FR-S3-04 (CI expansion)
```

### 11.3 Files Changed Summary

| File | Sprint FRs | Change Type |
|------|-----------|-------------|
| `installer/install.sh` | S1-03, S2-01, S2-02, S2-03, S2-07, S5-01, S5-02 | Major rewrite |
| `google-workspace-mcp/src/auth/oauth.ts` | S1-01, S1-07, S1-08, S4-02, S4-04, S4-05, S4-06 | Major rewrite |
| `google-workspace-mcp/src/tools/drive.ts` | S1-02, S4-01 | Input sanitization + retry |
| `google-workspace-mcp/src/tools/gmail.ts` | S1-10, S4-01, S4-07, S4-08 | Security + MIME + retry |
| `google-workspace-mcp/src/tools/calendar.ts` | S3-07, S4-01, S4-03 | Types + retry + timezone |
| `google-workspace-mcp/src/index.ts` | S3-07, S3-08 | Type fix + i18n |
| `google-workspace-mcp/Dockerfile` | S1-06, S4-09 | Non-root + Node 22 |
| `installer/modules/atlassian/install.sh` | S1-04, S1-09, S2-03 | Credential security + path |
| `installer/modules/base/install.sh` | S2-04 | Package manager expansion |
| `installer/modules/google/install.sh` | S2-03, S2-08 | MCP path + timeout |

**New Files**:
| File | Sprint | Purpose |
|------|--------|---------|
| `src/utils/retry.ts` | S4-01 | Exponential backoff |
| `src/utils/sanitize.ts` | S1-02, S1-10 | Input sanitization (7 functions) |
| `src/utils/time.ts` | S3-05, S4-03 | Time parsing + dynamic timezone (timezone.ts consolidated) |
| `src/utils/mime.ts` | S4-07 | Recursive MIME parsing |
| `src/utils/messages.ts` | S3-05, S5-05 | Centralized i18n-ready messages (8 categories) |
| `.github/workflows/ci.yml` | S3-03 | CI pipeline |
| `vitest.config.ts` | S3-01 | Test configuration |
| `eslint.config.js` | S3-06 | Linter configuration |
| `.dockerignore` | S4-10 | Build context exclusion |
| `google-workspace-mcp/.env.example` | S4-02, S4-03 | Environment variable template |
| `installer/module-schema.json` | S3-02 | module.json JSON Schema definition |
| `installer/tests/*.sh` | S3-02 | Smoke tests |
| `installer/modules/shared/colors.sh` | S3-05 | ANSI color constants + helper functions |
| `installer/modules/shared/docker-utils.sh` | S3-05 | Docker management (9 functions) |
| `installer/modules/shared/mcp-config.sh` | S3-05 | MCP JSON configuration (6 functions) |
| `installer/modules/shared/browser-utils.sh` | S3-05 | Cross-platform browser (4 functions) |
| `installer/modules/shared/package-manager.sh` | S3-05 | Package manager abstraction (5 functions: pkg_detect_manager, pkg_install, pkg_install_cask, pkg_is_installed, pkg_ensure_installed) |
| `installer/.env.example` | S1-04 | Atlassian environment variable template |

### 11.4 calendar.ts Migration Example (Before/After)

> **Gap analysis reflected**: Shared utilities gap analysis D-14 -- Missing consolidated migration example

**Before** (current calendar.ts, `calendar_create_event` handler):
```typescript
calendar_create_event: {
  handler: async ({ title, startTime, endTime, ... }) => {
    const { calendar } = await getGoogleServices(); // Creates 6 services per call

    const parseTime = (timeStr: string) => {       // Duplicate function
      if (timeStr.includes("T")) return timeStr;
      const [date, time] = timeStr.split(" ");
      return `${date}T${time}:00+09:00`;            // Hardcoded timezone
    };

    const event = {
      summary: title,
      start: { dateTime: parseTime(startTime), timeZone: "Asia/Seoul" }, // Hardcoded
      end: { dateTime: parseTime(endTime), timeZone: "Asia/Seoul" },
    };

    const response = await calendar.events.insert({   // No retry
      calendarId, requestBody: event,
    });

    return {
      success: true,
      message: `Event "${title}" has been created.`, // Hardcoded Korean (original)
    };
  },
},
```

**After** (post-refactoring):
```typescript
import { getGoogleServices } from "../auth/oauth.js";
import { parseTime, getTimezone } from "../utils/time.js";
import { messages, msg } from "../utils/messages.js";
import { withRetry } from "../utils/retry.js";
import { validateMaxLength } from "../utils/sanitize.js";

calendar_create_event: {
  handler: async ({ title, startTime, endTime, ... }) => {
    const { calendar } = await getGoogleServices();   // Cached singleton
    const timezone = getTimezone();                    // Dynamic timezone

    const event = {
      summary: validateMaxLength(title, 500),          // Input validation
      start: { dateTime: parseTime(startTime), timeZone: timezone },
      end: { dateTime: parseTime(endTime), timeZone: timezone },
      attendees: attendees?.map((email) => ({ email })),
    };

    const response = await withRetry(() =>             // Auto retry
      calendar.events.insert({
        calendarId, requestBody: event,
        sendUpdates: sendNotifications ? "all" : "none",
      })
    );

    return {
      success: true,
      eventId: response.data.id,
      link: response.data.htmlLink,
      message: msg(messages.calendar.eventCreated, title), // Centralized message
    };
  },
},
```

**Improvement summary**: Duplicate function removal, singleton services, auto retry, dynamic timezone, input validation, centralized messages

---

## 12. Related Documents

| Document | Path | Content |
|----------|------|---------|
| Plan | `docs/01-plan/features/adw-improvement.plan.md` | 44 requirements, 5 sprints |
| Security Spec | `docs/02-design/security-spec.md` | Sprint 1 full code, OWASP mapping |
| Test Strategy | `docs/03-analysis/test-strategy.md` | 78 unit + 73 smoke tests |
| Shared Utils Design | `docs/03-analysis/shared-utilities-design.md` | Installer + MCP shared modules (original detailed design) |
| Sprint 5 UX Design | `docs/02-design/features/sprint-5-ux-improvements.design.md` | Verification, rollback, i18n |
| Traceability Matrix | `docs/03-analysis/adw-requirements-traceability-matrix.md` | 44-requirement dependency graph |
| Gap: Shared Utilities | `docs/03-analysis/gap-shared-utilities.md` | Shared utilities gap analysis (20 gap items) |
| Gap: Security Verification | `docs/03-analysis/gap-security-verification.md` | Security verification gap analysis (12 security issues) |
| Gap: Requirements Traceability | `docs/03-analysis/gap-requirements-traceability.md` | Requirements traceability gap analysis (19 gap items) |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2026-02-12 | Initial design -- 44 requirements across 5 sprints | CTO Team (8 agents) |
| 1.1 | 2026-02-12 | Reflected 3 gap analysis reports -- FR-S3-05 detailed expansion (unified function names for 5 installer + 5 Google MCP utilities, docker-utils.sh 9 functions, package-manager.sh/browser-utils.sh detailed design), time.ts/timezone.ts consolidation decision, google-client.ts architecture decision (maintain oauth.ts internal caching + clearServiceCache()), sanitize.ts 7 functions finalized, messages.ts detailed design (8 categories + msg() helper), oauth.ts refactoring roadmap added, FR-S2-02 temp file cleanup (trap pattern), Input Validation Layer extension (Calendar/Docs/Sheets/Slides), .env.example template, module.json schema, ShellCheck CI, migration user guide, quantitative expected improvements, risk analysis, New Files table supplemented, calendar.ts Before/After migration example | Frontend Architect (gap analysis reflected) |
| 1.2 | 2026-02-13 | Full cross-verification of 7 analysis documents reflected. **New sections**: FR-S2-10 Windows admin privileges conditional request detailed design (Test-AdminRequired function, gap D-03 reflected), FR-S2-11 Docker Desktop version compatibility check design (docker_check_compatibility function), error message format standard (UserFacingError interface), retry.ts ECONNRESET/ETIMEDOUT network error handling (isRetryableError function, gap D-9 reflected). **Supplements**: Added security-audit (npm audit) + shellcheck job to CI pipeline, added TypeScript strict mode preservation verification method, Docker build cache optimization guide, i18n direction decision (English-only + preemptive key-based structure), added installer/.env.example to New Files table, complete list of 7 analysis documents in References, requirements traceability updated to 93.8% | CTO Lead (full cross-verification of 7 analysis documents) |
