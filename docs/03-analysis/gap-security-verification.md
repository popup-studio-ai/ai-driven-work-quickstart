# Security Verification Gap Analysis Report

> Security Architect | Created: 2026-02-12
> Target documents:
> - Verification report: `docs/03-analysis/security-verification-report.md`
> - Plan: `docs/01-plan/features/adw-improvement.plan.md`
> - Design spec: `docs/02-design/security-spec.md`

---

## 1. Analysis Overview

### 1.1 Purpose

Verify whether the 12 security issues identified in the security verification report (security-verification-report.md) are accurately reflected in the plan (adw-improvement.plan.md) and design spec (security-spec.md). Identify discrepancies (gaps) between documents and present specific items that require supplementation.

### 1.2 Analysis Scope

| Item | Details |
|------|------|
| Number of security issues | 12 (based on verification report) |
| Verification items | Severity reflection, fix code accuracy, OWASP mapping, effort estimation, priority |
| Document baseline date | All 2026-02-12 (based on same commit 7b16685) |

---

## 2. Reflection Status by Security Issue

| SEC-ID | Issue Name | Verification Report Severity | Plan Reflection | Design Spec Reflection | Gap |
|--------|-------|:-------------:|:---------:|:---------:|-----|
| SEC-01 | curl\|bash integrity not verified | Critical | O (FR-S1-03 partial, GPG is Out of Scope) | X (not included) | **Design spec missing**: SEC-01's checksum verification pattern is absent from the design spec. The plan addresses only osascript injection via FR-S1-03, and the `download_and_verify()` pattern is treated as Out of Scope |
| SEC-02 | Atlassian API token stored in plaintext | Critical | O (FR-S1-04) | O (FR-S1-04) | None |
| SEC-03 | Figma token exposure | **Informational** (downgraded) | O (FR-S1-05, downgraded to Low) | X (not included) | **Design spec missing**: Since SEC-03 is Informational, its absence from the design spec may be appropriate; however, it still exists as FR-S1-05 in the plan. The downgrade is clearly documented in the plan's FR-S1-05 description, so consistency is acceptable |
| SEC-04 | token.json encryption not applied | High | O (FR-S1-07) | O (FR-S1-07) | None |
| SEC-05 | Docker non-root not used | High | O (FR-S1-06) | O (FR-S1-06) | None |
| SEC-06 | Windows excessive admin privilege requests | High | O (FR-S2-10, Sprint 2) | X (not included) | **Design spec missing**: Outside Sprint 1 design spec scope so not a structural omission; however, the verification report's detailed fix code (`Invoke-AsAdmin` pattern) has not been reflected in any design spec yet |
| SEC-07 | Excessive OAuth scopes | High | O (FR-S4-02, Sprint 4) | X (not included) | **Design spec missing**: As Sprint 4 scope, its absence from the Sprint 1 design spec is structurally justified. Needs to be reflected in future Sprint 4 design spec |
| SEC-08 | OAuth state parameter missing | High | O (FR-S1-01) | O (FR-S1-01) | None |
| SEC-08a | osascript template injection | High | O (FR-S1-03) | O (FR-S1-03) | None |
| GWS-07 | Drive API query injection | High | O (FR-S1-02) | O (FR-S1-02) | None |
| GWS-08 | Gmail email header injection | Medium | O (FR-S1-10) | O (FR-S1-10) | None |
| SEC-12 | Atlassian install.sh variable escaping | Medium | O (FR-S1-09) | O (FR-S1-09) | None |

### 2.1 Reflection Rate Summary

| Category | Plan | Design Spec |
|------|:-----:|:-----:|
| Fully reflected | 12/12 (100%) | 8/12 (67%) |
| Partially reflected | 0 | 0 |
| Not reflected (structurally justified) | 0 | 3 items (SEC-06, SEC-07, SEC-03) |
| Not reflected (gap) | 0 | **1 item (SEC-01)** |

---

## 3. Plan Gaps

### 3.1 Effort Estimation Discrepancies

Effort estimation comparison between verification report and plan:

