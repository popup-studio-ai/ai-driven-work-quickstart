# Requirements Traceability Gap Analysis Report

> **Summary**: Gap identification and remediation recommendations between traceability matrix (48 issues / 44 FRs) and plan/design documents
>
> **Project**: popup-claude (AI-Driven Work Installer)
> **Author**: Gap Analyst Agent
> **Created**: 2026-02-12
> **Status**: Draft
> **References**:
> - `docs/03-analysis/adw-requirements-traceability-matrix.md` (Traceability Matrix)
> - `docs/01-plan/features/adw-improvement.plan.md` (Plan)
> - `docs/02-design/features/adw-improvement.design.md` (Design)

---

## 1. Analysis Overview

### 1.1 Analysis Purpose

Verify whether the 44 functional requirements, 8 potentially missing requirements, 7 implicit requirements, and 8 cross-cutting concerns identified in the traceability matrix are fully reflected in the plan and design documents, and derive items requiring remediation.

### 1.2 Analysis Scope

| Item | Traceability Matrix | Plan | Design |
|------|:----------:|:-----:|:-----:|
| Functional Requirements (FR) | 44 | 44 | 44 |
| Analysis Issue Coverage | 43/48 (89.6%) | 43/48 (89.6%) | 43/48 (89.6%) |
| Potentially Missing Requirements | 8 identified | Partially reflected | Partially reflected |
| Implicit Requirements | 7 identified | Not reflected | Partially reflected |
| Cross-Cutting Concerns | 8 identified | Partially reflected | Partially reflected |
| Critical Paths | 6 paths | Reflected | Reflected |
| Parallel Execution Groups | 5 sprints | Reflected | Reflected |

### 1.3 Key Conclusions

- **44 base FRs**: 100% reflected in both plan and design (no gaps)
- **8 potentially missing items**: 2 reflected, 6 not reflected (remediation needed)
- **7 implicit requirements**: 3 partially reflected, 4 not reflected (remediation needed)
- **8 cross-cutting concerns**: 5 reflected, 3 not reflected (remediation needed)
- **89.6% coverage missing 5 items**: Out of Scope validity confirmed

---

## 2. Missing Requirements Analysis

Analysis of the 8 potentially missing requirements identified in Traceability Matrix Section 8.1 for plan/design reflection status.

| # | ID | Requirement Name | Traceability Matrix Description | Plan Reflected | Design Reflected | Addition Needed |
|:-:|:---|:---------|:---------------|:---------:|:---------:|:----------:|
| 1 | FR-S3-09 (proposed) | npm audit / dependency vulnerability scan | Additional finding "npm audit not applied" from Appendix A.1 | **Not reflected** | **Not reflected** | **Yes** (High) |
| 2 | FR-S3-07 expansion | Additional `any` type locations | `sheets.ts:18,341`, `calendar.ts:288`, `slides.ts:135,156`, `docs.ts:236` | **Not reflected** (only index.ts:32 listed) | **Reflected** (all 7 locations listed in design 5.6) | Plan only |
| 3 | FR-S3-10 (proposed) | Security logging | Additional finding "security logging not implemented" from Appendix A.1 | **Not reflected** | **Not reflected** | **Yes** (Medium) |
| 4 | FR-S1-11 (proposed) | Input validation layer | "Input validation layer absence" noted in Appendix A.1 | **Not reflected** (no explicit FR) | **Reflected** (5 `sanitize.ts` functions designed in design 9.2) | Plan only |
| 5 | FR-S2-11 (proposed) | Docker Desktop version check | OS-06 mapped to FR-S2-04 in Section 8.2, but FR-S2-04 description only mentions package managers | **Not reflected** (FR-S2-04 only describes apt/dnf/pacman) | **Not reflected** | **Yes** (Medium) |
| 6 | - | OS-05 documentation handling | WSL restart guide already implemented, handled as documentation | **Reflected** (mapping table states "handled as documentation") | **Reflected** (included in Sprint 5 UX) | No |
| 7 | - | Pencil module security/platform fixes | Pencil module exists in codebase but not mentioned in requirements | **Not reflected** | **Not reflected** | Low (separate review) |
| 8 | - | Structured logging | QA-05 handled as Out of Scope | **Reflected** (Out of Scope explicitly stated) | **Not reflected** (no mention) | No (Out of Scope maintained valid) |

### 2.1 Key Findings

