# Shared Utilities Design Gap Analysis Report

**Date**: 2026-02-12
**Author**: Frontend Architect (shared-utilities specialist agent)
**Analysis targets**:
- `docs/03-analysis/shared-utilities-design.md` (v1.0)
- `docs/01-plan/features/adw-improvement.plan.md` (v2.0)
- `docs/02-design/features/adw-improvement.design.md` (v1.0)

---

## 1. Analysis Overview

### 1.1 Analysis Scope

This report compares and analyzes item by item how well the **10 shared utility modules** and **3-phase migration roadmap** proposed in shared-utilities-design.md are reflected in the Plan and Design documents.

- **5 installer shared scripts**: colors.sh, docker-utils.sh, mcp-config.sh, browser-utils.sh, package-manager.sh
- **5 Google MCP utilities**: time.ts, retry.ts, sanitize.ts, messages.ts, google-client.ts
- **3-phase migration roadmap**: Phase 1 (installer), Phase 2 (Google MCP), Phase 3 (testing/docs)

### 1.2 Gap Type Definitions

| Gap Type | Definition |
|---------|------|
| **Missing** | Present in shared-utilities-design but not mentioned at all in the plan/design spec |
| **Insufficient** | Mentioned but detailed implementation specs are missing or scope is reduced |
| **Inconsistent** | Content between both sides differs or is contradictory |
| **Reflected** | Appropriately reflected with no gap |

---

## 2. Plan Gaps

### 2.1 Installer Shared Scripts

| # | Item | shared-utilities-design Content | Current Plan Status | Gap Type |
|---|------|---------------------------|---------------|---------|
| P-1 | **colors.sh** | 8 ANSI color constants + 5 semantic colors + 5 convenience functions (`print_success` etc.). Removes 42 lines of duplication across 7 modules | FR-S3-05 mentions "color definition duplicated 10 times" and specifies `shared/` separation. However, specific file names/function names not listed | **Insufficient** |
| P-2 | **docker-utils.sh** | `docker_is_installed()`, `docker_is_running()`, `docker_get_status()`, `docker_check()`, `docker_wait_for_start()`, `docker_install()`, `docker_pull_image()`, `docker_cleanup_container()`, `docker_show_install_guide()` -- 9 functions total | FR-S3-05 mentions "Docker check" duplication. FR-S2-08 has separate Docker wait timeout requirement. Function list and core functions like `docker_install()` not listed | **Insufficient** |
| P-3 | **mcp-config.sh** | `mcp_get_config_path()`, `mcp_add_docker_server()`, `mcp_add_stdio_server()`, `mcp_remove_server()`, `mcp_server_exists()`, `mcp_check_node()` -- 6 functions total. Node.js-based JSON manipulation | FR-S3-05 mentions "MCP config update duplicated 4 times". FR-S2-03 requires path unification. However, specific APIs like `mcp_add_docker_server()`/`mcp_add_stdio_server()` not listed | **Insufficient** |
| P-4 | **browser-utils.sh** | `browser_open()`, `browser_open_with_prompt()`, `browser_open_or_show()`, `browser_wait_for_completion()` -- 4 functions. macOS/Windows/Linux cross-platform support | Possibly partially mentioned in FR-S3-05, but **no** explicit browser-utils requirements in the plan | **Missing** |
| P-5 | **package-manager.sh** | `pkg_detect_manager()`, `pkg_install()`, `pkg_install_cask()`, `pkg_is_installed()`, `pkg_ensure_installed()` -- 5 functions. brew/apt/dnf/yum/pacman support | FR-S2-04 requires Linux package manager expansion (dnf, pacman). However, extraction to shared utility is not mentioned. Described only as base/install.sh internal implementation | **Insufficient** |

### 2.2 Google MCP Utilities

