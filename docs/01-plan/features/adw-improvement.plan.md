# ADW Comprehensive Improvement Plan

> **Summary**: Achieve Match Rate 90%+ through comprehensive improvements in security/quality/compatibility based on ADW comprehensive analysis (65.5%)
>
> **Project**: popup-claude (AI-Driven Work Installer)
> **Version**: 2.2 (current master branch, commit 7b16685)
> **Author**: CTO Team (8-agent parallel analysis + full codebase verification)
> **Date**: 2026-02-13
> **Status**: Draft
> **References**:
> - `docs/03-analysis/adw-comprehensive.analysis.md` (comprehensive analysis)
> - `docs/03-analysis/security-verification-report.md` (security verification report)
> - `docs/03-analysis/shared-utilities-design.md` (shared utilities detailed design)
> - `docs/03-analysis/adw-requirements-traceability-matrix.md` (requirements traceability matrix)
> - `docs/03-analysis/gap-security-verification.md` (security verification gap analysis)
> - `docs/03-analysis/gap-shared-utilities.md` (shared utilities gap analysis)
> - `docs/03-analysis/gap-requirements-traceability.md` (requirements traceability gap analysis)

---

## 1. Overview

### 1.1 Purpose

Systematically resolve **30 total issues (3 Critical, 8 High, 14 Medium, 5 Low)**, **9 code quality issues**, and **10 OS compatibility issues** identified in the ADW comprehensive analysis report (Match Rate 65.5%), raising the achievement level of the core goal -- "one-click AI Native work environment setup" -- to 90% or higher.

### 1.2 Background

**Current State (65.5%)**:
| Area | Current Score | Target Score | Gap |
|------|:--------:|:--------:|:---:|
| One-click installation | 72% | 92% | +20% |
| MCP integration | 82% | 95% | +13% |
| Security | 50% | 90% | **+40%** |
| Cross-platform | 60% | 85% | +25% |
| Code quality | 46% | 85% | **+39%** |
| Documentation | 75% | 90% | +15% |

**3 Key Problems**:
1. **Multiple security vulnerabilities** -- Plaintext credential storage (Critical), OAuth CSRF not prevented (High), Drive query injection (High)
2. **0% test coverage** -- Complete absence of unit/integration tests, only manual CI trigger exists
3. **Linux not supported** -- Module loading fails on Linux due to `osascript`-dependent JSON parser

### 1.3 Related Documents

- Analysis (Core): `docs/03-analysis/adw-comprehensive.analysis.md`
- Security Verification: `docs/03-analysis/security-verification-report.md`
- Shared Utilities Design: `docs/03-analysis/shared-utilities-design.md`
- Requirements Traceability: `docs/03-analysis/adw-requirements-traceability-matrix.md`
- Gap Analysis (Security): `docs/03-analysis/gap-security-verification.md`
- Gap Analysis (Shared Utils): `docs/03-analysis/gap-shared-utilities.md`
- Gap Analysis (Traceability): `docs/03-analysis/gap-requirements-traceability.md`
- Architecture: `installer/ARCHITECTURE.md`
- Google MCP: `google-workspace-mcp/package.json`

---

## 2. Scope

### 2.1 In Scope

- [x] **Sprint 1 (Critical Security)**: Credential security, code injection prevention, CSRF prevention
- [x] **Sprint 2 (Platform & Stability)**: Linux compatibility, installer bug fixes, remote execution fixes
- [x] **Sprint 3 (Quality & Testing)**: Test framework adoption, CI automation, code quality improvements
- [x] **Sprint 4 (Google MCP Hardening)**: Rate limiting, dynamic timezone, service caching, MIME handling
- [x] **Sprint 5 (UX & Documentation)**: Post-installation verification, update/remove features, documentation sync

### 2.2 Out of Scope

- Enterprise management features (organization-level deployment, centralized management console)
- Telemetry/anonymous analytics collection system
- GitHub MCP server new development (CLI-to-MCP conversion)
- Offline/air-gapped installation support
- GPG signature-based script integrity verification -- requires separate infrastructure setup (SHA-256 checksum verification is **In Scope**, FR-S1-11)
- Third-party Docker image verification (SEC-11) -- supply chain security is at infrastructure level
- Structured logging framework (QA-05) -- however, **security event logging** is In Scope as FR-S3-10
- Automatic CHANGELOG generation (QA-09) -- to be reviewed after Sprint 5

### 2.3 v2.2 Changes (items moved to In Scope compared to v2.1)

> Items that were Out of Scope in v2.1 but moved to In Scope through gap analysis:
> - SHA-256 checksum-based remote script integrity verification (FR-S1-11) -- SEC-01 response
> - Input validation layer as cross-cutting concern (FR-S1-12) -- OWASP A03 cross-cutting response
> - npm audit CI integration (FR-S3-09) -- automated dependency security verification
> - Security event logging (FR-S3-10) -- OWASP A09 response
> - Docker Desktop version compatibility check (FR-S2-11) -- OS-06 response

---

## 3. Requirements

### 3.1 Functional Requirements

#### Sprint 1 — Critical Security (Immediate)

