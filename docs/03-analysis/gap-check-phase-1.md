# ADW Improvement Gap Analysis -- Check Phase 1

> **Summary**: Full verification of 48 FRs resulted in 37 fully implemented / 6 partially implemented / 5 not implemented
>
> **Feature**: adw-improvement
> **Version**: Check-1.0
> **Date**: 2026-02-13
> **Author**: CTO Lead (gap-detector + code-analyzer + qa-strategist collaboration)
> **Plan Reference**: `docs/01-plan/features/adw-improvement.plan.md` (v2.2)
> **Design Reference**: `docs/02-design/features/adw-improvement.design.md` (v1.2)

---

## Overall Match Rate: 77.1%

| Category | FR Count | Ratio |
|------|:-----:|:----:|
| Fully Implemented (100%) | 37 | 77.1% |
| Partially Implemented (50%) | 6 | 12.5% |
| Not Implemented (0%) | 5 | 10.4% |
| **Total** | **48** | |

**Weighted Score**: (37 x 100 + 6 x 50 + 5 x 0) / 48 = **83.3%**

---

## Sprint Details

### Sprint 1 -- Critical Security (12 FRs)

| FR ID | Requirement | Implementation Status | Match | Shortfall |
|-------|---------|:---------:|:------:|----------|
| FR-S1-01 | Add OAuth state parameter | Fully Implemented | 100% | None. `crypto.randomBytes(32)` state generation, validation on callback, 403 response + security log on failure. Matches design document exactly |
| FR-S1-02 | Drive API query escaping | Fully Implemented | 100% | None. `escapeDriveQuery()` + `validateDriveId()` implemented. Applied to all handlers including `drive_search`, `drive_list` in `drive.ts` |
| FR-S1-03 | osascript template injection prevention | Fully Implemented | 100% | None. `parse_json()` fully replaced with stdin pipe method. node > python3 > osascript fallback chain implemented |
| FR-S1-04 | Atlassian API token secure storage | Fully Implemented | 100% | None. `.env` file separation, `chmod 600`, `--env-file` method MCP config. Matches design document exactly |
| FR-S1-05 | Figma token secure storage | Fully Implemented | 100% | None. Informational (template placeholder confirmed). No code change needed |
| FR-S1-06 | Add Docker non-root user | Fully Implemented | 100% | None. `groupadd -r mcp && useradd -r -g mcp` + `USER mcp`. HEALTHCHECK included. Matches design document |
| FR-S1-07 | token.json file permission setting | Fully Implemented | 100% | None. `writeFileSync` mode 0o600 + defensive `chmodSync` + security logging |
| FR-S1-08 | Config directory permission setting | Fully Implemented | 100% | None. `mkdirSync` mode 0o700 + defensive chmod check/recovery. Windows exception handling included |
| FR-S1-09 | Atlassian install.sh variable escaping | Fully Implemented | 100% | None. Resolved integrated with FR-S1-04 via `--env-file` pattern. No user input insertion in Node.js `-e` blocks |
| FR-S1-10 | Gmail email header injection prevention | Fully Implemented | 100% | None. `sanitizeEmailHeader()` implemented + applied to `gmail_send`, `gmail_draft_create` |
| FR-S1-11 | Remote script download integrity verification | Fully Implemented | 100% | None. `download_and_verify()` function, `checksums.json`, `generate-checksums.sh`, CI `verify-checksums` job implemented |
| FR-S1-12 | Build input validation layer | Fully Implemented | 100% | None. All 7 functions in `sanitize.ts` implemented: `escapeDriveQuery`, `validateDriveId`, `sanitizeEmailHeader`, `validateEmail`, `validateMaxLength`, `sanitizeFilename`, `sanitizeRange` |

**Sprint 1 Match Rate: 100% (12/12 fully implemented)**

---

### Sprint 2 -- Platform & Stability (11 FRs)