| SEC-ID | Verification Report Effort | Plan Corresponding ID | Plan Stated Effort | Discrepancy |
|--------|:------------:|:------------:|:-------------:|:------:|
| SEC-01 | 6-8h | FR-S1-03 (partial) | Not specified | **Gap**: Individual FR-level effort not listed in the plan |
| SEC-02 | 4-6h | FR-S1-04 | Not specified | Same |
| SEC-03 | 0.5h | FR-S1-05 | Not specified | Same |
| SEC-04 | 2h (permissions), 6-8h (encryption) | FR-S1-07 | Not specified | Same |
| SEC-05 | 2-3h | FR-S1-06 | Not specified | Same |
| SEC-06 | 4-6h | FR-S2-10 | Not specified | Same |
| SEC-07 | 4-6h | FR-S4-02 | Not specified | Same |
| SEC-08 | 1-2h | FR-S1-01 | Not specified | Same |
| SEC-08a | 3-4h | FR-S1-03 | Not specified | Same |
| GWS-07 | 2-3h | FR-S1-02 | Not specified | Same |
| GWS-08 | 2h | FR-S1-10 | Not specified | Same |
| SEC-12 | 3-4h | FR-S1-09 | Not specified | Same |

**Key gap**: The plan does not list individual effort estimates in the FR (Functional Requirement) table. Instead, only aggregated effort by agent is presented in Appendix A.4:

- Verification report total effort: **34-49 hours**
- Plan Appendix A.4 security agent total effort: **34-49 hours** (matches)
- Plan Appendix A.4 security agent Critical Path: **12-16 hours**

**Conclusion**: At the aggregate level, the verification report's 34-49 hours is accurately reflected in the plan. However, since individual issue-level effort estimates are not listed in the plan body (Sprint 1 Requirements table), detailed scheduling during Sprint planning may be difficult.

In contrast, the design spec (security-spec.md) explicitly lists per-FR effort in the Sprint 1 Effort Estimate table, calculating a total of **22-33 hours**. This differs from the sum of Sprint 1-applicable issues from the verification report's 34-49 hours (see design spec gaps below).

### 3.2 Priority Discrepancies

Priority comparison between verification report and plan:

| SEC-ID | Verification Report Priority | Verification Report Severity | Plan Priority | Discrepancy |
|--------|:---------------:|:-------------:|:------------:|:------:|
| SEC-01 | 1st | Critical | FR-S1-03: **Critical** | None (partial coverage but priority matches) |
| SEC-08a | 2nd | High | FR-S1-03: **Critical** | None (plan upgraded, conservative judgment) |
| SEC-02 | 3rd | Critical | FR-S1-04: **High** | **Gap**: Verification report says Critical but plan downgraded to High |
| SEC-04 | 4th | High | FR-S1-07: **High** | None |
| SEC-08 | 5th | High | FR-S1-01: **Critical** | **Gap**: Verification report says High but plan upgraded to Critical |
| GWS-07 | 6th | High | FR-S1-02: **Critical** | **Gap**: Verification report says High but plan upgraded to Critical |
| SEC-12 | 7th | Medium | FR-S1-09: **High** | **Gap**: Verification report says Medium but plan upgraded to High |
| GWS-08 | 8th | Medium | FR-S1-10: **Medium** | None |
| SEC-05 | 9th | High | FR-S1-06: **High** | None |
| SEC-06 | 10th | High | FR-S2-10: **Medium** | **Gap**: Verification report says High but plan downgraded to Medium |
| SEC-07 | 11th | High | FR-S4-02: **High** | None |
| SEC-03 | 12th | Informational | FR-S1-05: **Low** | Acceptable (mapping Informational to Low is reasonable) |

**Key gaps**:
1. **SEC-02 (Critical -> High)**: Most serious discrepancy. Atlassian token plaintext storage was confirmed as Critical in the verification report but downgraded to High in the plan.
2. **SEC-08, GWS-07 (High -> Critical)**: Plan upgraded above verification report. Conservative approach is acceptable, but represents a discrepancy in consistency with the verification report.
3. **SEC-06 (High -> Medium)**: Windows admin privilege issue was downgraded to Medium while being deferred to Sprint 2.
4. **SEC-12 (Medium -> High)**: Plan upgraded.

### 3.3 Missing Items

| Missing Type | Details |
|----------|------|
| SEC-01 core response missing | The verification report proposes "SHA-256 checksum verification + GPG signing" as the core response for SEC-01. The plan treats GPG as Out of Scope, and there is no explicit FR for SHA-256 checksum verification (`download_and_verify()` pattern) either. FR-S1-03 only addresses osascript injection |
| Cross-cutting issues not reflected | Of the 4 "Cross-Cutting Concerns" in the verification report: (1) lack of input validation layer is addressed by the design spec's Input Validation Layer. (2) error message information leakage is partially addressed by the design spec's error handling. However, (3) **lack of security logging** and (4) **npm audit not applied** have no explicit FR in the plan |
| Security logging | The absence of security logging identified by the verification report as OWASP A09 (Security Logging and Monitoring Failures) is missing from both the plan and design spec. At minimum, logging of "authentication attempt failures", "token renewal", and "file permission changes" events is needed |
| npm audit | Regarding the verification report's "Dependencies Not Audited" finding, the plan's QA-05 treats it as Out of Scope, but the `npm ci` transition is partially addressed by the Dockerfile change in the design spec. The `npm audit` CI step is still not reflected |