| ID | Requirement | Priority | Effort(h) | Target File | Analysis Basis |
|----|-------------|:--------:|:-------:|----------|----------|
| FR-S1-01 | **Add OAuth state parameter** -- Generate `state` token in `generateAuthUrl()`, implement state verification logic in callback | **Critical** | 1-2 | `oauth.ts:113-118` | SEC-08: CSRF attack prevention. `shared/oauth-helper.sh` already has PKCE+state implementation, can reference pattern |
| FR-S1-02 | **Drive API query escaping** -- Escape single quotes in user input for `drive_search`, `drive_list` handlers | **Critical** | 2-3 | `drive.ts:18,59` | GWS-07: `name contains '${query}'` -- query manipulation possible when input contains `'`. Apply `query.replace(/'/g, "\\'")` |
| FR-S1-03 | **osascript template injection prevention** -- Replace backtick usage in `parse_json()` function with stdin pipe method | **Critical** | 3-4 | `install.sh:29-39` | SEC-08a: Arbitrary JavaScript execution when remote JSON contains backtick/`${}`. Change to `echo "$json" \| osascript -l JavaScript -e "..."` method |
| FR-S1-04 | **Atlassian API token secure storage** -- Change from plaintext in `.mcp.json` to environment variable reference method | **Critical** | 4-6 | `atlassian/install.sh:147-172` | SEC-02(Critical): `docker -e JIRA_API_TOKEN=$apiToken` records plaintext in config file. Separate `.env` file + `.gitignore` addition. Confirmed Critical in verification report (priority 3), consistent with Appendix A.1. `gap-security-verification.md` P-02 reflected: maintaining original risk level Critical from verification report |
| FR-S1-05 | **Figma token secure storage** -- Change `module.json` env reference to read from actual environment variables, create `.env` file in install script | **Low** | 0.5 | `figma/module.json:24`, `figma/install.sh` | SEC-03: ~~Critical~~ -> **Informational** (CTO team verification result: `{accessToken}` is a template placeholder and actual token is not written to disk. Actual install.sh has already been converted to Remote MCP method) |
| FR-S1-06 | **Add Docker non-root user** -- Add `RUN addgroup --system app && adduser --system --ingroup app app` + `USER app` to Dockerfile | **High** | 2-3 | `google-workspace-mcp/Dockerfile` | SEC-05: Running container as root risks host privilege escalation on container escape |
| FR-S1-07 | **Set token.json file permissions** -- Add `fs.chmodSync(TOKEN_PATH, 0o600)` after `fs.writeFileSync()` in `saveToken()` function | **High** | 1 | `oauth.ts:105-108` | SEC-04: Token file created with default permissions (644), readable by other users |
| FR-S1-08 | **Set config directory permissions** -- Apply `fs.mkdirSync(CONFIG_DIR, { recursive: true, mode: 0o700 })` in `ensureConfigDir()` | **High** | 0.5 | `oauth.ts:51-55` | SEC-14: Config directory created with default permissions |
| FR-S1-09 | **Atlassian install.sh variable escaping** -- Pass user input to Node.js `-e` block via environment variables (`URL=... node -e "process.env.URL"` instead of `node -e "..."`) | **High** | 3-4 | `atlassian/install.sh:147-172` | SEC-12: User input (URL, email, token) directly inserted into Node.js code string, enabling code injection |
| FR-S1-10 | **Gmail email header injection prevention** -- Remove newline characters (`\r\n`) from `to`, `cc`, `bcc` fields in `gmail_send` handler | **Medium** | 2 | `gmail.ts` (send handler) | GWS-08: Hidden recipients can be added via newline characters |
| FR-S1-11 | **Remote script download integrity verification** -- Replace `curl\|bash` pattern with `curl -o tmpfile + SHA-256 checksum verification + source` method. Publish `checksums.json` manifest to GitHub repository, implement `download_and_verify()` function. Covers 3 locations in install.sh + 1 in install.ps1. GPG signatures remain Out of Scope | **Critical** | 6-8 | `install.sh:101-117,350-351`, `install.ps1:336` | SEC-01(Critical): Remote code execution possible via MITM. Security verification report priority 1 response |
| FR-S1-12 | **Build input validation layer** -- Create `src/utils/sanitize.ts` shared utility. Structure input validation as cross-cutting concern with reusable utilities including `escapeDriveQuery()`, `sanitizeEmailHeader()`, `validateEmail()`, `validateDriveId()`, `validateMaxLength()`. Restructures individual validations from FR-S1-02, FR-S1-10 | **High** | 2-3 | `google-workspace-mcp/src/utils/sanitize.ts` (new) | Exists only in design doc (security-spec.md Section 9.2) without explicit FR in plan. OWASP A03 (Injection) cross-cutting response |
| | | | **Total: 28-37** | | |

#### Sprint 2 — Platform & Stability (Within 1 week)

| ID | Requirement | Priority | Effort(h) | Target File | Analysis Basis |
|----|-------------|:--------:|:-------:|----------|----------|
| FR-S2-01 | **Implement cross-platform JSON parser** -- Reimplement `parse_json()` using `node -e`. Fallback to `python3 -c` if Node not installed, then `jq` fallback | **Critical** | 4-6 | `install.sh:29-39` | INS-01/OS-01: `osascript` is macOS-only. Complete module loading failure on Linux |
| FR-S2-02 | **Download shared scripts during remote execution** -- In `run_module()` function, download `shared/oauth-helper.sh` to temp directory via `curl -sSL` before execution in remote mode to enable `source`. **Ensure temporary file cleanup**: Use `trap 'rm -rf "$SHARED_TMP"' EXIT INT TERM` pattern for cleanup on both normal and abnormal termination | **High** | 3-4 | `install.sh:346-352`, `notion/install.sh:54`, `figma/install.sh:58` | INS-07: `BASH_SOURCE[0]` is empty during `curl\|bash` remote execution, making `$SCRIPT_DIR/../shared/oauth-helper.sh` path resolution impossible. `gap-requirements-traceability.md` implicit requirement #3 (temporary file cleanup) reflected |
| FR-S2-03 | **Unify MCP config path** -- Unify Mac/Linux to use `~/.claude/mcp.json` same as Windows. **Affected scope: 3 files** (`install.sh:406`, `google/install.sh:328`, `atlassian/install.sh:145`) | **High** | 2-3 | `install.sh:406`, `google/install.sh:328`, `atlassian/install.sh:145` | INS-02: 3 Mac script locations use `~/.mcp.json` (legacy), Windows uses `~/.claude/mcp.json` (current). Commit `b8b01a2` only changed Windows, Mac not updated |
| FR-S2-04 | **Expand Linux package managers** -- Add `dnf` (Fedora/RHEL), `pacman` (Arch) detection and installation logic to `base/install.sh`. **Note**: Must start after FR-S2-01 (parse_json) completion (serial dependency) | **Medium** | 3-4 | `base/install.sh:46-49, 88-93` | INS-05/OS-02: Only apt/snap supported. Expand major Linux distribution coverage |
| FR-S2-05 | **Fix Figma module.json consistency** -- Change to `type: "remote-mcp"`, fix `requirements.node: false` (since actual implementation uses `claude mcp add --transport http`) | **Medium** | 1 | `figma/module.json` | INS-08: module.json has `type: "mcp"`, `node: true` but actual install.sh uses Remote MCP registration |
| FR-S2-06 | **Fix Atlassian module.json Docker notation** -- Add `requirements.docker: "optional"` or separate `modes` field to represent Docker/Rovo dual mode | **Medium** | 1 | `atlassian/module.json:15` | INS-09: `docker: false` but Docker mode exists. Affects main installer status display |
| FR-S2-07 | **Sort module execution order** -- Sort `SELECTED_MODULES` by `MODULE_ORDERS` array before execution | **Low** | 2 | `install.sh:376` | INS-04: Modules execute in input order. Need to guarantee order for dependent modules (base->google) |
| FR-S2-08 | **Add Docker wait timeout** -- Add timeout wrapper (300 seconds) to `docker wait` call in `google/install.sh` | **Low** | 1-2 | `google/install.sh:315` | INS-10: Infinite wait possible on authentication failure |
| FR-S2-09 | **Specify Python 3 dependency in module.json** -- Add `requirements.python3: true` to Notion, Figma module.json | **Medium** | 0.5 | `notion/module.json`, `figma/module.json` | OS-07: OAuth helper requires python3 but undocumented |
| FR-S2-10 | **Conditional Windows admin privileges** -- Provide admin privilege skip option when not base module. Determine per-module necessity with `Test-AdminRequired` function and conditionally request UAC elevation | **High** | 4-6 | `install.ps1:130-153` | SEC-06(High): Unconditionally requires admin privileges for all installations. Original High risk level restored from verification report. `gap-security-verification.md` P-03 reflected |
| FR-S2-11 | **Docker Desktop version compatibility check** -- Add detection logic for Docker Desktop 4.42+ not supporting macOS Ventura. Parse Desktop version from `docker version` output, cross-verify with OS version and output warning message on incompatibility. Integrate into `docker_check()` function in shared utility `docker-utils.sh` | **Medium** | 2-3 | `google/install.sh`, `atlassian/install.sh`, `installer/modules/shared/docker-utils.sh` | OS-06(High): Docker Desktop 4.42+ does not support macOS Ventura. See `gap-requirements-traceability.md` Section 2 #5 |
| | | | **Total: 26-39** | | |