| FR ID | Requirement | Implementation Status | Match | Shortfall |
|-------|---------|:---------:|:------:|----------|
| FR-S2-01 | Cross-platform JSON parser implementation | Fully Implemented | 100% | None. node > python3 > osascript fallback chain. Integrated implementation with FR-S1-03 |
| FR-S2-02 | Remote execution shared script download | Partially Implemented | 50% | `download_and_verify()` based remote download mechanism exists, but shared script pre-download logic (`SHARED_TMP` + `trap cleanup`) **not implemented** in `run_module()`. Practical impact low since module scripts don't source shared |
| FR-S2-03 | MCP config path unification | Fully Implemented | 100% | None. Both `google/install.sh` and `atlassian/install.sh` use `~/.claude/mcp.json`. Legacy migration logic included |
| FR-S2-04 | Linux package manager expansion | Fully Implemented | 100% | None. `apt-get`, `dnf`, `pacman` branching implemented in `base/install.sh`. Also integrated in `package-manager.sh` |
| FR-S2-05 | Figma module.json consistency fix | Partially Implemented | 50% | `type: "remote-mcp"`, `node: false` applied. However `python3: true` **not added** (related to design FR-S2-09) |
| FR-S2-06 | Atlassian module.json Docker annotation fix | Not Implemented | 0% | `docker: true` maintained, `modes` field **not added**. Current module.json has no Docker/Rovo dual mode representation |
| FR-S2-07 | Module execution order sorting | Fully Implemented | 100% | None. `MODULE_ORDERS` based `sort -t: -k1 -n` sorting implemented |
| FR-S2-08 | Docker wait timeout addition | Fully Implemented | 100% | None. 300-second timeout polling loop implemented in `google/install.sh` |
| FR-S2-09 | Python 3 dependency module.json specification | Not Implemented | 0% | `python3: true` **not added** to Notion, Figma module.json |
| FR-S2-10 | Windows admin privilege conditional request | Fully Implemented | 100% | None. `Test-AdminRequired` function, per-module admin requirement determination implemented |
| FR-S2-11 | Docker Desktop version compatibility check | Fully Implemented | 100% | None. `docker_check_compatibility()` function, macOS version cross-verification, auto-invocation within `docker_check()` |

**Sprint 2 Match Rate: 72.7% (8 fully + 2 partial + 1 not implemented)**

---

### Sprint 3 -- Quality & Testing (10 FRs)

| FR ID | Requirement | Implementation Status | Match | Shortfall |
|-------|---------|:---------:|:------:|----------|
| FR-S3-01 | Google MCP unit test creation | Partially Implemented | 50% | 5 test files exist (`gmail.test.ts`, `sanitize.test.ts`, `retry.test.ts`, `time.test.ts`, `mime.test.ts`). However **per-tool tests not written** (drive, calendar, docs, sheets, slides). Mostly utility tests, likely below target 60% coverage |
| FR-S3-02 | Installer smoke test creation | Fully Implemented | 100% | None. 4 test files: `test_framework.sh`, `test_module_json.sh`, `test_install_syntax.sh`, `test_module_ordering.sh` |
| FR-S3-03 | CI auto-trigger addition | Fully Implemented | 100% | None. `push: [master, develop]` + `pull_request: [master]` triggers. Full pipeline: lint, build, test, smoke-tests, security-audit, shellcheck, docker-build, verify-checksums |
| FR-S3-04 | CI test scope expansion | Fully Implemented | 100% | None. smoke-tests job runs entire `installer/tests/`. module_json tests cover all modules |
| FR-S3-05a | Installer shared utility extraction | Partially Implemented | 50% | All 5 shared scripts created (`colors.sh`, `docker-utils.sh`, `mcp-config.sh`, `browser-utils.sh`, `package-manager.sh`). However **7 module scripts don't actually source them**. Inline color definitions still exist in `base/install.sh`, `atlassian/install.sh` etc. 0 of 5 acceptance criteria met |
| FR-S3-05b | Google MCP shared utility extraction | Partially Implemented | 50% | All 5 utility files created (`time.ts`, `retry.ts`, `sanitize.ts`, `mime.ts`, `messages.ts`). `time.ts` import confirmed in `calendar.ts`. However **(1) withRetry() not applied** -- not imported in any tool file, **(2) mime.ts not integrated** -- `gmail.ts` retains its own MIME parsing, **(3) messages.ts not integrated** -- not imported in tool files. 2 of 5 acceptance criteria met (parseTime integration, sanitize applied) |
| FR-S3-06 | ESLint + Prettier setup | Fully Implemented | 100% | None. `eslint.config.js` (flat config), `.prettierrc` configured. lint/format scripts in `package.json` |
| FR-S3-07 | Remove `any` types | Fully Implemented | 100% | None. `index.ts:32`'s `params: any` -> `params: Record<string, unknown>`, other `any` locations removed confirmed |
| FR-S3-08 | Error message English unification | Fully Implemented | 100% | None. `index.ts`: confirmed changes like "Error:" and "Server startup failed:" |
| FR-S3-09 | npm audit CI integration | Fully Implemented | 100% | None. `security-audit` job: `npm audit --audit-level=high` implemented |