1. **FR-S3-07 scope mismatch**: Plan lists only `index.ts:32`, but design includes all 7 locations (index.ts, sheets.ts, slides.ts, calendar.ts, docs.ts). **Plan has narrower scope than design**, plan update needed.

2. **Input validation layer**: No separate FR in plan, but design has `sanitize.ts` designed with 5 functions (escapeDriveQuery, validateDriveId, sanitizeEmailHeader, validateEmail, validateMaxLength). Distributed across FR-S1-02 and FR-S1-10, but **recommended to be explicitly stated as a cross-cutting concern**.

3. **npm audit**: CI pipeline (FR-S3-03) has no `npm audit` step. High priority from security perspective.

---

## 3. Implicit Requirements Analysis

Reflection status of 7 implicit requirements identified in Traceability Matrix Section 8.2.

| # | Item | Description | Related Sprint | Plan Reflected | Design Reflected |
|:-:|:-----|:----|:----------:|:---------:|:---------:|
| 1 | Backwards compatibility testing | MCP path change (FR-S2-03), OAuth state (FR-S1-01), parse_json (FR-S2-01) migration path verification | S1, S2 | **Partially reflected** (listed as risks R-01, R-02, R-04) | **Reflected** (migration script designed for FR-S2-03, stateless fallback for FR-S1-01) |
| 2 | Error handling consistency | Unified error handling pattern for Rate limiting (FR-S4-01) + Token validation (FR-S4-05) | S4 | **Not reflected** | **Partially reflected** (error handling pattern exists in retry.ts but no integration guide) |
| 3 | Temporary file cleanup | Guaranteed cleanup after temp dir download in FR-S2-02 | S2 | **Not reflected** (trap handler not mentioned) | **Not reflected** (only temp dir creation designed, cleanup not mentioned) |
| 4 | CI secret management | Google API credential mocking/stubbing | S3 | **Not reflected** | **Reflected** (`vi.mock("../../auth/oauth.js")` pattern in design 5.1) |
| 5 | Migration documentation | User guide for `~/.mcp.json` legacy path users | S2, S5 | **Not reflected** (only risk R-01 mentioned) | **Not reflected** (migration code only, no user documentation) |
| 6 | TypeScript strict mode preservation | Prevent strict:true regression when removing `any` | S3 | **Not reflected** | **Not reflected** (replacement types specified but strict compatibility test not mentioned) |
| 7 | Docker build cache invalidation | Impact of base image change + user addition + .dockerignore on layer caching | S1, S4 | **Not reflected** | **Partially reflected** (cache consideration exists in Dockerfile multi-stage design but no explicit guide) |

### 3.1 Key Findings

1. **Temporary file cleanup (item 3)**: Both plan and design omit FR-S2-02's temp dir cleanup. Shell script `trap` handler should guarantee cleanup even on abnormal exit. **Design remediation required**.

2. **Migration documentation (item 5)**: MCP path change (FR-S2-03) identified as High priority risk (R-01), but specific user migration guide creation is missing from plan/design. **Recommended to include in FR-S5-03 scope**.

3. **Error handling consistency (item 2)**: `withRetry()` function designed, but user-facing error message format after retry failure is not unified. Recommend adding error message format standard to Sprint 4 design.

---

## 4. Cross-Cutting Concerns Analysis

Reflection status of Traceability Matrix Section 7 (Target File Impact Matrix) + Section 8.3 (Cross-Cutting Concerns).

### 4.1 High-Impact File Coordination Analysis

| File | Related Requirement Count | Design Coordination Needed | Plan Status | Design Status |
|:-----|:--------------:|:------------:|:----------:|:----------:|
| `oauth.ts` | **7** (S1-01, S1-07, S1-08, S4-02, S4-04, S4-05, S4-06) | **Critical** | **Reflected** (per-sprint WP separation in Section 8.1) | **Reflected** (sequential design in Section 3.1, 6.2-6.5) |
| `install.sh` | **6** (S1-03, S2-01, S2-02, S2-07, S5-01, S5-02) | **Critical** | **Reflected** (per-sprint WP separation in Section 8.1) | **Reflected** (Section 3.3, 4.1-4.3, 7.1-7.2) |
| `gmail.ts` | 3 (S1-10, S4-07, S4-08) | High | Reflected | Reflected |
| `atlassian/install.sh` | 3 (S1-04, S1-09, S2-03) | High | Reflected | Reflected |
| `figma/module.json` | 3 (S1-05, S2-05, S2-09) | Medium | Reflected | Reflected |
| `Dockerfile` | 2 (S1-06, S4-09) | Medium | Reflected | **Reflected** (integrated Dockerfile design in Section 8.1) |