#### Sprint 3 — Quality & Testing (Within 2 weeks)

| ID | Requirement | Priority | Effort(h) | Target File | Analysis Basis |
|----|-------------|:--------:|:-------:|----------|----------|
| FR-S3-01 | **Write Google MCP unit tests** -- Adopt Vitest framework, write minimum core logic tests per tool file (gmail, calendar, drive, docs, sheets, slides). Target coverage: 60%+ | **Critical** | 16-20 | `google-workspace-mcp/` (new) | QA-01: 0% test coverage. Minimum safety net needed for regression prevention |
| FR-S3-02 | **Write installer smoke tests** -- Bash-based test scripts for each module's `module.json` parsing and basic execution verification | **High** | 8-10 | `installer/tests/` (new) | QA-01: No regression testing means for installer changes |
| FR-S3-03 | **Add CI auto-trigger** -- Add workflow that automatically runs on PR/push. Google MCP build + unit tests + installer smoke tests | **High** | 4-6 | `.github/workflows/test-installer.yml` | QA-02: Only manual `workflow_dispatch` exists. No automatic verification before PR merge |
| FR-S3-04 | **Expand CI test scope** -- Add google, atlassian modules to CI test targets (currently only base, github, notion, figma) | **Medium** | 2-3 | `.github/workflows/test-installer.yml:17-22` | Analysis report: CI test scope incomplete |
| FR-S3-05a | **Extract installer shared utilities** -- Create 5 shared scripts in `installer/modules/shared/` directory: `colors.sh` (8+5 ANSI color constants + 5 convenience functions: `print_success()`/`print_error()`/`print_warning()`/`print_info()`/`print_debug()`), `docker-utils.sh` (9 functions: `docker_is_installed()`/`docker_is_running()`/`docker_get_status()`/`docker_check()`/`docker_wait_for_start()`/`docker_install()`/`docker_pull_image()`/`docker_cleanup_container()`/`docker_show_install_guide()`), `mcp-config.sh` (6 functions: `mcp_get_config_path()`/`mcp_check_node()`/`mcp_add_docker_server()`/`mcp_add_stdio_server()`/`mcp_remove_server()`/`mcp_server_exists()`), `browser-utils.sh` (4 functions: `browser_open()`/`browser_open_with_prompt()`/`browser_open_or_show()`/`browser_wait_for_completion()`, includes WSL detection), `package-manager.sh` (5 functions: `pkg_detect_manager()`/`pkg_install()`/`pkg_install_cask()`/`pkg_is_installed()`/`pkg_ensure_installed()`, supports brew/apt/dnf/yum/pacman). Sequentially refactor 7 installer modules (base, google, atlassian, figma, notion, github, pencil) to shared utility source. **Acceptance criteria**: (1) All modules use shared source, (2) Zero inline color definitions, (3) Docker modules use `docker_check()`, (4) MCP modules use `mcp_add_docker_server()`/`mcp_add_stdio_server()`, (5) Browser modules use `browser_open()` | **Medium** | 12-16 | `installer/modules/shared/` (new), `installer/modules/*/install.sh` (modified) | QA-06: Color 42 lines duplicated 10 times, Docker check duplicated 4 times, MCP config duplicated 4 times, browser open duplicated 4 times. See `shared-utilities-design.md` Section 1.3. `gap-shared-utilities.md` P-1~P-5, D-1~D-7 reflected |
| FR-S3-05b | **Extract Google MCP shared utilities** -- Create 5 utilities in `src/utils/` directory: `time.ts` (parseTime, getCurrentTime, addDays, formatDate + getTimezone, getUtcOffsetString -- timezone.ts functionality merged), `retry.ts` (withRetry, RetryOptions, isRetryableError -- handles 429/500/502/503/504 + ECONNRESET/ETIMEDOUT), `sanitize.ts` (7 integrated input validation functions -- linked with FR-S1-12), `messages.ts` (8 categories ~60 message keys + `msg()` helper -- implement simultaneously with FR-S5-05), `mime.ts` (extractTextBody, extractAttachments -- recursive MIME parsing). Add service caching + `clearServiceCache()` test utility to `oauth.ts` (linked with FR-S4-04). **Acceptance criteria**: (1) Zero duplicate parseTime in calendar.ts, (2) 69 handlers use cached getGoogleServices(), (3) All API calls wrapped with withRetry(), (4) User input passes through sanitize functions, (5) Zero hardcoded Korean messages (upon Sprint 5 completion) | **Medium** | 10-14 | `google-workspace-mcp/src/utils/` (new), `google-workspace-mcp/src/tools/*.ts` (modified) | QA-06: parseTime duplicated in 2 locations, QA-07: Service regenerated 69 times. See `shared-utilities-design.md` Section 2. `gap-shared-utilities.md` P-6~P-10, D-8~D-14 reflected |
| FR-S3-06 | **ESLint + Prettier configuration** -- Add linter/formatter configuration to Google MCP TypeScript project | **Low** | 2-3 | `google-workspace-mcp/` (new) | QA-08: No code style consistency tooling |
| FR-S3-07 | **Remove `any` types** -- Replace `any`/`as any` usage at `index.ts:32`, `sheets.ts:18,341`, `calendar.ts:288`, `slides.ts:135,156`, `docs.ts:236` with proper types. 7 locations total | **Low** | 2-3 | `google-workspace-mcp/src/index.ts:32`, `sheets.ts`, `calendar.ts`, `slides.ts`, `docs.ts` | GWS-04: Undermines meaning of TypeScript strict mode. Reflects additional discovery locations from Appendix A.2 Code Analyzer. See `gap-requirements-traceability.md` Section 2.1 |
| FR-S3-08 | **Unify error messages to English** -- Unify `index.ts:48` `오류:`, `oauth.ts:207` `서버 시작 실패:` etc. to English. Not simple replacement but establish structured message management foundation using FR-S3-05b's `messages.ts` centralized message structure | **Low** | 1-2 | `index.ts:48`, `oauth.ts` | GWS-03: Mixed Korean/English error messages. See `gap-shared-utilities.md` P-9 |
| FR-S3-09 | **npm audit CI integration** -- Add `npm audit --audit-level=high` step to CI pipeline. Build fails when High+ vulnerabilities found. Build automated dependency security verification gate with `npm ci` transition | **High** | 2-3 | `.github/workflows/ci.yml` (modified) | Security Architect additional finding: "Dependencies Not Audited". See `gap-security-verification.md` P-06 |
| FR-S3-10 | **Security event logging** -- Output authentication success/failure, token refresh, file permission change events to stderr in structured format. Minimum fields: timestamp, event_type, result, detail. Since MCP server uses stdout exclusively for JSON-RPC, use stderr | **Medium** | 4-6 | `oauth.ts`, `index.ts` | OWASP A09 (Security Logging and Monitoring Failures): Absence of security logging. See `gap-security-verification.md` P-05 |
| | | | **Total: 63-86** | | |