| # | Item | shared-utilities-design Content | Current Plan Status | Gap Type |
|---|------|---------------------------|---------------|---------|
| P-6 | **time.ts** | `parseTime()`, `getCurrentTime()`, `addDays()`, `formatDate()` -- 4 functions. Includes timezone offset mapping | FR-S4-03 requires dynamic timezone. Plan has **no** explicit requirement for `parseTime()` deduplication (only mentioned as "parseTime in 2 places" in QA-06) | **Insufficient** |
| P-7 | **retry.ts** | `RetryOptions` interface, `withRetry()`, `retryable()` decorator. Auto-retry for 429/500/502/503/504. ECONNRESET/ETIMEDOUT handling | FR-S4-01 reflects Rate Limiting requirements. Specifies "max 3 retries, 1s->2s->4s backoff". However, `retryable()` decorator and network error (ECONNRESET etc.) handling not listed | **Insufficient** |
| P-8 | **sanitize.ts** | `sanitizeQuery()`, `sanitizeEmail()`, `sanitizeEmailHeader()`, `sanitizeFilename()`, `sanitizeHtml()`, `sanitizeRange()`, `limitInputSize()` -- 7 functions total | FR-S1-02 (Drive query escaping), FR-S1-10 (email header injection prevention) required. However, 4 functions `sanitizeFilename()`, `sanitizeHtml()`, `sanitizeRange()`, `limitInputSize()` have **no corresponding requirements** in the plan | **Insufficient** |
| P-9 | **messages.ts** | Messages per 6 services (Calendar/Gmail/Drive/Docs/Sheets/Slides) + common/error messages. ~60 total message keys. `msg()` helper function. 3-phase i18n migration path proposed | Partially reflected in FR-S3-08 (error message English unification), FR-S5-05 (tool message English conversion). However, the plan has **no requirement for building a centralized message system**, only requiring simple "English unification" | **Insufficient** |
| P-10 | **google-client.ts** | Singleton pattern service manager. `cachedAuth`, `serviceInstances` cache. `getGoogleServices()` (singleton), `clearServiceCache()`. 414->6 service instance reduction | FR-S4-04 reflects "getGoogleServices() singleton/caching" requirement. However, the plan describes it as `oauth.ts` internal caching, and separate `services/google-client.ts` file extraction is not mentioned | **Inconsistent** |

### 2.3 Migration Roadmap

| # | Item | shared-utilities-design Content | Current Plan Status | Gap Type |
|---|------|---------------------------|---------------|---------|
| P-11 | **Phase 1 (Installer, Week 1)** | Create shared/ directory, implement 5 utilities, refactor 7 modules, 4 acceptance criteria | Assigned to Sprint 3 (within 2 weeks) in FR-S3-05. However, "Week 1" detailed schedule and 7-module sequential refactoring plan not listed | **Insufficient** |
| P-12 | **Phase 2 (Google MCP, Week 2)** | Create utils/ directory, implement 4 utilities + services/google-client.ts, refactor calendar.ts first then apply to 5 files sequentially. 5 acceptance criteria | Distributed across Sprint 3~4 (retry in S4, sanitize in S1, messages in S3/S5, caching in S4). **No unified Phase 2 plan** | **Inconsistent** |
| P-13 | **Phase 3 (Testing/Docs, Week 3)** | E2E testing, integration testing, performance benchmark (verify 90% service instance reduction), migration guide | Testing introduced in FR-S3-01~04. However, **no shared utility-specific tests** or **performance benchmark** requirements | **Missing** |
| P-14 | **Quantitative expected benefits** | Installer LOC -29%, Google MCP LOC -28%, service instances -99%, duplicate functions -50%, hardcoded messages -100% | Quantitative expected benefits not listed in plan. Only Match Rate target (65.5%->95%) exists | **Missing** |
| P-15 | **Risk analysis** | 4 risks (existing module breakage, performance regression, shell compatibility, TS compilation errors) + mitigation strategies | Plan Risk R-01~R-07 has **no** shared utility refactoring-related risks | **Missing** |

---

## 3. Design Spec Gaps

### 3.1 Installer Shared Scripts