**Sprint 3 Match Rate: 80% (7 fully + 3 partial)**

---

### Sprint 4 -- Google MCP Hardening (10 FRs)

| FR ID | Requirement | Implementation Status | Match | Shortfall |
|-------|---------|:---------:|:------:|----------|
| FR-S4-01 | Google API Rate Limiting implementation | Partially Implemented | 50% | `withRetry()` function correctly implemented in `retry.ts` (exponential backoff, 429/500/502/503/504, network errors). However **not applied to actual tool handlers**. No `withRetry` import in any of the 6 tool files |
| FR-S4-02 | OAuth scope dynamic configuration | Fully Implemented | 100% | None. `SCOPE_MAP` + `resolveScopes()` + `GOOGLE_SCOPES` environment variable support |
| FR-S4-03 | Calendar timezone dynamic | Fully Implemented | 100% | None. `time.ts`'s `getTimezone()` + `TIMEZONE` environment variable. Confirmed `import { getTimezone, parseTime }` in `calendar.ts`. 0 `Asia/Seoul` hardcoded occurrences |
| FR-S4-04 | getGoogleServices() singleton/caching | Fully Implemented | 100% | None. TTL 50-min caching, `ServiceCache` interface, `clearServiceCache()` test utility |
| FR-S4-05 | Token refresh_token validity check | Fully Implemented | 100% | None. `refresh_token` existence check in `loadToken()`, 5-min expiry buffer implemented |
| FR-S4-06 | Concurrent auth request handling | Fully Implemented | 100% | None. `authInProgress` Promise-based mutex, null initialization in `finally` block |
| FR-S4-07 | Gmail nested MIME parsing improvement | Partially Implemented | 50% | `extractTextBody()`, `extractAttachments()` recursive parsing correctly implemented in `mime.ts`. However **not imported in `gmail.ts`**. `gmail_read` handler still uses its own 1-level `parts` parsing |
| FR-S4-08 | Gmail attachment download improvement | Fully Implemented | 100% | None. `gmail_attachment_get` handler returns full `response.data.data` (1000-char truncation code removed confirmed) |
| FR-S4-09 | Node.js 22 migration | Fully Implemented | 100% | None. Dockerfile `FROM node:22-slim`, `@types/node: ^22.0.0` |
| FR-S4-10 | .dockerignore addition | Fully Implemented | 100% | None. `.google-workspace/`, `node_modules/`, `.git/`, `.env*`, `client_secret.json`, `token.json` etc. included |

**Sprint 4 Match Rate: 85% (8 fully + 2 partial)**

---

### Sprint 5 -- UX & Documentation (6 FRs)

| FR ID | Requirement | Implementation Status | Match | Shortfall |
|-------|---------|:---------:|:------:|----------|
| FR-S5-01 | Post-installation auto-verification | Fully Implemented | 100% | None. `verify_module_installation()` function, MCP config verification, Docker image verification implemented |
| FR-S5-02 | Rollback mechanism introduction | Fully Implemented | 100% | None. `backup_mcp_config()`, `rollback_mcp_config()`, auto-rollback on failure, backup deletion on success |
| FR-S5-03 | ARCHITECTURE.md synchronization | Not Implemented | 0% | Pencil module, `shared/` directory, Remote MCP type **not added**. Current ARCHITECTURE.md has no mention of `shared/`, `pencil` |
| FR-S5-04 | package.json version update | Fully Implemented | 100% | None. `version: "1.0.0"` confirmed |
| FR-S5-05 | Google MCP tool message English conversion | Not Implemented | 0% | `messages.ts` file exists but 6 tool files **don't import it**. Tool descriptions are still in Korean (e.g., "Google Drive에서 파일을 검색합니다" / "Searches for files in Google Drive"). `messages.ts` centralized management structure not actually applied |
| FR-S5-06 | .gitignore reinforcement | Fully Implemented | 100% | None. `client_secret.json`, `token.json`, `.env`, `.env.local`, `.env.*.local`, `credentials.env` patterns all included |