#### Sprint 4 — Google MCP Hardening (Within 3 weeks)

| ID | Requirement | Priority | Effort(h) | Target File | Analysis Basis |
|----|-------------|:--------:|:-------:|----------|----------|
| FR-S4-01 | **Implement Google API rate limiting** -- Add exponential backoff retry logic. Auto-retry on 429 (Too Many Requests) and 503 errors (max 3 attempts, 1s->2s->4s backoff) | **High** | 4-6 | `google-workspace-mcp/src/tools/*.ts` | GWS-02: Only returns error on Google API quota exceeded. Fails even on transient errors |
| FR-S4-02 | **Dynamic OAuth scope configuration** -- Enable selecting only needed service scopes via `GOOGLE_SCOPES` env variable. Maintain all scopes when unspecified (backward compatible) | **High** | 4-6 | `oauth.ts:17-25` | SEC-07: Always requests all 6 service scopes. Requires Drive/Calendar permission even for Gmail-only usage |
| FR-S4-03 | **Dynamic Calendar timezone** -- Read from env variable `TIMEZONE` (default: `Intl.DateTimeFormat().resolvedOptions().timeZone`) instead of hardcoded `Asia/Seoul` | **High** | 3-4 | `calendar.ts:161,170,175` | GWS-09: `+09:00` (KST) hardcoded. Wrong timezone applied for non-Korean users |
| FR-S4-04 | **getGoogleServices() singleton/caching** -- Cache auth client and service instances at module level. Regenerate only on token expiry. **Note**: Recommended to start after FR-S4-05 (token validation), FR-S4-06 (mutex) completion (serial dependency) | **Medium** | 4-6 | `oauth.ts:227-238` | QA-07: `getGoogleServices()` regenerated on every call from 71 tools. Unnecessary OAuth check repetition |
| FR-S4-05 | **Token refresh_token validity verification** -- Check `refresh_token` existence during `loadToken()`, prompt re-authentication if missing | **Medium** | 2-3 | `oauth.ts:196-211` | GWS-01: Only checks `expiry_date`. Infinite failure possible when refresh_token is revoked |
| FR-S4-06 | **Concurrent authentication request handling** -- Prevent concurrent auth requests using mutex/semaphore pattern. First request completes, rest use cached result | **Medium** | 3-4 | `oauth.ts:113-182` | GWS-05: Race condition possible when multiple tools request authentication simultaneously |
| FR-S4-07 | **Gmail nested MIME parsing improvement** -- Extract nested multipart email body via recursive `parts` traversal | **Medium** | 3-4 | `gmail.ts:70-75` | GWS-10: Only parses 1st level `parts`. Body missing in emails with attachments |
| FR-S4-08 | **Gmail attachment download improvement** -- Remove 1000-char truncation, return full base64 data (with size limit option) | **Low** | 2-3 | `gmail.ts:358` | GWS-11: Attachment data truncated to 1000 chars, making actual download impossible |
| FR-S4-09 | **Node.js 22 migration** -- Update Dockerfile `node:20-slim` to `node:22-slim` | **Medium** | 2-3 | `Dockerfile` | OS-08: Node.js 20 LTS EOL 2026-04-30. Need to migrate before security patch discontinuation |
| FR-S4-10 | **.dockerignore addition** -- Exclude `.google-workspace/`, `node_modules/`, `.git/` etc. from build context | **Low** | 0.5 | `google-workspace-mcp/` (new) | GWS-12: Risk of authentication files being included in Docker build context |
| | | | **Total: 28-40** | | |

#### Sprint 5 — UX & Documentation (Within 1 month)

| ID | Requirement | Priority | Effort(h) | Target File | Analysis Basis |
|----|-------------|:--------:|:-------:|----------|----------|
| FR-S5-01 | **Post-installation auto-verification** -- Run MCP server connection test (health check) after each module installation. Output guide message on failure | **High** | 6-8 | `install.sh` (completion section) | Analysis 8.1: Auto-verification of normal operation after installation not implemented |
| FR-S5-02 | **Introduce rollback mechanism** -- Backup current `.mcp.json` before installation, restore original on failure | **Medium** | 4-6 | `install.sh` | INS-03: Remains in partial installation state on installation failure |
| FR-S5-03 | **ARCHITECTURE.md sync** -- Add Pencil module, Remote MCP type (Notion, Figma), `shared/` directory | **Low** | 2-3 | `installer/ARCHITECTURE.md` | INS-06/QA architecture match: 2 items inconsistent |
| FR-S5-04 | **package.json version update** -- `0.1.0` -> `1.0.0` (SemVer compliance since in production deployment) | **Low** | 0.5 | `google-workspace-mcp/package.json:3` | GWS-06: In production use but version is 0.1.0 |
| FR-S5-05 | **Google MCP tool message internationalization** -- Unify all tool `description` and response `message` to English (internationalization preparation). Leverage FR-S3-05b's `messages.ts` centralized structure | **Low** | 4-6 | `google-workspace-mcp/src/tools/*.ts` | GWS-03: Korean messages meaningless for non-Korean users |
| FR-S5-06 | **.gitignore enhancement** -- Verify `client_secret.json` pattern addition, add `.env` file patterns | **Medium** | 0.5 | `.gitignore` | SEC-10: Risk of Google OAuth client secret file leakage |
| | | | **Total: 17-24** | | |

### 3.2 Non-Functional Requirements

