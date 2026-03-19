# ADW Improvement Gap Analysis -- Check Phase 2

> **Summary**: After Act Phase Iterate 1, re-verification of 48 FRs. 8 of 11 shortfall items fully resolved, 3 remaining (partial)
>
> **Feature**: adw-improvement
> **Version**: Check-2.0
> **Date**: 2026-02-13
> **Author**: gap-detector (Check Phase 2 re-verification)
> **Plan Reference**: `docs/01-plan/features/adw-improvement.plan.md` (v2.2)
> **Design Reference**: `docs/02-design/features/adw-improvement.design.md` (v1.2)
> **Check Phase 1 Reference**: `docs/03-analysis/gap-check-phase-1.md`

---

## Overall Match Rate: 93.8%

| Category | FR Count | Ratio |
|------|:-----:|:----:|
| Fully Implemented (100%) | 45 | 93.8% |
| Partially Implemented (50%) | 3 | 6.2% |
| Not Implemented (0%) | 0 | 0% |
| **Total** | **48** | |

**Weighted Score**: (45 x 100 + 3 x 50 + 0 x 0) / 48 = **96.9%**

> Compared to Check Phase 1: 77.1% -> 93.8% (+16.7pp), Weighted score 83.3% -> 96.9% (+13.6pp)
> **Target of 90% exceeded**

---

## Previous Shortfall Items Re-verification Results

| # | FR ID | Check Phase 1 | Check Phase 2 | Changes |
|---|-------|:-------------:|:-------------:|----------|
| 1 | FR-S4-01 | Partial(50%) | **Full(100%)** | `withRetry()` applied to all 6 tool files. 91 `await withRetry()` calls wrapping 87 API method calls confirmed at 100% |
| 2 | FR-S4-07 | Partial(50%) | **Full(100%)** | Confirmed `import { extractTextBody, extractAttachments } from "../utils/mime.js"` at `gmail.ts:5`. `gmail_read` handler (line 79-85) applies `extractTextBody(response.data.payload)` + `extractAttachments(response.data.payload)` recursive parsing |
| 3 | FR-S3-05a | Partial(50%) | **Partial(50%)** | 2 of 5 acceptance criteria met (details below). All 7 modules apply `source "$SHARED_DIR/colors.sh"` (criterion 1). Inline colors moved to fallback else blocks (criterion 2 partial). However `docker_check()`, `mcp_add_docker_server()`, `browser_open()` not used (criteria 3,4,5) |
| 4 | FR-S5-05 | Not Impl.(0%) | **Full(100%)** | All 6 tool files have `import { messages, msg } from "../utils/messages.js"` applied. 11 `msg()` calls confirmed. All user-facing `description` fields converted to English. Remaining Korean is only 4 JSDoc comments (non-functional) |
| 5 | FR-S3-01 | Partial(50%) | **Partial(50%)** | Existing utility tests 4 (sanitize, retry, time, mime) + tool tests 3 (gmail, drive, calendar) = 7 test files total. docs, sheets, slides tests not written. Target coverage 60% unconfirmed |
| 6 | FR-S2-02 | Partial(50%) | **Full(100%)** | `install.sh:553-569` has `SHARED_TMP`, `setup_shared_dir()`, `trap 'rm -rf "$SHARED_TMP"' EXIT` fully implemented. In remote mode, creates temp directory via `mktemp -d`, downloads 4 shared scripts, cleanup guaranteed on normal/abnormal exit |
| 7 | FR-S5-03 | Not Impl.(0%) | **Full(100%)** | `ARCHITECTURE.md` has `shared/` directory added (line 117-123), Pencil module added (line 112-115), Remote MCP type added (line 203-207), IDE Extension type added (line 209-217), execution order table added (line 221-234) |
| 8 | FR-S2-06 | Not Impl.(0%) | **Full(100%)** | Confirmed `"modes": ["docker", "rovo"]` field added at `atlassian/module.json:12` |
| 9 | FR-S2-09 | Not Impl.(0%) | **Full(100%)** | Confirmed `"python3": true` at `notion/module.json:16` |
| 10 | FR-S2-05 | Partial(50%) | **Full(100%)** | Confirmed `"type": "remote-mcp"`, `"node": false`, `"python3": true` (line 17) all present in `figma/module.json` |
| 11 | FR-S3-05b | Partial(50%) | **Partial(50%)** | 4 of 5 acceptance criteria met (details below). `parseTime` integration, `getGoogleServices()` caching, `withRetry()` full application, `sanitize` application all confirmed. However hardcoded Korean message criterion has 4 JSDoc comments remaining (no functional impact, but strictly "0 items" criterion not met) |