---

## 4. Design Spec Gaps

### 4.1 Fix Code Discrepancies

Verification report vs design spec fix code comparison within Sprint 1 scope:

| SEC-ID | Verification Report Fix Code | Design Spec Fix Code | Discrepancy |
|--------|:------------------:|:---------------:|:------:|
| SEC-01 | `download_and_verify()` (SHA-256 checksum) | Not included | **Gap**: No corresponding entry in design spec |
| SEC-02 | `.env` file + `chmod 600` + `--env-file` | `.env` file + `chmod 600` + `--env-file` + `chmod 600 .mcp.json` | Design spec is more detailed. **Acceptable** |
| SEC-03 | Placeholder name change recommendation | Not included (Informational) | Structural omission, acceptable |
| SEC-04 | `fs.writeFileSync(..., { mode: 0o600 })` + `ensureConfigDir` mode 0o700 | Same + defensive `chmodSync` added | Design spec is more detailed. **Acceptable** |
| SEC-05 | `groupadd/useradd` + `USER mcp` + chown | Same + `npm ci` + `HEALTHCHECK` + `NODE_ENV=production` | Design spec is more detailed. **Acceptable** |
| SEC-06 | `Invoke-AsAdmin` pattern | Not included (Sprint 2 scope) | Structural omission, Sprint 2 design spec needed |
| SEC-07 | `SCOPE_MAP` + `getScopesForModules()` | Not included (Sprint 4 scope) | Structural omission, Sprint 4 design spec needed |
| SEC-08 | `crypto.randomBytes(32)` + state verification | Same + timeout + HTML error page | Design spec is more detailed. **Acceptable** |
| SEC-08a | `echo "$json" \| node -e "..."` stdin approach | Same pattern + `process.stdout.write` (prevent trailing newline) | Design spec is more detailed. **Acceptable** |
| GWS-07 | `escapeDriveQuery()` + `DRIVE_ID_PATTERN` validation | Same + `validateDriveId()` function + applied to all Drive handlers | Design spec is more detailed. **Acceptable** |
| GWS-08 | `sanitizeEmailHeader()` + `validateEmail()` | Same + `validateEmailAddress()` (comma-separated + Name <email> support) | Design spec is more detailed. **Acceptable** |
| SEC-12 | Environment variable approach (`MCP_CONFIG_PATH=... node -e "process.env..."`) | Same + `google/install.sh` also modified + `{ mode: 0o600 }` .mcp.json write | Design spec is more detailed. **Acceptable** |

**Conclusion**: Of 9 items within Sprint 1 scope, 8 have more detailed and specific fix code in the design spec than the verification report. Only SEC-01 is completely missing.

### 4.2 OWASP Mapping Discrepancies

| SEC-ID | Verification Report OWASP | Design Spec OWASP | Discrepancy |
|--------|:---------------:|:-----------:|:------:|
| SEC-01 | A08 (Software and Data Integrity Failures) | N/A (not included) | Cannot compare as not in design spec |
| SEC-02 | A02 (Cryptographic Failures) | A02 | None |
| SEC-03 | N/A (Informational) | N/A (not included) | Not applicable |
| SEC-04 | A02 (Cryptographic Failures) | A02 | None |
| SEC-05 | A05 (Security Misconfiguration) | A05 | None |
| SEC-06 | A04 (Insecure Design) | N/A (not included) | Cannot compare as not in design spec |
| SEC-07 | A01 (Broken Access Control) | N/A (not included) | Cannot compare as not in design spec |
| SEC-08 | A07 (Identification and Authentication Failures) | A07 | None |
| SEC-08a | A03 (Injection) | A03 | None |
| GWS-07 | A03 (Injection) | A03 | None |
| GWS-08 | A03 (Injection) | A03 | None |
| SEC-12 | A03 (Injection) | A03 | None |

**Conclusion**: OWASP mappings for all issues included in the design spec match the verification report 100%. No discrepancies.

### 4.3 Missing Items