### 4.2 Cross-Cutting Concern Reflection Status

| # | Concern | Affected Requirements | Plan Reflected | Design Reflected | Gap |
|:-:|:------|:------------|:---------:|:---------:|:--:|
| 1 | oauth.ts refactoring needed (7 FRs) | S1-01, S1-07, S1-08, S4-02, S4-04, S4-05, S4-06 | **Not reflected** (no separate refactoring FR) | **Partially reflected** (sequential design but no module split proposed) | **Gap** |
| 2 | install.sh change order coordination (6 FRs) | S1-03, S2-01, S2-02, S2-07, S5-01, S5-02 | **Reflected** (S1-03 and S2-01 integration explicitly stated) | **Reflected** (Section 3.3 + 4.1 integration) | OK |
| 3 | Environment variable proliferation management | S1-04, S4-02, S4-03, S1-05 | **Not reflected** (.env.example not mentioned) | **Not reflected** (.env.example template not designed) | **Gap** |
| 4 | module.json schema standardization | S2-05, S2-06, S2-09 | **Not reflected** (only individual FR-level modifications) | **Not reflected** (no schema definition) | **Gap** |
| 5 | Test infrastructure architecture | S3-01, S3-02, S3-03, S3-04, S3-06 | **Reflected** (S3 WP1~WP3 composition) | **Reflected** (Section 5 entire, separate test-strategy.md reference) | OK |
| 6 | Docker security hardening batch | S1-06, S4-09, S4-10 | **Partially reflected** (split between S1 and S4) | **Reflected** (integrated Dockerfile in Section 8.1) | OK |
| 7 | i18n direction decision | S3-08, S5-05 | **Not reflected** (only English unification stated, i18n key approach undecided) | **Partially reflected** (messages.ts centralization mentioned but no i18n framework decided) | Minor Gap |
| 8 | Shell script quality baseline | S1-03, S1-09, S2-01, S2-02, S3-05 | **Not reflected** (ShellCheck CI not mentioned) | **Not reflected** (ShellCheck not mentioned) | **Gap** |

### 4.3 Key Findings

1. **oauth.ts refactoring**: 7 requirements modify the same file, but no module split design (into auth, token, cache etc.). High merge conflict and regression risk.

2. **Environment variable management**: At least 4 new environment variables (CONFLUENCE_*, JIRA_*, GOOGLE_SCOPES, TIMEZONE) added, but no `.env.example` template designed.

3. **module.json schema**: 3 FRs modify module.json, but no formal schema definition (JSON Schema etc.), risking recurrence of inconsistencies.

4. **ShellCheck CI**: Shell script changes span 5 FRs, but CI does not include ShellCheck validation. Traceability matrix recommendation not reflected in design.

---

## 5. Critical Path and Parallel Execution Analysis

### 5.1 Critical Path Reflection Status

Comparison of 6 critical paths from Traceability Matrix Section 4.1~4.2 with Plan Section 8.1.

| Critical Path | Traceability Matrix | Plan Reflected | Design Reflected | Status |
|:------------|:-----------|:---------:|:---------:|:----:|
| FR-S1-03 -> FR-S2-01 -> FR-S2-04 -> FR-S5-01 | Section 4.1 | **Reflected** (FR-S1-03 prioritized in S1 Phase1, FR-S2-01 placed in S2 Phase1) | **Reflected** (dependencies stated in Section 11.1, integrated design 3.3+4.1) | OK |
| FR-S1-01 -> FR-S4-02 | Section 4.1 | **Reflected** (FR-S1-01 in S1 WP1) | **Reflected** (dependency chain stated in Section 11.2) | OK |
| FR-S3-01 -> FR-S3-03 -> FR-S3-04 | Section 4.1 | **Reflected** (S3 WP1->WP2 order) | **Reflected** (Sprint 3 Phase order in Section 11.1) | OK |
| FR-S2-03 -> FR-S5-02 | Section 4.1 | **Reflected** | **Reflected** | OK |
| FR-S3-05 -> FR-S5-03 | Section 4.1 | **Reflected** | **Reflected** | OK |
| FR-S1-06 -> FR-S4-09 | Section 4.1 | **Reflected** | **Reflected** (integrated Dockerfile in Section 8.1) | OK |

**Conclusion**: All 6 critical paths accurately reflected in both plan and design. **No gaps**.