| Category | Criteria | Measurement Method |
|----------|----------|-------------------|
| **Security** | OWASP Top 10 major item response -- Injection (A03), CSRF (A01), Broken Auth (A07) | Code review + security agent verification |
| **Test Coverage** | Google MCP server 60%+, installer smoke tests for all modules | Vitest coverage report |
| **CI/CD** | PR auto-test + build verification gate | GitHub Actions workflow |
| **Performance** | Service instance reuse (caching) during Google API calls | Response time measurement |
| **Compatibility** | macOS 14+, Windows 10+, Ubuntu 22.04+, Fedora 39+, Arch Linux | CI matrix test |
| **Reliability** | Rollback on installation failure, Docker wait timeout, rate limit retry | E2E test scenarios |
| **Shell Quality** | Zero ShellCheck warning-level or above errors (entire installer) | ShellCheck CI job |
| **Dependency Security** | Zero npm audit high+ vulnerabilities | npm audit CI gate |
| **Security Logging** | Authentication success/failure, token refresh, file permission change event logging | Security log output verification |

---

## 4. Success Criteria

### 4.1 Definition of Done

- [ ] All Critical/High security issues resolved (FR-S1-01 ~ FR-S1-12)
- [ ] `install.sh` works correctly on Linux (FR-S2-01)
- [ ] Google MCP unit test 60%+ coverage (FR-S3-01)
- [ ] CI auto-runs on PR/push (FR-S3-03)
- [ ] Gap Analysis Match Rate 90%+ achieved

### 4.2 Quality Criteria

- [ ] Zero Critical/High security vulnerabilities
- [ ] Test coverage 60% or higher (Google MCP)
- [ ] Zero ESLint errors
- [ ] CI build success
- [ ] All module installation smoke tests pass

### 4.3 Quantitative Expected Impact

| Metric | Current | Target | Improvement | Basis |
|------|:----:|:----:|:------:|------|
| Installer LOC | ~1,200 lines | ~850 lines | **-29%** | Duplicate code removal across 7 modules via shared utility extraction (FR-S3-05a) |
| Google MCP LOC | ~1,800 lines | ~1,300 lines | **-28%** | Integration of parseTime, sanitize, messages via shared utility extraction (FR-S3-05b) |
| Service instance creation | 414 times/all calls | 6 times/cache TTL | **-99%** | getGoogleServices() singleton caching (FR-S4-04) |
| Test coverage | 0% | 60%+ | **+60%** | Vitest adoption (FR-S3-01) + installer smoke tests (FR-S3-02) |
| Security vulnerabilities (Critical/High) | 3C + 8H = 11 | 0 | **-100%** | Full resolution of Sprint 1~2 security issues |
| Match Rate | 65.5% | 95%+ | **+30%** | Upon completion of all 5 Sprints |

> See `gap-shared-utilities.md` Section 5 for quantitative expected impact

### 4.4 Completion Criteria per Sprint

| Sprint | Completion Criteria | Expected Match Rate |
|--------|----------|:--------------:|
| Sprint 1 | 12 security issues resolved (FR-S1-01~12), code review complete | 74% |
| Sprint 2 | Linux support, 11 installer bugs fixed (FR-S2-01~11) | 82% |
| Sprint 3 | Test adoption, CI automation (incl. npm audit), code quality improvement, shared utility extraction (5a/5b) | 88% |
| Sprint 4 | 10 Google MCP hardening items | 92% |
| Sprint 5 | UX improvements, documentation sync | **95%+** |

---

## 5. Risks and Mitigation

| # | Risk | Impact | Likelihood | Mitigation |
|---|------|:------:|:----------:|------------|
| R-01 | Existing user settings lost on MCP config path change | High | Medium | Provide migration script, support legacy path fallback |
| R-02 | Existing auth flow breaks on OAuth state addition | High | Low | Backward compatible: allow callback without state (warning log only) |
| R-03 | googleapis compatibility on Node.js 22 migration | Medium | Medium | Local test + CI verification before migration |
| R-04 | Existing macOS behavior change on cross-platform JSON parser change | Medium | Low | Use same `node -e` method on macOS. Keep osascript fallback |
| R-05 | Increased complexity of env variable-based token storage in Docker environment | Medium | Medium | Provide Docker compose example, environment variable setup guide |
| R-06 | Google API mock implementation complexity on test adoption | Medium | High | Use googleapis-mock library or MSW (Mock Service Worker) |
| R-07 | Edge cases increase due to Linux package manager diversity | Low | High | Support only 3 major (apt, dnf, pacman), manual guidance for others |
| R-08 | Existing installer module behavior breaks during shared utility refactoring | High | Medium | Sequential per-module refactoring + smoke test after each module refactoring. See `gap-shared-utilities.md` P-15 |

---

## 6. Architecture Considerations

### 6.1 Project Level Selection

| Level | Characteristics | Recommended For | Selected |
|-------|-----------------|-----------------|:--------:|
| **Starter** | Simple structure | Static sites | ☐ |
| **Dynamic** | Feature-based modules, BaaS integration | Web apps with backend | ☐ |
| **Enterprise** | Strict layer separation, DI, microservices | High-traffic systems | ☑ |

> ADW follows Enterprise level structure based on cross-platform installer + MCP server + Docker architecture.

### 6.2 Key Architectural Decisions

| Decision | Options | Selected | Rationale |
|----------|---------|----------|-----------|
| JSON Parser | osascript / node -e / python3 -c / jq | **node -e (primary)** | Node.js is always available as base installation dependency. python3 fallback when not installed |
| Test Framework | Jest / Vitest / Mocha | **Vitest** | Native TypeScript support, ESM compatible, fast execution |
| CI Trigger | workflow_dispatch / push / PR | **push + PR** | Mandatory automatic quality gate before PR merge |
| Token Storage | Plaintext JSON / OS Keychain / .env | **.env + environment variables** | Cross-platform compatible, Docker-friendly |
| Rate Limiting | Custom implementation / p-retry / google-auth-library built-in | **Custom exponential backoff** | Minimize external dependencies, specialized 429/503 handling |
| Timezone | Hardcoded / environment variable / Intl API | **Intl API default + environment variable override** | Auto-detect user system timezone, explicit override possible |

### 6.3 Change Impact Scope