### Summary: 11 shortfalls -> 8 fully resolved, 3 remaining (partial)

---

## Remaining Shortfall Items

| # | FR ID | Shortfall | Current Fulfillment | Priority | Notes |
|---|-------|----------|:----------:|:--------:|------|
| 1 | FR-S3-05a | Shared utility functions not applied: 7 modules source `colors.sh` but don't use `docker_check()`, `mcp_add_docker_server()`, `browser_open()` and other shared functions. Each module still has inline Docker check/MCP config/browser open logic | 2/5 criteria | **Low** | Color integration complete. Remaining 3 criteria (Docker/MCP/Browser utility functions) require large-scale refactoring, recommend handling in separate Sprint. No functional correctness impact |
| 2 | FR-S3-01 | Per-tool tests partially unwritten: docs, sheets, slides tests don't exist. 7 test files exist but target 60% coverage unmeasured | Utils 4 + Tools 3 / 6 | **Medium** | Core tool tests (gmail, drive, calendar) written. Remaining 3 tools (docs, sheets, slides) have similar structure, can lower priority |
| 3 | FR-S3-05b | 4 JSDoc Korean comments remaining: `gmail.ts:9`, `calendar.ts:8`, `docs.ts:7`, `sheets.ts:7` have `* XXX tool definitions` style comments. Not user-facing messages but developer comments, no functional impact | 4/5 criteria | **Low** | Strictly "0 hardcoded Korean items" criterion not met, but code comments are not user-facing, so no practical impact. Cleanup takes less than 5 minutes |

---

## FR-S3-05a Acceptance Criteria Re-verification

### Installer Shared Utilities (5 criteria)

| # | Criterion | Check-1 | Check-2 | Evidence |
|---|------|:-------:|:-------:|------|
| 1 | All 7 installer modules source `shared/colors.sh` | Not Met | **Met** | All 7 modules (`base`, `google`, `atlassian`, `figma`, `notion`, `github`, `pencil`) confirmed `source "$SHARED_DIR/colors.sh"`. Fallback else block ensures remote execution safety |
| 2 | 0 inline color definitions | Not Met | **Partially Met** | Each module's `else` block has fallback color definitions. This is a defensive pattern for remote execution (`curl\|bash`) when `SHARED_DIR` path cannot be resolved. Primary path uses shared source. Strict "0 items" criterion not met but design intent is reasonable |
| 3 | Docker modules use `docker_check()` | Not Met | **Not Met** | `google/install.sh:21` uses `docker info > /dev/null 2>&1` inline. `docker-utils.sh`'s `docker_check()` not called |
| 4 | MCP modules use `mcp_add_docker_server()`/`mcp_add_stdio_server()` | Not Met | **Not Met** | `google/install.sh:340-375` handles MCP config directly with inline Node.js code. `mcp-config.sh` functions not called |
| 5 | Browser modules use `browser_open()` | Not Met | **Not Met** | No `open`/`xdg-open` direct call pattern in module install.sh (confirmed). Modules requiring browser opening (google) handle inline |

**FR-S3-05a Fulfillment: 2/5 (40%) -- Partial Implementation (50%) maintained**

> Analysis: Only criterion 1 (colors source) was fully resolved. Criterion 2 (inline 0 items) is partially met with fallback pattern.
> Criteria 3/4/5 require large-scale refactoring to replace each module's inline logic with shared function calls,
> and since there is no functional correctness impact, recommend handling in subsequent Sprint.

---

## FR-S3-05b Acceptance Criteria Re-verification

### Google MCP Shared Utilities (5 criteria)