### 5.2 Parallel Execution Group Reflection Status

Comparison of parallel execution groups from Traceability Matrix Section 4.3 with Plan Section 8.1.

| Sprint | Traceability Matrix Parallel Groups | Plan WP Composition | Match | Differences |
|:-------:|:---------------------|:-------------|:---------:|:------|
| S1 | S1-WP1(01,08), S1-WP2(02,03,10), S1-WP3(04,05,06,07), Serial(09) | S1-WP1(01,08), S1-WP2(02,03,09,10), S1-WP3(04~07) | **Partial** | Plan S1-WP2 includes FR-S1-09 (traceability matrix classifies as Serial) |
| S2 | S2-WP1(01,10), S2-WP2(05,06), S2-WP3(02,08), Serial(03,04,07,09) | S2-WP1(01,04,10), S2-WP2(02,03,05~09) | **Partial** | Plan groups more broadly. Traceability matrix's fine-grained dependencies (S2-04->S2-01, S2-09->S2-05) not reflected |
| S3 | S3-WP1(01,02,06), S3-WP2(05), S3-WP3(07,08), Serial(03,04) | S3-WP1(01,02,06), S3-WP2(03,04), S3-WP3(05,07,08) | **Match** | Group composition identical, only numbering differs |
| S4 | S4-WP1(01,03,07), S4-WP2(02,05), S4-WP3(09,10), Serial(04,06,08) | S4-WP1(01,04~06), S4-WP2(02,03), S4-WP3(09,10) | **Partial** | Plan places stability group in S4-WP1, traceability matrix's S4-04 serial dependency (after S4-05, S4-06) not reflected |
| S5 | S5-WP1(04,05,06), S5-WP2(03), Serial(01,02) | S5-WP1(01,02), S5-WP2(03~05) | **Partial** | Plan groups 01,02 in WP1, but traceability matrix designates as Serial due to cross-sprint dependencies (S2-01, S2-03) |
| Cross-Sprint | S3 and S4 can run in parallel | **Reflected** (Section 8.1: "Sprint 4 -- Can run in parallel with Sprint 3") | **Match** | |

### 5.3 Parallel Execution Gap Details

| Gap ID | Sprint | Traceability Matrix | Plan | Impact |
|:-----:|:-------:|:-----------|:------|:-----|
| PG-01 | S1 | FR-S1-09 is Serial after FR-S1-04 | Plan includes in S1-WP2 as parallel | Low - Same file region so sequential work recommended |
| PG-02 | S2 | FR-S2-04 is Serial after FR-S2-01 | Plan places both in S2-WP1 | **Medium** - Cannot expand package manager before Linux parse_json completion |
| PG-03 | S2 | FR-S2-09 is Serial after FR-S2-05 | Plan places both in S2-WP2 | Low - Same file (figma/module.json) needs sequential modification |
| PG-04 | S4 | FR-S4-04 is Serial after FR-S4-05, FR-S4-06 | Plan places in S4-WP1 | **Medium** - Caching should be implemented after token validation + mutex design |

**Recommendation**: PG-02 and PG-04 should either specify Phase order within plan WPs or update the plan to reflect the traceability matrix's Serial designation.

---

## 6. Remediation Recommendations

### 6.1 Plan Additions

| Priority | Item | Current Status | Recommended Action |
|:-------:|:-----|:---------|:---------|
| **High** | FR-S3-07 scope expansion | Only index.ts:32 listed | Add sheets.ts, calendar.ts, slides.ts, docs.ts `any` locations (align with design) |
| **High** | FR-S3-09 (npm audit) addition | Does not exist | Create new requirement in Sprint 3 FR list: "Add `npm audit --audit-level=high` step to CI pipeline" |
| **Medium** | FR-S2-11 (Docker Desktop version check) addition | Does not exist | Create FR for Docker Desktop 4.42+ / macOS Ventura compatibility check logic for OS-06 response, or expand FR-S2-04 scope |
| **Medium** | FR-S1-11 (input validation layer) specification | Does not exist (only in design) | Add `sanitize.ts` utility creation FR as cross-cutting concern in Sprint 1 |
| **Medium** | Parallel execution group refinement | Listed at WP level | Specify PG-02 (S2-04->S2-01), PG-04 (S4-04->S4-05,S4-06) serial dependencies |
| **Low** | FR-S3-10 (security logging) review | Does not exist | Review authentication failure and input validation failure logging requirements (decide whether to transition from Out of Scope to In Scope) |
| **Low** | Pencil module security review | Does not exist | Evaluate separately whether Pencil module needs Sprint 1 level security review |