```
Targets:
┌─────────────────────────────────────────────────────┐
│ installer/                                           │
│   install.sh ─── parse_json() reimplementation,     │
│                  module sorting                      │
│   install.ps1 ── conditional admin privilege request │
│   modules/                                           │
│     shared/      ── add shared utilities             │
│     atlassian/   ── token security, variable escaping│
│     figma/       ── module.json fix, token security  │
│     notion/      ── module.json fix                  │
│     google/      ── Docker wait timeout              │
│     base/        ── Linux package manager expansion  │
├─────────────────────────────────────────────────────┤
│ google-workspace-mcp/                                │
│   Dockerfile ─── non-root, Node 22, .dockerignore   │
│   src/auth/oauth.ts ── state, permissions, caching,  │
│                        file permissions              │
│   src/index.ts ─── type fix, error message i18n      │
│   src/tools/                                         │
│     drive.ts ─── query escaping                      │
│     gmail.ts ─── header injection, MIME parsing,     │
│                  attachments                          │
│     calendar.ts ─── dynamic timezone                 │
├─────────────────────────────────────────────────────┤
│ .github/workflows/ ── CI auto-trigger, test expansion│
│ .gitignore ── .env, client_secret.json pattern check │
│ installer/ARCHITECTURE.md ── documentation sync      │
└─────────────────────────────────────────────────────┘
```

---

## 7. Convention Prerequisites

### 7.1 Existing Project Conventions

- [ ] `CLAUDE.md` has coding conventions section
- [x] `installer/ARCHITECTURE.md` exists (but needs sync)
- [ ] `CONVENTIONS.md` exists at project root
- [ ] ESLint configuration (`.eslintrc.*`) — **does not exist, to be added in Sprint 3**
- [ ] Prettier configuration (`.prettierrc`) — **does not exist, to be added in Sprint 3**
- [x] TypeScript configuration (`tsconfig.json`) — strict mode enabled

### 7.2 Conventions to Define/Verify

| Category | Current State | To Define | Priority |
|----------|:------------:|-----------|:--------:|
| **Error Messages** | Mixed Korean/English | Unify to English, review i18n key approach | Medium |
| **Shell Script** | Per-module duplicated code | `shared/` utility import pattern | High |
| **TypeScript** | strict, any usage | Prohibit `any`, use unknown + type guard | Medium |
| **Security** | Plaintext storage | Environment variable reference, file permission 600 | **Critical** |
| **Docker** | Root execution | Non-root user pattern | High |
| **Env Management** | Distributed environment variables | `.env.example` template, document new environment variables | Medium |
| **Module Schema** | Unofficial JSON structure | Define `installer/module-schema.json` JSON Schema | Medium |
| **Shell Quality** | ShellCheck not applied | Integrate ShellCheck verification into CI, zero warning-level or above errors | Medium |

---

## 8. Implementation Strategy

### 8.1 Sprint Execution Plan

```
Sprint 1 (Critical Security) ─── Start immediately
  ├── S1-WP1: OAuth + CSRF prevention (FR-S1-01, FR-S1-08)
  ├── S1-WP2: Injection prevention (FR-S1-02, FR-S1-03, FR-S1-09, FR-S1-10, FR-S1-12)
  ├── S1-WP3: Credential security (FR-S1-04~07)
  └── S1-WP4: Integrity verification (FR-S1-11)

Sprint 2 (Platform) ─── After Sprint 1 completion
  ├── S2-WP1: Cross-platform (FR-S2-01, FR-S2-10, FR-S2-11)
  │   └── **PG-02**: FR-S2-04 starts after FR-S2-01 completion (serial dependency)
  │   └── **PG-03**: FR-S2-09 starts after FR-S2-05 completion (same file, serial)
  ├── S2-WP2: Installer bugs (FR-S2-02, FR-S2-03, FR-S2-04, FR-S2-05~09)
  └── S2-WP3: Gap Analysis #1 (Sprint 1+2 verification)

Sprint 3 (Quality) ─── After Sprint 2 completion
  ├── S3-WP1: Test foundation (FR-S3-01, FR-S3-02, FR-S3-06)
  ├── S3-WP2: CI/CD automation (FR-S3-03, FR-S3-04, FR-S3-09) + ShellCheck CI integration
  ├── S3-WP3: Code quality (FR-S3-05a, FR-S3-05b, FR-S3-07, FR-S3-08)
  │   └── FR-S3-05a (installer) → FR-S3-05b (Google MCP) sequential refactoring
  └── S3-WP4: Security quality (FR-S3-10: security event logging, OWASP A09 response)

Sprint 4 (Google MCP) ─── Can run in parallel with Sprint 3
  ├── S4-WP1: Stability (FR-S4-01, FR-S4-05, FR-S4-06)
  │   └── **PG-04**: FR-S4-04 (caching) starts after FR-S4-05 (token validation) + FR-S4-06 (mutex) completion (serial dependency)
  ├── S4-WP2: Internationalization/caching (FR-S4-02, FR-S4-03, FR-S4-04)
  └── S4-WP3: Infrastructure/features (FR-S4-07~10)

Sprint 5 (UX & Docs) ─── After Sprint 3+4 completion
  ├── S5-WP1: User experience (FR-S5-01, FR-S5-02)
  ├── S5-WP2: Documentation (FR-S5-03~05)
  └── S5-WP3: Final Gap Analysis + Completion Report
```

### 8.2 Analysis Issue → Requirement Mapping (Full Traceability)