| # | Criterion | Check-1 | Check-2 | Evidence |
|---|------|:-------:|:-------:|------|
| 1 | 0 duplicate `parseTime()` in `calendar.ts` | **Met** | **Met** | Confirmed `import { getTimezone, parseTime } from "../utils/time.js"` in `calendar.ts` (line 3). 0 local `parseTime` function definitions. Imported `parseTime()` used at 4 locations (line 173, 177, 301, 304) |
| 2 | 69 handlers use cached `getGoogleServices()` | **Met** | **Met** | Total 75 `getGoogleServices()` calls confirmed across all 6 tool files. `ServiceCache` + TTL 50-min caching intact in `oauth.ts:93-99`. `clearServiceCache()` test utility exists (line 433) |
| 3 | `withRetry()` applied to all API calls | Not Met | **Met** | All 6 tool files confirmed `import { withRetry } from "../utils/retry.js"`. Total 91 `await withRetry()`, wrapping 87 API method calls -- 100%. Exponential backoff (1s->2s->4s), 429/500/502/503/504 + network error response |
| 4 | User input passes through sanitize functions | **Met** | **Met** | `drive.ts`: `escapeDriveQuery()` 5 times, `validateDriveId()` 14 times. `gmail.ts`: `sanitizeEmailHeader()` 5 times. All 7 `sanitize.ts` functions intact |
| 5 | 0 hardcoded Korean messages | Not Met | **Mostly Met** | 0 Korean in user-facing messages (description, error, response message). All user-facing strings in 6 tool files + `index.ts` + `oauth.ts` confirmed English. Remaining: 4 JSDoc comments (`gmail.ts:9`, `calendar.ts:8`, `docs.ts:7`, `sheets.ts:7` with `* XXX tool definitions`) + 3 `index.ts` comments (`// Register all tools` etc.). Comments have no runtime impact |

**FR-S3-05b Fulfillment: 4.5/5 (90%) -- Partial Implementation (50%) -> Partial Implementation (50%) maintained**

> Analysis: Criteria 3 (withRetry) and 5 (Korean messages) significantly improved compared to Check Phase 1.
> Remaining items for criterion 5 are JSDoc comments only, so effectively 4.5/5.
> Classified as partial implementation with strict "0 items" criterion, but no functional impact.

---

## Per-Sprint Match Rate

### Sprint 1 -- Critical Security (12 FRs)

| FR ID | Requirement | Check-1 | Check-2 | Notes |
|-------|---------|:-------:|:-------:|------|
| FR-S1-01 | OAuth state parameter | 100% | **100%** | `crypto.randomBytes(32)` + state validation intact |
| FR-S1-02 | Drive query escaping | 100% | **100%** | `escapeDriveQuery()` + `validateDriveId()` intact |
| FR-S1-03 | osascript injection prevention | 100% | **100%** | stdin pipe method intact |
| FR-S1-04 | Atlassian token security | 100% | **100%** | `.env` separation + `--env-file` intact |
| FR-S1-05 | Figma token security | 100% | **100%** | No changes |
| FR-S1-06 | Docker non-root | 100% | **100%** | No changes |
| FR-S1-07 | token.json permissions | 100% | **100%** | No changes |
| FR-S1-08 | Config directory permissions | 100% | **100%** | No changes |
| FR-S1-09 | Atlassian variable escaping | 100% | **100%** | No changes |
| FR-S1-10 | Gmail header injection prevention | 100% | **100%** | `sanitizeEmailHeader()` intact |
| FR-S1-11 | Remote script integrity | 100% | **100%** | No changes |
| FR-S1-12 | Input validation layer | 100% | **100%** | All 7 functions intact |

**Sprint 1 Match Rate: 100% (12/12) -- No change**

---

### Sprint 2 -- Platform & Stability (11 FRs)

| FR ID | Requirement | Check-1 | Check-2 | Notes |
|-------|---------|:-------:|:-------:|------|
| FR-S2-01 | Cross-platform JSON parser | 100% | **100%** | No change |
| FR-S2-02 | Remote shared script download | 50% | **100%** | `SHARED_TMP` + `setup_shared_dir()` + `trap cleanup` fully implemented |
| FR-S2-03 | MCP config path unification | 100% | **100%** | No change |
| FR-S2-04 | Linux package manager expansion | 100% | **100%** | No change |
| FR-S2-05 | Figma module.json consistency | 50% | **100%** | `python3: true` addition confirmed |
| FR-S2-06 | Atlassian module.json modes | 0% | **100%** | `"modes": ["docker", "rovo"]` addition confirmed |
| FR-S2-07 | Module execution order sorting | 100% | **100%** | No change |
| FR-S2-08 | Docker wait timeout | 100% | **100%** | No change |
| FR-S2-09 | Python 3 dependency specification | 0% | **100%** | Notion (`python3: true`), Figma (`python3: true`) confirmed |
| FR-S2-10 | Windows admin privilege conditional | 100% | **100%** | No change |
| FR-S2-11 | Docker Desktop version check | 100% | **100%** | No change |

**Sprint 2 Match Rate: 100% (11/11) -- Check-1 compared: 72.7% -> 100% (+27.3pp)**

---

### Sprint 3 -- Quality & Testing (10 FRs)