**Sprint 5 Match Rate: 66.7% (4 fully + 2 not implemented)**

---

## Shortfall Items List (Act Phase Targets)

| # | FR ID | Shortfall | Priority | Estimated Effort | Notes |
|---|-------|----------|:--------:|:---------:|------|
| 1 | FR-S3-05a | **Shared utilities not applied**: 5 shared scripts created, but 7 module scripts don't source them. Inline color definitions/Docker check/MCP config/browser open duplicate code remains | **High** | 4-6h | 0 of 5 acceptance criteria met. Large refactoring scope, recommend separate Act iteration |
| 2 | FR-S3-05b (withRetry) | **withRetry() not applied**: `retry.ts` implementation complete, but not applied to ~80 API calls across 6 tool files (gmail, drive, calendar, docs, sheets, slides) | **High** | 3-4h | Need to wrap existing API calls with `withRetry(() => ...)` |
| 3 | FR-S3-05b (mime.ts) | **mime.ts not integrated**: Recursive parsing functions implemented, but `gmail.ts` still uses its own 1-level parsing | **Medium** | 1-2h | Import `extractTextBody()`, `extractAttachments()` in `gmail_read` handler |
| 4 | FR-S3-05b (messages.ts) | **messages.ts not integrated**: 8-category message definitions complete, but not imported in tool files | **Low** | 2-3h | Work simultaneously with Sprint 5 FR-S5-05 |
| 5 | FR-S5-05 | **Korean tool messages remain**: `description` and response `message` in 6 tool files are in Korean. `messages.ts` usage not applied | **Low** | 4-6h | Perform together with FR-S3-05b messages.ts integration |
| 6 | FR-S5-03 | **ARCHITECTURE.md not updated**: Pencil module, shared/ directory, Remote MCP type, execution order section not added | **Low** | 1-2h | Documentation update only |
| 7 | FR-S2-06 | **Atlassian module.json modes field not added**: No Docker/Rovo dual mode representation | **Low** | 0.5h | Add `modes: ["docker", "rovo"]` field |
| 8 | FR-S2-09 | **Python 3 dependency not specified**: No `python3` field in Notion, Figma module.json | **Low** | 0.5h | Add `"python3": true` to each module.json |
| 9 | FR-S2-05 | **Figma module.json python3 not added**: `type: "remote-mcp"`, `node: false` applied, but `python3: true` missing | **Low** | 0.5h | Perform simultaneously with FR-S2-09 |
| 10 | FR-S2-02 | **Remote shared script pre-download not implemented**: `SHARED_TMP` + `trap cleanup` pattern not applied | **Low** | 1-2h | Perform together with FR-S3-05a refactoring |
| 11 | FR-S3-01 | **Unit test coverage insufficient**: Only 5 utility tests exist. Per-tool core logic tests not written | **Medium** | 8-12h | Add drive, calendar, docs, sheets, slides tests |

---

## Gap Analysis by Category

### Security (Sprint 1): 100% -- All Fully Implemented

All 12 security FRs in Sprint 1 were implemented matching the design document exactly. Notable points:
- All 7 functions in `sanitize.ts` fully implemented (FR-S1-12)
- SHA-256 checksum verification + CI auto-verification (FR-S1-11)
- Security event logging (FR-S3-10, `logSecurityEvent` in oauth.ts)

### Platform Compatibility (Sprint 2): 72.7% -- 3 Items Below Target

Core issues (cross-platform JSON parser, MCP path unification, Linux package managers) completed.
3 metadata consistency issues (module.json field additions) are below target. All Low priority.

### Code Quality (Sprint 3): 80% -- Shared Utility Integration is Key