| Analysis Issue ID | Severity | Requirement ID | Sprint |
|:----------:|:------:|:----------:|:------:|
| SEC-01 | Critical | FR-S1-03 (osascript injection), **FR-S1-11** (SHA-256 checksum), Out of Scope (GPG) | S1 |
| SEC-02 | Critical | FR-S1-04 | S1 |
| SEC-03 | Critical | FR-S1-05 | S1 |
| SEC-04 | High | FR-S1-07 | S1 |
| SEC-05 | High | FR-S1-06 | S1 |
| SEC-06 | High | FR-S2-10 | S2 |
| SEC-07 | High | FR-S4-02 | S4 |
| SEC-08 | High | FR-S1-01 | S1 |
| SEC-08a | High | FR-S1-03 | S1 |
| SEC-09 | Medium | FR-S1-09 | S1 |
| SEC-10 | Medium | FR-S5-06 | S5 |
| SEC-11 | Medium | Out of Scope (third-party image verification) | - |
| SEC-12 | Medium | FR-S1-09 | S1 |
| SEC-13 | Medium | FR-S1-04 (resolved by env variable transition) | S1 |
| SEC-14 | Medium | FR-S1-08 | S1 |
| INS-01 | High | FR-S2-01 | S2 |
| INS-02 | Medium | FR-S2-03 | S2 |
| INS-03 | Medium | FR-S5-02 | S5 |
| INS-04 | Low | FR-S2-07 | S2 |
| INS-05 | Medium | FR-S2-04 | S2 |
| INS-06 | Low | FR-S5-03 | S5 |
| INS-07 | High | FR-S2-02 | S2 |
| INS-08 | Medium | FR-S2-05 | S2 |
| INS-09 | Medium | FR-S2-06 | S2 |
| INS-10 | Low | FR-S2-08 | S2 |
| GWS-01 | Medium | FR-S4-05 | S4 |
| GWS-02 | Medium | FR-S4-01 | S4 |
| GWS-03 | Low | FR-S3-08, FR-S5-05 | S3/S5 |
| GWS-04 | Low | FR-S3-07 | S3 |
| GWS-05 | Medium | FR-S4-06 | S4 |
| GWS-06 | Low | FR-S5-04 | S5 |
| GWS-07 | High | FR-S1-02 | S1 |
| GWS-08 | Medium | FR-S1-10 | S1 |
| GWS-09 | Medium | FR-S4-03 | S4 |
| GWS-10 | Medium | FR-S4-07 | S4 |
| GWS-11 | Low | FR-S4-08 | S4 |
| GWS-12 | Low | FR-S4-10 | S4 |
| OS-01 | High | FR-S2-01 | S2 |
| OS-02 | Medium | FR-S2-04 | S2 |
| OS-05 | Medium | (addressed via documentation) | S5 |
| OS-06 | High | **FR-S2-11** (Docker Desktop version compatibility check) | S2 |
| OS-07 | Medium | FR-S2-09 | S2 |
| OS-08 | Medium | FR-S4-09 | S4 |
| QA-01 | Critical | FR-S3-01, FR-S3-02 | S3 |
| QA-02 | High | FR-S3-03 | S3 |
| QA-03 | Medium | FR-S3-05a, FR-S3-05b | S3 |
| QA-04 | Medium | FR-S5-02 | S5 |
| QA-05 | Low | (Structured logging is Out of Scope, but security logging addressed via **FR-S3-10**) | S3/- |
| QA-06 | Medium | FR-S3-05a, FR-S3-05b | S3 |
| QA-07 | Medium | FR-S4-04 | S4 |
| QA-08 | Low | FR-S3-06 | S3 |
| QA-09 | Low | Out of Scope (CHANGELOG generation) | - |

> **Traceability result**: 48 total analysis issues, **45 addressed** (93.8%), 3 Out of Scope (SEC-11, QA-05, QA-09)
> Coverage improved from 89.6% to 93.8% with addition of new FRs in v2.1 (S1-11, S1-12, S2-11, S3-09, S3-10)
>
> **v2.2 additional verification**: Full cross-verification of 3 gap analysis reports (security verification, shared utilities, requirements traceability) completed.
> - Security verification gap 6 plan supplement items (P-01~P-06): Fully reflected (5 items in v2.1, 1 additional item supplemented in v2.2)
> - Shared utilities gap 15 plan items (P-1~P-15): Fully reflected (FR-S3-05a/b detailed, R-08 added, quantitative expected impact included)
> - Requirements traceability gap 19 items: All 4 High items reflected, all 7 Medium items reflected, 6 of 8 Low items reflected (Pencil security review/i18n direction to be reviewed separately)

---

## 9. Detailed Remediation Approaches

### 9.1 Sprint 1 Core Implementation Guide

#### FR-S1-01: OAuth state parameter (oauth.ts)

**Current code** (`oauth.ts:113-118`):
```typescript
const authUrl = oauth2Client.generateAuthUrl({
  access_type: "offline",
  scope: SCOPES,
  prompt: "consent",
});
```

**Improvement direction**:
```typescript
import crypto from "crypto";

const state = crypto.randomBytes(32).toString("hex");
const authUrl = oauth2Client.generateAuthUrl({
  access_type: "offline",
  scope: SCOPES,
  prompt: "consent",
  state,
});
// State verification in callback:
// if (url.searchParams.get("state") !== state) reject("State mismatch");
```

#### FR-S1-02: Drive API query escaping (drive.ts)

**Current code** (`drive.ts:18`):
```typescript
let q = `name contains '${query}' and trashed = false`;
```

**Improvement direction**:
```typescript
const escapedQuery = query.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
let q = `name contains '${escapedQuery}' and trashed = false`;
```

#### FR-S1-03: parse_json() osascript injection prevention (install.sh)

**Current code** (`install.sh:29-39`):
```bash
parse_json() {
    local json="$1"
    osascript -l JavaScript -e "
        var obj = JSON.parse(\`$json\`);  # backtick injection vulnerable
```

**Improvement direction** (integrated with Sprint 2 FR-S2-01):
```bash
parse_json() {
    local json="$1"
    local key="$2"
    # node -e method (JSON passed via stdin, injection impossible)
    echo "$json" | node -e "
        const chunks = [];
        process.stdin.on('data', c => chunks.push(c));
        process.stdin.on('end', () => {
            const obj = JSON.parse(chunks.join(''));
            const keys = process.argv[1].split('.');
            let val = obj;
            for (const k of keys) val = val ? val[k] : undefined;
            console.log(val === undefined ? '' : String(val));
        });
    " "$key" 2>/dev/null || echo ""
}
```

#### FR-S1-06: Docker non-root user (Dockerfile)

**Current code** -- runs as root:
```dockerfile
CMD ["node", "dist/index.js"]
```

**Improvement direction**:
```dockerfile
# Add to production stage:
RUN addgroup --system --gid 1001 app && \
    adduser --system --uid 1001 --ingroup app app && \
    chown -R app:app /app
USER app
CMD ["node", "dist/index.js"]
```

### 9.2 Sprint 2 Core Implementation Guide

#### FR-S2-01: Cross-platform JSON parser

```bash
parse_json() {
    local json="$1"
    local key="$2"

    # Priority: node > python3 > osascript (macOS only)
    if command -v node > /dev/null 2>&1; then
        echo "$json" | node -e "..." "$key"
    elif command -v python3 > /dev/null 2>&1; then
        echo "$json" | python3 -c "
import json, sys
obj = json.load(sys.stdin)
keys = sys.argv[1].split('.')
val = obj
for k in keys:
    val = val.get(k, '') if isinstance(val, dict) else ''
print(val if val else '')
" "$key"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS fallback (keep existing method but improved to stdin method)
        echo "$json" | osascript -l JavaScript -e "..."
    else
        echo "Error: node or python3 required" >&2
        return 1
    fi
}
```

#### FR-S2-02: Shared script download during remote execution

Add pre-download logic for remote mode to `run_module()` function in `install.sh`:

```bash
run_module() {
    local module_name=$1
    # ...
    if [ "$USE_LOCAL" = false ]; then
        # Remote mode: download shared scripts to temp directory
        local tmp_dir=$(mktemp -d)
        mkdir -p "$tmp_dir/shared"
        curl -sSL "$BASE_URL/modules/shared/oauth-helper.sh" \
            -o "$tmp_dir/shared/oauth-helper.sh" 2>/dev/null || true
        # Set SCRIPT_DIR to temp directory to resolve source path
        export INSTALLER_SHARED_DIR="$tmp_dir/shared"
        # Module scripts prioritize INSTALLER_SHARED_DIR environment variable
    fi
}
```