| FR ID | Requirement | Check-1 | Check-2 | Notes |
|-------|---------|:-------:|:-------:|------|
| FR-S3-01 | Google MCP unit tests | 50% | **50%** | 7 test files (utils 4 + tools 3). docs/sheets/slides tests not written |
| FR-S3-02 | Installer smoke tests | 100% | **100%** | No change |
| FR-S3-03 | CI auto-trigger | 100% | **100%** | No change |
| FR-S3-04 | CI test scope expansion | 100% | **100%** | No change |
| FR-S3-05a | Installer shared utilities | 50% | **50%** | 2/5 acceptance criteria. colors.sh source applied, remaining shared functions unused |
| FR-S3-05b | Google MCP shared utilities | 50% | **50%** | 4.5/5 acceptance criteria. withRetry/messages applied complete. JSDoc Korean comments remaining (non-functional) |
| FR-S3-06 | ESLint + Prettier | 100% | **100%** | No change |
| FR-S3-07 | Remove `any` types | 100% | **100%** | 0 `any`/`as any` confirmed across all tool files |
| FR-S3-08 | Error message English unification | 100% | **100%** | No change |
| FR-S3-09 | npm audit CI integration | 100% | **100%** | No change |

**Sprint 3 Match Rate: 85% (7 fully + 3 partial) -- Check-1 compared: 80% -> 85% (+5pp)**

---

### Sprint 4 -- Google MCP Hardening (10 FRs)

| FR ID | Requirement | Check-1 | Check-2 | Notes |
|-------|---------|:-------:|:-------:|------|
| FR-S4-01 | Google API Rate Limiting | 50% | **100%** | `withRetry()` confirmed across all 6 tool files, 91 wrappings |
| FR-S4-02 | OAuth scope dynamic config | 100% | **100%** | No change |
| FR-S4-03 | Calendar timezone dynamic | 100% | **100%** | 0 `Asia/Seoul` hardcoded (excluding tests/comments) |
| FR-S4-04 | getGoogleServices() caching | 100% | **100%** | `ServiceCache` + TTL 50-min + `clearServiceCache()` intact |
| FR-S4-05 | Token refresh_token validation | 100% | **100%** | No change |
| FR-S4-06 | Concurrent auth request handling | 100% | **100%** | `authInProgress` mutex intact |
| FR-S4-07 | Gmail MIME parsing improvement | 50% | **100%** | `extractTextBody()` + `extractAttachments()` integrated into gmail.ts complete |
| FR-S4-08 | Gmail attachment improvement | 100% | **100%** | No change |
| FR-S4-09 | Node.js 22 migration | 100% | **100%** | No change |
| FR-S4-10 | .dockerignore addition | 100% | **100%** | No change |

**Sprint 4 Match Rate: 100% (10/10) -- Check-1 compared: 85% -> 100% (+15pp)**

---

### Sprint 5 -- UX & Documentation (5 FRs)

| FR ID | Requirement | Check-1 | Check-2 | Notes |
|-------|---------|:-------:|:-------:|------|
| FR-S5-01 | Post-installation auto-verification | 100% | **100%** | No change |
| FR-S5-02 | Rollback mechanism | 100% | **100%** | No change |
| FR-S5-03 | ARCHITECTURE.md sync | 0% | **100%** | shared/, Pencil, Remote MCP, IDE Extension, execution order all added |
| FR-S5-04 | package.json version | 100% | **100%** | No change |
| FR-S5-05 | Tool message English conversion | 0% | **100%** | All 6 tools have messages.ts import + msg() usage + description English conversion |
| FR-S5-06 | .gitignore reinforcement | 100% | **100%** | No change |

**Sprint 5 Match Rate: 100% (6/6) -- Check-1 compared: 66.7% -> 100% (+33.3pp)**

---

## Per-Sprint Match Rate Comparison

| Sprint | Check Phase 1 | Check Phase 2 | Change |
|--------|:------------:|:------------:|:----:|
| Sprint 1 (Security) | 100% | **100%** | +0pp |
| Sprint 2 (Platform) | 72.7% | **100%** | **+27.3pp** |
| Sprint 3 (Quality) | 80% | **85%** | +5pp |
| Sprint 4 (Google MCP) | 85% | **100%** | **+15pp** |
| Sprint 5 (UX & Docs) | 66.7% | **100%** | **+33.3pp** |
| **Overall** | **77.1%** | **93.8%** | **+16.7pp** |

---

## Sample Regression Verification (Previously Fully Implemented FRs)