| Missing Item | Severity | Details |
|----------|:------:|------|
| **SEC-01 entire** | **Critical** | The `curl\|bash` integrity verification assigned the highest priority (1st) in the verification report is completely missing from the design spec. The plan treats GPG signing as Out of Scope, but SHA-256 checksum verification is not Out of Scope yet is not reflected in the design spec |
| **FR-S1-05 (SEC-03)** | Low | Figma placeholder name change exists as FR-S1-05 in the plan but is not included in the design spec. Low priority so impact is minimal |
| **Input Validation Layer expansion** | Medium | The design spec's Validation Coverage Matrix only covers Drive/Gmail. Input validation for Calendar, Docs, Sheets, Slides tools is undefined |
| **Security logging** | Medium | No design for the verification report's Cross-Cutting Concern #3 (OWASP A09) |

### 4.4 Design Spec Effort vs Verification Report Effort Comparison

Comparing effort for Sprint 1 applicable issues:

| FR-ID | Verification Report SEC | Verification Report Effort | Design Spec Effort | Difference |
|-------|:------------------:|:-------------:|:---------:|:----:|
| FR-S1-01 | SEC-08 | 1-2h | 1-2h | Match |
| FR-S1-02 | GWS-07 | 2-3h | 2-3h | Match |
| FR-S1-03 | SEC-08a | 3-4h | 3-4h | Match |
| FR-S1-04 | SEC-02 | 4-6h (env file) | 4-6h | Match |
| FR-S1-06 | SEC-05 | 2-3h | 2-3h | Match |
| FR-S1-07 | SEC-04 | 2h (permissions only) | 0.5h | **Gap**: Design spec is more optimistic (reasonable since it's permissions-only) |
| FR-S1-08 | SEC-04 (related) | (included) | 0.5h | Not separately broken out in verification report |
| FR-S1-09 | SEC-12 | 3-4h | 2-3h | **Gap**: Design spec is 1 hour more optimistic |
| FR-S1-10 | GWS-08 | 2h | 1-2h | Approximate match |
| Input validation layer | (Cross-Cutting) | N/A | 2-3h | No separate effort in verification report, design spec additional item |
| Integration testing | N/A | N/A | 3-4h | No separate effort in verification report, design spec additional item |
| **Total** | | **~24-32h** (Sprint 1 estimate) | **22-33h** | Approximate match |

**Conclusion**: 1-2 hour differences exist at the individual issue level, but the total ranges overlap so overall consistency is maintained. The design spec's inclusion of "input validation layer" and "integration testing" as additional items is appropriate; these items were not included in the verification report.

---

## 5. Remediation Recommendations

### 5.1 Plan Modifications

| # | Modification Target | Current State | Recommendation |
|---|----------|----------|------|
| P-01 | **Add SEC-01 response FR** | FR-S1-03 only addresses osascript injection, SHA-256 checksum not addressed | Add `FR-S1-11: Remote Script Download Integrity Verification` to Sprint 1. Change `curl\|bash` to `curl -o tmpfile + shasum verification + source` using the `download_and_verify()` pattern. Keep GPG signing Out of Scope |
| P-02 | **Correct SEC-02 priority** | FR-S1-04 marked as **High** | Upgrade to **Critical**. This issue was confirmed as Critical in the verification report, and is also recorded as Critical in plan Appendix A.1, creating an inconsistency between body and appendix |
| P-03 | **Correct SEC-06 priority** | FR-S2-10 marked as **Medium** | Restore to **High**. Confirmed as High in verification report. Keep Sprint 2 deferral but reflect original priority level |
| P-04 | **Specify individual FR effort** | No effort column in Sprint requirements table | Add verification report-based effort estimates as a column for each FR. Enable per-Sprint total time calculation |
| P-05 | **Add security logging FR** | Missing | Add `FR-Sx-xx: Security Event Logging` to Sprint 3 or 4. Addresses OWASP A09. Minimum items: authentication failure, token renewal, file permission changes |
| P-06 | **Add npm audit CI step** | QA-05 Out of Scope | Expand FR-S3-03 (CI automation) to include `npm audit` step. Or separate as a distinct FR |

### 5.2 Design Spec Modifications

| # | Modification Target | Current State | Recommendation |
|---|----------|----------|------|
| D-01 | **Add SEC-01 design** | Completely missing | Add `FR-S1-11: Remote Script Integrity Verification` section. Design `checksums.json` manifest + `download_and_verify()` function. Address 3 `curl\|bash` patterns in install.sh + 1 `irm\|iex` pattern in install.ps1 |
| D-02 | **Expand Input Validation** | Only covers Drive/Gmail | Add input validation matrix for Calendar, Docs, Sheets, Slides tools. Especially Calendar date/time parameters and Sheets range strings (A1 notation) validation |
| D-03 | **Adjust FR-S1-07 effort** | 0.5h | Adjust to 1h. 0.5h is optimistic when including existing file migration (644 -> 600) and Windows compatibility testing |
| D-04 | **Specify google/install.sh scope** | Mentioned in FR-S1-09 but lacks detailed design | Describe the complete fix code for google/install.sh lines 330-346 in detail. Currently only brief code is provided |

---

## 6. Specific Content Addition Proposals

### 6.1 SEC-01 Design Spec Addition Proposal (for D-01)

The following content is recommended to be added to `security-spec.md`:

```markdown
## FR-S1-11: Remote Script Integrity Verification

**Verification Report Reference:** SEC-01
**OWASP Mapping:** A08 -- Software and Data Integrity Failures
**Severity:** Critical
**Effort:** 6-8 hours

### 1. Current Vulnerability

install.sh lines 350-351:
- `curl -sSL "$BASE_URL/modules/$module_name/install.sh" | bash`

install.sh lines 101-117:
- `curl -sSL "$BASE_URL/modules.json"` (integrity not verified)
- `curl -sSL "$BASE_URL/modules/$name/module.json"` (integrity not verified)

install.ps1 line 336:
- `irm "$BaseUrl/modules/$ModuleName/install.ps1" | iex`

### 2. Refactored Design

1. Publish `checksums.json` to GitHub repository:
   - Contains SHA-256 hashes for each script/module file
   - Auto-generated at release time (CI/CD pipeline)

2. `download_and_verify()` function:
   - Download remote file to temporary file
   - Compare SHA-256 hash
   - Execute only on match

3. On failure, output clear error message and abort
```

### 6.2 Plan FR-S1-04 Priority Correction Proposal (for P-02)

In the plan Sprint 1 table:

**Current**: `FR-S1-04 | ... | **High** | ...`
**Corrected**: `FR-S1-04 | ... | **Critical** | ...`

Ensures consistency with Appendix A.1.

### 6.3 Plan Individual FR Effort Column Addition Proposal (for P-04)

Add an "Effort(h)" column to the Sprint 1 table:

| ID | Requirement | Priority | Effort(h) | Target Files |
|----|-------------|:--------:|:-------:|----------|
| FR-S1-01 | Add OAuth state parameter | Critical | 1-2 | oauth.ts:113-118 |
| FR-S1-02 | Drive API query escaping | Critical | 2-3 | drive.ts:18,59 |
| FR-S1-03 | osascript injection prevention | Critical | 3-4 | install.sh:29-39 |
| ... | ... | ... | ... | ... |

### 6.4 Security Logging FR Addition Proposal (for P-05)

```markdown
| FR-S3-09 | **Security Event Logging** -- Output authentication failure/success, token renewal, file permission change events
  to stderr in structured format. Minimum fields: timestamp, event_type, result,
  detail | **Medium** | `oauth.ts`, `index.ts` | OWASP A09: lack of security logging |
```

---

## 7. Overall Assessment

### 7.1 Document Consistency Scores

| Comparison Axis | Score | Basis |
|---------|:----:|------|
| Verification report -> Plan | **85/100** | All 12 items reflected, but SEC-01 core response (checksum) missing, SEC-02 priority discrepancy, individual effort not listed |
| Verification report -> Design spec | **78/100** | High consistency within Sprint 1 scope (8/9 items acceptable), but SEC-01 complete omission (Critical) is a major deduction |
| Plan <-> Design spec | **90/100** | Most FR-S1-01~S1-10 match bidirectionally within Sprint 1 scope. FR-S1-05 not in design spec is Low so deduction is minimal |

### 7.2 Action Priority

1. **(Immediate)** Add SEC-01 response FR and design -- Complete omission of a Critical issue is the most urgent
2. **(Immediate)** Correct SEC-02 (FR-S1-04) priority to Critical
3. **(Before Sprint 1 starts)** Reflect individual FR effort in the plan to ensure Sprint planning precision
4. **(During Sprint 3 planning)** Add security logging FR, add npm audit CI step
5. **(During Sprint 2/4 design)** Write design specs for SEC-06, SEC-07

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2026-02-12 | Initial draft -- Full gap analysis of 12 security issues | Security Architect Agent |