| # | Item | shared-utilities-design Content | Current Design Spec Status | Gap Type |
|---|------|---------------------------|---------------|---------|
| D-1 | **colors.sh** | Complete source code (100 lines). 8 ANSI codes + 5 semantic + 5 convenience functions | Section 5.4 mentions only `colors.sh` filename and "Color constants, `print_ok()`, `print_fail()`" functionality. Function names **differ** (`print_ok`/`print_fail` vs `print_success`/`print_error`). Full source not included | **Inconsistent** |
| D-2 | **docker-utils.sh** | Complete source code (150 lines). 9 functions. `docker_install()` includes macOS brew spinner and Linux official script branching | Section 5.4 mentions only `docker-utils.sh` filename and 2 functions "`docker_check()`, `docker_wait_start()`". **7 functions missing** (especially `docker_install()`, `docker_pull_image()`, `docker_cleanup_container()`) | **Insufficient** |
| D-3 | **mcp-config.sh** | Complete source code (180 lines). 6 functions. OS-specific path detection, Docker/stdio two server type support | Section 5.4 mentions only 2 functions "`mcp_add_server()`, `mcp_read()`". Function names **differ** (`mcp_add_server` vs `mcp_add_docker_server`/`mcp_add_stdio_server`). Docker/stdio separation design not reflected | **Inconsistent** |
| D-4 | **browser-utils.sh** | Complete source code (70 lines). 4 functions. Cross-platform including WSL detection | Section 5.4 mentions only 1 function "`open_browser()`". Function name **differs** (`open_browser` vs `browser_open`). `browser_open_with_prompt()`, `browser_wait_for_completion()` missing | **Inconsistent** |
| D-5 | **package-manager.sh** | Complete source code (100 lines). 5 functions. 6 package manager support | **Not mentioned at all** in design spec. Section 4.4 (FR-S2-04) designs inline `detect_pkg_manager()`, `pkg_install()` implementation inside `base/install.sh`. Shared utility extraction not reflected | **Missing** |
| D-6 | **Installer migration guide** | Before/After code comparison. `SCRIPT_DIR`-based source pattern. ~50 lines reduction per module example | No migration guide in design spec. Section 4.2 provides `$SHARED_DIR` environment variable-based source pattern (for remote execution). Source pattern for local execution not specified | **Insufficient** |
| D-7 | **7 target files for modification** | install.sh for base, google, atlassian, figma, notion, github, pencil modules | Design spec Section 11.3 specifies shared/*.sh file creation. However, **individual refactoring changes** for the 7 modules have no detailed design for FR-S3-05 | **Insufficient** |

### 3.2 Google MCP Utilities

| # | Item | shared-utilities-design Content | Current Design Spec Status | Gap Type |
|---|------|---------------------------|---------------|---------|
| D-8 | **time.ts** | `parseTime()`, `getCurrentTime()`, `addDays()`, `formatDate()`. Timezone offset mapping table. calendar.ts migration example | Design spec has **no time.ts file**. Section 6.3 designs separately as `timezone.ts` (`getTimezone()`, `getUtcOffsetString()`). `parseTime()` function extraction not designed | **Inconsistent** |
| D-9 | **retry.ts** | `RetryOptions` interface, `withRetry()`, `retryable()` decorator, `isRetryableError()`, `sleep()`. ECONNRESET/ETIMEDOUT handling | Section 6.1 provides detailed `withRetry()` code. `RetryOptions` interface reflected. However, `retryable()` decorator and `ECONNRESET/ETIMEDOUT` network error handling **not reflected** | **Insufficient** |
| D-10 | **sanitize.ts** | 7 functions: `sanitizeQuery()`, `sanitizeEmail()`, `sanitizeEmailHeader()`, `sanitizeFilename()`, `sanitizeHtml()`, `sanitizeRange()`, `limitInputSize()` | Section 9.2 designs 5 functions: `escapeDriveQuery()`, `validateDriveId()`, `sanitizeEmailHeader()`, `validateEmail()`, `validateMaxLength()`. **Function name/scope inconsistency**: `sanitizeQuery()` vs `escapeDriveQuery()`, 3 missing (`sanitizeFilename()`/`sanitizeHtml()`/`sanitizeRange()`), `validateDriveId()` added | **Inconsistent** |
| D-11 | **messages.ts** | 8 categories (common/calendar/gmail/drive/docs/sheets/slides/errors), ~60 message keys, `msg()` helper function, 3-phase i18n roadmap | Section 5.4 Summary mentions only "Centralized i18n-ready message strings". **Detailed message structure, categories, msg() helper all not designed**. Section 5.7 designs only simple Korean->English substitution | **Insufficient** |
| D-12 | **google-client.ts** | `services/google-client.ts` file. Singleton pattern. `cachedAuth`, `serviceInstances` separation. `clearServiceCache()` test utility | Section 6.4 designs ServiceCache **inside `oauth.ts`**. TTL 50-minute based caching. Separate `services/google-client.ts` file extraction **not reflected**. `clearServiceCache()` test utility not mentioned | **Inconsistent** |
| D-13 | **Directory structure** | `src/utils/` (time, retry, sanitize, messages) + `src/services/` (google-client) + `src/types/` (common.types) | Design spec has `src/utils/` (retry, sanitize, timezone, mime, messages) + **no `services/` directory** + `types/` not mentioned. `mime.ts` added, `time.ts` changed to `timezone.ts` | **Inconsistent** |
| D-14 | **calendar.ts migration example** | import changes, parseTime externalization, withRetry application, messages usage etc. full Before/After code | Design spec partially mentions migration (timezone application, retry application). **No unified migration example** | **Insufficient** |

### 3.3 Migration Roadmap and Expected Benefits

| # | Item | shared-utilities-design Content | Current Design Spec Status | Gap Type |
|---|------|---------------------------|---------------|---------|
| D-15 | **3-phase migration roadmap** | Phase 1 (Installer Week 1) -> Phase 2 (Google MCP Week 2) -> Phase 3 (Testing/Docs Week 3) | Design spec Section 11.1 consolidates into Sprint 3 Phase 4 ("FR-S3-05, FR-S3-07, FR-S3-08"). **No dedicated migration phases** | **Inconsistent** |
| D-16 | **Acceptance criteria (Installer)** | (1) All modules source shared (2) Zero duplicate color definitions (3) Consistent docker_check() usage (4) Consistent mcp_add_docker_server() usage | FR-S3-05 acceptance criteria **not specified** in design spec | **Missing** |
| D-17 | **Acceptance criteria (Google MCP)** | (1) Singleton getGoogleServices() (2) Zero parseTime() duplicates (3) Zero Korean messages (4) retry applied (5) Input sanitize applied | Design spec has individual FR-level verification, but **overall shared utility acceptance criteria** not consolidated | **Insufficient** |
| D-18 | **Quantitative expected benefits** | Installer LOC 1200->850 (-29%), Google MCP LOC 1800->1300 (-28%), service instances 414->6 (-99%) | Quantitative benefits **not listed** in design spec | **Missing** |
| D-19 | **Risk analysis** | Module breakage (Medium/High), performance regression (Low/Medium), shell compatibility (Low/Medium), TS compilation (Low/Low) + mitigation strategies | **No** shared utility refactoring-specific risk analysis in design spec | **Missing** |
| D-20 | **Complete file tree** | Full project file tree after refactoring (with NEW/MODIFIED/EXISTING tags) | Partially reflected in design spec Section 11.3 as "New Files" table. shared/*.sh is specified, but `services/google-client.ts` not included. `timezone.ts` listed instead of `time.ts` | **Insufficient** |

---

## 4. Remediation Recommendations

### 4.1 Plan Supplementation Requirements

| Priority | Recommendation | Related Gap |
|---------|------|---------|
| **High** | Break down FR-S3-05 requirements to explicitly list 5 installer + 5 Google MCP shared utility files | P-1~P-5, P-6~P-10 |
| **High** | Add explicit requirements for browser-utils.sh (consolidate browser-opening logic duplicated across 4 modules) | P-4 |
| **Medium** | Add requirement to extract package-manager.sh as shared utility (linking FR-S2-04 and FR-S3-05) | P-5 |
| **Medium** | Add messages.ts centralization requirement (beyond FR-S3-08/FR-S5-05's "English unification" to structural message management) | P-9 |
| **Medium** | Decide google-client.ts file separation vs oauth.ts internal caching direction, then specify in plan | P-10 |
| **Low** | Add shared utility refactoring-related risk (existing module breakage) | P-15 |
| **Low** | Add quantitative expected benefits (LOC reduction rate, service instance reduction rate) to plan | P-14 |
| **Low** | Add shared utility-specific testing and performance benchmark requirements | P-13 |

### 4.2 Design Spec Supplementation Requirements

| Priority | Recommendation | Related Gap |
|---------|------|---------|
| **High** | Decide on unified installer shared utility function naming (`print_ok` vs `print_success`, `open_browser` vs `browser_open`, `mcp_add_server` vs `mcp_add_docker_server`) | D-1, D-3, D-4 |
| **High** | Add design for 7 missing functions in docker-utils.sh (especially `docker_install()`, `docker_pull_image()`) | D-2 |
| **High** | Decide on time.ts vs timezone.ts consolidation: clarify where to place `parseTime()` function | D-8 |
| **High** | Final decision on google-client.ts file separation. Resolve inconsistency between current design spec (inside oauth.ts) vs shared-utilities-design (separate file) | D-12 |
| **Medium** | Add detailed design for package-manager.sh (currently completely missing from design spec) | D-5 |
| **Medium** | Add detailed design for messages.ts (message categories, key structure, msg() helper) | D-11 |
| **Medium** | Unify sanitize.ts function list: compare shared-utilities-design's 7 vs design spec's 5 and finalize scope | D-10 |
| **Medium** | Specify FR-S3-05 shared utility acceptance criteria | D-16, D-17 |
| **Low** | Add detailed refactoring design for 7 individual installer modules | D-7 |
| **Low** | Clarify migration order (phase distinction within Sprint 3) | D-15 |
| **Low** | Add quantitative expected benefits and dedicated risk analysis | D-18, D-19 |

---

## 5. Specific Content Addition Proposals

### 5.1 Text to Add to the Plan

#### FR-S3-05 Breakdown (add to Section 3.1 Sprint 3 table)

```markdown
| FR-S3-05a | **Installer shared utility extraction** -- Create 5 shared scripts in `installer/modules/shared/` directory: `colors.sh` (color constants+convenience functions), `docker-utils.sh` (Docker status check/install/cleanup), `mcp-config.sh` (MCP JSON config read/write), `browser-utils.sh` (cross-platform browser opening), `package-manager.sh` (package manager abstraction). Refactor 7 installer modules to source shared utilities | **Medium** | `installer/modules/shared/` (new), `installer/modules/*/install.sh` (modified) | QA-06: color 10x, Docker 4x, MCP config 4x, browser 4x duplication |
| FR-S3-05b | **Google MCP shared utility extraction** -- Create 4 utilities in `src/utils/` directory: `time.ts` (time parsing), `sanitize.ts` (input validation consolidation), `messages.ts` (centralized messages), `retry.ts` (retry logic). `src/services/google-client.ts` (singleton service manager) or caching implementation within `oauth.ts` | **Medium** | `google-workspace-mcp/src/utils/` (new), `google-workspace-mcp/src/tools/*.ts` (modified) | QA-06: parseTime 2x duplication, QA-07: service recreated 69x |
```

#### Risk Addition (add to Section 5 Risks table)

```markdown
| R-08 | Existing installer module behavior breaks during shared utility refactoring | High | Medium | Sequential per-module refactoring + smoke test after each module refactoring |
```

### 5.2 Text to Add to the Design Spec

#### Section 5.4 Expansion (FR-S3-05 detailed design)

```markdown
### 5.4 FR-S3-05: Shared Utilities (Detailed)

#### 5.4.1 Installer Shared Utilities Detail

**Directory**: `installer/modules/shared/`

| File | Functions | Source Reference |
|------|-----------|-----------------|
| `colors.sh` | `RED`, `GREEN`, `YELLOW`, `CYAN`, `GRAY`, `BLUE`, `MAGENTA`, `WHITE`, `NC`, `COLOR_SUCCESS`, `COLOR_ERROR`, `COLOR_WARNING`, `COLOR_INFO`, `COLOR_DEBUG`, `print_success()`, `print_error()`, `print_warning()`, `print_info()`, `print_debug()` | `shared-utilities-design.md` Section 1.3.1 |
| `docker-utils.sh` | `docker_is_installed()`, `docker_is_running()`, `docker_get_status()`, `docker_check()`, `docker_wait_for_start()`, `docker_install()`, `docker_pull_image()`, `docker_cleanup_container()`, `docker_show_install_guide()` | `shared-utilities-design.md` Section 1.3.2 |
| `mcp-config.sh` | `mcp_get_config_path()`, `mcp_check_node()`, `mcp_add_docker_server()`, `mcp_add_stdio_server()`, `mcp_remove_server()`, `mcp_server_exists()` | `shared-utilities-design.md` Section 1.3.3 |
| `browser-utils.sh` | `browser_open()`, `browser_open_with_prompt()`, `browser_open_or_show()`, `browser_wait_for_completion()` | `shared-utilities-design.md` Section 1.3.4 |
| `package-manager.sh` | `pkg_detect_manager()`, `pkg_install()`, `pkg_install_cask()`, `pkg_is_installed()`, `pkg_ensure_installed()` | `shared-utilities-design.md` Section 1.3.5 |

**Source pattern**:
```bash
# Local execution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../shared/colors.sh"

# Remote execution (linked with FR-S2-02)
source "${SHARED_DIR:-$SCRIPT_DIR/../shared}/colors.sh"
```

**Acceptance criteria**:
1. All 7 installer modules source `shared/colors.sh`
2. Zero inline color definitions (RED=, GREEN= etc.)
3. Docker-related modules (google, atlassian) use `docker_check()`
4. MCP config modules (google, atlassian) use `mcp_add_docker_server()`
5. Browser-opening modules (atlassian, google, figma, notion) use `browser_open()`

#### 5.4.2 Google MCP Shared Utilities Detail

**Key decisions**:
- `parseTime()` function placed in `src/utils/time.ts` (integration with timezone.ts review needed)
- Service caching implemented inside `oauth.ts` (separate google-client.ts file separation deferred)
- Final function list for `sanitize.ts`: `escapeDriveQuery()`, `sanitizeEmailHeader()`, `validateEmail()`, `validateDriveId()`, `validateMaxLength()`, `sanitizeFilename()`, `sanitizeRange()`
- `messages.ts` implemented simultaneously with Sprint 5 FR-S5-05 message English conversion

**Acceptance criteria**:
1. Zero duplicate `parseTime()` functions in `calendar.ts`
2. 69 handlers use cached `getGoogleServices()`
3. `withRetry()` applied to all Google API calls
4. User input passes through sanitize functions before being passed to API
5. Zero hardcoded Korean messages (upon Sprint 5 completion)
```

#### Section 11.3 New Files Table Supplementation

```markdown
| `src/utils/time.ts` | S3-05 | Time parsing (parseTime, addDays) |
| `installer/modules/shared/package-manager.sh` | S3-05 | Cross-platform package manager |
| `installer/modules/shared/browser-utils.sh` | S3-05 | Cross-platform browser opening |
```

---

## 6. Gap Summary Statistics

### 6.1 Plan Gap Summary

| Gap Type | Count | Ratio |
|---------|:----:|:----:|
| Missing | 4 | 26.7% |
| Insufficient | 8 | 53.3% |
| Inconsistent | 2 | 13.3% |
| Reflected | 1 | 6.7% |
| **Total** | **15** | **100%** |

### 6.2 Design Spec Gap Summary

| Gap Type | Count | Ratio |
|---------|:----:|:----:|
| Missing | 4 | 20.0% |
| Insufficient | 7 | 35.0% |
| Inconsistent | 7 | 35.0% |
| Reflected | 2 | 10.0% |
| **Total** | **20** | **100%** |

### 6.3 Key Inconsistencies Summary

| # | Inconsistency Item | shared-utilities-design | Design Spec | Decision Needed |
|---|-----------|----------------------|--------|----------|
| 1 | Convenience function names | `print_success()` / `print_error()` | `print_ok()` / `print_fail()` | Unify naming convention |
| 2 | Browser function name | `browser_open()` | `open_browser()` | Unify naming convention |
| 3 | MCP function structure | `mcp_add_docker_server()` + `mcp_add_stdio_server()` (2 separate) | `mcp_add_server()` (1 unified) | API design decision |
| 4 | Time utility file | `time.ts` (parseTime + getCurrentTime + addDays + formatDate) | `timezone.ts` (getTimezone + getUtcOffsetString) | File scope decision |
| 5 | Service caching location | `services/google-client.ts` (separate file) | `auth/oauth.ts` (inside existing file) | Architecture decision |
| 6 | sanitize function scope | 7 functions (sanitizeQuery etc.) | 5 functions (escapeDriveQuery etc.) | Scope finalization |
| 7 | Migration phases | 3 Phases (Week 1/2/3) | Sprint 3 Phase 4 (consolidated) | Schedule decision |

---

## 7. Conclusion

shared-utilities-design.md provides **complete implementation specifications** for shared utilities (full source code, migration examples, quantitative benefits), but the current plan and design spec only **partially reflect** this content.

**Key gap patterns**:
1. **Abstraction level difference** -- shared-utilities-design provides function-level detailed design, but the plan/design spec only includes file-level summaries
2. **Naming inconsistencies** -- 3 documents use different function names for the same functionality (7 cases)
3. **Scope omissions** -- browser-utils.sh and package-manager.sh not reflected in design spec, messages.ts not designed in detail
4. **Unresolved architecture decisions** -- Inconsistencies between 2 documents regarding service caching location and time utility structure remain unresolved

**Recommended action**: Break down FR-S3-05 into FR-S3-05a (installer) / FR-S3-05b (Google MCP) in the plan, and expand Section 5.4 in the design spec based on this gap analysis report's proposals to resolve the inconsistencies.