### 6.2 Design Additions

| Priority | Item | Current Status | Recommended Action |
|:-------:|:-----|:---------|:---------|
| **High** | FR-S2-02 temp file cleanup | Only temp dir creation designed | Add `trap 'rm -rf "$SHARED_TMP"' EXIT` pattern, guarantee cleanup on abnormal exit |
| **High** | oauth.ts refactoring guide | Only sequential application of 7 FRs described | Add refactoring roadmap to split oauth.ts into `auth-flow.ts`, `token-manager.ts`, `service-cache.ts` |
| **Medium** | .env.example template | Environment variables distributed across FRs | Add design for `.env.example` at project root documenting all new environment variables |
| **Medium** | module.json schema definition | Only individual modifications described | Add JSON Schema definition file (`installer/module-schema.json`) design |
| **Medium** | ShellCheck CI integration | Not mentioned | Add ShellCheck step to CI pipeline (Section 5.3) |
| **Medium** | Migration user guide | Only code designed | Add MCP path migration guide section to FR-S5-03 scope |
| **Low** | Error message format standard | Only console.warn in retry.ts | Define user-facing error message format standard (prefix, error code, resolution guide link) |
| **Low** | TypeScript strict compatibility test | Not mentioned | Add `tsc --strict --noEmit` verification step to FR-S3-07 tests |
| **Low** | Docker build cache guide | Only multi-stage described | Layer order optimization and `--mount=type=cache` usage guide |
| **Low** | i18n direction decision | English-only + messages.ts mentioned | Explicit decision on future i18n framework adoption (current: English-only, pre-apply key-based structure only) |

---

## 7. Specific Addition Content Proposals

### 7.1 Plan: FR-S3-07 Scope Expansion (Immediate Reflection)

Current plan FR-S3-07:
```
FR-S3-07 | `any` type removal — Replace `async (params: any)` at `index.ts:32` with proper types
```

Recommended revision:
```
FR-S3-07 | `any` type removal — Replace `any`/`as any` usage at `index.ts:32`, `sheets.ts:18,341`, `calendar.ts:288`,
          `slides.ts:135,156`, `docs.ts:236` with proper types
```

### 7.2 Plan: FR-S3-09 New (npm audit CI Integration)

```
| FR-S3-09 | **npm audit CI integration** — Add `npm audit --audit-level=high`
            step to CI pipeline. Build fails on High+ vulnerability discovery | **High** |
            `.github/workflows/ci.yml` | Security Architect additional finding |
```

### 7.3 Design: FR-S2-02 Temp File Cleanup Addition

Add to Section 4.2:
```bash
run_module() {
    local mod="$1"
    if [ "$USE_LOCAL" != true ]; then
        SHARED_TMP=$(mktemp -d)
        # Guarantee cleanup on any exit (normal, error, signal)
        trap 'rm -rf "$SHARED_TMP"' EXIT INT TERM
        for shared_script in oauth-helper.sh; do
            curl -sSL "$BASE_URL/modules/shared/$shared_script" \
                -o "$SHARED_TMP/$shared_script" || true
        done
        export SHARED_DIR="$SHARED_TMP"
    fi
    # ...
}
```

### 7.4 Design: .env.example Template

Add `.env.example` file design at project root:
```bash
# Google Workspace MCP Configuration
# Copy to .env and fill in values

# OAuth Scopes (comma-separated: gmail,calendar,drive,docs,sheets,slides)
# Default: all scopes enabled
# GOOGLE_SCOPES=gmail,calendar,drive

# Timezone (IANA format, e.g., America/New_York)
# Default: system timezone via Intl API
# TIMEZONE=Asia/Seoul

# Atlassian Configuration (FR-S1-04)
# CONFLUENCE_URL=https://your-domain.atlassian.net/wiki
# CONFLUENCE_USERNAME=your@email.com
# CONFLUENCE_API_TOKEN=your-token
# JIRA_URL=https://your-domain.atlassian.net
# JIRA_USERNAME=your@email.com
# JIRA_API_TOKEN=your-token
```

### 7.5 Design: CI Pipeline ShellCheck Step Addition

Add the following job to Section 5.3 CI workflow:
```yaml
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install ShellCheck
        run: sudo apt-get install -y shellcheck
      - name: Run ShellCheck
        run: |
          find installer/ -name "*.sh" -exec shellcheck -S warning {} +
```