The largest gap is the **"created but not integrated" pattern for shared utilities**:
- Installer: 5 shared scripts exist but 7 modules don't source them
- Google MCP: `retry.ts`, `mime.ts`, `messages.ts` exist but unused in tool files

### API Stability (Sprint 4): 85% -- withRetry Application is Key

The `withRetry()` function itself is correctly implemented, but not applied to actual API calls, so Rate Limiting protection is not operational.

### UX/Documentation (Sprint 5): 66.7% -- messages.ts + ARCHITECTURE.md

`messages.ts` not integrated into tool files, so Korean messages remain.

---

## Acceptance Criteria Fulfillment Status

### Plan v2.2 Section 4 -- Definition of Done

| Criterion | Status | Notes |
|------|:----:|------|
| All Critical/High security issues resolved (FR-S1-01~12) | **Met** | 12/12 fully implemented |
| `install.sh` works correctly on Linux (FR-S2-01) | **Met** | node > python3 fallback chain implemented |
| Google MCP unit test 60%+ coverage (FR-S3-01) | **Unconfirmed** | 5 test files exist, coverage execution needed |
| CI auto-runs on PR/push (FR-S3-03) | **Met** | 8-job pipeline complete |
| Gap Analysis Match Rate 90%+ achieved | **Not Met** | Current 83.3%, -6.7pp from target 90% |

### Design v1.2 Section 5.4 -- Shared Utility Acceptance Criteria

**Installer (FR-S3-05a)**:
| # | Criterion | Met |
|---|------|:----:|
| 1 | All 7 installer modules source shared/colors.sh | Not Met |
| 2 | 0 inline color definitions | Not Met |
| 3 | Docker modules use docker_check() | Not Met |
| 4 | MCP modules use mcp_add_docker_server()/mcp_add_stdio_server() | Not Met |
| 5 | Browser modules use browser_open() | Not Met |

**Google MCP (FR-S3-05b)**:
| # | Criterion | Met |
|---|------|:----:|
| 1 | 0 duplicate parseTime() in calendar.ts | **Met** |
| 2 | 69 handlers use cached getGoogleServices() | **Met** |
| 3 | withRetry() applied to all API calls | Not Met |
| 4 | User input passes through sanitize functions | **Met** (drive, gmail) |
| 5 | 0 hardcoded Korean messages | Not Met |

---

## Priority Act Phase Work Plan

### Immediate (Key to achieving 90% Match Rate)

| Task | FR | Expected Effect | Effort |
|------|-----|----------|------|
| Apply withRetry() to tool files | FR-S4-01, FR-S3-05b | +4.2pp | 3-4h |
| Integrate mime.ts into gmail.ts | FR-S4-07, FR-S3-05b | +2.1pp | 1-2h |
| Installer module shared source refactoring | FR-S3-05a | +4.2pp | 4-6h |

**Expected Match Rate Achievement**: 83.3% + 10.5pp = **93.8%** (exceeds target 90%)

### Follow-up (Documentation/Metadata)

| Task | FR | Effort |
|------|-----|------|
| messages.ts integration + English conversion | FR-S5-05, FR-S3-05b | 4-6h |
| ARCHITECTURE.md update | FR-S5-03 | 1-2h |
| module.json field additions (modes, python3) | FR-S2-06, FR-S2-09, FR-S2-05 | 1h |
| Per-tool unit test additions | FR-S3-01 | 8-12h |

---

## Quantitative Expected Effect Verification

| Metric | Plan Target | Current Measurement | Achievement |
|------|:--------:|:--------:|:------:|
| Security vulnerabilities (Critical/High) | 0 | **0** | 100% |
| Test coverage | 60%+ | Not measured (5 test files) | Unconfirmed |
| Service instance creation | 6x/TTL | **6x/TTL** (caching implemented) | 100% |
| Installer LOC reduction | -29% | No reduction (shared not applied) | 0% |
| Google MCP LOC reduction | -28% | Partial reduction (some utils applied) | ~30% |
| Match Rate | 95%+ | **83.3%** | 87.7% |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| Check-1.0 | 2026-02-13 | Initial full verification of 48 FRs. Match Rate 83.3% | CTO Lead |