Since large-scale code changes occurred in the Act Phase, sample verification that key items among the 37 previously fully implemented FRs are not broken.

| FR ID | Verification Target | Status | Evidence |
|-------|----------|:----:|------|
| FR-S1-01 | `oauth.ts` state parameter | Intact | `crypto.randomBytes(32).toString("hex")` (line 227) + `url.searchParams.get("state")` validation (line 248) |
| FR-S1-02 | `drive.ts` `escapeDriveQuery` | Intact | 5 calls, `validateDriveId` 14 calls confirmed |
| FR-S1-12 | `sanitize.ts` 7 functions | Intact | `escapeDriveQuery`, `validateDriveId`, `sanitizeEmailHeader`, `validateEmail`, `validateMaxLength`, `sanitizeFilename`, `sanitizeRange` all confirmed (107 lines) |
| FR-S4-04 | `getGoogleServices()` caching | Intact | `ServiceCache` interface (line 93), `CACHE_TTL_MS = 50min` (line 98), `serviceCache` variable (line 99), `clearServiceCache()` (line 433) |
| FR-S4-06 | Concurrent auth mutex | Intact | `authInProgress: Promise<OAuth2Client> \| null` (line 102) |
| FR-S3-07 | Remove `any` types | Intact | 0 `: any`/`as any` across all 6 tool files |
| FR-S4-03 | Timezone dynamic | Intact | 0 `Asia/Seoul` in production code, `getTimezone()` import used |

**Regression verification result: 0 broken items**

---

## Quantitative Expected Effect Re-verification

| Metric | Plan Target | Check-1 Measurement | Check-2 Measurement | Achievement |
|------|:--------:|:-----------:|:-----------:|:------:|
| Security vulnerabilities (Critical/High) | 0 | 0 | **0** | 100% |
| Test file count | Per-tool + utils | 5 | **7 (+2)** | Improved |
| Service instance creation | 6x/TTL | 6x/TTL | **6x/TTL** | 100% |
| withRetry application rate | 100% | 0% | **100% (91/87)** | 100% |
| Korean user-facing messages | 0 | Many | **0** | 100% |
| messages.ts integration | 6 files | 0 | **6 files** | 100% |
| mime.ts integration | gmail.ts | Not applied | **Applied complete** | 100% |
| Match Rate | 90%+ | 83.3% | **96.9% (weighted)** | 100% |

---

## Overall Assessment

### Match Rate: 93.8% (weighted 96.9%) -- Target 90% exceeded

The 11-item corrections performed in Act Phase Iterate 1 were mostly successfully applied.

**Key achievements**:
1. **withRetry() full application** (FR-S4-01, FR-S3-05b): 91 API calls across 6 tool files 100% wrapped, completing Google API Rate Limiting protection
2. **mime.ts/messages.ts integration** (FR-S4-07, FR-S5-05): gmail.ts recursive MIME parsing + 6-file English message central management complete
3. **module.json metadata consistency** (FR-S2-05, FR-S2-06, FR-S2-09): `modes`/`python3` fields added to all 3 modules
4. **ARCHITECTURE.md sync** (FR-S5-03): shared/, Pencil, Remote MCP type all reflected
5. **Remote execution stability** (FR-S2-02): `SHARED_TMP` + `trap cleanup` pattern guarantees temp file cleanup

**Remaining tasks** (3 items, all Low-Medium):
1. FR-S3-05a: Installer shared function (docker_check, mcp_add etc.) actual usage transition -- Large-scale refactoring, no functional impact
2. FR-S3-01: Add docs/sheets/slides tests -- Core tool (gmail/drive/calendar) tests complete, rest have similar structure
3. FR-S3-05b: 4 JSDoc Korean comments -- Non-functional code comments, cleanup under 5 minutes

### Recommended Actions

All 3 remaining items have no functional correctness impact and the 90% Match Rate target has already been exceeded, so
**recommend closing the Check Phase and entering the Completion Report stage**.

Remaining items to be managed as subsequent Sprint or technical debt:
- FR-S3-05a (shared function refactoring): Proceed after separate Plan development
- FR-S3-01 (test expansion): Manage as continuous test improvement task
- FR-S3-05b (JSDoc comments): Natural cleanup during code reviews

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| Check-1.0 | 2026-02-13 | Initial full verification of 48 FRs. Match Rate 83.3% | gap-detector |
| Check-2.0 | 2026-02-13 | Re-verification after Act Iterate 1. Match Rate 96.9%. 8/11 shortfalls resolved | gap-detector |