### 7.6 Design: oauth.ts Refactoring Roadmap

Add to Section 6:
```
oauth.ts refactoring (merge conflict prevention when applying 7 FRs):

Current structure: oauth.ts (single file, ~240 lines)
  - generateAuthUrl() + callback handler
  - loadToken() + saveToken()
  - getGoogleServices()
  - config directory management

Proposed structure:
  src/auth/
    config.ts         -- CONFIG_DIR, ensureConfigDir(), SCOPES (FR-S1-08, FR-S4-02)
    token-manager.ts  -- loadToken(), saveToken(), validateRefreshToken() (FR-S1-07, FR-S4-05)
    auth-flow.ts      -- generateAuthUrl(), callback, state validation, mutex (FR-S1-01, FR-S4-06)
    service-cache.ts  -- getGoogleServices(), singleton cache with TTL (FR-S4-04)
    index.ts          -- re-export public API (backwards compatible)

Application timing: After Sprint 1 completion, before Sprint 4 start
```

---

## 8. 89.6% Coverage Missing 5 Items Analysis

Per Traceability Matrix Section 10 last line: "48 issues, 43 addressed (89.6%), 5 Out of Scope".

| # | Analysis Issue ID | Severity | Content | Out of Scope Reason | Validity |
|:-:|:----------:|:-----:|:-----|:----------------|:-----:|
| 1 | SEC-01 (partial) | Critical | GPG signature-based script integrity verification | Requires separate infrastructure (key management, signature distribution) | **Valid** - GPG infrastructure is separate project scope |
| 2 | SEC-11 | Medium | Third-party Docker image verification | External image supply chain security is outside project scope | **Valid** - Image signature verification (cosign etc.) is infrastructure level |
| 3 | QA-05 | Low | Structured logging | Over-engineering at current stage | **Valid** - However, security event logging (FR-S3-10 proposal) should be reviewed separately |
| 4 | QA-09 | Low | CHANGELOG auto-generation | Code quality takes priority over tool adoption | **Valid** - Can be reviewed after Sprint 5 |
| 5 | SEC-01 (GPG) | Critical | MITM prevention during remote execution | Basic protection via HTTPS, GPG is additional layer | **Conditionally valid** - Acceptable as long as HTTPS is guaranteed, but worth reviewing lightweight verification via SRI hash long-term |

**Conclusion**: All 5 Out of Scope rulings are valid. However, SEC-01 (GPG) has value in reviewing lightweight Subresource Integrity (SRI) hash verification on the long-term roadmap.

---

## 9. Overall Gap Summary

| Category | Total Items | No Gap | Gap Found | Gap Rate |
|:--------|:--------:|:------:|:------:|:------:|
| 44 base FRs | 44 | 44 | 0 | 0% |
| Potentially missing requirements | 8 | 2 | 6 | 75% |
| Implicit requirements | 7 | 1 | 6 | 86% |
| Cross-cutting concerns | 8 | 5 | 3 | 38% |
| Critical paths | 6 | 6 | 0 | 0% |
| Parallel execution groups | 5 | 1 | 4 | 80% |
| 89.6% coverage missing | 5 | 5 | 0 | 0% |

### 9.1 Gap Severity Classification

| Severity | Count | Items |
|:-----:|:----:|:-----|
| **High** | 4 | FR-S3-07 scope mismatch, FR-S3-09 (npm audit) missing, FR-S2-02 cleanup not designed, oauth.ts refactoring guide absent |
| **Medium** | 7 | FR-S2-11 (Docker Desktop), FR-S1-11 (input validation) plan not reflected, .env.example not designed, module.json schema absent, ShellCheck CI not reflected, migration guide absent, parallel execution PG-02/PG-04 |
| **Low** | 8 | FR-S3-10 (security logging), Pencil module, error message format, TypeScript strict test, Docker cache guide, i18n direction, error handling consistency, parallel execution PG-01/PG-03 |

### 9.2 Immediate Action Recommendations (High)

1. **Plan FR-S3-07 scope revision**: `index.ts:32` -> 7 locations expanded (align with design)
2. **Plan FR-S3-09 addition**: npm audit CI integration requirement creation
3. **Design FR-S2-02 remediation**: Add trap-based temp file cleanup
4. **Design oauth.ts refactoring guide**: Add module split roadmap

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2026-02-12 | Initial gap analysis report -- 3-document cross-analysis | Gap Analyst Agent |