---

## 10. Next Steps

1. [ ] Plan document review and approval
2. [ ] Design document creation (`/pdca design adw-improvement`)
3. [ ] Sprint 1 start -- Critical Security issues immediate fix
4. [ ] Run Gap Analysis after Sprint 1 completion (`/pdca analyze adw-improvement`)

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-02-12 | Initial draft -- CTO Team 8-agent parallel analysis | CTO Team |
| 2.0 | 2026-02-12 | 44 requirements established based on adw-comprehensive.analysis.md | CTO Team |
| 2.1 | 2026-02-12 | Reflected 3 additional analysis documents + 3 gap analyses. 5 new FRs (S1-11, S1-12, S2-11, S3-09, S3-10), FR-S3-05 detailed (5a/5b), R-08 risk added, individual effort estimates, quantitative expected impact, Sprint execution plan | CTO Team |
| 2.2 | 2026-02-13 | Full cross-verification of 7 analysis documents completed. FR-S1-04 priority corrected to Critical (P-02), FR-S2-10 priority restored to High (P-03), FR-S2-02 temporary file cleanup guarantee (trap pattern), FR-S3-05a/b function names detailed (29+7 functions finalized), PG-02/PG-04 serial dependencies specified, 3 NFRs added (ShellCheck/npm audit/security logging), 3 conventions added (Env/Schema/ShellCheck), Out of Scope refined (In Scope transition history), References full list of 7 analysis documents, Sprint 2 total recalculated | CTO Lead |

---

## Appendix A: CTO Team Verification Summary

### A.1 Security Architect Verification Results

| Report ID | Reported Severity | Verified Severity | Status | Notes |
|---------|:----------:|:----------:|:----:|------|
| SEC-01 | Critical | **Critical** | Confirmed | Remote code execution possible via MITM |
| SEC-02 | Critical | **Critical** | Confirmed | API token recorded as plaintext in `.mcp.json` |
| SEC-03 | Critical | **Informational** | **Downgraded** | `{accessToken}` is template placeholder, not written to disk |
| SEC-04 | High | **High** | Confirmed | `token.json` file permission 644 (readable by other users) |
| SEC-05 | High | **High** | Confirmed | Docker container running as root |
| SEC-06 | High | **High** | Confirmed | Admin privileges required for all modules on Windows |
| SEC-07 | High | **High** | Confirmed | Always requests all 6 service scopes unconditionally |
| SEC-08 | High | **High** | Confirmed | OAuth state parameter missing (CSRF) |
| SEC-08a | High | **High** | Confirmed | Arbitrary JS execution possible via backtick injection |
| GWS-07 | High | **High** | Confirmed | `'` not escaped in Drive queries |
| GWS-08 | Medium | **Medium** | Confirmed | Email header injection possible via CRLF |
| SEC-12 | Medium | **Medium** | Confirmed | User input directly inserted into `node -e` |

> Additional findings: Absence of input validation layer, security logging not implemented, `npm audit` not applied

### A.2 Code Analyzer Verification Results

| Report ID | Reported Severity | Verified Severity | Status | Notes |
|---------|:----------:|:----------:|:----:|------|
| INS-01 | High | **High** | Confirmed | `osascript` macOS-only, module loading fails on Linux |
| INS-02 | Medium | **High** | **Upgraded** | Mac 3-file path mismatch (commit b8b01a2 only changed Windows) |
| INS-03 | Medium | **Medium** | Confirmed | No rollback mechanism |
| INS-07 | High | **High** | Confirmed | oauth-helper.sh not downloaded during remote execution |
| INS-08 | Medium | **Medium** | Confirmed | Figma module.json is npx style but actual is Remote MCP |
| INS-09 | Medium | **Low** | **Downgraded** | `docker: false` is design intent considering Rovo path |
| GWS-01 | Medium | **Medium** | Confirmed | No expiry buffer + expiry_date non-existence case not handled |
| GWS-02 | Medium | **Medium** | Confirmed | All 69 handlers have no rate limit |
| GWS-05 | Medium | **Medium** | Confirmed | EADDRINUSE possible on concurrent authentication |
| GWS-07 | High | **High** | Confirmed | drive_search + drive_list + mimeType in 3 locations |
| GWS-09 | Medium | **Medium** | Confirmed | `Asia/Seoul` hardcoded in 4 locations |
| GWS-10 | Medium | **Medium** | Confirmed | Nested multipart not parsed |
| QA-01 | Critical | **Critical** | Confirmed | 0 test files, 0 test infrastructure |
| QA-06 | Medium | **Medium** | Confirmed | Color duplicated in 9 files, MCP config in 2 locations, parseTime in 2 locations |
| QA-07 | Medium | **Medium** | Confirmed | 6 services regenerated per each of 69 handlers |

> Additional findings: `any` type also used at `sheets.ts:18,341`, `calendar.ts:288`, `slides.ts:135,156`

### A.3 Enterprise Expert Verification Results

| Report ID | Reported Severity | Verified Severity | Status | Notes |
|---------|:----------:|:----------:|:----:|------|
| OS-01 | High | **Critical** | **Upgraded** | Entire install.sh non-functional on Linux |
| OS-02 | Medium | **Medium** | Confirmed | Only apt/snap supported, only github module supports dnf |
| OS-05 | Medium | **Low** | **Downgraded** | WSL restart guide already implemented |
| OS-06 | High | **High** | Confirmed | Docker Desktop 4.42+ does not support macOS Ventura |
| OS-07 | Medium | **Medium** | Confirmed | python3 required in 3 modules but not indicated in module.json |
| OS-08 | Medium | **High** | **Upgraded** | Node.js 20 EOL in 77 days (2026-04-30) |
| INS-04 | Low | **Low** | Confirmed | PowerShell has sorting implementation, Shell does not |
| INS-05 | Medium | (duplicate) | = OS-02 | Same issue |
| INS-10 | Low | **Low** | Confirmed | No `docker wait` timeout |

> Key finding: **PowerShell implementation is more robust than Shell in every dimension** -- JSON parsing (native), module sorting (implemented), error handling (`try/catch`), package manager (winget universal)

### A.4 Overall Effort Estimate

| Category | Security Agent | Code Analysis Agent | Enterprise Agent | Total |
|------|:-----------:|:----------------:|:------------------:|:----:|
| Critical Path | 12-16h | 7-8h | 7-13h | **26-37h** |
| Overall | 34-49h | 40-55h | 18-32h | **92-136h** |
